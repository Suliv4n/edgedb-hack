namespace Edgedb;

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
    private Socket $socket;
    private Reader $reader;
    private bool $isOperationInProgress = false;
    private ?TransactionTypeEnum $serverTransactionStatus = null;
    private CodecRegistery $codecRegistery;

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
            $this->fetch($query, $arguments, false, true);
        } finally {
            $this->endOperation();
        }

        return null;
    }

    public function fetchMany(string $query, dict<string, mixed> $arguments = dict[]): mixed
    {
        $this->beginOperation();
        try {
            $this->fetch($query, $arguments, false, false);
        } finally {
            $this->endOperation();
        }

        return null;
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

                $status = $responseMessageContent->getStatus();
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
    ): mixed {
        $this->parse($query, $asJson, $expectOne);
        //$this->executeFlow($arguments);

        return null;
    }

    private function parse(
        string $query,
        bool $asJson,
        bool $expectOne
    ): mixed {
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

        while ($parsing) {
            if ($responseBuffer->isConsumed()) {
                $responseBuffer = $this->socket->receive();
            }

            $responseMessage = $this->reader->read($responseBuffer);
            
            if ($responseMessage is PrepareCompleteMessage) {
                $this->handlePrepareCompleteMessage($responseMessage);
            } else if ($responseMessage is ReadyForCommandMessage) {
                $this->serverTransactionStatus = $responseMessage->getValue()->getTransactionState();
                $parsing = false;
            }

            $responseBuffer->sliceFromCursor();
        }

        return null;
    }

    private function handlePrepareCompleteMessage(PrepareCompleteMessage $message): void
    {
        $inTypedesc = $message->getValue()->getInputTypedescId();
        $outTypedesc = $message->getValue()->getOutputTypedescId();

        $inCodec =  $this->codecRegistery->get($inTypedesc);
        $outCodec = $this->codecRegistery->get($outTypedesc);

        if ($inCodec === null || $outCodec === null)
        {
            $describeStatementMessage = new DescribeStatementMessage(
                new DescribeStatementStruct(
                    vec[],
                    DescribeAspectEnum::DATA_DESCRIPTION
                )
            );

            $parsing = true;

            $this->socket->sendMessage($describeStatementMessage, new SynchMessage());

            $responseMessageBuffer = $this->socket->receive();
            

            while ($parsing) {
                if ($responseMessageBuffer->isConsumed()) {
                    $responseMessageBuffer = $this->socket->receive();
                }

                $responseMessage = $this->reader->read($responseMessageBuffer);

                if ($responseMessage is CommandDataDescriptionMessage) {
                    \var_dump('Description received !');
                } else if ($responseMessage is ReadyForCommandMessage) {
                    $this->serverTransactionStatus = $responseMessage->getValue()->getTransactionState();
                    $parsing = false;
                }

                $responseMessageBuffer->sliceFromCursor();
            }
        }
    }

    private function executeFlow(dict<string, mixed> $arguments): vec<mixed> {
        $result = vec[];

        /*$executeMessage = new PrepareMessage(
            new PrepareStruct(
                vec[],
                '',
                ''
            )
        );

        $this->socket->sendMessage($executeMessage);
        */

        return $result;
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