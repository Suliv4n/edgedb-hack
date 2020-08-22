namespace Edgedb\Codec;

use type Edgedb\Message\Type\Int32Type;
use type Edgedb\Message\Type\UInt32Type;
use type Edgedb\Message\Buffer;
use type Exception;

use namespace HH\Lib\Str;
use namespace HH\Lib\C;

class SetCodec implements CodecInterface
{
    public function __construct(
        private string $typeId,
        private CodecInterface $subCodec
    ) {}

    public function encode(mixed $value): string
    {
        throw new Exception('Sets can not be passed as arguments.');
    }

    public function decode(Buffer $buffer): mixed
    {
        $decoded = vec[];

        return $decoded;
    }

    public function decodeSetOfArrays(Buffer $buffer): vec<mixed>
    {
        $dimension = Int32Type::read($buffer)->getValue();

        $buffer->discard(4); // Ignore flag
        $buffer->discard(4); // Reserved

        if ($dimension === 0) {
            return vec[];
        }

        if ($dimension !== 1) {
            throw new Exception('Expected 1-dimensional array of records of arrays');
        }

        $decoded = vec[];

        $length = UInt32Type::read($buffer)->getValue();

        for ($i = 0; $i < $length; $i++) {
            $buffer->discard(4); // Ignore array element size

            $recordSize = UInt32Type::read($buffer)->getValue();

            if ($recordSize !== 1) {
                throw new Exception(
                    'Expected a record with a single element as an array set '
                    . 'element envelope'
                );
            }

            $buffer->discard(4); // Reserved

            $elementLength = Int32Type::read($buffer)->getValue();

            if ($elementLength === -1) {
                throw new Exception('Unexpected NULL value in array set element');
            }

            $elementBuffer = $buffer->extractFromCursor($elementLength);
            $decoded[] = $this->subCodec->decode($elementBuffer);
        }

        return $decoded;
    }

    public function decodeSet(Buffer $buffer): vec<mixed> {
        $dimension = Int32Type::read($buffer)->getValue();
        
        $buffer->discard(4); // Ignore flag
        $buffer->discard(4); // Reserved

        if ($dimension === 0) {
            return vec[];
        }

        if ($dimension !== 1) {
            throw new Exception(Str\format('Invalid set dimensinality: %d', $dimension));
        }

        $length = UInt32Type::read($buffer)->getValue();

        $decoded = vec[];

        for ($i = 0; $i < $length; $i++) {
            $elementLength = Int32Type::read($buffer)->getValue();

            if ($elementLength === -1) {
                $decoded[] = null;
            } else {
                $elementBuffer = $buffer->extractFromCursor($elementLength);
                $decoded[] = $this->subCodec->decode($elementBuffer);
            }
        }

        return $decoded;
    }

    public function getTypeId(): string
    {
        return $this->typeId;
    }
}