use type Edgedb\Connection;

include(__DIR__ . '/vendor/autoload.hack');

use namespace HH\Lib\Str;

<<__EntryPoint>>
function main(): noreturn {
    
    Facebook\AutoloadMap\initialize();

    $connection = new Connection(
        '127.0.0.1',
        5656,
        'edgedb',
        'edgedb',
        'root'
    );

    $connection->connect();

    exit(0);
}