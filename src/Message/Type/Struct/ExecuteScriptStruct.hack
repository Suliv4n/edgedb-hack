namespace Edgedb\Message\Type\Struct;

use type Edgedb\Message\Type\VectorType;
use type Edgedb\Message\Type\StringType;

class ExecuteScriptStruct extends AbstractStruct
{
    public function __construct(
        vec<HeaderStruct> $headers,
        string $query
    ){
        parent::__construct(darray[
            'headers' => new VectorType($headers),
            'query' => new StringType($query)
        ]);
    }
}