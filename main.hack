use type Edgedb\Client;

include(__DIR__ . '/vendor/autoload.hack');

use namespace HH\Lib\Str;

<<__EntryPoint>>
function main(): noreturn {
    
    Facebook\AutoloadMap\initialize();

    $connection = new Client(
        '127.0.0.1',
        5656,
        'edgedb',
        'edgedb',
        'root'
    );

    try {
        $connection->connect();
        $connection->execute("START TRANSACTION;");
    }
    finally {
        $connection->close();
    }

    exit(0);
}