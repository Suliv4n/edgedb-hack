namespace Edgedb\Message\Client;

use type Edgedb\Message\AbstractMessage;
use type Edgedb\Message\Type\Struct\ExecuteScriptStruct;
use type Edgedb\Message\MessageTypeEnum;

class ExecuteScriptMessage extends AbstractMessage<ExecuteScriptStruct>
{
    public function __construct(ExecuteScriptStruct $content) {
        parent::__construct(MessageTypeEnum::EXECUTE_SCRIPT, $content);
    }
}

