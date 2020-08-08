namespace Edgedb\Codec;

use type Edgedb\Message\Type\Int32Type;
use type Edgedb\Message\Type\UInt32Type;
use type Edgedb\Message\Buffer;
use type Exception;

use namespace HH\Lib\Str;
use namespace HH\Lib\C;
use namespace HH\Lib\Vec;

class NamedTupleCodec implements CodecInterface, ArgumentsEncoderInterface
{
    private keyset<string> $namesSet;

    public function __construct(
        private vec<CodecInterface> $subCodecs,
        private vec<string> $names
    ) {
        $this->namesSet = keyset($names);
    }

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

    public function encodeArguments(mixed $arguments): string
    {
        if (! ($arguments is dict<_, _>)) {
            throw new Exception('Expected arguments to be dict.');
        }

        $keys = Vec\keys($arguments);
        $codecsCount = C\count($this->subCodecs);

        if (C\count($keys) !== $codecsCount) {
            $extraKeys = Vec\filter(
                $keys, 
                ($key) ==> C\contains($this->namesSet, $key)
            );

            throw new Exception(
                Str\format(
                    'Unexpected named argument%s %s',
                    C\count($extraKeys) === 1 ? '' : 's',
                    Str\join($keys, ', ')
                )
            );
        }

        if ($codecsCount === 0)
        {
            return EmptyTupleCodec::getBytes();
        }

        $elementsData = '';

        for ($i = 0; $i < $codecsCount; $i++) {
            $key = $this->names[$i];

            if (!C\contains_key($arguments, $key)) {
                throw new Exception("Missing named argument {$key}");
            }

            $value = $arguments[$key];

            $elementsData .= (new Int32Type(0))->write(); // Reserved

            if ($value is null) {
                $elementsData .= (new Int32Type(-1))->write();
            } else {
                $codec = $this->subCodecs[$i];
                $elementsData .= $codec->encode($value);
            }
        }

        $encoded = (new Int32Type(4 + Str\length($elementsData)))->write();
        $encoded .= (new Int32Type($codecsCount))->write();
        $encoded .= $elementsData;

        return $encoded;
    }
}