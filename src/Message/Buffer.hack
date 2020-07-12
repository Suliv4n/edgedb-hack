namespace Edgedb\Message;

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

    public function __toString(): string {
        $string = '<Buffer ';
        
        $hexa = vec[];
        for ($i = 0; $i < Str\length($this->bytes); $i++) {
            $hexa[] = \ord($this->bytes[$i]) 
                |> \dechex($$) 
                |> \str_pad($$, 2, '0', \STR_PAD_LEFT);
        }
        
        $string .= \implode(' ', $hexa) . '>';
        
        return $string;
    }
}