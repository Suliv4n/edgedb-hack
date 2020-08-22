use type Edgedb\Client;



use namespace HH\Lib\Str;

<<__EntryPoint>>
function main(): noreturn {
    
    include(__DIR__ . '/vendor/autoload.hack');

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
        $results = $connection->fetchOne("SELECT Person { first_name, last_name} FILTER .id = <uuid>'c503ea94-c434-11ea-8f91-2b22302887a3';");
        var_dump($results);
    }
    finally {
        $connection->close();
    }

    exit(0);
}
