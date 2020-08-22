namespace Edgedb\Message;

use type Exception;

use function hexdec;
use function chr;

use namespace HH\Lib\Str;

class Buffer
{
    private int $cursor = 0;

    public function __construct(
        private string $bytes
    ) {}

    public function read(int $length): string 
    {
        $extract = Str\slice($this->bytes, $this->cursor, $length);
        $this->cursor += $length;

        return $extract;
    }

    public function readUntilEnd(): string
    {
        $extract = Str\slice($this->bytes, $this->cursor);
        $this->cursor = Str\length($this->bytes);

        return $extract;
    }

    public function setCursor(int $cursor): void
    {
        $this->cursor = $cursor;
    }

    public function sliceFromCursor(): void
    {
        $this->bytes = Str\slice($this->bytes, $this->cursor);
        $this->cursor = 0;
    }

    public function isConsumed(): bool
    {
        return $this->cursor === Str\length($this->bytes);
    }

    public function discard(int $length): void
    {
        if ($this->cursor + $length > Str\length($this->bytes)) {
            throw new Exception("Buffer overread");
        }

        $this->cursor += $length;
    }

    public function getCursor(): int
    {
        return $this->cursor;
    }

    public function extractFromCursor(int $length): Buffer
    {
        $extract = "";

        for ($i = $this->cursor; $i < $this->cursor + $length; $i++) {
            $extract .= $this->bytes[$i];
        }

        $this->cursor += $length;

        return new Buffer($extract);
    }

    public static function fromBase16(string $hex): Buffer
    {
        $bytesHex = $hex 
            |> Str\replace($$, ' ', '')
            |> Str\chunk($$, 2);

        $bytes = '';
        foreach ($bytesHex as $byteHex) {
            $bytes .= $byteHex
                |> hexdec($$)
                |> chr($$);
        }

        return new self($bytes);
    }

    public function toBase16(): string
    {
        $hexa = '';
        for ($i = 0; $i < Str\length($this->bytes); $i++) {
            $hexa .= \ord($this->bytes[$i]) 
                |> \dechex($$) 
                |> \str_pad($$, 2, '0', \STR_PAD_LEFT);
        }

        return $hexa;
    }
}