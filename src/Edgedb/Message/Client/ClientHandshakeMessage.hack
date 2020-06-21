namespace Edgedb\Message\Client;

use type Edgedb\Message\AbstractMessage;
use type Edgedb\Message\Struct\Param;
use type Edgedb\Message\Type\Struct\ClientHandshakeStruct;
use type Edgedb\Message\MessageTypeEnum;

class ClientHandshakeMessage extends AbstractMessage<ClientHandshakeStruct>
{
    public function __construct(ClientHandshakeStruct $content) {
        parent::__construct(MessageTypeEnum::CLIENT_HANDSHAKE, $content);
    }
}

