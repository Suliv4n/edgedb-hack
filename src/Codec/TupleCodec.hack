namespace Edgedb\Codec;

use type Edgedb\Message\Type\Int32Type;
use type Edgedb\Message\Type\UInt32Type;
use type Edgedb\Message\Buffer;
use type Exception;

use namespace HH\Lib\Str;
use namespace HH\Lib\C;

class TupleCodec implements CodecInterface, ArgumentsEncoderInterface
{
    public function __construct(
        private string $typeId,
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

    public function encodeArguments(mixed $arguments): string
    {
        if (! ($arguments is vec<_>)) {
            throw new Exception('Expected arguments to be vec.');
        }

        $codecsCount = C\count($this->subCodecs);

        if ($codecsCount !== C\count($arguments)) {
            throw new Exception(
                Str\format(
                    'Expected %d argument%s, but got %d.',
                    $codecsCount,
                    $codecsCount === 1 ? '' : 's',
                    C\count($arguments)
                )
            );
        }

        if ($codecsCount === 0) {
            return EmptyTupleCodec::getBytes();
        }

        $elementsData = '';

        for ($i = 0; $i < $codecsCount; $i++) { 
            $argument = $arguments[$i];

            $elementsData .= (new Int32Type(0))->write(); // Reserved

            if ($argument === null) {
                $elementsData .= (new Int32Type(-1))->write();
            } else {
                $codec = $this->subCodecs[$i];
                $elementsData .= $codec->encode($argument);
            }
        }

        $encoded = (new Int32Type(4 + Str\length($elementsData)))->write();
        $encoded .= (new Int32Type($codecsCount))->write();
        $encoded .= $elementsData;

        return $encoded;
    }

    public function getTypeId(): string
    {
        return $this->typeId;
    }
}