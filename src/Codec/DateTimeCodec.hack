namespace Edgedb\Codec;

use type Edgedb\Message\Type\UInt32Type;
use type Edgedb\Message\Type\Int64Type;
use type Edgedb\Message\Buffer;
use type Exception;
use type DateTime;
use type DateInterval;
use type DateTimeZone;

use namespace HH\Lib\Str;
use namespace HH\Lib\Math;

class DateTimeCodec extends LocalDateTimeCodec
{
    public function __construct()
    {
        parent::__construct();
        $this->referenceDatetime->setTimezone(new DateTimeZone('UTC'));
    }

    public function getTypeId(): string
    {
        return '000000000000-0000-0000-00000000010a';
    }
}