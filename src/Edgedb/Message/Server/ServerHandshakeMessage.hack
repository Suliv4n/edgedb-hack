namespace Edgedb\Message\Server;

use type Edgedb\Message\Readable;
use type Edgedb\Message\AbstractMessage;
use type Edgedb\Message\Struct\Param;
use type Edgedb\Message\Type\Struct\ServerHandshakeStruct;
use type Edgedb\Message\Buffer;
use type Edgedb\Message\MessageTypeEnum;

class ServerHandshakeMessage extends AbstractMessage<ServerHandshakeStruct> implements Readable
{
    public function __construct(ServerHandshakeStruct $content) {
        parent::__construct(MessageTypeEnum::SERVER_HANDSHAKE, $content);
    }

    public static function read(Buffer $buffer): ServerHandshakeMessage
    {
        self::setBufferCursorAtContentBegining($buffer);
        $content = ServerHandshakeStruct::read($buffer);

        return new self($content);
    }
}

