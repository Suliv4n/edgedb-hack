namespace Edgedb\Codec;

use type Edgedb\Message\Type\Struct\BigIntStruct;
use type Edgedb\Message\Type\UInt32Type;
use type Edgedb\Message\Buffer;

use type Exception;

class BigIntCodec extends ScalarCodec
{
    public function encode(mixed $value): string
    {
        if (! ($value is int)) {
            throw new Exception('Expected value to be int');
        }

        $bigInt = BigIntStruct::fromInt($value);
        $bigIntLength = $bigInt->getLength();

        $encoded = (new UInt32Type($bigIntLength))->write();
        $encoded .= $bigInt->write();

        return $encoded;
    }

    public function decode(Buffer $buffer): mixed
    {
        return BigIntStruct::read($buffer)->getInt();
    }

    public function getTypeId(): string
    {
        return '000000000000-0000-0000-000000000110';
    }
}