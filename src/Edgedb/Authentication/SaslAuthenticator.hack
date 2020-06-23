namespace Edgedb\Authentication;

use type Edgedb\Message\Client\AuthenticationSASLInitialResponseMessage;
use type Edgedb\Message\Type\Struct\AuthenticationSASLInitialResponseStruct;
use type Edgedb\Message\MessageTypeEnum;
use type Edgedb\Message\Type\Struct\AuthenticationSASLContinueStruct;
use type Edgedb\Exception\ProtocolException;

class SaslAuthenticator extends AbstractAuthenticator
{
    const string METHOD = 'SCRAM-SHA-256';
    
    public function authenticate(
        string $username,
        ?string $password
    ): void {
        $scram = new Scram();
        $clientNonce = $scram->generateNonce();

        $clientFirstBare = $scram->generateBareFromNonceAndUsername($clientNonce, $username);
        $clientFirstMessage = $scram->buildClientFirstMessage($username, $clientNonce);

        $message = new AuthenticationSASLInitialResponseMessage(
            new AuthenticationSASLInitialResponseStruct(
                self::METHOD,
                $clientFirstMessage
            )
        );

        $this->socket->sendMessage($message);
        $buffer = $this->socket->receive();
        
        $serverMessage = $this->reader->read($buffer, MessageTypeEnum::AUTHENTICATION);
        $serverMessageContent = $serverMessage->getValue();

        invariant(
            $serverMessageContent is AuthenticationSASLContinueStruct, 
            "Message content should be a %s",
            AuthenticationSASLContinueStruct::class
        );

        $saslMessage = $serverMessageContent->getSaslData();

        $scramParameters = $scram->parseScramMessage($saslMessage);
        \var_dump($scramParameters);
    }
}