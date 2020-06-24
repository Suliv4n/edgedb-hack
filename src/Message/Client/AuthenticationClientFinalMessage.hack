namespace Edgedb\Message\Client;

use type Edgedb\Message\AbstractMessage;
use type Edgedb\Message\Struct\Param;
use type Edgedb\Message\Type\Struct\AuthenticationSASLResponseStruct;
use type Edgedb\Message\MessageTypeEnum;

class AuthenticationSASLResponseMessage extends AbstractMessage<AuthenticationSASLResponseStruct>
{
    public function __construct(AuthenticationSASLResponseStruct $content) {
        parent::__construct(MessageTypeEnum::AUTHENTICATION_CLIENT_FINAL, $content);
    }
}

