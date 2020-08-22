namespace Test\Edgedb\Message\Type;

use type Facebook\HackTest\HackTest;
use type Edgedb\Message\Type\CharType;
use type Edgedb\Message\Buffer;

use function Facebook\FBExpect\expect;

class CharTypeTest extends HackTest {

    public function testRead(): void
    {
        $buffer = Buffer::fromBase16('42');
        expect(CharType::read($buffer)->getValue())->toBeSame('B');
    }

    public function testWrite(): void 
    {
        $int = new CharType('A');
        $buffer = new Buffer($int->write());
        expect($buffer->toBase16())->toBeSame('41');
    }
}