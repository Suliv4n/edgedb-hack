namespace Edgedb\Message;

enum IOFormatEnum: string as string
{
    BINARY = 'b';
    JSON = 'j';
    SJON_ELEMENTS = 'J';
}