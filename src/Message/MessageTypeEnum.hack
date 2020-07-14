namespace Edgedb\Message;

enum MessageTypeEnum: string as string
{
    // Client
    CLIENT_HANDSHAKE = 'V';
    AUTHENTICATION_SASL_ITINIAL_RESPONSE = 'p';
    AUTHENTICATION_CLIENT_FINAL = 'r';
    EXECUTE_SCRIPT = 'Q';
    EXECUTE = 'E';
    PREPARE = 'P';
    SYNCH = 'S';
    DESCRIBE_STATEMENT = 'D';
    
    // Server
    SERVER_HANDSHAKE = 'v';
    AUTHENTICATION = 'R';
    ERROR = 'E';
    COMMAND_COMPLETE = 'C';
    READY_FOR_COMMAND = 'Z';
    PREPARE_COMPLETE = '1';
    COMMAND_DATA_DESCRIPTION = 'T';
}