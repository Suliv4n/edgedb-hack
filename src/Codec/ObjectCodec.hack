namespace Edgedb\Codec;

use type Edgedb\Message\Type\Int32Type;
use type Edgedb\Message\Type\UInt32Type;
use type Edgedb\Message\Buffer;
use type Exception;

use namespace HH\Lib\Str;
use namespace HH\Lib\C;

class ObjectCodec implements CodecInterface
{
    public function __construct(
        private vec<CodecInterface> $subCodecs,
        private vec<string> $names,
        private vec<int> $flags
    ) {}

    public function encode(mixed $value): string
    {
        throw new Exception('Object can not be passed as arguments.');
    }

    public function decode(Buffer $buffer): mixed
    {
        $decoded = dict[];

        $elementsCount = UInt32Type::read($buffer)->getValue();

        if ($elementsCount !== C\count($this->subCodecs)) {
            throw new Exception(
                Str\format(
                    'Cannot decode object: expected %d elements got %d',
                    C\count($this->subCodecs),
                    $elementsCount
                )
            );
        }

        for ($i = 0; $i < $elementsCount; $i++) {
            $buffer->discard(4); // reserved
            $elementLength = Int32Type::read($buffer)->getValue();
            $name = $this->names[$i];

            $value = null;

            if ($elementLength !== -1) {
                $elementBuffer = $buffer->extractFromCursor($elementLength);
                $value = $this->subCodecs[$i]->decode($elementBuffer);
            }
            $decoded[$name] = $value;
        }

        return $decoded;
    }
}