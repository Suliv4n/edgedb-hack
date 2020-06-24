namespace Edgedb\Message\Type;

use namespace HH\Lib\Str;

use type Edgedb\Message\Readable;
use type Edgedb\Message\Buffer;

class StringType extends AbstractType<string>
{
    public function write(): string
    {
        $utf8Value = \utf8_encode($this->getValue());
        $length = Str\length($utf8Value);
        
        $length = new Int32Type($length);
        
        return $length->write() . $utf8Value;
    }

    public function getLength(): int
    {
        $utf8Value = \utf8_encode($this->getValue());
        $length = Str\length($utf8Value);

        return 4 + $length;
    }

    public static function read(Buffer $buffer): StringType
    {
        $length = Int32Type::read($buffer)->getValue();

        $string = $buffer->read($length) |> \utf8_decode($$);

        return new self($string);
    }
}