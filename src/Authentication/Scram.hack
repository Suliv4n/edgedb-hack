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
        //return random_bytes($length);
        return "123456789123456789";
    }

    public function generateBareFromNonceAndUsername(string $nonce, string $username): string
    {
        return Str\format(
            'n=%s,r=%s',
            $this->saslprep($username),
            $nonce
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

        $nonce = $this->extractValue($saslData[0]);
        $salt = $this->extractValue($saslData[1]);
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
            'c=biws,r=%s', $serverNonce
        );

        $authMessage = Str\join(
            vec[
                $clientFirstBare,
                $serverFirst,
                $clientFinal
            ],    
            ','
        ) |> utf8_decode($$);

        $saltedPassword = $this->getSaltedPassword(
            $this->saslprep($password),
            $salt,
            $iterations
        );

        $clientKey = hash_hmac('sha256', utf8_decode('Client Key'), $saltedPassword, true);
        $storedKey = hash('sha256', $clientKey, true);
        $clientSignature = hash_hmac('sha256', $authMessage, $storedKey, true);
        $clientProof = $this->xor($clientKey, $clientSignature);

        $sevrerKey = hash_hmac('sha256', utf8_decode('Server Key'), $saltedPassword, true);
        $serverProof = hash_hmac('sha256', $authMessage, $sevrerKey, true);

        $clientFinalMessage = Str\format(
            '%s,p=%s',
            $clientFinal,
            base64_encode($clientProof)
        );

        return tuple($clientFinalMessage, $serverProof);
    }

    private function getSaltedPassword(
        string $password,
        string $salt,
        int $iterations 
    ): string {
        $decodedSalt = base64_decode($salt, true);

        $hi = hash_hmac('sha256', $decodedSalt . hex2bin('00000001'), $password, true);
        $ui = $hi;

        for ($i = 0; $i < $iterations - 1; $i++) {
            $ui = hash_hmac('sha256', $ui, $password, true);
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