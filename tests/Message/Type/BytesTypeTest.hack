namespace Test\Edgedb\Message\Type;

use type Facebook\HackTest\HackTest;
use type Edgedb\Message\Type\BytesType;
use type Edgedb\Message\Buffer;

use function Facebook\FBExpect\expect;

class BytesTypeTest extends HackTest {

    public function testRead(): void
    {
        $buffer = Buffer::fromBase16('0000000d48656c6c6f20776f726c642021');
        expect(BytesType::read($buffer)->getValue())->toBeSame('Hello world !');
    }

    public function testWrite(): void 
    {
        $int = new BytesType('Hello world !');
        $buffer = new Buffer($int->write());
        expect($buffer->toBase16())->toBeSame('0000000d48656c6c6f20776f726c642021');
    }
}