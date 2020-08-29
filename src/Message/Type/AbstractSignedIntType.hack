namespace Edgedb\Message\Type;

use type Exception;

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

abstract class AbstractSignedIntType extends AbstractType<int>
{
    public function __construct(int $value) {
        parent::__construct($value);
    }

    protected function toBytes(int $bitsCount): string
    {
        if ($this->getValue() < 0) {
            $value = Math\abs($this->getValue());

            $bin = decbin($value) |> Str\pad_left($$, $bitsCount, '0');
            $binA2 = '';

            for ($i = 0; $i < Str\length($bin); $i++) {
                $binA2 .= $bin[$i] === '1' ? '0' : '1';
            }

            $i = Str\length($bin) - 1;
            $retain = 0;
            do {
                $binA2[$i] = $binA2[$i] === '1' ? '0' : '1';

                if ($binA2[$i] === '0') {
                    $retain = 1;
                } else {
                    $retain = 0;
                }

                $i--;
            } while($i >= 0 && $retain === 1);

            $bytes = C\reduce(
                Str\chunk($binA2, 8),
                ($bytes, $binByte) ==> $bytes . (bindec($binByte) |> chr($$)),
                ''
            );
        } else {
            if ($bitsCount === 64) {
                $bytes = pack('J', $this->getValue());
            } else if ($bitsCount === 32) {
                $bytes = pack('N', $this->getValue());
            } else if ($bitsCount === 16) {
                $bytes = pack('n', $this->getValue());
            } else if ($bitsCount === 8) {
                $bytes = pack('C', $this->getValue());
            } else {
                throw new Exception('Expected bytes count to be 8, 16, 32 or 64');
            }
        }

        return $bytes;
    }

    protected static function toInt(string $bytes): int
    {
        $bytesCount = Str\length($bytes);
        $bitsCount = $bytesCount * 8;

        $bin = '';
        for ($i = 0; $i < $bytesCount; $i++) {
            $bin .= $bytes[$i]
                |> ord($$)
                |> decbin($$)
                |> Str\pad_left($$, 8, '0');
        }

        $value = 0;
        for ($i = 1; $i < $bitsCount; $i++) {
            $bit = intval($bin[$i]);
            $value += (int) ($bit * 2 ** ($bitsCount - 1 - $i));
        }

        if ($bin[0] === "1") {
            $value -= 1 << ($bitsCount - 1);
        }

        return $value;
    }
}