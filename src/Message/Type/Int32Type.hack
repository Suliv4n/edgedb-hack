namespace Edgedb\Message\Type;

use Edgedb\Message\Buffer;
use type Edgedb\Message\Readable;

use function pack;
use function unpack;
use function ord;
use function chr;
use function decbin;
use function bindec;
use function intval;

use namespace HH\Lib\Str;
use namespace HH\Lib\Math;
use namespace HH\Lib\C;

class Int32Type extends AbstractType<int>
{
    public function write(): string
    {
        if ($this->getValue() < 0) {
            $value = Math\abs($this->getValue());

            $bin = decbin($value) |> Str\pad_left($$, 32, '0');
            $binA2 = '';

            for ($i = 0; $i < Str\length($bin); $i++) {
                $binA2 .= $bin[$i] === '1' ? '0' : '1';
            }

            $decA2 = bindec($binA2) + 1;
            
            $binA2 = decbin($decA2) |> Str\pad_left($$, 32, '0');

            $bytes = C\reduce(
                Str\chunk($binA2, 8),
                ($bytes, $binByte) ==> bindec($binByte) |> chr($$),
                ''
            );

        } else {
            $bytes = pack('N', $this->getValue());
        }

        

        return $bytes;
    }

    public function getLength(): int
    {
        return 4;
    }

    public static function read(Buffer $buffer): Int32Type
    {
        $bytes = $buffer->read(4);

        $bin = "";
        for ($i = 0; $i < 4; $i++) {
            $bin .= Str\pad_left(decbin(ord($bytes[$i])), 8, '0');
        }

        $value = 0;
        for ($i = 1; $i < 32; $i++) {
            $bit = intval($bin[$i]);
            $value += (int) ($bit * 2 ** (31 - $i));
        }

        if ($bin[0] === "1") {
            $value -= 1 << 31;
        }

        return new self($value);
    }
}
