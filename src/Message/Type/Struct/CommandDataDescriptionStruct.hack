namespace Edgedb\Message\Type\Struct;

use type Edgedb\Message\Buffer;
use type Edgedb\Message\Readable;
use type Edgedb\Message\CardinalityEnum;
use type Edgedb\Message\Type\CharType;
use type Edgedb\Message\Type\UInt16Type;
use type Edgedb\Message\Type\VectorType;
use type Edgedb\Message\Type\UuidType;
use type Edgedb\Message\Type\BytesType;

class CommandDataDescriptionStruct extends AbstractStruct implements Readable
{
    public function __construct(
        private vec<HeaderStruct> $headers,
        private CardinalityEnum $cardinality,
        private string $inputTypedescId,
        private string $inputTypedesc,
        private string $outputTypedescId,
        private string $outputTypedesc
    ){
        parent::__construct(darray[
            'headers' => new VectorType<HeaderStruct>($headers),
            'cardinality' => new CharType($cardinality),
            'input_typedesc_id' => new UuidType($inputTypedescId),
            'input_typedesc' => new BytesType($inputTypedesc),
            'output_typedesc_id' => new UuidType($outputTypedescId),
            'output_typedesc' => new BytesType($outputTypedesc)
        ]);
    }

    public function getInputTypeDescId(): string
    {
        return $this->inputTypedescId;
    }

    public function getInputTypeDesc(): string
    {
        return $this->inputTypedesc;
    }

    public function getOutputTypeDescId(): string
    {
        return $this->outputTypedescId;
    }

    public function getOutputTypeDesc(): string
    {
        return $this->outputTypedesc;
    }

    public static function read(Buffer $buffer): CommandDataDescriptionStruct
    {
        $headersCount = UInt16Type::read($buffer)->getValue();
        $headers = vec[];
        for ($i = 0; $i < $headersCount; $i++) {
            $headers[] = HeaderStruct::read($buffer);
        }

        $cardinality = CharType::read($buffer)->getValue()
            |> CardinalityEnum::assert($$);

        $inputTypedescId = UuidType::read($buffer)->getValue();
        $inputTypeDesc = BytesType::read($buffer)->getValue();
        
        $outputTypedescId = UuidType::read($buffer)->getValue();
        $outputTypedesc = BytesType::read($buffer)->getValue();

        return new self(
            $headers, 
            $cardinality,
            $inputTypedescId,
            $inputTypeDesc,
            $outputTypedescId,
            $outputTypedesc
        );
    }
}