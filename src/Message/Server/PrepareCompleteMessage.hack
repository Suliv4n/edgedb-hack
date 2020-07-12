namespace Edgedb\Message\Server;

use type Edgedb\Message\Buffer;
use type Edgedb\Message\Readable;
use type Edgedb\Message\AbstractMessage;
use type Edgedb\Message\Type\Struct\PrepareCompleteStruct;
use type Edgedb\Message\MessageTypeEnum;

class PrepareCompleteMessage extends AbstractMessage<PrepareCompleteStruct> implements Readable
{
    public function __construct(PrepareCompleteStruct $content) {
        parent::__construct(MessageTypeEnum::PREPARE_COMPLETE, $content);
    }

    public static function read(Buffer $buffer): PrepareCompleteMessage
    {
        self::setBufferCursorAtContentBegining($buffer);
        $content = PrepareCompleteStruct::read($buffer);

        return new self($content);
    }
}