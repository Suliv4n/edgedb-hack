namespace Edgedb\Message\Type\Struct;

use type Edgedb\Message\Buffer;
use type Edgedb\Message\Readable;
use type Edgedb\Message\Type\VectorType;
use type Edgedb\Message\Type\UInt16Type;
use type Edgedb\Message\Type\BytesType;

class DataStruct extends AbstractStruct implements Readable
{
    public function __construct(
        private vec<string> $data
    ) {
        parent::__construct(
            darray[
                'data' => VectorType::bytesVectorFromStrings($data)
            ]
        );
    }

    public function getEncodedData(): vec<string> {
        return $this->data;
    }

    public static function read(Buffer $buffer): DataStruct
    {
        $elementsCount = UInt16Type::read($buffer)->getValue();

        $data = vec[];
        for ($i = 0; $i < $elementsCount; $i++) {
            $data[] = BytesType::read($buffer)->getValue();
        }

        return new self($data);
    }
}