namespace Edgedb\Message\Type\Struct;

use type Edgedb\Message\Type\AbstractType;

abstract class AbstractStruct extends AbstractType<darray<string, AbstractType<mixed>>>
{
    public function write(): string
    {
        $buffer = '';
        foreach ($this->getValue() as $name => $type) {
            $buffer .= $type->write();
        }

        return $buffer;
    }

    public function set<T>(string $name, T $newValue): void
    {
        $value = $this->getValue();
        $value[$name] = $newValue;
    }

    public function getLength(): int
    {
        $length = 0;
        foreach ($this->getValue() as $element) {
            $length += $element->getLength();
        }

        return $length;
    }
}