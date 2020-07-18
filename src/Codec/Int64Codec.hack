namespace Edgedb\Codec;

use type Edgedb\Message\Type\Int64Type;
use type Edgedb\Message\Type\UInt32Type;
use type Edgedb\Message\Buffer;

use type Exception;

class Int64Codec implements CodecInterface
{
    public function encode(mixed $value): string
    {
        if (! ($value is int)) {
            throw new Exception('Expected value to be int');
        }

        $encoded = (new UInt32Type(8))->write();
        $encoded .= (new Int64Type($value))->write();

        return $encoded;
    }

    public function decode(Buffer $buffer): mixed
    {
        return Int64Type::read($buffer)->getValue();
    }
}