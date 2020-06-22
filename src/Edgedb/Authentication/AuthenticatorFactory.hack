namespace Edgedb\Authentication;

use type Edgedb\Exception\UnsupportedAuthenticationMethodsException;
use type Edgedb\Socket;
use type Edgedb\Message\Reader;

class AuthenticatorFactory
{
    public function __construct(
        private Socket $socket,
        private Reader $reader
    ) {}

    public function createFromMethods(vec<string> $methods): AbstractAuthenticator
    {
        foreach ($methods as $method) {
            $authenticator = $this->createAuthenticatorFromMethod($method);
            if ($authenticator is nonnull) {
                return $authenticator;
            }
        }

        throw new UnsupportedAuthenticationMethodsException($methods);
    }

    private function createAuthenticatorFromMethod(string $method): ?AbstractAuthenticator
    {
        switch ($method) {
            case SaslAuthenticator::METHOD:
                $authenticator = new SaslAuthenticator();
                break;
            default:
                return null;
        }

        $authenticator->setSocket($this->socket);
        $authenticator->setReader($this->reader);

        return $authenticator;
    }

}