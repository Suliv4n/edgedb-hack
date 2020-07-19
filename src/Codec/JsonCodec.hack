namespace Edgedb\Codec;

use type Edgedb\Message\Type\UInt32Type;
use type Edgedb\Message\Type\UInt8Type;
use type Edgedb\Message\Buffer;
use type Exception;
use function chr;
use function unpack;

use namespace HH\Lib\Str;
use namespace HH\Lib\Vec;

class JsonCodec implements CodecInterface
{
    public function encode(mixed $value): string
    {
        if (! ($value is string)) {
            throw new Exception('Expected value to be string');
        }

        $jsondata = unpack('C*', $value) 
            |> Vec\map($$, ($ord) ==> chr($ord))
            |> Str\join($$, '');

        $encoded = (new UInt32Type(1 + Str\length($jsondata)))->write();
        $encoded .= (new UInt8Type(1))->write();
        $encoded .= $jsondata;

        return $encoded;
    }

    public function decode(Buffer $buffer): mixed
    {
        $format = UInt8Type::read($buffer)->getValue();

        if ($format !== 1) {
            throw new Exception("Unexpected json format {$format}");
        }

        $json = $buffer->readUntilEnd();

        return $json;
    }
}