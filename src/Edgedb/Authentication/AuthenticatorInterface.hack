namespace Edgedb\Authentication;

interface AuthenticatorInterface
{
    public function authenticate(): void;
}