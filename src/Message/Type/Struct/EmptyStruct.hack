namespace Edgedb\Message\Type\Struct;

class EmptyStruct extends AbstractStruct
{
    public function __construct() {
        parent::__construct(darray[]);
    }
}