namespace Edgedb\Protocol;

class Version
{
    public function __construct(
        private int $majorVersion,
        private int $minorVersion
    ) {}

    public function getMajorversion(): int
    {
        return $this->majorVersion;
    }

    public function getMinorVersion(): int
    {
        return $this->minorVersion;
    }
}