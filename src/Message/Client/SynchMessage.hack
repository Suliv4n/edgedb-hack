namespace Edgedb\Message\Client;

use type Edgedb\Message\AbstractMessage;
use type Edgedb\Message\MessageTypeEnum;
use type Edgedb\Message\Type\Struct\EmptyStruct;


class SynchMessage extends AbstractMessage<EmptyStruct>
{
    public function __construct() {
        parent::__construct(MessageTypeEnum::SYNCH, new EmptyStruct());
    }
}

