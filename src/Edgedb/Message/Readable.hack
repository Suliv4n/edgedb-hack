namespace Edgedb\Message;

use type Edgedb\Message\Type\AbstractType;

interface Readable
{
    public static function read(Buffer $buffer): AbstractType<mixed>;
}