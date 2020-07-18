namespace Edgedb\Message\Type\Struct;

use type Edgedb\Message\Buffer;
use type Edgedb\Message\Readable;
use type Edgedb\Message\Type\StringType;
use type Edgedb\Message\Type\UInt16Type;
use type Edgedb\Message\Type\VectorType;

class CommandCompleteStruct extends AbstractStruct implements Readable
{
    public function __construct(
        private vec<HeaderStruct> $headers,
        private string $status
    ){
        parent::__construct(darray[
            'headers' => new VectorType<HeaderStruct>($headers),
            'string' => new StringType($status)
        ]);
    }

    public function getHeaders(): vec<HeaderStruct>
    {
        return $this->headers;
    }

    public function getStatus(): string
    {
        return $this->status;
    }

    public static function read(Buffer $buffer): CommandCompleteStruct
    {
        $headersCount = UInt16Type::read($buffer)->getValue();
        $headers = vec[];
        for ($i = 0; $i < $headersCount; $i++) {
            $headers[] = HeaderStruct::read($buffer);
        }

        $status = StringType::read($buffer)->getValue();

        return new self($headers, $status);
    }
}