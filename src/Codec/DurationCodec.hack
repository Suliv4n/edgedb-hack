namespace Edgedb\Codec;

use type Edgedb\Message\Type\Int64Type;
use type Edgedb\Message\Type\UInt32Type;
use type Edgedb\Message\Type\Int32Type;
use type Edgedb\Message\Buffer;
use type DateInterval;
use type Exception;

use namespace HH\Lib\Str;
use namespace HH\Lib\Math;

class DurationCodec implements CodecInterface
{
    public function encode(mixed $value): string
    {
        if (! ($value is DateInterval)) {
            throw new Exception(Str\format('Expected value to be %s', DateInterval::class));
        }

        $microseconds = $value->h * 60 * 60 * 10**6;
        $microseconds += $value->i * 60 * 10**6;
        $microseconds += $value->s * 10**6;
        
        $days = $value->d;

        $months = $value->m;
        $months += $value->y * 12;

        $encoded = (new UInt32Type(16))->write();
        $encoded .= (new Int64Type((int) $microseconds))->write();
        $encoded .= (new Int32Type((int) $days))->write();
        $encoded .= (new Int32Type((int) $months))->write();

        return $encoded;
    }

    public function decode(Buffer $buffer): mixed
    {
        $microseconds = Int64Type::read($buffer)->getValue();
        $seconds = Math\int_div($microseconds, 1000000);

        $hours = Math\int_div($seconds, 60 * 60);
        $seconds -= $hours * 60 * 60;

        $minutes = Math\int_div($seconds, 60);
        $seconds -= $minutes * 60;
        
        $days = Int32Type::read($buffer)->getValue();

        $months = Int32Type::read($buffer)->getValue();
        $years = Math\int_div($months, 12);
        $months -= $years * 12;


        $intervalString = 'P' 
            . $years . 'Y'
            . $months . 'M'
            . $days . 'D'
            . 'T'
            . $hours . 'H'
            . $minutes . 'M'
            . $seconds . 'S';

        return new DateInterval($intervalString);
    }
}