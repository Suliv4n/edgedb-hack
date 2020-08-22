namespace Edgedb;

use type Edgedb\Codec\ArgumentsEncoderInterface;
use type Edgedb\Codec\EmptyTupleCodec;
use type Edgedb\Codec\CodecInterface;
use type Edgedb\Authentication\AuthenticationStatusEnum;
use type Edgedb\Authentication\AuthenticatorFactory;
use type Edgedb\Buffer\Message;
use type Edgedb\Buffer\WriteBuffer;
use type Edgedb\Codec\CodecRegistery;
use type Edgedb\Exception\ConcurrentOperationException;
use type Edgedb\Message\Buffer;
use type Edgedb\Message\CardinalityEnum;
use type Edgedb\Message\Client\ClientHandshakeMessage;
use type Edgedb\Message\Client\DescribeStatementMessage;
use type Edgedb\Message\Client\ExecuteMessage;
use type Edgedb\Message\Client\ExecuteScriptMessage;
use type Edgedb\Message\Client\PrepareMessage;
use type Edgedb\Message\Client\SynchMessage;
use type Edgedb\Message\DescribeAspectEnum;
use type Edgedb\Message\IOFormatEnum;
use type Edgedb\Message\MessageTypeEnum;
use type Edgedb\Message\Reader;
use type Edgedb\Message\Server\AuthenticationMessage;
use type Edgedb\Message\Server\CommandCompleteMessage;
use type Edgedb\Message\Server\PrepareCompleteMessage;
use type Edgedb\Message\Server\ReadyForCommandMessage;
use type Edgedb\Message\Server\ServerHandshakeMessage;
use type Edgedb\Message\Server\DataMessage;
use type Edgedb\Message\Server\CommandDataDescriptionMessage;
use type Edgedb\Message\Type\Struct\AuthenticationRequiredSASLStruct;
use type Edgedb\Message\Type\Struct\ClientHandshakeStruct;
use type Edgedb\Message\Type\Struct\CommandCompleteStruct;
use type Edgedb\Message\Type\Struct\DescribeStatementStruct;
use type Edgedb\Message\Type\Struct\ExecuteScriptStruct;
use type Edgedb\Message\Type\Struct\ExecuteStruct;
use type Edgedb\Message\Type\Struct\ParamStruct;
use type Edgedb\Message\Type\Struct\PrepareCompleteStruct;
use type Edgedb\Message\Type\Struct\PrepareStruct;
use type Edgedb\Message\Type\Struct\ReadyForCommandStruct;
use type Edgedb\Protocol\Version;
use type Edgedb\TransactionTypeEnum;

use namespace HH\Lib\Str;
use namespace HH\Lib\Vec;

use function HH\invariant;
use function get_class;

class Client
{
    const type QueryTypeDescription = shape(
        'cardinality' => CardinalityEnum,
        'inCodec' => CodecInterface,
        'outCodec' => CodecInterface 
    ); 

    private Socket $socket;
    private Reader $reader;
    private bool $isOperationInProgress = false;
    private ?TransactionTypeEnum $serverTransactionStatus = null;
    private CodecRegistery $codecRegistery;
    private ?string $lastStatus; 

    public function __construct(
        string $host,
        int $port,
        private string $database,
        private string $username,
        private ?string $password = null
    )
    {
        $this->socket = new Socket($host, $port);
        $this->reader = new Reader();
        $this->codecRegistery = new CodecRegistery();
    }

    public function getSocket(): Socket
    {
        return $this->socket;
    }

    public function connect(): void 
    {
        $this->handshake();
    }

    private function handshake(): void 
    {
        $clientVersion = new Version(0, 7);
        $handshake = new ClientHandshakeMessage(
            new ClientHandshakeStruct(
                $clientVersion,
                vec[
                    new ParamStruct('user', $this->username),
                    new ParamStruct('database', $this->database),
                ],
                vec[]
            )
        );

        $this->socket->sendMessage($handshake);

        $buffer = $this->socket->receive();
        $message = $this->reader->read($buffer);

        $messageType = $message->getType();

        if ($messageType === 'R') {
            invariant(
                $message is AuthenticationMessage,
                'Type R message should be a %s but is a %s.',
                AuthenticationMessage::class,
                get_class($message)
            );

            $messageContent = $message->getValue();
    
            invariant(
                $messageContent is AuthenticationRequiredSASLStruct,
                'The message should contain a %s but contains a %s.',
                AuthenticationRequiredSASLStruct::class,
                get_class($messageContent)
            );

            $this->handleAuthenticationRequiredSASLMessage($messageContent);
        }
    }

    private function handleAuthenticationRequiredSASLMessage(
        AuthenticationRequiredSASLStruct $authenticationStruct
    ): void {
        $methods = $authenticationStruct->getMethods();

        $authenticatorFactory = new AuthenticatorFactory($this->socket, $this->reader);
        $authenticator = $authenticatorFactory->createFromMethods($methods);

        $authenticator->authenticate($this->username, $this->password);
    }

    public function execute(string $query): void
    {
        $this->beginOperation();

        try {
            $this->processExecute($query);
        } finally {
            $this->endOperation();
        }
    }

    public function fetchOne(string $query, dict<string, mixed> $arguments = dict[]): mixed
    {
        $this->beginOperation();
        try {
            $result = $this->fetch($query, $arguments, false, true);
        } finally {
            $this->endOperation();
        }

        return $result[0];
    }

    public function fetchMany(string $query, dict<string, mixed> $arguments = dict[]): mixed
    {
        $this->beginOperation();
        try {
            $result = $this->fetch($query, $arguments, false, false);
        } finally {
            $this->endOperation();
        }

        return $result;
    }

    private function beginOperation(): void
    {
        if ($this->isOperationInProgress) {
            throw new ConcurrentOperationException(
                'Another operation is in progress. Use multiple separate'
                . 'connections to run operations concurrently.'
            );
        }

        $this->isOperationInProgress = true;
    }

    private function processExecute(string $query): void
    {
        $message = new ExecuteScriptMessage(
            new ExecuteScriptStruct(vec[], $query)
        );

        $this->socket->sendMessage($message);

        $parsing = true;
        $responseBuffer = $this->socket->receive();
        while ($parsing) {

            if ($responseBuffer->isConsumed()) {
                $responseBuffer = $this->socket->receive();
            }

            $responseMessage = $this->reader->read($responseBuffer);
            $responseMessageContent = $responseMessage->getValue();

            if ($responseMessage->getType() === MessageTypeEnum::COMMAND_COMPLETE) {
                invariant(
                    $responseMessageContent is CommandCompleteStruct,
                    'The message should contain a %s but contains a %s.',
                    CommandCompleteStruct::class,
                    get_class($responseMessageContent)
                );

                $this->lastStatus = $responseMessageContent->getStatus();
            } else if ($responseMessage->getType() === MessageTypeEnum::READY_FOR_COMMAND) {
                invariant(
                    $responseMessageContent is ReadyForCommandStruct,
                    'The message should contain a %s but contains a %s.',
                    ReadyForCommandStruct::class,
                    get_class($responseMessageContent)
                );

                $this->serverTransactionStatus = $responseMessageContent->getTransactionState();

                $parsing = false;
            }

            $responseBuffer->sliceFromCursor();
        }
    }

    private function fetch(
        string $query,
        dict<string, mixed> $arguments,
        bool $asJson,
        bool $expectOne
    ): vec<mixed> {
        $queryTypeDescription = $this->parse($query, $asJson, $expectOne);

        $this->validateFetchCardinality($expectOne, $queryTypeDescription['cardinality']);
        $result = $this->executeFlow(
            $arguments,
            $queryTypeDescription['inCodec'],
            $queryTypeDescription['outCodec'] 
        );

        return $result;
    }

    private function parse(
        string $query,
        bool $asJson,
        bool $expectOne
    ): self::QueryTypeDescription {
        $prepareMessage = new PrepareMessage(
            new PrepareStruct(
                vec[],
                $asJson ? IOFormatEnum::JSON : IOFormatEnum::BINARY,
                $expectOne ? CardinalityEnum::ONE : CardinalityEnum::MANY,
                '',
                $query
            )
        );

        $this->socket->sendMessage($prepareMessage, new SynchMessage());
        $responseBuffer = $this->socket->receive();

        $parsing = true;
        $queryTypeDescription = null;
        while ($parsing) {
            if ($responseBuffer->isConsumed()) {
                $responseBuffer = $this->socket->receive();
            }

            $responseMessage = $this->reader->read($responseBuffer);
            
            if ($responseMessage is PrepareCompleteMessage) {
                $queryTypeDescription = $this->handlePrepareCompleteMessage($responseMessage);
            } else if ($responseMessage is ReadyForCommandMessage) {
                $this->serverTransactionStatus = $responseMessage->getValue()->getTransactionState();
                $parsing = false;
            }

            $responseBuffer->sliceFromCursor();
        }

        invariant($queryTypeDescription !== null, 'QueryTypeDescription can not be null');

        return $queryTypeDescription;
    }

    private function handlePrepareCompleteMessage(PrepareCompleteMessage $message): self::QueryTypeDescription
    {
        $queryDescriptionsType = null;

        $inTypedesc = $message->getValue()->getInputTypedescId();
        $outTypedesc = $message->getValue()->getOutputTypedescId();

        $inCodec =  $this->codecRegistery->get($inTypedesc);
        $outCodec = $this->codecRegistery->get($outTypedesc);

        if ($outCodec !== null && $inCodec !== null) {
            $queryDescriptionsType = shape(
                'cardinality' => $message->getValue()->getCardinality(),
                'inCodec' => $inCodec,
                'outCodec' => $outCodec
            );
        }
        else {
            $describeStatementMessage = new DescribeStatementMessage(
                new DescribeStatementStruct(
                    vec[],
                    DescribeAspectEnum::DATA_DESCRIPTION
                )
            );

            $parsing = true;

            $this->socket->sendMessage($describeStatementMessage, new SynchMessage());

            $responseMessageBuffer = $this->socket->receive();
            
            $queryDescriptionsType = null;
            while ($parsing) {
                if ($responseMessageBuffer->isConsumed()) {
                    $responseMessageBuffer = $this->socket->receive();
                }

                $responseMessage = $this->reader->read($responseMessageBuffer);

                if ($responseMessage is CommandDataDescriptionMessage) {
                    $queryDescriptionsType = $this->handleCommandDataDescriptionMessage($responseMessage);
                } else if ($responseMessage is ReadyForCommandMessage) {
                    $this->serverTransactionStatus = $responseMessage->getValue()->getTransactionState();
                    $parsing = false;
                }

                $responseMessageBuffer->sliceFromCursor();
            }
        }


        if ($queryDescriptionsType is null) {
            throw new \Exception('failed to receive type information in response to a Parse message');
        }

        return $queryDescriptionsType;
    }

    private function handleCommandDataDescriptionMessage(
        CommandDataDescriptionMessage $message
    ): self::QueryTypeDescription {
        $content = $message->getValue();

        $inputTypeDescId = $content->getInputTypeDescId();
        $outputTypeDescId = $content->getOutputTypeDescId();

        $inCodec = $this->codecRegistery->get($inputTypeDescId);
        $outCodec = $this->codecRegistery->get($outputTypeDescId);

        if ($inCodec === null) {
            $inCodec = $this->codecRegistery->buildCodec($content->getInputTypeDesc());
        }   

        if ($outCodec === null) {
            $outCodec = $this->codecRegistery->buildCodec($content->getOutputTypeDesc());
        }

        return shape(
            "cardinality" => $content->getCardinality(),
            "inCodec" => $inCodec,
            "outCodec" => $outCodec
        );
    }

    private function validateFetchCardinality(bool $expectOne, CardinalityEnum $fetchCardinality): void {
        if ($expectOne && $fetchCardinality === CardinalityEnum::NO_RESULT) {
            throw new \Exception("Query executed via fetchOne*() returned no data.");
        }
    }

    private function executeFlow(
        dict<string, mixed> $arguments,
        CodecInterface $inCodec,
        CodecInterface $outCodec
    ): vec<mixed> {
        $result = vec[];

        $encodedArguments = $this->encodeArguments($arguments, $inCodec);

        $executeMessage = new ExecuteMessage(
            new ExecuteStruct(vec[], '', $encodedArguments)
        );

        $this->socket->sendMessage($executeMessage, new SynchMessage());

        $parsing = true;

        $responseBuffer = $this->socket->receive();
        
        $result = vec[];
        $i = 0;
        while ($parsing) {
            if ($responseBuffer->isConsumed()) {
                $responseBuffer = $this->socket->receive();
            }

            $responseMessage = $this->reader->read($responseBuffer);

            if ($responseMessage is DataMessage) {
                $result = Vec\concat(
                    $result,
                    $this->handleDataMessage($responseMessage, $outCodec)
                );
            } else if ($responseMessage is CommandCompleteMessage) {
                $this->lastStatus = $responseMessage->getValue()->getStatus();
            } 
            else if ($responseMessage is ReadyForCommandMessage) {
                $this->serverTransactionStatus = $responseMessage->getValue()->getTransactionState();
                $parsing = false;
            }

            $responseBuffer->sliceFromCursor();
        }

        return $result;
    }

    private function pptimisticExecuteFlow(
        dict<string, mixed> $arguments,
        bool $asJson,
        CodecInterface $inCodec,
        CodecInterface $outCodec,
        string $query
    ): vec<mixed> {
        $results = vec[];

        return $results;
    }

    private function encodeArguments(
        dict<string, mixed> $arguments, 
        CodecInterface $codec
    ): string {
        if ($codec is EmptyTupleCodec) {
            return EmptyTupleCodec::getBytes();
        }

        if (! ($codec is  ArgumentsEncoderInterface)) {
            throw new \Exception('Can not encode arguments with given input codec.');
        }

        return $codec->encodeArguments($arguments);
    }

    private function handleDataMessage(
        DataMessage $dataMessage,
        CodecInterface $outCodec,
    ): vec<mixed> {
        $content = $dataMessage->getValue();

        $encodedDataSet = $content->getEncodedData();
        $decodedData = vec[];
        foreach ($encodedDataSet as $encodedData) {
            $decodedData[] = $outCodec->decode(
                new Buffer($encodedData)
            );
        }

        return $decodedData;
    }

    private function endOperation(): void
    {
        $this->isOperationInProgress = false;
    }

    public function close(): void
    {
        $this->socket->close();
    }
}