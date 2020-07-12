namespace Edgedb\Message\Client;

use type Edgedb\Message\AbstractMessage;
use type Edgedb\Message\Type\Struct\ExecuteStruct;
use type Edgedb\Message\MessageTypeEnum;

class ExecuteMessage extends AbstractMessage<ExecuteStruct>
{
    public function __construct(ExecuteStruct $content) {
        parent::__construct(MessageTypeEnum::EXECUTE, $content);
    }
}

