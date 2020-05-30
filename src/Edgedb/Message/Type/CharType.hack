namespace Edgedb\Message\Type;

class CharType extends AbstractType<string>
{
    public function write(): string
    {
        $char = $this->getValue()[0];

        return \pack('C', \ord($char));
    }
}