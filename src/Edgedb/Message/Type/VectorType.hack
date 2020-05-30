namespace Edgedb\Message\Type;

use namespace HH\Lib\Str;
use namespace HH\Lib\C;

class VectorType<T as AbstractType<mixed>> extends AbstractType<vec<T>>
{
    public function write(): string
    {
        $buffer = "";
        $count = C\count($this->getValue());
        
        $buffer = (new Int16Type($count))->write();
        foreach ($this->getValue() as $value) {
            $buffer .= $value->write();
        }

        return $buffer;
    }
}