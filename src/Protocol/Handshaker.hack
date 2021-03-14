namespace Edgedb\Protocol;

use type Edgedb\Authentication\AuthenticatorFactory;
use type Edgedb\Client;
use type Edgedb\Message\Client\ClientHandshakeMessage;
use type Edgedb\Message\Reader;
use type Edgedb\Message\Server\AuthenticationMessage;
use type Edgedb\Message\Type\Struct\AuthenticationRequiredSASLStruct;
use type Edgedb\Message\Type\Struct\ClientHandshakeStruct;
use type Edgedb\Message\Type\Struct\ParamStruct;

use function get_class;

class Handshaker
{
    private Reader $reader;

    public function __construct(
        private Client $client
    ) {
        $this->reader = new Reader();
    }

    public function handshake(): void
    {
        $clientVersion = new Version(0, 7);
        $handshake = new ClientHandshakeMessage(
            new ClientHandshakeStruct(
                $clientVersion,
                vec[
                    new ParamStruct('user', $this->client->getUsername()),
                    new ParamStruct('database', $this->client->getDatabase()),
                ],
                vec[]
            )
        );

        $this->client->getSocket()->sendMessage($handshake);

        $buffer = $this->client->getSocket()->receive();
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

        $authenticatorFactory = new AuthenticatorFactory($this->client->getSocket(), $this->reader);
        $authenticator = $authenticatorFactory->createFromMethods($methods);

        $authenticator->authenticate($this->client->getUsername(), $this->client->getPassword());
    }
}