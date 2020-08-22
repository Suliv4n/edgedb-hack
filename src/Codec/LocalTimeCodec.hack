namespace Edgedb\Codec;

use type Edgedb\Message\Type\UInt32Type;
use type Edgedb\Message\Type\Int64Type;
use type Edgedb\Message\Buffer;
use type Exception;
use type DateTime;
use type DateInterval;

use namespace HH\Lib\Str;
use namespace HH\Lib\Math;

class LocalTimeCodec extends ScalarCodec
{
    public function encode(mixed $value): string
    {
        if (! ($value is DateTime)) {
            throw new Exception(Str\format('Expected value to be %s', DateTime::class));
        }

        $hour = (int) $value->format('H');
        $minutes = (int) $value->format('i');
        $seconds = (int) $value->format('s');
        $microseconds = (int) $value->format('u');

        $microsecondsFromMidnight = $hour * 60 * 60 * 10**6;
        $microsecondsFromMidnight += $minutes * 60 * 10**6;
        $microsecondsFromMidnight += $seconds * 10**6;
        $microsecondsFromMidnight += $microseconds;

        $encoded = (new UInt32Type(8))->write();
        $encoded .= (new Int64Type((int) $microsecondsFromMidnight))->write();

        return $encoded;
    }

    public function decode(Buffer $buffer): mixed
    {
        $microseconds = Int64Type::read($buffer)->getValue();

        $hours = Math\int_div($microseconds, 60 * 60 * 10*6);
        $microseconds -= $hours * 60 * 60 * 10*6;

        $minutes = Math\int_div($microseconds, 60 * 10*6);
        $microseconds -= $minutes * 60 * 10*6;

        $seconds = Math\int_div($microseconds, 10*6);
        $microseconds -= $minutes * 10*6;

        $date = (string) $hours |> Str\pad_left($$, 2, '0');
        $date .= ':' . (string) $minutes |> Str\pad_left($$, 2, '0');
        $date .= ':' . (string) $seconds |> Str\pad_left($$, 2, '0');
        $date .= '.' . (string) $microseconds;

        $localTime = DateTime::createFromFormat('h:i:s.u', $date);

        return $localTime;
    }

    public function getTypeId(): string
    {
        return '000000000000-0000-0000-00000000010d';
    }
}