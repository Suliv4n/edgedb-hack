namespace Edgedb\Codec;

enum TypeEnum : int
{
    TYPE_SET = 0;
    TYPE_SHAPE = 1;
    TYPE_BASE_SCALAR = 2;
    TYPE_SCALAR = 3;
    TYPE_TUPLE = 4;
    TYPE_NAMED_TUPLE = 5;
    TYPE_ARRAY = 6;
    TYPE_ENUM = 7;
}