namespace Edgedb\Message\Type\Struct;

use type Edgedb\Message\Buffer;
use type Edgedb\Message\Readable;
use type Edgedb\Message\Type\Int16Type;
use type Edgedb\Message\Type\Struct\ParamStruct;
use type Edgedb\Message\Type\Struct\ProtocolExtStruct;
use type Edgedb\Message\Type\VectorType;
use type Edgedb\Protocol\Version;


class ServerHandshakeStruct extends AbstractStruct implements Readable
{
    public function __construct(
        private Version $version,
        private vec<ProtocolExtStruct> $extensions
    ){
        parent::__construct(darray[
            'major_version' => new Int16Type($version->getMajorversion()),
            'minor_version' => new Int16Type($version->getMinorVersion()),
            'protocol_extensions' => new VectorType($extensions)
        ]);
    }

    public function getVersion(): Version
    {
        return $this->version;
    }

    public function getExtensions(): vec<ProtocolExtStruct>
    {
        return $this->extensions;
    }

    public static function read(Buffer $buffer): ServerHandshakeStruct
    {
        $majorVersion = Int16Type::read($buffer)->getValue();
        $minorVersion = Int16Type::read($buffer)->getValue();

        $version = new Version($majorVersion, $minorVersion);

        $extensionsCount = Int16Type::read($buffer)->getValue();
        $extensions = vec[];
        for ($i = 0; $i < $extensionsCount; $i++) {
            $extensions[] = ProtocolExtStruct::read($buffer);
        }

        return new self($version, $extensions);
    }
}