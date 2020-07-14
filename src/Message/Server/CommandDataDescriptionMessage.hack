namespace Edgedb\Message\Server;

use type Edgedb\Message\Buffer;
use type Edgedb\Message\Readable;
use type Edgedb\Message\AbstractMessage;
use type Edgedb\Message\Type\Struct\CommandDataDescriptionStruct;
use type Edgedb\Message\MessageTypeEnum;

class CommandDataDescriptionMessage extends AbstractMessage<CommandDataDescriptionStruct> implements Readable
{
    public function __construct(CommandDataDescriptionStruct $content) {
        parent::__construct(MessageTypeEnum::COMMAND_DATA_DESCRIPTION, $content);
    }

    public static function read(Buffer $buffer): CommandDataDescriptionMessage
    {
        self::setBufferCursorAtContentBegining($buffer);
        $content = CommandDataDescriptionStruct::read($buffer);

        return new self($content);
    }
}