namespace Edgedb\Message\Type;

class Int32Type extends AbstractType<int>
{
    public function write(): string
    {
        $bytes = \pack('N', $this->getValue());
        return $bytes;
    }
}