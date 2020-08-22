namespace Edgedb\Codec;

use type Edgedb\Message\Type\Int16Type;
use type Edgedb\Message\Type\UInt32Type;
use type Edgedb\Message\Buffer;

use type Exception;

class Int16Codec extends ScalarCodec
{
    public function encode(mixed $value): string
    {
        if (! ($value is int)) {
            throw new Exception('Expected value to be int');
        }

        $encoded = (new UInt32Type(2))->write();
        $encoded .= (new Int16Type($value))->write();

        return $encoded;
    }

    public function decode(Buffer $buffer): mixed
    {
        return Int16Type::read($buffer)->getValue();
    }

    public function getTypeId(): string
    {
        return '000000000000-0000-0000-000000000103';
    }
}