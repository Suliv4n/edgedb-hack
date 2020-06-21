namespace Edgedb\Authentication;

use type Edgedb\Exception\UnsupportedAuthenticationMethodsException;

class AuthenticatorFactory
{
    public function createFromMethods(vec<string> $methods): AuthenticatorInterface
    {
        foreach ($methods as $method) {
            $authenticator = $this->createAuthenticatorFromMethod($method);
            if ($authenticator is nonnull) {
                return $authenticator;
            }
        }

        throw new UnsupportedAuthenticationMethodsException($methods);
    }

    private function createAuthenticatorFromMethod(string $method): ?AuthenticatorInterface
    {
            switch ($method) {
                case 'SCRAM-SHA-256':
                    return new SaslAuthenticator();
                default:
                    return null;
            }
    }

}