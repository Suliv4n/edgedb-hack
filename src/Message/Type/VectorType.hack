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
            $buffer = (new UInt32Type($count))->write();
        } else {
            $buffer = (new UInt16Type($count))->write();
        }

        foreach ($this->getValue() as $value) {
            $buffer .= $value->write();
        }

        return $buffer;
    }

    public function getLength(): int
    {
        $length = $this->useLongIntForCount ? 4 : 2;

        foreach ($this->getValue() as $element)
        {
            $length += $element->getLength();
        }

        return $length;
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

    public static function bytesVectorFromStrings(
        vec<string> $strings
    ): VectorType<BytesType> {
        $bytesVector = vec[];

        foreach ($strings as $string) {
            $bytesVector[] = new BytesType($string);
        }

        return new self<BytesType>($bytesVector);
    }
}