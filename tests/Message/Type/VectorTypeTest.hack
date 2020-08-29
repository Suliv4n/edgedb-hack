namespace Test\Edgedb\Message\Type;

use type Facebook\HackTest\HackTest;
use type Edgedb\Message\Type\VectorType;
use type Edgedb\Message\Type\UInt8Type;
use type Edgedb\Message\Type\BytesType;
use type Edgedb\Message\Buffer;

use function Facebook\FBExpect\expect;

class VectorTypeTest extends HackTest {

    public function testWrite(): void 
    {
        $vector = new VectorType<BytesType>(vec[
            new BytesType('Hello'),
            new BytesType('world'),
            new BytesType('!')
        ]);
        
        expect($vector->getLength())->toBeSame(25);
        $buffer = new Buffer($vector->write());
        expect($buffer->toBase16())->toBeSame('00030000000548656c6c6f00000005776f726c640000000121');

        $vector = new VectorType<UInt8Type>(
            vec[
                new UInt8Type(1),
                new UInt8Type(2),
                new UInt8Type(3)
            ], 
            true
        );

        expect($vector->getLength())->toBeSame(7);
        $buffer = new Buffer($vector->write());
        expect($buffer->toBase16())->toBeSame('00000003010203');
    }

    public function testFromBytesVector(): void
    {
        $value = vec['One', 'Two', 'Three'];
        $vector = VectorType::bytesVectorFromStrings($value);

        expect($vector->getValue()[0]->getValue())->toBeSame('One');
        expect($vector->getValue()[1]->getValue())->toBeSame('Two');
        expect($vector->getValue()[2]->getValue())->toBeSame('Three');
    }
}