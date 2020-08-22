namespace Edgedb\Message\Type;

use type Edgedb\Message\Buffer;
use type Edgedb\Message\Readable;

use function decbin;
use function bindec;
use function ord;
use function chr;
use function intval;

use namespace HH\Lib\Str;
use namespace HH\Lib\Math;
use namespace HH\Lib\C;

class Float32Type extends AbstractType<float> implements Readable
{
    public function write(): string
    {
        $bin = $this->getValue() >= 0 ? '0' : '1';

        $absluteValue = Math\abs($this->getValue());
        $int = intval($absluteValue);
        $intBin = decbin($int);
        $decimal = $absluteValue - $int;
        $decimalBin = '';

        for ($i = 0; $i < 31; $i++) {
            $decimal *= 2;
            if ($decimal >= 1) {
                $decimal -= 1;
                $decimalBin .= '1';
            } else {
                $decimalBin .= '0';
            }
        }

        if ($int > 0) {
            $exponent = Str\length($intBin) - 1;
            $fraction = Str\slice($intBin, 1) . $decimalBin;
        } else {
            $exponent = -(Str\search($decimalBin, '1') ?? 0) - 1;
            $fraction = Str\trim_left($decimalBin, '0')
                |> Str\slice($$, 1);
        }

        $fraction = Str\slice($fraction, 0, 23);

        $exponent += 127;
        $exponentBin = decbin($exponent)
            |> Str\pad_left($$, 8, '0');

        $bin .= $exponentBin . $fraction;

        $bytes = C\reduce(
            Str\chunk($bin, 8),
            ($bytes, $binByte) ==> $bytes . (bindec($binByte) |> chr($$)),
            ''
        );

        return $bytes;
    }

    public function getLength(): int
    {
        return 4;
    }

    public static function read(Buffer $buffer): Float32Type
    {
        $bytes = $buffer->read(4);
        $bin = '';

        for ($i = 0; $i < Str\length($bytes); $i++) {
            $bin .= $bytes[$i]
                |> ord($$)
                |> decbin($$)
                |> Str\pad_left($$, 8, '0');
        }

        if (Str\replace($bin, '0', '') === '') {
            return new self(.0);
        }

        $sign = $bin[0] === '0' ? 1 : -1;
        $exponent = Str\slice($bin, 1, 8) 
            |> bindec($$) - 127;
        $fraction = Str\slice($bin, 9) 
            |> Str\trim_right($$, '0');

        $coefficient = 1;
        for ($i = 0; $i < Str\length($fraction); $i++) {
            $bit = $fraction[$i] === '0' ? 0 : 1;
            $coefficient += $bit * (2 ** (-$i - 1));
        }

        $value = $sign * $coefficient * (2 ** $exponent);

        return new self($value);
    }
}