namespace Edgedb\Message;

use type Edgedb\Message\AbstractMessage;
use type Edgedb\Message\Type\Struct\AbstractStruct;
use type Edgedb\Message\Type\CharType;
use type Edgedb\Message\Server\ServerHandshakeMessage;
use type Edgedb\Message\Server\AuthenticationRequiredSASLMessage;

class Reader
{
    public function read(Buffer $buffer): AbstractMessage<AbstractStruct>
    {
        $messageType = $this->readMessageType($buffer);

        switch ($messageType) {
            case 'v':
                return ServerHandshakeMessage::read($buffer);
            case 'R':
                return AuthenticationRequiredSASLMessage::read($buffer);
            default:
                throw new \Exception('Unknown message type ' . $messageType . '.');
        }
    }

    private function readMessageType(Buffer $buffer): string
    {
        return CharType::read($buffer)->getValue();
    }
}