namespace Edgedb\Message\Type;

use type Edgedb\Message\Buffer;
use type Edgedb\Message\Readable;
use type Edgedb\Message\Type\StringType;
use type Edgedb\Message\Type\UInt8Type;
use type Edgedb\Message\Type\UInt16Type;
use type Edgedb\Message\Type\Struct\HeaderStruct;

use namespace HH\Lib\Str;
use namespace HH\Lib\C;
use namespace HH\Lib\Vec;

class UnprefixedVectorType<T as AbstractType<mixed>> extends AbstractType<vec<T>>
{
    public function __construct(
        vec<T> $value
    ) {
        parent::__construct($value);
    }

    public function write(): string
    {
        $buffer = '';

        foreach ($this->getValue() as $value) {
            $buffer .= $value->write();
        }

        return $buffer;
    }

    public function getLength(): int
    {
        $length = 0;

        foreach ($this->getValue() as $element) {
            $length += $element->getLength();
        }

        return $length;
    }


    public static function fromUInt16Vector(vec<int> $integers): UnprefixedVectorType<UInt16Type>
    {
        $wrappedIntegers = vec[];

        foreach ($integers as $interger) {
            $wrappedIntegers[] = new UInt16Type($interger);
        }

        return new self<UInt16Type>($wrappedIntegers);
    }
}