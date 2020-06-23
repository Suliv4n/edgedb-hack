namespace Edgedb\Authentication;

use type Normalizer;
use type Edgedb\Exception\MalformedScramException;

use function random_bytes;
use function base64_encode;
use function base64_decode;
use function intval;

use namespace HH\Lib\Str;
use namespace HH\Lib\C;
use namespace HH\Lib\Regex;

class Scram
{
    const type SCRAM = shape(
        'nonce' => string,
        'salt' => string,
        'iterations' => int
    );

    const int RAW_NONCE_LENGTH = 18;
    
    public function generateNonce(
        int $length = self::RAW_NONCE_LENGTH
    ): string {
        return random_bytes($length);
    }

    public function generateBareFromNonceAndUsername(string $nonce, string $username): string
    {
        $normalizedUsername = Normalizer::normalize($username, Normalizer::NFKC);
        \var_dump($nonce);
        return Str\format(
            'n=%s,r=%s',
            $normalizedUsername,
            base64_encode($nonce) |> \rtrim($$, '=')
        );
    }

    public function buildClientFirstMessage(string $username, string $clientNonce): string
    {
        return Str\format(
            'n,,%s',
            $this->generateBareFromNonceAndUsername($clientNonce, $username)
        );
    }

    public function parseScramMessage(string $scramMessage): self::SCRAM
    {
        $saslData = Str\split($scramMessage, ',');

        if ($this->areSaslParametersValid($saslData)) {
            throw new MalformedScramException($scramMessage);
        }

        $nonce = $this->extractValue($saslData[0]) |> base64_decode($$);
        $salt = $this->extractValue($saslData[1]) |> base64_decode($$);
        $iterations = $this->extractValue($saslData[2]) |> intval($$);

        return shape(
            'nonce' => $nonce,
            'salt' => $salt,
            'iterations' => $iterations
        );
    }

    private function areSaslParametersValid(vec<string> $saslData): bool {
        
        return C\count($saslData) === 3
            && Str\slice($saslData[0], 2) === 'r='
            && Str\slice($saslData[1], 2) === 's='
            && Regex\matches($saslData[2], re'/i=[0-9]+/');
    }

    private function extractValue(string $saslParameter): string
    {
        return Str\split($saslParameter, '=', 2)[1];
    }
}