namespace Edgedb\Message\Type;


abstract class AbstractType<+T>
{
    public function __construct(
        private T $value
    ) {}

    public function getValue(): T
    {
        return $this->value;
    }


    abstract public function write(): string;
}