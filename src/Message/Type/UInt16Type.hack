namespace Edgedb\Message\Type;

use Edgedb\Message\Buffer;
use type Edgedb\Message\Readable;

class UInt16Type extends AbstractType<int> implements Readable
{
    public function write(): string
    {
        $bytes = \pack('n', $this->getValue());
        return $bytes;
    }

    public function getLength(): int
    {
        return 2;
    }

    public static function read(Buffer $buffer): UInt16Type
    {
        $value = $buffer->read(2)
            |> \unpack('n', $$)[1];

        return new self($value);
    }
}