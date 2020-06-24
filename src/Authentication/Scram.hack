namespace Edgedb\Authentication;

use type Normalizer;
use type Edgedb\Exception\MalformedScramException;

use function random_bytes;
use function base64_encode;
use function base64_decode;
use function intval;
use function utf8_decode;
use function utf8_encode;
use function hex2bin;
use function hash;
use function hash_hmac;
use function HH\invariant;
use function ord;
use function chr;
use function rtrim;

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
        return Str\format(
            'n=%s,r=%s',
            $this->saslprep($username),
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

    public function buildClientFinalMessage(
        string $password,
        string $salt,
        int $iterations,
        string $clientFirstBare,
        string $serverFirst,
        string $serverNonce
    ): (string, string) {
        $clientFinal = Str\format(
            'c=biws,r=%s', base64_encode($serverNonce)
        );

        $authMessage = Str\join(
            vec[
                $clientFirstBare,
                $serverFirst,
                $clientFinal
            ],    
            ','
        ) |> utf8_encode($$);

        $saltedPassword = $this->getSaltedPassword(
            utf8_decode($this->saslprep($password)),
            $salt,
            $iterations
        );

        $clientKey = hash_hmac('sha256', utf8_decode('Client Key'), $saltedPassword);
        $storedKey = hash('sha256', $clientKey);
        $clientSignature = hash_hmac('sha256', $authMessage, $storedKey);
        $clientProof = $this->xor($clientKey, $clientSignature);

        $sevrerKey = hash_hmac('sha256', utf8_decode('Server Key'), $saltedPassword);
        $serverProof = hash_hmac('sha256', $authMessage, $sevrerKey);

        $clientFinalMessage = Str\format(
            '%s,p=%s',
            $clientFinal,
            base64_encode($clientProof)
        );

        \var_dump($clientFinalMessage);

        return tuple($clientFinalMessage, $serverProof);
    }

    private function getSaltedPassword(
        string $password,
        string $salt,
        int $iterations 
    ): string {
        $hi = hash_hmac('sha256', $password, $salt . hex2bin('00000001'));
        $ui = $hi;

        for ($i = 0; $i < $iterations - 1; $i++) {
            $ui = hash_hmac('sha256', $password, $ui);
            $hi = $this->xor($hi, $ui);
        }

        return $hi;
    }

    private function xor(string $left, string $right): string {
        invariant(
            Str\length($right) === Str\length($left),
            'Left and right members must be same length'
        );

        $xor = '';

        for ($i = 0; $i < Str\length($left); $i++) {
            $xor .= chr(ord($left[$i]) ^ ord($right[$i]));
        }

        return $xor;
    }

    private function saslprep(string $string): string
    {
        return Normalizer::normalize($string, Normalizer::NFKC);
    }
}