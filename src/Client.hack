namespace Edgedb;

use type Edgedb\Authentication\AuthenticationStatusEnum;
use type Edgedb\Authentication\AuthenticatorFactory;
use type Edgedb\Buffer\Message;
use type Edgedb\Buffer\WriteBuffer;
use type Edgedb\Exception\ConcurrentOperationException;
use type Edgedb\Message\Buffer;
use type Edgedb\Message\Client\ClientHandshakeMessage;
use type Edgedb\Message\Client\ExecuteScriptMessage;
use type Edgedb\Message\MessageTypeEnum;
use type Edgedb\Message\Reader;
use type Edgedb\Message\Server\AuthenticationMessage;
use type Edgedb\Message\Server\ServerHandshakeMessage;
use type Edgedb\Message\Type\Struct\AuthenticationRequiredSASLStruct;
use type Edgedb\Message\Type\Struct\ClientHandshakeStruct;
use type Edgedb\Message\Type\Struct\CommandCompleteStruct;
use type Edgedb\Message\Type\Struct\ExecuteScriptStruct;
use type Edgedb\Message\Type\Struct\ReadyForCommandStruct;
use type Edgedb\Message\Type\Struct\ParamStruct;
use type Edgedb\Protocol\Version;
use type Edgedb\Message\Server\CommandCompleteMessage;
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
            $responseMessage = $this->reader->read($responseBuffer);
            $responseMessageContent = $responseMessage->getValue();

            if ($responseMessage->getType() === MessageTypeEnum::COMMAND_COMPLETE) {
                invariant(
                    $responseMessageContent is CommandCompleteStruct,
                    'The message should contain a %s but contains a %s.',
                    CommandCompleteStruct::class,
                    get_class($responseMessageContent)
                );

                \var_dump($responseMessageContent->getStatus());

                $status = $responseMessageContent->getStatus();
            } else if ($responseMessage->getType() === MessageTypeEnum::READY_FOR_COMMAND) {
                invariant(
                    $responseMessageContent is ReadyForCommandStruct,
                    'The message should contain a %s but contains a %s.',
                    ReadyForCommandStruct::class,
                    get_class($responseMessageContent)
                );

                $this->serverTransactionStatus = $responseMessageContent->getTransactionState();

                \var_dump($this->serverTransactionStatus);
                $parsing = false;
            } else {
                throw new \Exception("We should not be here");
            }

            $responseBuffer->sliceFromCursor();
        }
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