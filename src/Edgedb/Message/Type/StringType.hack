namespace Edgedb\Message\Type;

use namespace HH\Lib\Str;

class StringType extends AbstractType<string>
{
    public function write(): string
    {
        $utf8Value = \utf8_encode($this->getValue());
        $length = Str\length($utf8Value);
        
        $length = new Int32Type($length);
        
        return $length->write() . $utf8Value;
    }
}