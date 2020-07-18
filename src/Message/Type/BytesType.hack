namespace Edgedb\Message\Type;

use type Edgedb\Message\Buffer;
use type Edgedb\Message\Readable;
use namespace HH\Lib\Str;

class BytesType extends AbstractType<string> implements Readable
{
    public function write(): string
    {
        $length = Str\length($this->getValue());
        $length = new UInt32Type($length);
        
        return $length->write() . $this->getValue();
    }

    public function getLength(): int
    {
        return 4 + Str\length($this->getValue());
    }

    public static function read(Buffer $buffer): BytesType 
    {
        $length = UInt32Type::read($buffer)->getValue();
        $bytes = $buffer->read($length);

        return new self($bytes);
    }
}