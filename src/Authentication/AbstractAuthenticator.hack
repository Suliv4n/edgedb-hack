namespace Edgedb\Authentication;

use type Edgedb\Socket;
use type Edgedb\Message\Reader;

abstract class AbstractAuthenticator
{
    <<__LateInit>>
    protected Socket $socket;

    <<__LateInit>>
    protected Reader $reader;

    abstract public function authenticate(string $username, ?string $password): void;
    
    final public function setSocket(Socket $socket): void
    {
        $this->socket = $socket;
    }

    final public function setReader(Reader $reader): void
    {
        $this->reader = $reader;
    }
}