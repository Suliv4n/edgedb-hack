
namespace Edgedb\Message\Type\Struct;

use type Edgedb\Authentication\AuthenticationStatusEnum;
use type Edgedb\Message\Buffer;
use type Edgedb\Message\Type\UInt32Type;
use type Edgedb\Message\Type\StringType;

class AuthenticationRequiredSASLStruct extends AuthenticationStruct
{
    public function __construct(
        private vec<string> $methods
    ) {
        parent::__construct(AuthenticationStatusEnum::AUTH_SASL);
        $this->set('methods', $methods);
    }

    public function getMethods(): vec<string>
    {
        return $this->methods;
    }
    
    public static function read(Buffer $buffer): AuthenticationRequiredSASLStruct
    {
        $methodsCount = UInt32Type::read($buffer)->getValue();

        $methods = vec[];
        for ($i = 0; $i < $methodsCount; $i++) {
            $methods[] = StringType::read($buffer)->getValue();
        }

        return new self($methods);
    }
}