namespace Edgedb\Message\Type\Struct;

use type Edgedb\Message\Type\VectorType;
use type Edgedb\Message\Type\StringType;
use type Edgedb\Message\Type\BytesType;
use type Edgedb\Message\Type\CharType;
use type Edgedb\Message\IOFormatEnum;
use type Edgedb\Message\CardinalityEnum;

class ExecuteStruct extends AbstractStruct
{
    public function __construct(
        vec<HeaderStruct> $headers,
    ){
        parent::__construct(darray[
            'headers' => new VectorType($headers),
        ]);
    }
}