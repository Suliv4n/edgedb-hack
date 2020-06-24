namespace Edgedb\Protocol;

class Error
{
    public function __construct(
        private int $code,
        private ErrorSeverityEnum $severity,
        private string $message,
        private darray<int, string> $attributes = darray[]
    ) {}

    public function getCode(): int
    {
        return $this->code;
    }

    public function getSeverity(): ErrorSeverityEnum
    {
        return $this->severity;
    }

    public function getMessage(): string
    {
        return $this->message;
    }

    public function getAttributes(): darray<int, string>
    {
        return $this->attributes;
    }
}