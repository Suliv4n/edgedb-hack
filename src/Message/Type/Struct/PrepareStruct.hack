namespace Edgedb\Message\Type\Struct;

use type Edgedb\Message\Type\VectorType;
use type Edgedb\Message\Type\StringType;
use type Edgedb\Message\Type\BytesType;
use type Edgedb\Message\Type\CharType;
use type Edgedb\Message\IOFormatEnum;
use type Edgedb\Message\CardinalityEnum;

class PrepareStruct extends AbstractStruct
{
    public function __construct(
        vec<HeaderStruct> $headers,
        IOFormatEnum $ioFormat,
        CardinalityEnum $cardinality,
        string $statementName,
        string $command
    ){
        parent::__construct(darray[
            'headers' => new VectorType($headers),
            'io_format' => new CharType($ioFormat),
            'expected_cardinality' => new CharType($cardinality),
            'statement_name' => new BytesType($statementName),
            'command' => new StringType($command)
        ]);
    }
}