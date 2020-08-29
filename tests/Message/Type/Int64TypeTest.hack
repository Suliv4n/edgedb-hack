namespace Test\Edgedb\Message\Type;

use type Facebook\HackTest\HackTest;
use type Edgedb\Message\Type\Int64Type;
use type Edgedb\Message\Buffer;

use function Facebook\FBExpect\expect;

class Int64TypeTest extends HackTest {

    public function testRead(): void
    {
        $buffer = Buffer::fromBase16('0000000000000000');
        expect(Int64Type::read($buffer)->getValue())->toBeSame(0);

        $buffer = Buffer::fromBase16('ffffffffffffffff');
        expect(Int64Type::read($buffer)->getValue())->toBeSame(-1);

        $buffer = Buffer::fromBase16('0000000000000001');
        expect(Int64Type::read($buffer)->getValue())->toBeSame(1);

        $buffer = Buffer::fromBase16('7fffffffffffffff');
        expect(Int64Type::read($buffer)->getValue())->toBeSame(9223372036854775807);

        $buffer = Buffer::fromBase16('8000000000000000');
        expect(Int64Type::read($buffer)->getValue())->toBeSame(-9223372036854775807 - 1);
    }

    public function testWrite(): void 
    {
        $int = new Int64Type(0);
        $buffer = new Buffer($int->write());
        expect($buffer->toBase16())->toBeSame('0000000000000000');

        $int = new Int64Type(1);
        $buffer = new Buffer($int->write());
        expect($buffer->toBase16())->toBeSame('0000000000000001');

        $int = new Int64Type(9223372036854775807);
        $buffer = new Buffer($int->write());
        expect($buffer->toBase16())->toBeSame('7fffffffffffffff');

        $int = new Int64Type(-9223372036854775807 - 1);
        $buffer = new Buffer($int->write());
        expect($buffer->toBase16())->toBeSame('8000000000000000');
    }
}