namespace Edgedb\Message;

use namespace HH\Lib\Str;

use type Edgedb\Message\Buffer;
use type Edgedb\Message\Type\AbstractType;
use type Edgedb\Message\Type\Struct\AbstractStruct;
use type Edgedb\Message\Type\Int32Type;
use type Edgedb\Message\Type\CharType;
use type Edgedb\Message\MessageTypeEnum;

abstract class AbstractMessage<+T as AbstractStruct> extends AbstractType<T>
{
    protected dict<string, mixed> $struct = dict[];

    public function __construct(
        private string $type,
        private T $content
    ) {
        parent::__construct($content);
    }

    public function getType(): MessageTypeEnum
    {
        return MessageTypeEnum::assert($this->type);
    }

    public function getLength(): int
    {
        return $this->content->getLength() + 4;
    }

    public function write(): string
    {
        $buffer = $this->content->write();
        $length = $this->getLength();

        $buffer = (new CharType($this->type))->write()
            . (new Int32Type($length))->write()
            . $buffer;

        return $buffer;
    }

    protected static function setBufferCursorAtContentBegining(Buffer $buffer): void
    {
        $buffer->setCursor(5);
    }
}