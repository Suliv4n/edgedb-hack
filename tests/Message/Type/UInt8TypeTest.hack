namespace Test\Edgedb\Message\Type;

use type Facebook\HackTest\HackTest;
use type Edgedb\Message\Type\UInt8Type;
use type Edgedb\Message\Buffer;

use function Facebook\FBExpect\expect;

class UInt8TypeTest extends HackTest {

    public function testRead(): void
    {
        $buffer = Buffer::fromBase16('00');
        expect(UInt8Type::read($buffer)->getValue())->toBeSame(0);

        $buffer = Buffer::fromBase16('ff');
        expect(UInt8Type::read($buffer)->getValue())->toBeSame(255);

        $buffer = Buffer::fromBase16('42');
        expect(UInt8Type::read($buffer)->getValue())->toBeSame(66);
    }

    public function testWrite(): void 
    {
        $int = new UInt8Type(0);
        $buffer = new Buffer($int->write());
        expect($buffer->toBase16())->toBeSame('00');

        $int = new UInt8Type(255);
        $buffer = new Buffer($int->write());
        expect($buffer->toBase16())->toBeSame('ff');

        $int = new UInt8Type(66);
        $buffer = new Buffer($int->write());
        expect($buffer->toBase16())->toBeSame('42');
    }
}