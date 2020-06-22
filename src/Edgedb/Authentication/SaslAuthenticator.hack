namespace Edgedb\Authentication;

use type Edgedb\Message\Client\AuthenticationSASLInitialResponseMessage;
use type Edgedb\Message\Type\Struct\AuthenticationSASLInitialResponseStruct;

class SaslAuthenticator extends AbstractAuthenticator
{
    const string METHOD = 'SCRAM-SHA-256';
    
    public function authenticate(
        string $username,
        ?string $password
    ): void {
        $scram = new Scram();
        $clientNonce = $scram->generateNonce();

        $clientFirstMessage = $scram->buildClientFirstMessage($username, $clientNonce);

        $clientFirstBare = $scram->generateBareFromNonceAndUsername($clientNonce, $username);

        $message = new AuthenticationSASLInitialResponseMessage(
            new AuthenticationSASLInitialResponseStruct(
                self::METHOD,
                $clientFirstMessage
            )
        );

        $this->socket->sendMessage($message);

        $buffer = $this->socket->receive();

        $this->reader->read($buffer);
    }
}