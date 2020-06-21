namespace Edgedb;

use type Edgedb\Authentication\AuthenticatorFactory;
use type Edgedb\Buffer\WriteBuffer;
use type Edgedb\Buffer\Message;
use type Edgedb\Message\Reader;
use type Edgedb\Protocol\Version;
use type Edgedb\Message\Type\Struct\ClientHandshakeStruct;
use type Edgedb\Message\Type\Struct\ParamStruct;
use type Edgedb\Message\Client\ClientHandshakeMessage;
use type Edgedb\Message\Server\ServerHandshakeMessage;
use type Edgedb\Message\Server\AuthenticationRequiredSASLMessage;
use type Edgedb\Message\Buffer;
use type Edgedb\Message\MessageTypeEnum;

use namespace HH\Lib\Str;
use namespace HH\Lib\Vec;

use function HH\invariant;

class Connection
{
    private Socket $socket;

    public function __construct(
        string $host,
        int $port,
        private string $database,
        private string $username,
        private ?string $password = null
    )
    {
        $this->socket = new Socket($host, $port);
    }

    public function connect(): void 
    {   
        $this->handshake();
    }

    private function handshake(): void 
    {
        $reader = new Reader();

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
        $message = $reader->read($buffer);

        $messageType = $message->getType();

        if ($messageType === 'R') {
            invariant(
                $message is AuthenticationRequiredSASLMessage,
                'Type R message should be a %s but is a %s).',
                AuthenticationRequiredSASLMessage::class,
                \get_class($message)
            );

            $this->handleAuthenticationRequiredSASLMessage($message);
        }

        $this->socket->close();
    }

    private function handleAuthenticationRequiredSASLMessage(
        AuthenticationRequiredSASLMessage $message
    ): void {
        $methods = $message->getValue()->getMethods();

        $authenticatorFactory = new AuthenticatorFactory();
        $authenticator = $authenticatorFactory->createFromMethods($methods);

        $authenticator->authenticate();
    }
}