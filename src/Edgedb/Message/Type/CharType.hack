namespace Edgedb\Message\Type;

use type Edgedb\Message\Type\CharType;
use type Edgedb\Message\Buffer;
use type Edgedb\Message\Readable;

class CharType extends AbstractType<string> implements Readable
{
    public function write(): string
    {
        $char = $this->getValue()[0];

        return \pack('C', \ord($char));
    }

    public function getLength(): int
    {
        return 1;
    }

    public static function read(Buffer $buffer): CharType
    {
        $value = $buffer->read(1)
            |> \unpack('C', $$);

        return new CharType($value);
    }
}