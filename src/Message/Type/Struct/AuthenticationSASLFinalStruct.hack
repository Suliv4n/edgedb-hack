namespace Edgedb\Message\Type\Struct;

use type Edgedb\Message\Type\BytesType;
use type Edgedb\Authentication\AuthenticationStatusEnum;
use type Edgedb\Message\Buffer;

class AuthenticationSASLFinalStruct extends AuthenticationStruct
{
    public function __construct(
        private string $saslData
    ) {
        parent::__construct(AuthenticationStatusEnum::AUTH_SASL_FINAL);
        $this->set('sasl_data', $saslData);
    }

    public function getSaslData(): string {
        return $this->saslData;
    }

    public static function read(Buffer $buffer): AuthenticationSASLFinalStruct
    {
        $saslData = BytesType::read($buffer)->getValue();
        return new self($saslData);
    }
}