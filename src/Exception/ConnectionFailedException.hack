namespace Edgedb\Exception;

use type Exception;

use namespace HH\Lib\Str;

class ConnectionFailedException extends Exception
{
    public function __construct(
        string $host,
        int $errorNumber,
        string $message
    ) {
        parent::__construct(
            Str\format(
                'Could not connect to %s due to error "%s" (error %d).',
                $host,
                $message,
                $errorNumber
            )
        );
    }
}