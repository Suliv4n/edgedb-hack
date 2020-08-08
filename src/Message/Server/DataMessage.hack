namespace Edgedb\Message\Server;

use type Edgedb\Message\Buffer;
use type Edgedb\Message\Readable;
use type Edgedb\Message\AbstractMessage;
use type Edgedb\Message\Type\Struct\DataStruct;
use type Edgedb\Message\MessageTypeEnum;

class DataMessage extends AbstractMessage<DataStruct> implements Readable
{
    public function __construct(DataStruct $content) {
        parent::__construct(MessageTypeEnum::DATA, $content);
    }

    public static function read(Buffer $buffer): DataMessage
    {
        self::setBufferCursorAtContentBegining($buffer);
        $content = DataStruct::read($buffer);

        return new self($content);
    }
}