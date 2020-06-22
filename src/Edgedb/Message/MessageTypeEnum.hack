namespace Edgedb\Message;

enum MessageTypeEnum: string as string
{
    // Client
    CLIENT_HANDSHAKE = 'V';
    AUTHENTICATION_SASL_ITINIAL_RESPONE = 'p';
    
    // Server
    SERVER_HANDSHAKE = 'v';
    AUTHENTICATION = 'R';
    ERROR = 'E';
}