namespace Edgedb\Message\Type\Struct;

use type Edgedb\Message\Buffer;
use type Edgedb\Message\Readable;
use type Edgedb\Message\Type\StringType;
use type Edgedb\Message\Type\Int16Type;
use type Edgedb\Message\Type\VectorType;

class ProtocolExtStruct extends AbstractStruct implements Readable
{
    public function __construct(
        string $name,
        vec<HeaderStruct> $headers
    ) {
        parent::__construct(darray[
            'extension_name' => new StringType($name),
            'headers' => new VectorType<HeaderStruct>($headers)
        ]);
    }

    public static function read(Buffer $buffer): ProtocolExtStruct
    {
        $name = StringType::read($buffer)->getValue();
        
        $headersCount = Int16Type::read($buffer)->getValue();

        $headers = vec[];
        for ($i = 0; $i < $headersCount; $i++) {
            $headers[] = HeaderStruct::read($buffer);
        }

        return new self($name, $headers);
    }
}