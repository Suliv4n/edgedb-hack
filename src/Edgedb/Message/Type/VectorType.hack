namespace Edgedb\Message\Type;

use type Edgedb\Message\Buffer;
use type Edgedb\Message\Readable;
use type Edgedb\Message\Type\StringType;
use type Edgedb\Message\Type\Struct\HeaderStruct;

use namespace HH\Lib\Str;
use namespace HH\Lib\C;
use namespace HH\Lib\Vec;

class VectorType<T as AbstractType<mixed>> extends AbstractType<vec<T>>
{
    public function __construct(
        vec<T> $value,
        private bool $useLongIntForCount = false
    ) {
        parent::__construct($value);
    }

    public function write(): string
    {
        $buffer = '';
        $count = C\count($this->getValue());
        
        if ($this->useLongIntForCount) {
            $buffer = (new Int32Type($count))->write();
        } else {
            $buffer = (new Int16Type($count))->write();
        }

        foreach ($this->getValue() as $value) {
            $buffer .= $value->write();
        }

        return $buffer;
    }

    public function getLength(): int
    {
        $length = 2;
        foreach ($this->getValue() as $element)
        {
            $length += $element->getLength();
        }

        return $length;
    }

    public static function fromStringVector(
        vec<string> $strings,
        bool $useLongIntForCount = false
    ): VectorType<StringType> {
        $wrappedString = Vec\map<string, StringType>($strings, ($string) ==> new StringType($string));
        return new VectorType($wrappedString, $useLongIntForCount);
    }

    public static function fromMapToHeaders(
        darray<int, string> $map
    ): VectorType<HeaderStruct> {
        $headers = vec[];
        foreach ($map as $key => $value) {
            $headers[] = new HeaderStruct($key, $value);
        }

        return new self<HeaderStruct>($headers);
    }
}