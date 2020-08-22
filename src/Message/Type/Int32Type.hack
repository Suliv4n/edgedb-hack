namespace Edgedb\Message\Type;

use Edgedb\Message\Buffer;
use type Edgedb\Message\Readable;

class Int32Type extends AbstractSignedIntType implements Readable
{
    public function write(): string
    {
        return $this->toBytes(32);
    }

    public function getLength(): int
    {
        return 4;
    }

    public static function read(Buffer $buffer): Int32Type
    {
        $bytes = $buffer->read(4);

        $value = parent::toInt($bytes);

        return new self($value);
    }
}
