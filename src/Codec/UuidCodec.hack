namespace Edgedb\Codec;

use type Edgedb\Message\Type\UInt32Type;
use type Edgedb\Message\Type\UuidType;
use type Edgedb\Message\Buffer;
use type Exception;

use namespace HH\Lib\Str;
use namespace HH\Lib\Vec;

class UuidCodec implements CodecInterface
{
    public function encode(mixed $value): string
    {
        if (! ($value is string)) {
            throw new Exception('Expected value to be string');
        }

        $encoded = (new UInt32Type(16))->write();
        $encoded .= (new UuidType($value))->write();

        return $encoded;
    }

    public function decode(Buffer $buffer): mixed
    {
        return UuidType::read($buffer)->getValue();
    }
}