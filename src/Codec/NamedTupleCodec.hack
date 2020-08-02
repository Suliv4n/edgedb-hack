namespace Edgedb\Codec;

use type Edgedb\Message\Type\Int32Type;
use type Edgedb\Message\Type\UInt32Type;
use type Edgedb\Message\Buffer;
use type Exception;

use namespace HH\Lib\Str;
use namespace HH\Lib\C;

class NamedTupleCodec implements CodecInterface
{
    public function __construct(
        private vec<CodecInterface> $subCodecs,
        private vec<string> $names
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
                        'Cannot decode NamedTuple: expected %d elements, got %d',
                        $elementsCount,
                        C\count($this->subCodecs
                    )
                )
            );
        }

        $decoded = dict[];

        for ($i = 0; $i < $elementsCount; $i++) {
            $buffer->discard(4);
            $elementLength = Int32Type::read($buffer)->getValue();

            $value = null;
            $name = $this->names[$i];
            if ($elementLength !== -1) {
                $elementBuffer = $buffer->extractFromCursor($elementLength);
                $value = $this->subCodecs[$i]->decode($elementBuffer);
            }

            $decoded[$i] = $value;
            $decoded[$name] = $value;
        }

        return $decoded;
    }
}