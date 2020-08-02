namespace Edgedb\Message\Type;

use type Edgedb\Message\Buffer;
use type Edgedb\Message\Readable;

class UuidType extends AbstractType<string> implements Readable
{
    public function write(): string
    {
        return $this->getValue();
    }

    public function getLength(): int
    {
        return 16;
    }

    public static function read(Buffer $buffer): UuidType 
    {
        $bytes = $buffer->read(16);
        return new self($bytes);
    }
}