namespace Edgedb\Message;

use namespace HH\Lib\Str;

use type Edgedb\Message\Type\Struct\AbstractStruct;
use type Edgedb\Message\Type\Int32Type;
use type Edgedb\Message\Type\CharType;

abstract class AbstractMessage<T as AbstractStruct>
{
    protected dict<string, mixed> $struct = dict[];

    public function __construct(
        private string $type,
        private T $content
    )
    {}

    public function getType(): string
    {
        return $this->type;
    }

    public function write(): string
    {
        $buffer = $this->content->write();
        $length = Str\length($buffer);

        $buffer = (new CharType($this->type))->write()
            . (new Int32Type($length + 4))->write()
            . $buffer;

        return $buffer;
    }
}