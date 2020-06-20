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

    public function supports(Version $version): bool
    {
        return $version->majorVersion === $this->majorVersion
            && (
                $version->majorVersion !== 0 
                || $version->minorVersion  === $this->minorVersion
            );
    }

    public function __toString(): string
    {
        return $this->majorVersion . '.' . $this->minorVersion;
    }
}