namespace Edgedb\Authentication;

class SaslAuthenticator implements AuthenticatorInterface
{
    public function authenticate(): void
    {
        \var_dump('AUTHENTICATION \o/');
    }
}