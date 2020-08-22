namespace Test\Edgedb\Message\Type;

use type Facebook\HackTest\HackTest;
use type Edgedb\Message\Type\Float32Type;
use type Edgedb\Message\Buffer;

use function Facebook\FBExpect\expect;

class Float32TypeTest extends HackTest {

    public function testRead(): void
    {
        $buffer = Buffer::fromBase16('00000000');
        expect(Float32Type::read($buffer)->getValue())->toBeSame(.0);

        $buffer = Buffer::fromBase16('c17a0000');
        expect(Float32Type::read($buffer)->getValue())->toBeSame(-15.625);

        $buffer = Buffer::fromBase16('3e800000');
        expect(Float32Type::read($buffer)->getValue())->toBeSame(0.25);
    }

    public function testWrite(): void 
    {
        $float = new Float32Type(-15.625);
        $buffer = new Buffer($float->write());
        expect($buffer->toBase16())->toBeSame('c17a0000');

        $float = new Float32Type(0.25);
        $buffer = new Buffer($float->write());
        expect($buffer->toBase16())->toBeSame('3e800000');
    }
}