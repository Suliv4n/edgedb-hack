namespace Edgedb\Codec;

class CodecRegistery
{
    public function get<T>(string $id): ?CodecInterface<T>
    {
        return null;
    }
    
    public function set<T>(string $id, CodecInterface<T> $codec): void 
    {

    }
}