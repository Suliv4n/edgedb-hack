namespace Edgedb\Message\Type;

use function decbin;
use function bindec;
use function ord;
use function chr;
use function intval;

use namespace HH\Lib\Str;
use namespace HH\Lib\Math;
use namespace HH\Lib\C;

abstract class AbstractFloatType extends AbstractType<float>
{
    protected function toBytes(int $bitsCount, int $exponentBitsCount): string
    {
        if ($this->getValue() === .0) {
            return Str\repeat(chr(0), Math\int_div($bitsCount, 8));
        }

        $bin = $this->getValue() >= 0 ? '0' : '1';

        $absluteValue = Math\abs($this->getValue());
        $int = intval($absluteValue);
        $intBin = decbin($int);
        $decimal = $absluteValue - $int;
        $decimalBin = '';

        for ($i = 0; $i < $bitsCount - 1; $i++) {
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
                |> Str\pad_right($$, $bitsCount - $exponentBitsCount, '0')
                |> Str\slice($$, 1);
        }

        $fraction = Str\slice($fraction, 0, $bitsCount - $exponentBitsCount - 1);

        $exponent += 2 ** ($exponentBitsCount - 1) - 1;
        $exponentBin = decbin($exponent)
            |> Str\pad_left($$, $exponentBitsCount, '0');

        $bin .= $exponentBin . $fraction;

        $bytes = C\reduce(
            Str\chunk($bin, 8),
            ($bytes, $binByte) ==> $bytes . (bindec($binByte) |> chr($$)),
            ''
        );

        return $bytes;
    }

    protected static function toFloat(string $bytes, int $exponentBitsCount): float
    {
        $bin = '';

        for ($i = 0; $i < Str\length($bytes); $i++) {
            $bin .= $bytes[$i]
                |> ord($$)
                |> decbin($$)
                |> Str\pad_left($$, 8, '0');
        }

        if (Str\replace($bin, '0', '') === '') {
            return .0;
        }

        $sign = $bin[0] === '0' ? 1 : -1;
        $exponent = Str\slice($bin, 1, $exponentBitsCount)
            |> bindec($$) - (2 ** ($exponentBitsCount - 1) - 1);
        $fraction = Str\slice($bin, $exponentBitsCount + 1)
            |> Str\trim_right($$, '0');

        $coefficient = 1;
        for ($i = 0; $i < Str\length($fraction); $i++) {
            $bit = $fraction[$i] === '0' ? 0 : 1;
            $coefficient += $bit * (2 ** (-$i - 1));
        }

        return $sign * $coefficient * (2 ** $exponent);
    }
}