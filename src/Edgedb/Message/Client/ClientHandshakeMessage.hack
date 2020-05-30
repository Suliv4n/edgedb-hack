namespace Edgedb\Message\Client;

use type Edgedb\Message\AbstractMessage;
use type Edgedb\Message\Struct\Param;
use type Edgedb\Message\Type\Struct\ClientHandshakeStruct;

class ClientHandshakeMessage extends AbstractMessage<ClientHandshakeStruct>
{
    public function __construct(ClientHandshakeStruct $content) {
        parent::__construct("V", $content);
    }
}

