namespace Edgedb\Codec;

interface CodecInterface<T>
{
    public function encode(T $value): string;
    public function decode(string $value): T;
}