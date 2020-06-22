namespace Edgedb\Protocol;

enum ErrorSeverityEnum: int as int
{
    ERROR = 0x78;
    FATAL = 0xc8;
    PANIC = 0xff;
}