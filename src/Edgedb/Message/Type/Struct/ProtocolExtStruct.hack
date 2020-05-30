namespace Edgedb\Message\Type\Struct;

use type Edgedb\Message\Type\VectorType;
use type Edgedb\Message\Type\StringType;
use type Edgedb\Message\Type\Struct\HeaderStruct;

class ProtocolExtStruct extends AbstractStruct
{
    public function __construct(
        string $name,
        vec<HeaderStruct> $headers
    ) {
        parent::__construct(darray[
            "extension_name" => new StringType($name),
            "headers" => new VectorType<HeaderStruct>($headers)
        ]);
    }
}