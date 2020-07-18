namespace Edgedb\Message\Type;

use Edgedb\Message\Buffer;
use type Edgedb\Message\Readable;

use function pack;
use function unpack;

class Int64Type extends AbstractType<int>
{
    public function write(): string
    {
        $bytes = pack('q', $this->getValue());
        return $bytes;
    }

    public function getLength(): int
    {
        return 8;
    }

    public static function read(Buffer $buffer): Int64Type
    {
        $value = $buffer->read(8)
            |> unpack('q', $$)[1];

        return new self($value);
    }
}