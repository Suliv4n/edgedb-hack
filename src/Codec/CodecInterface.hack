namespace Edgedb\Codec;

use type Edgedb\Message\Buffer;

interface CodecInterface
{
    public function encode(mixed $value): string;
    public function decode(Buffer $buffer): mixed;
    public function getTypeId(): string;
}