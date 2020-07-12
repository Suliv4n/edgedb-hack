namespace Edgedb\Message\Client;

use type Edgedb\Message\AbstractMessage;
use type Edgedb\Message\Type\Struct\PrepareStruct;
use type Edgedb\Message\MessageTypeEnum;

class PrepareMessage extends AbstractMessage<PrepareStruct>
{
    public function __construct(PrepareStruct $content) {
        parent::__construct(MessageTypeEnum::PREPARE, $content);
    }
}

