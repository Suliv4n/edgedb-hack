namespace Edgedb\Exception;

use type Exception;

class MalformedScramException extends Exception
{
    public function __construct(string $scramMessage)
    {
        parent::__construct('Malformed scram message : ' . $scramMessage);
    }
}