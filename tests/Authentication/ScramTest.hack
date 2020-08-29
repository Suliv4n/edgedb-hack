namespace Test\Edgedb\Authentication;

use type Edgedb\Authentication\Scram;
use type Facebook\HackTest\HackTest;

use function Facebook\FBExpect\expect;
use function base64_encode;

use namespace HH\Lib\Str;

class ScramTest extends HackTest {
    public function testGenerateNonce(): void 
    {
        $scram = new Scram();

        $nonce1 = $scram->generateNonce(12);
        $nonce2 = $scram->generateNonce(12);

        expect(Str\length($nonce1))->toBeSame(12);
        expect(Str\length($nonce1))->toBeSame(12);

        expect($nonce1)->toNotBeSame($nonce2);
    }

    public function testGenerateBareFromNonceAndUsername(): void
    {
        $scram = new Scram();
        $nonce = 'test';
        $username = 'Sul';
        
        $bare = $scram->generateBareFromNonceAndUsername($nonce, $username);

        expect($bare)->toBeSame('n=' . $username . ',r=' . base64_encode($nonce));
    }

    public function testParseScramMessage(): void
    {
        $scram = new Scram();

        $data = $scram->parseScramMessage('r=n0nce,s=pepper,i=12');

        expect($data)->toBeSame(shape(
            'nonce' => 'n0nce',
            'salt' => 'pepper',
            'iterations' => 12
        ));
    }
}