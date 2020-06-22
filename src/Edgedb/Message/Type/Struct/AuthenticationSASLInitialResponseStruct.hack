namespace Edgedb\Message\Type\Struct;

use type Edgedb\Message\Type\StringType;

class AuthenticationSASLInitialResponseStruct extends AbstractStruct
{
    public function __construct(
        string $method,
        string $saslData
    ) {
        parent::__construct(darray[
            'method' => new StringType($method),
            'sasl_data' => new StringType($saslData)
        ]);
    }
}