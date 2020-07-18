namespace Edgedb\Message\Type\Struct;

use type Edgedb\Message\Type\UInt16Type;
use type Edgedb\Message\Type\Int16Type;
use type Edgedb\Message\Type\UnprefixedVectorType;
use type Edgedb\Message\Readable;
use type Edgedb\Message\Buffer;

use namespace HH\Lib\Math;
use namespace HH\Lib\C;

class BigIntStruct extends AbstractStruct implements Readable
{
    const POSITIVE = 0x0000;
    const NEGATIVE = 0x4000;

    public function __construct(
        private int $weight,
        private bool $isPositive,
        private vec<int> $digits = vec[]
    ) {
        parent::__construct(darray[
            'ndigits' => new UInt16Type(C\count($digits)),
            'weight' => new Int16Type($weight),
            'sign' => new UInt16Type($isPositive ? self::POSITIVE : self::NEGATIVE),
            'reserved' => new UInt16Type(0),
            'digits' => UnprefixedVectorType::fromUInt16Vector($digits)
        ]);
    }

    public static function fromInt(int $number): BigIntStruct
    {
        $nbase = 10000;

        if ($number === 0) {
            return new self(0, true);
        }

        $absoluteNumber = Math\abs($number);
        $digits = vec<int>[];
        while ($absoluteNumber > 0) {
            $mod = $absoluteNumber % $nbase;

            $absoluteNumber = Math\int_div($absoluteNumber, $nbase);
            $digits[] = $mod;
        }

        return new self(
            C\count($digits) - 1,
            $number > 0,
            $digits
        );
    }

    public function getInt(): int
    {
        $nbase = 10000;

        $value = 0;

        foreach ($this->digits as $digit) {
            $digit *= $nbase * $this->weight;
            $nbase = Math\int_div($nbase, 10);
        }

        return $this->isPositive ? $value : -$value;
    }


    public static function read(Buffer $buffer): BigIntStruct
    {
        $ndigits = UInt16Type::read($buffer)->getValue();
        $weight = Int16Type::read($buffer)->getValue();
        $sign = UInt16Type::read($buffer)->getValue();
        $reserved = Int16Type::read($buffer);
        
        $digits = vec[];
        
        for ($i = 0; $i < $ndigits; $i++) {
            $digits[] = UInt16Type::read($buffer)->getValue();
        }

        return new self($weight, $sign === self::POSITIVE, $digits);
    }
}