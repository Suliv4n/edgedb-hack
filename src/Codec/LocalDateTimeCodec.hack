namespace Edgedb\Codec;

use type Edgedb\Message\Type\UInt32Type;
use type Edgedb\Message\Type\Int64Type;
use type Edgedb\Message\Buffer;
use type Exception;
use type DateTime;
use type DateInterval;

use namespace HH\Lib\Str;
use namespace HH\Lib\Math;

class LocalDateTimeCodec extends ScalarCodec
{
    protected DateTime $referenceDatetime;

    public function __construct()
    {
        $this->referenceDatetime = new DateTime();
        $this->referenceDatetime->setDate(2000, 1, 1);
        $this->referenceDatetime->setTime(0, 0, 0);
    }

    public function encode(mixed $value): string
    {
        if (! ($value is DateTime)) {
            throw new Exception(Str\format('Expected value to be %s', DateTime::class));
        }

        $microseconds = (int) $value->format('u');
        $microseconds += $value->getTimestamp() * 10**6;
        $microseconds -= (int) $this->referenceDatetime->format('u');
        $microseconds -= (int) $this->referenceDatetime->getTimestamp() * 10**6;

        $encoded = (new UInt32Type(8))->write();
        $encoded .= (new Int64Type((int) $microseconds))->write();

        return $encoded;
    }

    public function decode(Buffer $buffer): mixed
    {
        $microseconds = Int64Type::read($buffer)->getValue();

        $microsecondsDiff = $microseconds % 1000000;

        if ($microseconds < 0) {
            $microsecondsDiff = 10**6 - $microsecondsDiff;
        }

        $referenceMicroTimestamp = $this->referenceDatetime->getTimestamp() * 10**6;
        $referenceMicroTimestamp += $microseconds;
        

        $localDatetime = new DateTime();
        $localDatetime->setTimestamp($referenceMicroTimestamp / 10**6);
        $localDatetimeString = $localDatetime->format('Y-m-d h:i:s');

        $localDatetime = DateTime::createFromFormat(
            'Y-m-d h:i:s.u', 
            $localDatetimeString . '.' . (string) $microsecondsDiff
        );

        if ($microseconds < 0) {
            $localDatetime->modify('-1second');
        }

        return $localDatetime;
    }
}