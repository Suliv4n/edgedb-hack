namespace Test\Edgedb\Message\Type;

use type Facebook\HackTest\HackTest;
use type Edgedb\Message\Type\StringType;
use type Edgedb\Message\Buffer;

use function Facebook\FBExpect\expect;

class StringTypeTest extends HackTest {

    public function testRead(): void
    {
        $buffer = Buffer::fromBase16('0000000b48656c6c6f2120f09f9982');
        expect(StringType::read($buffer)->getValue())->toBeSame('Hello! 🙂');
    }

    public function testWrite(): void
    {
        $int = new StringType('Hello! 🙂');
        $buffer = new Buffer($int->write());
        expect($buffer->toBase16())->toBeSame('0000000b48656c6c6f2120f09f9982');
    }
}