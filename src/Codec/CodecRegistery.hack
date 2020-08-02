namespace Edgedb\Codec;

use type Edgedb\Message\Buffer;
use type Edgedb\Message\Type\UInt8Type;
use type Edgedb\Message\Type\UInt16Type;
use type Edgedb\Message\Type\UInt32Type;
use type Edgedb\Message\Type\StringType;
use type Edgedb\Message\Type\UuidType;
use type Exception;

class CodecRegistery
{
    private dict<string, CodecInterface> $codecs = dict[];
    private dict<string, CodecInterface> $codecsBuildCache = dict[];
    private dict<string, CodecInterface> $customScalarCodecs = dict[];
    private ScalarCodecs $scalarCodecs;

    public function __construct()
    {
        $this->scalarCodecs = new ScalarCodecs();
    }

    public function get(string $id): ?CodecInterface
    {
        return $this->codecs[$id] ?? null;
    }
    
    public function set(string $id, CodecInterface $codec): void 
    {
        
    }

    public function buildCodec(string $typeData): CodecInterface
    {
        $typeDataBuffer = new Buffer($typeData);
        $codecs = vec[];

        $codec = null;
        while(!$typeDataBuffer->isConsumed()) {
            $codec = $this->processBuildCodec($typeDataBuffer, $codecs);

            if ($codec === null) {
                continue;
            }

            $codecs[] = $codec;
        }

        if ($codec === null) {
            throw new Exception("Could not build a codec");
        }

        return $codec;
    }

    private function processBuildCodec(
        Buffer $buffer,
        vec<CodecInterface> $codecs
    ): ?CodecInterface {
        $type = UInt8Type::read($buffer)->getValue();
        $typeId = UuidType::read($buffer)->getValue();
        $codec = $this->get($typeId);

        if ($codec === null) {
            $codec = $this->codecsBuildCache[$typeId] ?? null;
        }

        if ($codec !== null) {
            switch ($type) {
                case TypeEnum::TYPE_SCALAR:
                case TypeEnum::TYPE_SET:
                    $buffer->discard(2);
                    break;

                case TypeEnum::TYPE_SHAPE:
                    $elementsCount = UInt16Type::read($buffer)->getValue();
                    for ($i = 0; $i < $elementsCount; $i++) {
                        $buffer->discard(1);
                        $elementLength = UInt32Type::read($buffer)->getValue();
                        $buffer->discard($elementLength + 2);
                    }
                    break;

                case TypeEnum::TYPE_TUPLE:
                    $elementsCount = UInt16Type::read($buffer)->getValue();
                    $buffer->discard(2 * $elementsCount);
                    break;

                case TypeEnum::TYPE_NAMED_TUPLE:
                    $elementsCount = UInt16Type::read($buffer)->getValue();
                    for ($i = 0; $i < $elementsCount; $i++) {
                        $elementLength = UInt32Type::read($buffer)->getValue();
                        $buffer->discard($elementLength + 2);
                    }
                    break;

                case TypeEnum::TYPE_ARRAY:
                    $buffer->discard(2);
                    $arrayDimension = UInt16Type::read($buffer)->getValue();
                    if ($arrayDimension !== 1) {
                        throw new Exception("Can not handle array with more than one dimension.");
                    }
                    $buffer->discard(4);
                    break;

                case TypeEnum::TYPE_ENUM:
                    $elementsCount = UInt16Type::read($buffer)->getValue();
                    for ($i = 0; $i < $elementsCount; $i++) {
                        $elementLength = UInt32Type::read($buffer)->getValue();
                        $buffer->discard($elementLength);
                    }
                    break;

                case TypeEnum::TYPE_BASE_SCALAR:
                    break;
                
                default:
                    if ($type < 0xf0 || $type > 0xff) {
                        throw new Exception("No codec implementation for Edgedb data class {$type}");
                    }
                    
                    $length = UInt32Type::read($buffer)->getValue();
                    $buffer->discard($length);
            }

            return $codec;
        }

        switch ($type) {
            case TypeEnum::TYPE_BASE_SCALAR:
                $codec = $this->customScalarCodecs[$typeId] ?? null;
                if ($codec !== null) {
                    break;
                }

                $codec = $this->scalarCodecs->get($typeId) ?? null;
                
                if ($codec === null) {
                    throw new Exception('No codec.');
                }
                
                break;
            
            case TypeEnum::TYPE_SHAPE:
                $elementsCount = UInt16Type::read($buffer)->getValue();
                $subCodecs = vec[];
                $names = vec[];
                $flags = vec[];

                for ($i = 0; $i < $elementsCount; $i++) {
                    $flag = UInt8Type::read($buffer)->getValue();

                    $name = StringType::read($buffer)->getValue();

                    $position = UInt16Type::read($buffer)->getValue();
                    $subCodec = $codecs[$position] ?? null;

                    if ($subCodec === null) {
                        throw new Exception('Could not build object codec: missing subcodec');
                    }

                    $subCodecs[] = $subCodec;
                    $names[] = $name;
                    $flags[] = $flag;
                }

                $codec = new ObjectCodec($subCodecs, $names, $flags);
                break;

            case TypeEnum::TYPE_SET:
                $position = UInt16Type::read($buffer)->getValue();
                $subCodec = $codecs[$position];
                
                if ($subCodec === null) {
                    throw new Exception('Could not build set codec: missing subcodec');
                }

                $codec = new SetCodec($subCodec);
                break;

            case TypeEnum::TYPE_SCALAR:
                $position = UInt16Type::read($buffer)->getValue();
                $codec = $codecs[$position] ?? null;

                if ($codec === null) {
                    throw new Exception(
                        'Could not build scalar codec: missing a codec for base scalar'
                    );
                }

                if (! ($codec is ScalarCodec)) {
                    throw new Exception(
                        'Could not build scalar codec: base scalar has a non-scalar codec'
                    );
                }

                break;

            case TypeEnum::TYPE_ARRAY:
                $position = UInt16Type::read($buffer)->getValue();
                $dimension = UInt16Type::read($buffer)->getValue();

                if ($dimension !== 1) {
                    throw new Exception('Cannot handle arrays with more than one dimension');
                }

                $dimensionLength = UInt32Type::read($buffer)->getValue();

                $subCodec = $codecs[$position] ?? null;

                if ($subCodec === null) {
                    throw new Exception('Could not build array codec: missing subcodec');
                }

                $codec = new ArrayCodec($subCodec, $dimensionLength);
                break;

            case TypeEnum::TYPE_TUPLE:
                $elementsCount = UInt16Type::read($buffer)->getValue();
                if ($elementsCount === 0) {
                    $codec = new EmptyTupleCodec(); 
                } else {
                    $subCodecs = vec[];

                    for ($i = 0; $i < $elementsCount; $i++) {
                        $position = UInt16Type::read($buffer)->getValue();

                        $subCodec = $codecs[$position];
                        if ($subCodec === null) {
                            throw new Exception('Could not build tuple codec : missing subcodec');
                        }

                        $subCodecs[] = $codecs[$position];
                    }

                    $codec = new TupleCodec($subCodecs);
                }

                break;

            case TypeEnum::TYPE_NAMED_TUPLE:
                $elementsCount = UInt16Type::read($buffer)->getValue();

                $subCodecs = vec[];
                $names = vec[];

                for ($i = 0; $i < $elementsCount; $i++) {
                    $names[] = StringType::read($buffer)->getValue();
                    $position = UInt16Type::read($buffer)->getValue();

                    $subCodec = $codecs[$position] ?? null;
                    if ($subCodec === null) {
                        throw new Exception('Could not build namedtuple codec : missing subcodec');
                    }

                    $subCodecs[] = $subCodec;
                }

                $codec = new NamedTupleCodec($subCodecs, $names);

                break;
                case TypeEnum::TYPE_ENUM:
                    $elementsCount = UInt16Type::read($buffer)->getValue();
                    for ($i = 0; $i < $elementsCount; $i++) {
                        $elementLength = UInt32Type::read($buffer)->getValue();
                        $buffer->discard($elementLength);
                    }
                    $codec = new EnumCodec();
                break;
            default:
                $codec = null;
        }

        if ($codec === null) {
            throw new Exception('Could not build a codec');
        }

        $this->codecsBuildCache[$typeId] = $codec;

        return $codec;
    }
}