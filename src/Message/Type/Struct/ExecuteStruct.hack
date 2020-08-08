namespace Edgedb\Message\Type\Struct;

use type Edgedb\Message\Type\VectorType;
use type Edgedb\Message\Type\StringType;
use type Edgedb\Message\Type\BytesType;

class ExecuteStruct extends AbstractStruct
{
    public function __construct(
        vec<HeaderStruct> $headers,
        string $statementName,
        string $encodedArguments
    ){
        parent::__construct(darray[
            'headers' => new VectorType($headers),
            'statement_name' => new BytesType($statementName),
            'arguments' => new BytesType($encodedArguments)
        ]);
    }
}