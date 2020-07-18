namespace Edgedb\Message\Type\Struct;

use type Edgedb\Message\Buffer;
use type Edgedb\Message\Readable;
use type Edgedb\Message\Type\UInt16Type;
use type Edgedb\Message\Type\UInt32Type;
use type Edgedb\Message\Type\UInt8Type;
use type Edgedb\Message\Type\StringType;
use type Edgedb\Message\Type\VectorType;
use type Edgedb\Protocol\Error;
use type Edgedb\Protocol\ErrorSeverityEnum;

class ErrorStruct extends AbstractStruct implements Readable
{
    public function __construct(
        private Error $error
    ) {
        parent::__construct(darray[
            'severity' => new UInt8Type($error->getSeverity()),
            'error_code' => new UInt32Type($error->getCode()),
            'message' => new StringType($error->getMessage()),
            'attributes' => VectorType::fromMapToHeaders($error->getAttributes())
        ]);
    }

    public function getError(): Error
    {
        return $this->error;
    }

    public static function read(Buffer $buffer): ErrorStruct
    {
        $severity = UInt8Type::read($buffer)->getValue()
            |> ErrorSeverityEnum::assert($$);
        
        $code = UInt32Type::read($buffer)->getValue();

        $message = StringType::read($buffer)->getValue();

        $attributesCount = UInt16Type::read($buffer)->getValue();

        $attributes = darray[];
        for ($i = 0; $i < $attributesCount; $i++) {
            $header = HeaderStruct::read($buffer);
            $attributes[$header->getKey()] = $header->getHeaderValue();
        }

        $error = new Error(
            $code,
            $severity,
            $message,
            $attributes
        );

        return new self($error);
    }
}