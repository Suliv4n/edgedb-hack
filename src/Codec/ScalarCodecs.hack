namespace Edgedb\Codec;

use function bin2hex;
use function hex2bin;

use type Exception;

use namespace HH\Lib\C;

class ScalarCodecs
{
    private dict<string, CodecInterface> $codecs = dict[];

    public function __construct()
    {
        $this->registerScalarTypes();
    }

    const dict<string, string> KNOWN_TYPES = dict[
        '00000000000000000000000000000001' => 'anytype',
        '00000000000000000000000000000002' => 'anytuple',
        '000000000000000000000000000000f0' => 'std',
        '000000000000000000000000000000ff' => 'empty-tuple',
        '00000000000000000000000000000100' => 'std::uuid',
        '00000000000000000000000000000101' => 'std::str',
        '00000000000000000000000000000102' => 'std::bytes',
        '00000000000000000000000000000103' => 'std::int16',
        '00000000000000000000000000000104' => 'std::int32',
        '00000000000000000000000000000105' => 'std::int64',
        '00000000000000000000000000000106' => 'std::float32',
        '00000000000000000000000000000107' => 'std::float64',
        '00000000000000000000000000000108' => 'std::decimal',
        '00000000000000000000000000000109' => 'std::bool',
        '0000000000000000000000000000010a' => 'std::datetime',
        '0000000000000000000000000000010b' => 'std::local_datetime',
        '0000000000000000000000000000010c' => 'std::local_date',
        '0000000000000000000000000000010d' => 'std::local_time',
        '0000000000000000000000000000010e' => 'std::duration',
        '0000000000000000000000000000010f' => 'std::json',
        '00000000000000000000000000000110' => 'std::bigint',
    ];

    public function registerScalarType(string $typename, CodecInterface $codec): void
    {
        $id = C\find_key(self::KNOWN_TYPES, (string $type) ==> $type === $typename);

        if ($id === null) {
            throw new Exception("Unknow type name {$typename}");
        }

        $id = hex2bin($id);

        $this->codecs[$id] = $codec;
    }

    public function get(string $id): ?CodecInterface
    {
        return $this->codecs[$id] ?? null;
    }

    private function registerScalarTypes(): void {
        $this->registerScalarType('std::int16', new Int16Codec());
        $this->registerScalarType('std::int32', new Int32Codec());
        $this->registerScalarType('std::int64', new Int64Codec());

        $this->registerScalarType('std::float32', new Float32Codec());
        $this->registerScalarType('std::float64', new Float64Codec());

        $this->registerScalarType('std::bigint', new BigIntCodec());

        $this->registerScalarType('std::bool', new BoolCodec());
        
        $this->registerScalarType('std::json', new JsonCodec());
        $this->registerScalarType('std::str', new StringCodec());
        $this->registerScalarType('std::bytes', new BytesCodec());

        $this->registerScalarType('std::uuid', new UuidCodec());

        $this->registerScalarType('std::local_date', new LocalDateCodec());
        $this->registerScalarType('std::local_time', new LocalTimeCodec());
        $this->registerScalarType('std::local_datetime', new LocalDateTimeCodec());
        $this->registerScalarType('std::datetime', new DateTimeCodec());
        $this->registerScalarType('std::duration', new DurationCodec());
    }
}