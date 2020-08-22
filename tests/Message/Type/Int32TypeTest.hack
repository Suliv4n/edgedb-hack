namespace Test\Edgedb\Message\Type;

use type Facebook\HackTest\HackTest;
use type Edgedb\Message\Type\Int32Type;
use type Edgedb\Message\Buffer;

use function Facebook\FBExpect\expect;

class Int32TypeTest extends HackTest {

    public function testRead(): void
    {
        $buffer = Buffer::fromBase16('00000000');
        expect(Int32Type::read($buffer)->getValue())->toBeSame(0);

        $buffer = Buffer::fromBase16('ffffffff');
        expect(Int32Type::read($buffer)->getValue())->toBeSame(-1);

        $buffer = Buffer::fromBase16('80000000');
        expect(Int32Type::read($buffer)->getValue())->toBeSame(-2147483648);

        $buffer = Buffer::fromBase16('00067932');
        expect(Int32Type::read($buffer)->getValue())->toBeSame(424242);

        $buffer = Buffer::fromBase16('fffffac7');
        expect(Int32Type::read($buffer)->getValue())->toBeSame(-1337);
    }

    public function testWrite(): void 
    {
        $int = new Int32Type(0);
        $buffer = new Buffer($int->write());
        expect($buffer->toBase16())->toBeSame('00000000');

        $int = new Int32Type(-1);
        $buffer = new Buffer($int->write());
        expect($buffer->toBase16())->toBeSame('ffffffff');

        $int = new Int32Type(-2147483648);
        $buffer = new Buffer($int->write());
        expect($buffer->toBase16())->toBeSame('80000000');

        $int = new Int32Type(424242);
        $buffer = new Buffer($int->write());
        expect($buffer->toBase16())->toBeSame('00067932');

        $int = new Int32Type(-1337);
        $buffer = new Buffer($int->write());
        expect($buffer->toBase16())->toBeSame('fffffac7');
    }
}