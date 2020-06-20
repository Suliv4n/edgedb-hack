namespace Edgedb;

use type Edgedb\Buffer\WriteBuffer;
use type Edgedb\Buffer\Message;
use type Edgedb\Message\Reader;
use type Edgedb\Protocol\Version;
use type Edgedb\Message\Type\Struct\ClientHandshakeStruct;
use type Edgedb\Message\Type\Struct\ParamStruct;
use type Edgedb\Message\Client\ClientHandshakeMessage;
use type Edgedb\Message\Server\ServerHandshakeMessage;
use type Edgedb\Message\Buffer;

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
        $version = new Version(1, 0);

        
        $handshakeMessage = new ClientHandshakeMessage(
            new ClientHandshakeStruct(
                new Version(1, 0),
                vec[
                    new ParamStruct("user", $this->username),
                    new ParamStruct("database", $this->database),
                ],
                vec[]
            )
        );

        $handshake = $handshakeMessage->write();

        $this->send($handshake);

        $bytes = '';
        \socket_recv($this->socket, inout $bytes, 2048, 0);
        $buffer = new Buffer($bytes);

        $serverResponse = ServerHandshakeMessage::read($buffer);
        \var_dump($serverResponse);

        \socket_close($this->socket);
    }

    private function send(string $bytes): void {
        \socket_send($this->socket, $bytes, \strlen($bytes), 0);
    }
}