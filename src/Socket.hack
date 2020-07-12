namespace Edgedb;

use type Edgedb\Message\AbstractMessage;
use type Edgedb\Message\Type\Struct\AbstractStruct;
use type Edgedb\Exception\ConnectionFailedException;
use type Edgedb\Message\Buffer;

use function stream_socket_client;
use function socket_send;
use function socket_close;
use function socket_recv;

use namespace HH\Lib\Str;

class Socket
{
    private resource $socket;

    public function __construct(
        private string $host,
        private int $port
    ) {
        $socketAddress = Str\format('%s:%d', $this->host, $this->port);
        $errorNumber = 0;
        $errorString = '';

        $this->socket = stream_socket_client(
            $socketAddress,
            inout $errorString,
            inout $errorString
        );

        if ($errorNumber !== 0) {
            throw new ConnectionFailedException($socketAddress, $errorNumber, $errorString);
        }
    }

    public function sendMessage<T as AbstractStruct>(AbstractMessage<T> ...$messages): void
    {
        $bytes = '';
        foreach ($messages as $message) {
            $bytes .= $message->write();
        }

        socket_send($this->socket, $bytes, Str\length($bytes), 0);
    }

    public function receive(): Buffer
    {
        $bytes = '';
        socket_recv($this->socket, inout $bytes, 2048, 0);

        return new Buffer($bytes);
    }

    public function close(): void
    {
        socket_close($this->socket);
    }
}