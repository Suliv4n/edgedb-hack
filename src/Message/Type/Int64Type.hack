namespace Edgedb\Message\Type;

use Edgedb\Message\Buffer;
use type Edgedb\Message\Readable;

class Int64Type extends AbstractSignedIntType implements Readable
{
    public function write(): string
    {
        return $this->toBytes(64);
    }

    public function getLength(): int
    {
        return 8;
    }

    public static function read(Buffer $buffer): Int64Type
    {
        $bytes = $buffer->read(8);

        $value = parent::toInt($bytes);

        return new self($value);
    }
}
