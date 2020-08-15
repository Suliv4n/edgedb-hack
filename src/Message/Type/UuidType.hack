namespace Edgedb\Message\Type;

use type Edgedb\Message\Buffer;
use type Edgedb\Message\Readable;

use namespace HH\Lib\Str;

use function ord;
use function chr;
use function dechex;
use function hexdec;

class UuidType extends AbstractType<string> implements Readable
{
    public function write(): string
    {
        $uuidHex = $this->getValue()
            |> Str\replace($$, '-', '');

        $bytes = '';

        for ($i = 0; $i < 16; $i++) {
            $bytes .= Str\slice($uuidHex, $i*2, 2)
             |> hexdec($$)
             |> chr($$);
        }

        return $this->getValue();
    }

    public function getLength(): int
    {
        return 16;
    }

    public static function read(Buffer $buffer): UuidType 
    {
        $bytes = $buffer->read(16);
        $uuidHex = '';
        for ($i = 0; $i < 16; $i++) {
            $uuidHex .= ord($bytes[$i])
                |> dechex($$)
                |> Str\pad_left($$, 2, '0');

            if (
                $i === 3
                || $i === 5
                || $i === 7
                || $i === 9
            ) {
                $uuidHex .= '-';
            }
        }

        return new self($uuidHex);
    }
}