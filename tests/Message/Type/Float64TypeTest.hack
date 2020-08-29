namespace Test\Edgedb\Message\Type;

use type Facebook\HackTest\HackTest;
use type Edgedb\Message\Type\Float64Type;
use type Edgedb\Message\Buffer;

use function Facebook\FBExpect\expect;

class Float64TypeTest extends HackTest {

    public function testRead(): void
    {
        $buffer = Buffer::fromBase16('0000000000000000');
        expect(Float64Type::read($buffer)->getValue())->toBeSame(.0);

        $buffer = Buffer::fromBase16('c02f400000000000');
        expect(Float64Type::read($buffer)->getValue())->toBeSame(-15.625);

        $buffer = Buffer::fromBase16('3fd0000000000000');
        expect(Float64Type::read($buffer)->getValue())->toBeSame(0.25);
    }

    public function testWrite(): void 
    {
        $float = new Float64Type(.0);
        $buffer = new Buffer($float->write());
        expect($buffer->toBase16())->toBeSame('0000000000000000');

        $float = new Float64Type(-15.625);
        $buffer = new Buffer($float->write());
        expect($buffer->toBase16())->toBeSame('c02f400000000000');
    }
}