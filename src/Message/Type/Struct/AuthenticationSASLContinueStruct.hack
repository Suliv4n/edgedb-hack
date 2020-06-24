namespace Edgedb\Message\Type\Struct;

use type Edgedb\Message\Type\BytesType;
use type Edgedb\Authentication\AuthenticationStatusEnum;
use type Edgedb\Message\Buffer;

class AuthenticationSASLContinueStruct extends AuthenticationStruct
{
    public function __construct(
        private string $saslData
    ) {
        parent::__construct(AuthenticationStatusEnum::AUTH_SASL_CONTINUE);
        $this->set('sasl_data', $saslData);
    }

    public function getSaslData(): string {
        return $this->saslData;
    }

    public static function read(Buffer $buffer): AuthenticationSASLContinueStruct
    {
        $saslData = BytesType::read($buffer)->getValue();
        return new self($saslData);
    }
}