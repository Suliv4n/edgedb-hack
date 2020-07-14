namespace Edgedb\Message\Client;

use type Edgedb\Message\AbstractMessage;
use type Edgedb\Message\Struct\Param;
use type Edgedb\Message\Type\Struct\DescribeStatementStruct;
use type Edgedb\Message\MessageTypeEnum;

class DescribeStatementMessage extends AbstractMessage<DescribeStatementStruct>
{
    public function __construct(DescribeStatementStruct $content) {
        parent::__construct(MessageTypeEnum::DESCRIBE_STATEMENT, $content);
    }
}
