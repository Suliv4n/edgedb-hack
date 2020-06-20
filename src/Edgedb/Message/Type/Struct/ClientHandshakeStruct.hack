namespace Edgedb\Message\Type\Struct;

use type Edgedb\Protocol\Version;
use type Edgedb\Message\Type\Int16Type;
use type Edgedb\Message\Type\VectorType;
use type Edgedb\Message\Type\Struct\ParamStruct;
use type Edgedb\Message\Type\Struct\ProtocolExtStruct;

class ClientHandshakeStruct extends AbstractStruct
{
    public function __construct(
        Version $version,
        vec<ParamStruct> $parameters,
        vec<ProtocolExtStruct> $extensions
    ){
        parent::__construct(darray[
            'major_version' => new Int16Type($version->getMajorversion()),
            'minor_version' => new Int16Type($version->getMinorVersion()),
            'parameters' => new VectorType($parameters),
            'protocol_extensions' => new VectorType($extensions)
        ]);
    }
}