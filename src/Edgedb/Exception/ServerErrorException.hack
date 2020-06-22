namespace Edgedb\Exception;

use type Exception;
use type Edgedb\Protocol\Error;
use type Edgedb\Protocol\ErrorSeverityEnum;

use namespace HH\Lib\Str;

class ServerErrorException extends Exception
{
    public function __construct(Error $error) {
        parent::__construct(
            Str\format(
                'Server respond with error : %s (code %d, severity %s)',
                $error->getMessage(),
                $error->getCode(),
                ErrorSeverityEnum::getNames()[$error->getSeverity()]
            )
        );
    }
}