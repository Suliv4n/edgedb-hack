namespace Edgedb\Message\Type\Struct;

use type Edgedb\Message\Type\Int16Type;
use type Edgedb\Message\Type\BytesType;

class HeaderStruct extends AbstractStruct
{
    public function __construct(int $key, string $value)
    {
        parent::__construct(darray[
            "key" => new Int16Type($key),
            "value" => new BytesType($value)
        ]);
    }
}