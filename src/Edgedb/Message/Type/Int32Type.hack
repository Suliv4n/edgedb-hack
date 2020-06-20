namespace Edgedb\Message\Type;

use Edgedb\Message\Buffer;
use type Edgedb\Message\Readable;

class Int32Type extends AbstractType<int> implements Readable
{
    public function write(): string
    {
        $bytes = \pack('N', $this->getValue());
        return $bytes;
    }

    public function getLength(): int
    {
        return 4;
    }

    public static function read(Buffer $buffer): Int32Type
    {
        $value = $buffer->read(4) |> \unpack('N', $$);
        return new Int32Type($value);
    }
}