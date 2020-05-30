namespace Edgedb\Message\Type;

class Int16Type extends AbstractType<int>
{
    public function write(): string
    {
        $bytes = \pack('n', $this->getValue());
        return $bytes;
    }
}