namespace Edgedb\Message\Server;

use type Edgedb\Message\Readable;
use type Edgedb\Message\AbstractMessage;
use type Edgedb\Message\Struct\Param;
use type Edgedb\Message\Type\Struct\ErrorStruct;
use type Edgedb\Message\Buffer;
use type Edgedb\Message\MessageTypeEnum;

class ErrorMessage extends AbstractMessage<ErrorStruct> implements Readable
{
    public function __construct(ErrorStruct $content) {
        parent::__construct(MessageTypeEnum::SERVER_HANDSHAKE, $content);
    }

    public static function read(Buffer $buffer): ErrorMessage
    {
        self::setBufferCursorAtContentBegining($buffer);
        $content = ErrorStruct::read($buffer);

        return new self($content);
    }
}

