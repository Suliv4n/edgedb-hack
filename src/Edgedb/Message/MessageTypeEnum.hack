namespace Edgedb\Message;

enum MessageTypeEnum: string as string
{
    CLIENT_HANDSHAKE = 'V';
    SERVER_HANDSHAKE = 'v';
    AUTHENTICATION_REQUIRED_SASL = 'R';
}