namespace Edgedb\Message\Client;

use type Edgedb\Message\AbstractMessage;
use type Edgedb\Message\Struct\Param;
use type Edgedb\Message\Type\Struct\AuthenticationSASLInitialResponseStruct;
use type Edgedb\Message\MessageTypeEnum;

class AuthenticationSASLInitialResponseMessage extends AbstractMessage<AuthenticationSASLInitialResponseStruct>
{
    public function __construct(AuthenticationSASLInitialResponseStruct $content) {
        parent::__construct(MessageTypeEnum::AUTHENTICATION_SASL_ITINIAL_RESPONSE, $content);
    }
}

