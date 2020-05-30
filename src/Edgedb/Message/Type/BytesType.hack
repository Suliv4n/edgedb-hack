namespace Edgedb\Message\Type;

use namespace HH\Lib\Str;

class BytesType extends AbstractType<string>
{
    public function write(): string
    {
        $length = Str\length($this->getValue());
        $length = new Int32Type($length);
        
        return $length->write() . $this->getValue();
    }
}