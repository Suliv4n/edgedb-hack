namespace Edgedb\Message\Server;

use type Edgedb\Message\Buffer;
use type Edgedb\Message\Readable;
use type Edgedb\Message\AbstractMessage;
use type Edgedb\Message\Type\Struct\AuthenticationRequiredSASLStruct;

class AuthenticationRequiredSASLMessage extends AbstractMessage<AuthenticationRequiredSASLStruct> implements Readable
{
    public function __construct(AuthenticationRequiredSASLStruct $content) {
        parent::__construct('R', $content);
    }

    public static function read(Buffer $buffer): AuthenticationRequiredSASLMessage
    {
        self::setBufferCursorAtContentBegining($buffer);
        $content = AuthenticationRequiredSASLStruct::read($buffer);

        return new self($content);
    }
}