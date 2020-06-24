namespace Edgedb\Message\Type\Struct;

use type Edgedb\Message\Type\StringType;
use type Edgedb\Message\Type\BytesType;

class AuthenticationSASLResponseStruct extends AbstractStruct
{
    public function __construct(string $saslData) {
        parent::__construct(darray[
            'sasl_data' => new BytesType($saslData)
        ]);
    }
}