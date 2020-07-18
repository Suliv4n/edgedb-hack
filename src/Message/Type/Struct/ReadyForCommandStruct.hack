namespace Edgedb\Message\Type\Struct;

use type Edgedb\Message\Buffer;
use type Edgedb\Message\Readable;
use type Edgedb\Message\Type\CharType;
use type Edgedb\Message\Type\UInt16Type;
use type Edgedb\Message\Type\VectorType;
use type Edgedb\TransactionTypeEnum;

class ReadyForCommandStruct extends AbstractStruct implements Readable
{
    public function __construct(
        private vec<HeaderStruct> $headers,
        private TransactionTypeEnum $transactionState
    ){
        parent::__construct(darray[
            'headers' => new VectorType<HeaderStruct>($headers),
            'transaction_state' => new CharType($transactionState)
        ]);
    }

    public function getHeaders(): vec<HeaderStruct>
    {
        return $this->headers;
    }

    public function getTransactionState(): TransactionTypeEnum
    {
        return $this->transactionState;
    }

    public static function read(Buffer $buffer): ReadyForCommandStruct
    {
        $headersCount = UInt16Type::read($buffer)->getValue();
        $headers = vec[];
        for ($i = 0; $i < $headersCount; $i++) {
            $headers[] = HeaderStruct::read($buffer);
        }

        $transactionState = CharType::read($buffer)->getValue()
            |> TransactionTypeEnum::assert($$);

        return new self($headers, $transactionState);
    }
}