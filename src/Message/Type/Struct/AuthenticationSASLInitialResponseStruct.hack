namespace Edgedb\Message\Type\Struct;

use type Edgedb\Message\Type\StringType;
use type Edgedb\Message\Type\BytesType;

class AuthenticationSASLInitialResponseStruct extends AbstractStruct
{
    public function __construct(
        string $method,
        string $saslData
    ) {
        parent::__construct(darray[
            'method' => new StringType($method),
            'sasl_data' => new BytesType($saslData)
        ]);
    }
}