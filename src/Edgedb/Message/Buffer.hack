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
}