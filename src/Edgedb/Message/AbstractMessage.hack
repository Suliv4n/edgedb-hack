namespace Edgedb\Message;

use namespace HH\Lib\Str;

use type Edgedb\Message\Type\AbstractType;
use type Edgedb\Message\Type\Struct\AbstractStruct;
use type Edgedb\Message\Type\Int32Type;
use type Edgedb\Message\Type\CharType;

abstract class AbstractMessage<T as AbstractStruct> extends AbstractType<T>
{
    protected dict<string, mixed> $struct = dict[];

    public function __construct(
        private string $type,
        private T $content
    ) {
        parent::__construct($content);
    }

    public function getType(): string
    {
        return $this->type;
    }

    public function getLength(): int
    {
        // Adding 4 for message type representing by 4 bytes characters.
        return $this->content->getLength() + 4;
    }

    public function write(): string
    {
        $buffer = $this->content->write();
        $length = $this->getLength();

        $buffer = (new CharType($this->type))->write()
            . (new Int32Type($length + 4))->write()
            . $buffer;

        return $buffer;
    }
}