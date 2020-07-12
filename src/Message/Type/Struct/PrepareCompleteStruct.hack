namespace Edgedb\Message\Type\Struct;

use type Edgedb\Message\Buffer;
use type Edgedb\Message\Readable;
use type Edgedb\Message\CardinalityEnum;
use type Edgedb\Message\Type\CharType;
use type Edgedb\Message\Type\VectorType;
use type Edgedb\Message\Type\UuidType;
use type Edgedb\Message\Type\Int16Type;

class PrepareCompleteStruct extends AbstractStruct implements Readable
{
    public function __construct(
        private vec<HeaderStruct> $headers,
        private CardinalityEnum $cardinality,
        private string $inputTypedescId,
        private string $outputTypedescId
    ){
        parent::__construct(darray[
            'headers' => new VectorType($headers),
            'cardinality' => new CharType($cardinality),
            'input_typedesc_id' => new UuidType($inputTypedescId),
            'input_typedesc_id' => new UuidType($outputTypedescId),
        ]);
    }

    public static function read(Buffer $buffer): PrepareCompleteStruct
    {
        $headersCount = Int16Type::read($buffer)->getValue();
        $headers = vec[];
        for ($i = 0; $i < $headersCount; $i++) {
            $headers[] = HeaderStruct::read($buffer);
        }

        $cardinality = CharType::read($buffer)->getValue()
            |> CardinalityEnum::assert($$);

        $inputTypedescId = UuidType::read($buffer)->getValue();
        $outputTypedescId = UuidType::read($buffer)->getValue();

        return new self(
            $headers,
            $cardinality,
            $inputTypedescId,
            $outputTypedescId
        );
    }
}