namespace Edgedb\Codec;

use type Edgedb\Message\Type\UInt32Type;
use type Edgedb\Message\Type\UInt8Type;
use type Edgedb\Message\Buffer;
use type Exception;

class BoolCodec extends ScalarCodec
{
    public function encode(mixed $value): string
    {
        if (! ($value is num || $value is bool)) {
            throw new Exception('Expected value to be bool or num');
        }

        $encoded = (new UInt32Type(1))->write();
        $encoded .= (new UInt8Type((bool) $value ? 1 : 0))->write();

        return $encoded;
    }

    public function decode(Buffer $buffer): mixed
    {
        return UInt8Type::read($buffer)->getValue() === 0
            ? false
            : true;
    }

    public function getTypeId(): string
    {
        return '000000000000-0000-0000-000000000109';
    }
}