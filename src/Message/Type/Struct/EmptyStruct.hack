namespace Edgedb\Message\Type\Struct;

use type Edgedb\Message\Type\StringType;
use type Edgedb\Message\Type\Int16Type;
use type Edgedb\Message\Type\VectorType;

class EmptyStruct extends AbstractStruct
{
    public function __construct() {
        parent::__construct(darray[]);
    }
}