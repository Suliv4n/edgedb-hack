namespace Edgedb\Message\Type;

use Edgedb\Message\Buffer;
use type Edgedb\Message\Readable;

class Int16Type extends AbstractSignedIntType implements Readable
{
    public function write(): string
    {
        return $this->toBytes(16);
    }

    public function getLength(): int
    {
        return 2;
    }

    public static function read(Buffer $buffer): Int16Type
    {
        $bytes = $buffer->read(2);

        $value = parent::toInt($bytes);

        return new self($value);
    }
}
