namespace Edgedb\Codec;

use type Edgedb\Message\Type\Int32Type;
use type Edgedb\Message\Type\UInt32Type;
use type Edgedb\Message\Buffer;
use type Exception;

use namespace HH\Lib\Str;
use namespace HH\Lib\C;

class ArrayCodec implements CodecInterface
{
    const int MAX_LENGTH = 0x7fffffff;

    public function __construct(
        private CodecInterface $subCodec,
        private int $length
    ) {}

    public function encode(mixed $value): string
    {
        if (! ($this->subCodec is ScalarCodec)) {
            throw new Exception('Only arrays of scalars are supported');
        }

        if (! ($value is vec<_>)) {
            throw new Exception('Expected value to be a vec');
        }

        $elementsCount = C\count($value);

        if ($elementsCount > self::MAX_LENGTH) {
            throw new Exception('Too many elements in array');
        }

        $elementsData = '';
        for ($i = 0; $i < $elementsCount; $i++) {
            $item = $value[$i];
            
            if ($item === null) {
                $elementsData .= (new Int32Type(-1))->write();
            } else {
                $elementsData .= $this->subCodec->encode($item);
            }
        }

        $encoded = (new Int32Type(12 + 8 + Str\length($elementsData)))->write();
        $encoded .= (new Int32Type(1))->write(); // Dimension
        $encoded .= (new Int32Type(0))->write(); // Flags
        $encoded .= (new Int32Type(0))->write(); // Reserved

        $encoded .= (new Int32Type($elementsCount))->write();
        $encoded .= (new Int32Type(1))->write();

        return $encoded;
    }

    public function decode(Buffer $buffer): mixed
    {
        $dimension = Int32Type::read($buffer)->getValue();
        
        $buffer->discard(4); // Ignore flags
        $buffer->discard(4); // Reserved

        if ($dimension === 0) {
            return vec[];
        }

        if ($dimension !== 1) {
            throw new Exception('Only 1-dimensional arrays are supported');
        }
        
        $length = UInt32Type::read($buffer)->getValue();

        if ($this->length !== -1 && $length !== $this->length) {
            throw new Exception(
                    Str\format(
                        'invalid array size: received %d, expected %d',
                        $length,
                        $this->length
                    )
                );
        }

        $buffer->discard(4); // ignore the lower bound info
        
        $decoded = vec[];

        for ($i = 0; $i < $length; $i++) {
            $elementLength = Int32Type::read($buffer)->getValue();
            
            if ($elementLength === -1) {
                $decoded[] = null;
            } else {
                $elementBuffer = $buffer->extractFromCursor($elementLength);
                $decoded[$i] = $this->subCodec->decode($buffer);
            }
        }

        return $decoded;
    }
}