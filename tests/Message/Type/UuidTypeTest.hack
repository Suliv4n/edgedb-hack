namespace Test\Edgedb\Message\Type;

use type Facebook\HackTest\HackTest;
use type Edgedb\Message\Type\UuidType;
use type Edgedb\Message\Buffer;

use function Facebook\FBExpect\expect;

class UuidTypeTest extends HackTest {

    public function testRead(): void
    {
        $buffer = Buffer::fromBase16('b9545c351fe7485fa6eaf8ead251abd3');
        expect(UuidType::read($buffer)->getValue())->toBeSame('b9545c35-1fe7-485f-a6ea-f8ead251abd3');
    }

    public function testWrite(): void 
    {
        $uuid = new UuidType('b9545c35-1fe7-485f-a6ea-f8ead251abd3');
        $buffer = new Buffer($uuid->write());
        expect($buffer->toBase16())->toBeSame('b9545c351fe7485fa6eaf8ead251abd3');
    }
}