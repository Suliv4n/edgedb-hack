namespace Edgedb\Message\Type;

use Edgedb\Message\Buffer;
use type Edgedb\Message\Readable;

class Int8Type extends AbstractType<int> implements Readable
{
    public function write(): string
    {
        $bytes = \pack('C', $this->getValue());
        return $bytes;
    }

    public function getLength(): int
    {
        return 1;
    }

    public static function read(Buffer $buffer): Int8Type
    {
        $value = $buffer->read(1)
            |> \unpack('C', $$)[1];

        return new self($value);
    }
}