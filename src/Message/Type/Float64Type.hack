namespace Edgedb\Message\Type;

use Edgedb\Message\Buffer;
use type Edgedb\Message\Readable;

class Float64Type extends AbstractType<float> implements Readable
{
    public function write(): string
    {
        $bytes = \pack('E', $this->getValue());
        return $bytes;
    }

    public function getLength(): int
    {
        return 8;
    }

    public static function read(Buffer $buffer): Float64Type
    {
        $value = $buffer->read(8)
            |> \unpack('E', $$)[1];

        return new self($value);
    }
}