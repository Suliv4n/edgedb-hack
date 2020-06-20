namespace Edgedb;

use type Exception;
use type Edgedb\Protocol\Version;

use namespace HH\Lib\Str;

class UnsupportedVersionException extends Exception
{
    public function __construct(
        Version $clientVersion, 
        Version $serverVersion
    ) {
        parent::__construct(
            Str\format(
                'The server requested an unsupported version of the protocol %s.'
                . 'Client protocol version is %s',
                \strval($serverVersion),
                \strval($clientVersion)
            )
        );
    }
}