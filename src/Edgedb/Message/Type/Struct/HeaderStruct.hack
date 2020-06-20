namespace Edgedb\Message\Type\Struct;

use type Edgedb\Message\Buffer;
use type Edgedb\Message\Readable;
use type Edgedb\Message\Type\BytesType;
use type Edgedb\Message\Type\Int16Type;

class HeaderStruct extends AbstractStruct implements Readable
{
    public function __construct(int $key, string $value)
    {
        parent::__construct(darray[
            "key" => new Int16Type($key),
            "value" => new BytesType($value)
        ]);
    }

    public static function read(Buffer $buffer): HeaderStruct
    {
        $key = Int16Type::read($buffer)->getValue();
        $name = BytesType::read($buffer)->getValue();

        return new self($key, $name);
    }
}