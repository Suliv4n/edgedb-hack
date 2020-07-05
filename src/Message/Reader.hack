namespace Edgedb\Message;

use type Edgedb\Message\AbstractMessage;
use type Edgedb\Message\Server\ErrorMessage;
use type Edgedb\Message\Type\Struct\AbstractStruct;
use type Edgedb\Message\Type\CharType;
use type Edgedb\Message\Server\ServerHandshakeMessage;
use type Edgedb\Message\Server\AuthenticationMessage;
use type Edgedb\Message\Server\CommandCompleteMessage;
use type Edgedb\Message\Server\ReadyForCommandMessage;
use type Edgedb\Exception\UnexpectedMessageTypeException;
use type Edgedb\Exception\ServerErrorException;

class Reader
{
    public function read(Buffer $buffer, ?MessageTypeEnum $expectedMessageType = null): AbstractMessage<AbstractStruct>
    {
        $messageType = $this->readMessageType($buffer);

        if ($messageType === MessageTypeEnum::ERROR) {
            $message = ErrorMessage::read($buffer);
            $error = $message->getValue()->getError();

            throw new ServerErrorException($error);
        }

        if ($expectedMessageType is nonnull && $messageType !== $expectedMessageType) {
            throw new UnexpectedMessageTypeException($expectedMessageType, $messageType);
        }

        switch ($messageType) {
            case MessageTypeEnum::SERVER_HANDSHAKE:
                return ServerHandshakeMessage::read($buffer);
            case MessageTypeEnum::AUTHENTICATION:
                return AuthenticationMessage::read($buffer);
            case MessageTypeEnum::COMMAND_COMPLETE:
                return CommandCompleteMessage::read($buffer);
            case MessageTypeEnum::READY_FOR_COMMAND:
                return ReadyForCommandMessage::read($buffer);
            default:
                throw new \Exception('Unknown message type ' . $messageType . '.');
        }
    }

    private function readMessageType(Buffer $buffer): MessageTypeEnum
    {
        return CharType::read($buffer)->getValue()
            |> MessageTypeEnum::assert($$);
    }
}