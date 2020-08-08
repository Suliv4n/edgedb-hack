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
        $results = $connection->fetchMany("SELECT Person { first_name, last_name} FILTER .first_name = 'Sulivan';");
    }
    finally {
        $connection->close();
    }

    exit(0);
}