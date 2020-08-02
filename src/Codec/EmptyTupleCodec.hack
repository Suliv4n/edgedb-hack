namespace Edgedb\Codec;

use namespace HH\Lib\C;

use type Edgedb\Message\Type\Int32Type;
use type Edgedb\Message\Buffer;

use type Exception;

class EmptyTupleCodec implements CodecInterface
{
    public function encode(mixed $value): string
    {
        if ( !($value is vec<_>)) {
            throw new Exception('Expected value to be vec.');
        }
        
        if (C\count($value) > 0) {
            throw new Exception('Expected 0 elements in value.');
        }

        $encoded = (new Int32Type(4))->write();
        $encoded .= (new Int32Type(0))->write();

        return $encoded;
    }
    
    public function decode(Buffer $buffer): mixed
    {
        $elementsCount = Int32Type::read($buffer)->getValue();

        if ($elementsCount > 0) {
            throw new Exception('Expected 0 elements in empty tuple.');
        }

        return vec[];
    }
}