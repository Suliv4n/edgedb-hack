namespace Test\Edgedb\Message\Type;

use type Facebook\HackTest\HackTest;
use type Edgedb\Message\Type\Int16Type;
use type Edgedb\Message\Buffer;

use function Facebook\FBExpect\expect;

class Int16TypeTest extends HackTest {

    public function testRead(): void
    {
        $buffer = Buffer::fromBase16('0000');
        expect(Int16Type::read($buffer)->getValue())->toBeSame(0);

        $buffer = Buffer::fromBase16('ffff');
        expect(Int16Type::read($buffer)->getValue())->toBeSame(-1);

        $buffer = Buffer::fromBase16('80000');
        expect(Int16Type::read($buffer)->getValue())->toBeSame(-32768);


        $buffer = Buffer::fromBase16('3039');
        expect(Int16Type::read($buffer)->getValue())->toBeSame(12345);

        $buffer = Buffer::fromBase16('abcd');
        expect(Int16Type::read($buffer)->getValue())->toBeSame(-21555);
    }

    public function testWrite(): void 
    {
        $int = new Int16Type(0);
        $buffer = new Buffer($int->write());
        expect($buffer->toBase16())->toBeSame('0000');

        $int = new Int16Type(-1);
        $buffer = new Buffer($int->write());
        expect($buffer->toBase16())->toBeSame('ffff');

        $int = new Int16Type(-32768);
        $buffer = new Buffer($int->write());
        expect($buffer->toBase16())->toBeSame('8000');

        $int = new Int16Type(12345);
        $buffer = new Buffer($int->write());
        expect($buffer->toBase16())->toBeSame('3039');

        $int = new Int16Type(-21555);
        $buffer = new Buffer($int->write());
        expect($buffer->toBase16())->toBeSame('abcd');
    }
}