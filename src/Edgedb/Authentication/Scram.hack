namespace Edgedb\Authentication;

use type Normalizer;

use function random_bytes;
use function base64_encode;

use namespace HH\Lib\Str;

class Scram
{
    const int RAW_NONCE_LENGTH = 18;
    
    public function generateNonce(
        int $length = self::RAW_NONCE_LENGTH
    ): string {
        return random_bytes($length);
    }

    public function generateBareFromNonceAndUsername(string $nonce, string $username): string
    {
        $normalizedUsername = Normalizer::normalize($username, Normalizer::NFKC);

        return Str\format(
            'n=%s,r=%s',
            $normalizedUsername,
            base64_encode($nonce)
        );
    }

    public function buildClientFirstMessage(string $username, string $clientNonce): string
    {
        return Str\format('n,,%s', $this->generateBareFromNonceAndUsername($clientNonce, $username));
    }
}