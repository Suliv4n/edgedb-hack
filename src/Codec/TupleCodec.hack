namespace Edgedb\Codec;

use type Edgedb\Message\Type\Int32Type;
use type Edgedb\Message\Type\UInt32Type;
use type Edgedb\Message\Buffer;
use type Exception;

use namespace HH\Lib\Str;
use namespace HH\Lib\C;

class TupleCodec implements CodecInterface
{
    public function __construct(
        private vec<CodecInterface> $subCodecs
    ) {}

    public function encode(mixed $value): string
    {
        throw new Exception('Tuples can not be passed as arguments.');
    }

    public function decode(Buffer $buffer): mixed
    {
        $elementsCount = UInt32Type::read($buffer)->getValue();

        if ($elementsCount !== C\count($this->subCodecs)) {
            throw new Exception(
                Str\format(
                        'Cannot decode Tuple: expected %d elements, got %d',
                        $elementsCount,
                        C\count($this->subCodecs
                    )
                )
            );
        }

        $decoded = vec[];

        for ($i = 0; $i < $elementsCount; $i++) {
            $buffer->discard(4);
            $elementLength = Int32Type::read($buffer)->getValue();

            if ($elementLength === -1) {
                $decoded[] = null;
            } else {
                $elementBuffer = $buffer->extractFromCursor($elementLength);
                $decoded[] = $this->subCodecs[$i]->decode($elementBuffer);
            }
        }

        return $decoded;
    }
}