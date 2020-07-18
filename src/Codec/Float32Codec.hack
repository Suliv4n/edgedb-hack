namespace Edgedb\Codec;

use type Edgedb\Message\Type\Float32Type;
use type Edgedb\Message\Type\UInt32Type;
use type Edgedb\Message\Buffer;

use type Exception;

class Float32Codec implements CodecInterface
{
    public function encode(mixed $value): string
    {
        if (! ($value is float)) {
            throw new Exception('Expected value to be int');
        }

        $encoded = (new UInt32Type(4))->write();
        $encoded .= (new Float32Type($value))->write();

        return $encoded;
    }

    public function decode(Buffer $buffer): mixed
    {
        return Float32Type::read($buffer)->getValue();
    }
}