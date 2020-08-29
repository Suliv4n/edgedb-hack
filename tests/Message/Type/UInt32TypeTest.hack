namespace Test\Edgedb\Message\Type;

use type Facebook\HackTest\HackTest;
use type Edgedb\Message\Type\UInt32Type;
use type Edgedb\Message\Buffer;

use function Facebook\FBExpect\expect;

class UInt32TypeTest extends HackTest {

    public function testRead(): void
    {
        $buffer = Buffer::fromBase16('00000000');
        expect(UInt32Type::read($buffer)->getValue())->toBeSame(0);

        $buffer = Buffer::fromBase16('ffffffff');
        expect(UInt32Type::read($buffer)->getValue())->toBeSame(4294967295);

        $buffer = Buffer::fromBase16('abcdef12');
        expect(UInt32Type::read($buffer)->getValue())->toBeSame(2882400018);
    }

    public function testWrite(): void 
    {
        $int = new UInt32Type(0);
        $buffer = new Buffer($int->write());
        expect($buffer->toBase16())->toBeSame('00000000');

        $int = new UInt32Type(4294967295);
        $buffer = new Buffer($int->write());
        expect($buffer->toBase16())->toBeSame('ffffffff');

        $int = new UInt32Type(2882400018);
        $buffer = new Buffer($int->write());
        expect($buffer->toBase16())->toBeSame('abcdef12');
    }
}