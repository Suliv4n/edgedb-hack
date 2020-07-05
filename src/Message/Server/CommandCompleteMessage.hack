namespace Edgedb\Message\Server;

use type Edgedb\Message\Buffer;
use type Edgedb\Message\Readable;
use type Edgedb\Message\AbstractMessage;
use type Edgedb\Message\Type\Struct\CommandCompleteStruct;
use type Edgedb\Message\MessageTypeEnum;

class CommandCompleteMessage extends AbstractMessage<CommandCompleteStruct> implements Readable
{
    public function __construct(CommandCompleteStruct $content) {
        parent::__construct(MessageTypeEnum::COMMAND_COMPLETE, $content);
    }

    public static function read(Buffer $buffer): CommandCompleteMessage
    {
        self::setBufferCursorAtContentBegining($buffer);
        $content = CommandCompleteStruct::read($buffer);

        return new self($content);
    }
}