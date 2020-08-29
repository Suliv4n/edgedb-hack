namespace Test\Edgedb\Message\Type;

use type Facebook\HackTest\HackTest;
use type Edgedb\Message\Type\UInt16Type;
use type Edgedb\Message\Buffer;

use function Facebook\FBExpect\expect;

class UInt16TypeTest extends HackTest {

    public function testRead(): void
    {
        $buffer = Buffer::fromBase16('0000');
        expect(UInt16Type::read($buffer)->getValue())->toBeSame(0);

        $buffer = Buffer::fromBase16('ffff');
        expect(UInt16Type::read($buffer)->getValue())->toBeSame(65535);

        $buffer = Buffer::fromBase16('4242');
        expect(UInt16Type::read($buffer)->getValue())->toBeSame(16962);
    }

    public function testWrite(): void 
    {
        $int = new UInt16Type(0);
        $buffer = new Buffer($int->write());
        expect($buffer->toBase16())->toBeSame('0000');

        $int = new UInt16Type(65535);
        $buffer = new Buffer($int->write());
        expect($buffer->toBase16())->toBeSame('ffff');

        $int = new UInt16Type(16962);
        $buffer = new Buffer($int->write());
        expect($buffer->toBase16())->toBeSame('4242');
    }
}