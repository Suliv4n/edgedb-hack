namespace Edgedb\Buffer;

use namespace HH\Lib\Str;

class WriteBuffer {

    private int $position = 0;
    private string $buffer = '';
    private int $allocatedSize = 0;

    /**
     * Begin an edgedb message.
     * 
     * @param string Char representating type of message. 
     */
    public function beginMessage(string $charType): this 
    {
        if ($this->position > 0)
        {
            throw new BufferException(
                'Cannot begin a new message: the previous message is not finished.'
            );
        }

        $this->writeChar($charType);

        return $this;
    }

    /**
     * Write a character in the buffer.
     * 
     * @param string $char The char to write.
     * 
     * @return self The current buffer instance.
     */
    public function writeChar(string $char): this
    {
        $byte = \pack('C', \ord($char));
        $this->write($byte);
        return $this;
    }

    /**
     * Write string in the buffer.
     * 
     * @param string $string The string to write.
     * 
     * @return self The current buffer instance.
     */
    public function writeString(string $string): this
    {
        $this->writeInt32BE(Str\length(\utf8_encode($string)));
        $this->write(\utf8_encode($string));
        return $this;
    }

    /**
     * Write an unsigned 16 bits integer big endian.
     * 
     * @param int $short Integer to write.
     * 
     * @return self The current buffer instance.
     */
    public function writeInt16BE(int $short): this
    {
        $bytes = \pack('n', $short);
        $this->write($bytes);
        return $this;
    }

    /**
     * Write an unsigned 32 bites integer big endian.
     * 
     * @param int $long integer to write.
     * 
     * @return self The current buffer instance.
     */
    public function writeInt32BE(int $long): this 
    {
        $bytes = \pack('N', $long);
        $this->write($bytes);
        return $this;
    }

    /**
     * Get the string buffer.
     * 
     * @return string The string buffer.
     */
    public function getBuffer(): string {
        return $this->buffer;
    }

    /**
     * End the buffered message.
     * 
     * @return self The current buffer instance.
     */
    public function endMessage(): this {

        $this->position = 1;
        $this->writeInt32BE($this->getMessageLength() - 1);
        return $this;
    }

    private function getMessageLength(): int {
        return Str\length($this->buffer) + 4;
    } 

    /**
     * Write bytes in the buffer on the current buffer position.
     * 
     * @param string $bytes Bytes to write.
     */
    private function write(string $bytes): void
    {
        $this->buffer = 
            Str\slice($this->buffer, 0, $this->position)
            . $bytes
            . Str\slice($this->buffer, $this->position);

        $this->position += Str\length($bytes);
    }
}