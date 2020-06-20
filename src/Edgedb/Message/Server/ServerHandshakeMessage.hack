namespace Edgedb\Message\Server;

use type Edgedb\Message\Readable;
use type Edgedb\Message\AbstractMessage;
use type Edgedb\Message\Struct\Param;
use type Edgedb\Message\Type\Struct\ServerHandshakeStruct;
use type Edgedb\Message\Buffer;

class ServerHandshakeMessage extends AbstractMessage<ServerHandshakeStruct> implements Readable
{
    public function __construct(ServerHandshakeStruct $content) {
        parent::__construct('v', $content);
    }

    public static function read(Buffer $buffer): ServerHandshakeMessage
    {
        self::setBufferCursorAtContentBegining($buffer);
        $content = ServerHandshakeStruct::read($buffer);

        return new self($content);
    }
}

