namespace Edgedb\Message\Type;

use Edgedb\Message\Buffer;
use type Edgedb\Message\Readable;

use function pack;
use function unpack;

class Int32Type extends AbstractType<int>
{
    public function write(): string
    {
        $bytes = pack('l', $this->getValue());
        return $bytes;
    }

    public function getLength(): int
    {
        return 4;
    }

    public static function read(Buffer $buffer): Int32Type
    {
        $value = $buffer->read(4) 
            |> unpack('l', $$)[1];

        return new self($value);
    }
}