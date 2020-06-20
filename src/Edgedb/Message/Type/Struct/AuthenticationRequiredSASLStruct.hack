namespace Edgedb\Message\Type\Struct;

use type Edgedb\Message\Buffer;
use type Edgedb\Message\Readable;
use type Edgedb\Message\Type\Int32Type;
use type Edgedb\Message\Type\VectorType;
use type Edgedb\Message\Type\StringType;

class AuthenticationRequiredSASLStruct extends AbstractStruct implements Readable
{
        public function __construct(
            private int $authenticationStatus,
            private vec<string> $methods
        ) {
            parent::__construct(darray[
                'auth_status' => new Int32Type($authenticationStatus),
                'methods' => VectorType::fromStringVector($methods, true)
            ]);
        }

        public function getMethods(): vec<string>
        {
            return $this->methods;
        }

        public function getAuthenticationStatus(): int
        {
            return $this->authenticationStatus;
        }

        public static function read(Buffer $buffer): AuthenticationRequiredSASLStruct
        {
            $authenticationStatus = Int32Type::read($buffer)->getValue();
            $methodsCount = Int32Type::read($buffer)->getValue();

            $methods = vec[];
            for ($i = 0; $i < $methodsCount; $i++) {
                $methods[] = StringType::read($buffer)->getValue();
            }

            return new self($authenticationStatus, $methods);
        }
}