namespace Edgedb\Message\Type\Struct;

use type Edgedb\Message\Buffer;
use type Edgedb\Message\Readable;
use type Edgedb\Message\Type\UInt32Type;
use type Edgedb\Message\Type\VectorType;
use type Edgedb\Message\Type\StringType;
use type Edgedb\Authentication\AuthenticationStatusEnum;

abstract class AuthenticationStruct extends AbstractStruct implements Readable
{
        public function __construct(
            private AuthenticationStatusEnum $authenticationStatus,
        ) {
            parent::__construct(darray[
                'auth_status' => new UInt32Type($authenticationStatus)
            ]);
        }

        public function getAuthenticationStatus(): int
        {
            return $this->authenticationStatus;
        }

        public static function read(Buffer $buffer): AuthenticationStruct
        {
            $authenticationStatus = UInt32Type::read($buffer)->getValue()
                |> AuthenticationStatusEnum::assert($$);

            switch ($authenticationStatus) {
                case AuthenticationStatusEnum::AUTH_SASL:
                    return AuthenticationRequiredSASLStruct::read($buffer);
                case AuthenticationStatusEnum::AUTH_SASL_CONTINUE:
                    return AuthenticationSASLContinueStruct::read($buffer);
                case AuthenticationStatusEnum::AUTH_SASL_FINAL:
                    return AuthenticationSASLFinalStruct::read($buffer);
                default:
                    throw new \Exception("Not yet implemented : " . AuthenticationStatusEnum::getNames()[$authenticationStatus]);
            }
        }
}