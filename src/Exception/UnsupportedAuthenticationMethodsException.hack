namespace Edgedb\Exception;

use type Exception;

use namespace HH\Lib\Str;

class UnsupportedAuthenticationMethodsException extends Exception
{
    public function __construct(
        vec<string> $methods
    ) {
        parent::__construct(
            Str\format(
                'The server offered the following SASL authentication %s'
                . 'methods, neither are supported.',
                Str\join($methods, ', ')
            )
        );
    }
}