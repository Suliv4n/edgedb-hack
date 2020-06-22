namespace Edgedb\Message\Server;

use type Edgedb\Message\Buffer;
use type Edgedb\Message\Readable;
use type Edgedb\Message\AbstractMessage;
use type Edgedb\Message\Type\Struct\AuthenticationStruct;
use type Edgedb\Message\MessageTypeEnum;

class AuthenticationMessage extends AbstractMessage<AuthenticationStruct> implements Readable
{
    public function __construct(AuthenticationStruct $content) {
        parent::__construct(MessageTypeEnum::AUTHENTICATION, $content);
    }

    public static function read(Buffer $buffer): AuthenticationMessage
    {
        self::setBufferCursorAtContentBegining($buffer);
        $content = AuthenticationStruct::read($buffer);

        return new self($content);
    }
}