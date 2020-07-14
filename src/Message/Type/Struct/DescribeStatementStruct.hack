namespace Edgedb\Message\Type\Struct;

use type Edgedb\Message\Type\CharType;
use type Edgedb\Message\Type\BytesType;
use type Edgedb\Message\Type\VectorType;
use type Edgedb\Message\DescribeAspectEnum;

class DescribeStatementStruct extends AbstractStruct
{
    public function __construct(
        vec<HeaderStruct> $headers,
        DescribeAspectEnum $aspect,
        string $statementName = ''
    ) {
        parent::__construct(darray[
            'headers' => new VectorType<HeaderStruct>($headers),
            'describe_aspect' => new CharType($aspect),
            'statement_name' => new BytesType($statementName)
        ]);
    }
}