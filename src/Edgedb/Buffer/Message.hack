namespace Edgedb\Buffer;

use namespace HH\Lib\Str;

class Message
{
    public function __construct(
        private string $message
    ){}

    public function getLength(): int
    {
        $extractedLength = Str\slice($this->message, 1, 4);
        $length = \unpack('N', $extractedLength)[1];

        return $length;
    }

    public function getPayload(): string
    {
        $payload = Str\slice($this->message, 5);
        $expectedMessageLength = $this->getLength();
        $payloadLength = Str\length($payload);

        if ($payloadLength != $expectedMessageLength - 4) {
            throw new BufferException(
                "Length message is {$expectedMessageLength} bytes but {$payloadLength} bytes found."
            );
        }

        return Str\slice($this->message, 5, $payloadLength);
    }

    public function getType(): string
    {
        return $this->message[0];
    }
}