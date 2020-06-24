namespace Edgedb\Exception;

use type Exception;
use type Edgedb\Message\MessageTypeEnum;

use namespace HH\Lib\Str;

class UnexpectedMessageTypeException extends Exception
{
    public function __construct(
        MessageTypeEnum $expectedMessageType,
        MessageTypeEnum $givenMessageType
    ) {
        parent::__construct(
            Str\format(
                'Expexted message type "%s" but got "%s".',
                $expectedMessageType,
                $givenMessageType
            )
        );
    }
}