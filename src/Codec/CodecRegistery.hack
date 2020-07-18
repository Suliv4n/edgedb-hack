namespace Edgedb\Codec;

use type Edgedb\Message\Buffer;
use type Edgedb\Message\Type\UInt8Type;
use type Edgedb\Message\Type\UInt16Type;
use type Edgedb\Message\Type\UInt32Type;
use type Edgedb\Message\Type\UuidType;
use type Exception;

class CodecRegistery
{
    private dict<string, CodecInterface> $codecs = dict[];
    private dict<string, CodecInterface> $codecsBuildCache = dict[];
    private dict<string, CodecInterface> $customScalarCodecs = dict[];

    public function get(string $id): ?CodecInterface
    {
        return $this->codecs[$id] ?? null;
    }
    
    public function set(string $id, CodecInterface $codec): void 
    {
        
    }

    private function buildCodec(string $typeData): void
    {
        $typeDataBuffer = new Buffer($typeData);

        while(!$typeDataBuffer->isConsumed())
        {
            $this->processBuildCodec($typeDataBuffer);
        }
    }

    private function processBuildCodec(Buffer $buffer): ?CodecInterface
    {
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
        /*
        switch ($type) {
            case TypeEnum::TYPE_BASE_SCALAR:
                $codec = $this->customScalarCodecs[$typeId] ?? null;
                if ($codec !== null) {
                    break;
                }

                $codec = 

                break;
            default:
                # code...
                break;
        }
        */

        return null;
    }
}