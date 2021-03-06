namespace Edgedb\Codec;

use type Edgedb\Message\Type\Float64Type;
use type Edgedb\Message\Type\UInt32Type;
use type Edgedb\Message\Buffer;

use type Exception;

class Float64Codec extends ScalarCodec
{
    public function encode(mixed $value): string
    {
        if (! ($value is float)) {
            throw new Exception('Expected value to be float');
        }

        $encoded = (new UInt32Type(8))->write();
        $encoded .= (new Float64Type($value))->write();

        return $encoded;
    }

    public function decode(Buffer $buffer): mixed
    {
        return Float64Type::read($buffer)->getValue();
    }

    public function getTypeId(): string
    {
        return '000000000000-0000-0000-000000000105';
    }
}