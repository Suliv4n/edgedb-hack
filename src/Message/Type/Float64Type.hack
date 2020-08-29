namespace Edgedb\Message\Type;

use type Edgedb\Message\Buffer;
use type Edgedb\Message\Readable;

class Float64Type extends AbstractFloatType implements Readable
{
    public function write(): string
    {
        return parent::toBytes(64, 11);
    }

    public function getLength(): int
    {
        return 4;
    }

    public static function read(Buffer $buffer): Float64Type
    {
        $value = parent::toFloat($buffer->read(8), 11);

        return new self($value);
    }
}