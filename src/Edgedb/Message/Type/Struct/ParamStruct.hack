namespace Edgedb\Message\Type\Struct;

use type Edgedb\Message\Type\StringType;
use type Edgedb\Message\Type\AbstractType;

class ParamStruct extends AbstractStruct
{
    public function __construct(
        string $name, 
        string $value
    ) {
        parent::__construct(darray[
            'parameter_name' => new StringType($name),
            'parameter_value' => new StringType($value)
        ]);
    }
}