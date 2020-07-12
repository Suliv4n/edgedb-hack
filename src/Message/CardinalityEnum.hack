namespace Edgedb\Message;

enum CardinalityEnum: string as string
{
    NO_RESULT = 'n';
    ONE = 'o';
    MANY = 'm';
}