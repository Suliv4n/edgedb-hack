namespace Edgedb\Codec;

use type Edgedb\Message\Type\UInt32Type;
use type Edgedb\Message\Type\Int32Type;
use type Edgedb\Message\Buffer;
use type Exception;
use type DateTime;
use type DateInterval;

use namespace HH\Lib\Str;
use namespace HH\Lib\Math;

class LocalDateCodec extends ScalarCodec
{
    private DateTime $referenceDate;

    public function __construct()
    {
        $this->referenceDate = new DateTime();
        $this->referenceDate->setDate(2000, 1, 1);
    }

    public function encode(mixed $value): string
    {
        if (! ($value is DateTime)) {
            throw new Exception(Str\format('Expected value to be %s', DateTime::class));
        }

        $interval = $value->diff($this->referenceDate);
        
        $encoded = (new UInt32Type(4))->write();
        $encoded .= (new UInt32Type($interval->days))->write();

        return $encoded;
    }

    public function decode(Buffer $buffer): mixed
    {
        $daysFromReferenceDate = Int32Type::read($buffer)->getValue();
        
        $localDate = new DateTime($this->referenceDate->getTimestamp());

        $interval = new DateInterval(
            Str\format('P%dD', Math\abs($daysFromReferenceDate))
        );

        if ($daysFromReferenceDate >= 0) {
            $localDate->add($interval);
        } else {
            $localDate->sub($interval);
        }

        return $localDate;
    }
}