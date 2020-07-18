namespace Edgedb\Message\Type;

use Edgedb\Message\Buffer;
use type Edgedb\Message\Readable;

class Float32Type extends AbstractType<float> implements Readable
{
    public function write(): string
    {
        $bytes = \pack('G', $this->getValue());
        return $bytes;
    }

    public function getLength(): int
    {
        return 4;
    }

    public static function read(Buffer $buffer): Float32Type
    {
        $value = $buffer->read(4)
            |> \unpack('G', $$)[1];

        return new self($value);
    }
}