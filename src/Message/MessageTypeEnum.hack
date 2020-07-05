namespace Edgedb\Message;

enum MessageTypeEnum: string as string
{
    // Client
    CLIENT_HANDSHAKE = 'V';
    AUTHENTICATION_SASL_ITINIAL_RESPONSE = 'p';
    AUTHENTICATION_CLIENT_FINAL = 'r';
    EXECUTE_SCRIPT = 'Q';
    
    // Server
    SERVER_HANDSHAKE = 'v';
    AUTHENTICATION = 'R';
    ERROR = 'E';
    COMMAND_COMPLETE = 'C';
    READY_FOR_COMMAND = 'Z';
}