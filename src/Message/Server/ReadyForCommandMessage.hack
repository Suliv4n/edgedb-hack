namespace Edgedb\Message\Server;

use type Edgedb\Message\Buffer;
use type Edgedb\Message\Readable;
use type Edgedb\Message\AbstractMessage;
use type Edgedb\Message\Type\Struct\ReadyForCommandStruct;
use type Edgedb\Message\MessageTypeEnum;

class ReadyForCommandMessage extends AbstractMessage<ReadyForCommandStruct> implements Readable
{
    public function __construct(ReadyForCommandStruct $content) {
        parent::__construct(MessageTypeEnum::READY_FOR_COMMAND, $content);
    }

    public static function read(Buffer $buffer): ReadyForCommandMessage
    {
        self::setBufferCursorAtContentBegining($buffer);
        $content = ReadyForCommandStruct::read($buffer);

        return new self($content);
    }
}