namespace Test\Edgedb\Message\Type;

use type Facebook\HackTest\HackTest;
use type Edgedb\Message\Type\UnprefixedVectorType;
use type Edgedb\Message\Type\UInt8Type;
use type Edgedb\Message\Type\BytesType;
use type Edgedb\Message\Buffer;

use function Facebook\FBExpect\expect;

class UnprefixedVectorTypeTest extends HackTest {

    public function testWrite(): void 
    {
        $vector = new UnprefixedVectorType<BytesType>(vec[
            new BytesType('Hello'),
            new BytesType('world'),
            new BytesType('!')
        ]);
        
        expect($vector->getLength())->toBeSame(23);
        $buffer = new Buffer($vector->write());
        expect($buffer->toBase16())->toBeSame('0000000548656c6c6f00000005776f726c640000000121');
    }

    public function testFromBytesVector(): void
    {
        $value = vec[1, 2, 3];
        $vector = UnprefixedVectorType::fromUInt16Vector($value);

        expect($vector->getValue()[0]->getValue())->toBeSame(1);
        expect($vector->getValue()[1]->getValue())->toBeSame(2);
        expect($vector->getValue()[2]->getValue())->toBeSame(3);
    }
}