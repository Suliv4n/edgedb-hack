namespace Edgedb\Codec;

use type Edgedb\Message\Type\UInt32Type;
use type Edgedb\Message\Type\StringType;
use type Edgedb\Message\Buffer;
use type Exception;

use namespace HH\Lib\Str;
use namespace HH\Lib\Vec;

class StringCodec extends ScalarCodec
{
    public function encode(mixed $value): string
    {
        if (! ($value is string)) {
            throw new Exception('Expected value to be string');
        }

        $encoded = (new StringType($value))->write();

        return $encoded;
    }

    public function decode(Buffer $buffer): mixed
    {
        return $buffer->readUntilEnd();
    }
}