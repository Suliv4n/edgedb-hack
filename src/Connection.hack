namespace Edgedb;

use type Edgedb\Authentication\AuthenticatorFactory;
use type Edgedb\Buffer\WriteBuffer;
use type Edgedb\Buffer\Message;
use type Edgedb\Message\Reader;
use type Edgedb\Protocol\Version;
use type Edgedb\Message\Type\Struct\ClientHandshakeStruct;
use type Edgedb\Message\Type\Struct\AuthenticationRequiredSASLStruct;
use type Edgedb\Message\Type\Struct\ParamStruct;
use type Edgedb\Message\Client\ClientHandshakeMessage;
use type Edgedb\Message\Server\ServerHandshakeMessage;
use type Edgedb\Message\Server\AuthenticationMessage;
use type Edgedb\Message\Buffer;
use type Edgedb\Message\MessageTypeEnum;
use type Edgedb\Authentication\AuthenticationStatusEnum;

use namespace HH\Lib\Str;
use namespace HH\Lib\Vec;

use function HH\invariant;

class Connection
{
    private Socket $socket;
    private Reader $reader;

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
                'Type R message should be a %s but is a %s).',
                AuthenticationMessage::class,
                \get_class($message)
            );

            $messageContent = $message->getValue();
            if ($messageContent->getAuthenticationStatus() === AuthenticationStatusEnum::AUTH_SASL) {
                invariant(
                    $messageContent is AuthenticationRequiredSASLStruct,
                    'The message should contain a %s but contains a %s).',
                    AuthenticationRequiredSASLStruct::class,
                    \get_class($messageContent)
                );
            }

            if (!($messageContent is AuthenticationRequiredSASLStruct)) {
                throw new \Exception("wtf");
            }

            $this->handleAuthenticationRequiredSASLMessage($messageContent);
        }

        $this->socket->close();
    }

    private function handleAuthenticationRequiredSASLMessage(
        AuthenticationRequiredSASLStruct $authenticationStruct
    ): void {
        $methods = $authenticationStruct->getMethods();

        $authenticatorFactory = new AuthenticatorFactory($this->socket, $this->reader);
        $authenticator = $authenticatorFactory->createFromMethods($methods);

        $authenticator->authenticate($this->username, $this->password);
    }
}