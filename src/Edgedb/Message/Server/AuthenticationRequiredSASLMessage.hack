namespace Edgedb\Message\Server;

use type Edgedb\Message\Buffer;
use type Edgedb\Message\Readable;
use type Edgedb\Message\AbstractMessage;
use type Edgedb\Message\Type\Struct\AuthenticationRequiredSASLStruct;
use type Edgedb\Message\MessageTypeEnum;

class AuthenticationRequiredSASLMessage extends AbstractMessage<AuthenticationRequiredSASLStruct> implements Readable
{
    public function __construct(AuthenticationRequiredSASLStruct $content) {
        parent::__construct(MessageTypeEnum::AUTHENTICATION_REQUIRED_SASL, $content);
    }

    public static function read(Buffer $buffer): AuthenticationRequiredSASLMessage
    {
        self::setBufferCursorAtContentBegining($buffer);
        $content = AuthenticationRequiredSASLStruct::read($buffer);

        return new self($content);
    }
}