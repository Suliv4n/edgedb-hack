namespace Edgedb\Codec;

interface ArgumentsEncoderInterface
{
    public function encodeArguments(mixed $arguments): string;
}