namespace Edgedb\Message\Type;

use type Edgedb\Message\Buffer;
use type Edgedb\Message\Readable;

class Float32Type extends AbstractFloatType implements Readable
{
    public function write(): string
    {
        return parent::toBytes(32, 8);
    }

    public function getLength(): int
    {
        return 4;
    }

    public static function read(Buffer $buffer): Float32Type
    {
        $value = parent::toFloat($buffer->read(4), 8);

        return new self($value);
    }
}