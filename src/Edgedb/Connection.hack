namespace Edgedb;

use type Edgedb\Buffer\WriteBuffer;

use namespace HH\Lib\Str;
use namespace HH\Lib\Vec;

class Connection
{
    <<__LateInit>>
    private resource $socket;

    public function __construct(
        private string $host,
        private int $port,
        private string $database,
        private string $username,
        private ?string $password = null
    )
    {}

    public function connect(): void 
    {
        $socketAddress = Str\format('%s:%d', $this->host, $this->port);
        $errorNumber = 0;
        $errorString = '';
        $this->socket = \stream_socket_client($socketAddress, inout $errorNumber, inout $errorString);

        if ($errorNumber !== 0)
        {
            throw new ConnectionException(
                Str\format(
                    'Fail to connect to edgedb server at %s : %s',
                    $socketAddress,
                    $errorString
                )
            );
        }
        
        $this->handshake();
    }

    private function handshake(): void 
    {
        echo "Handshake edgedb\n";

        $buffer = new WriteBuffer();

        $buffer
            ->beginMessage('V') //Message type
            ->writeInt16BE(1) //Protocol major version
            ->writeInt16BE(0) //Protocol minor version
            ->writeInt16BE(2) //Number of parameters
            ->writeString('user')
            ->writeString($this->username)
            ->writeString('database')
            ->writeString($this->database)
            ->writeInt16BE(0) //Number of protocol extensions 
            ->endMessage();

        $handshake = $buffer->getBuffer();
        $this->send($handshake);

        $buff = '';
        \socket_recv($this->socket, inout $buff, 2048, 0);
        \var_dump($buff);
    }

    private function send(string $bytes): void {
        echo "Send to server :\n";
        \var_dump($bytes);
        \var_dump(Vec\map(Str\split($bytes, ''), $byte ==> \ord($byte)) );
        \socket_send($this->socket, $bytes, \strlen($bytes), 0);
    }
}