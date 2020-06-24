namespace Edgedb\Authentication;

enum AuthenticationStatusEnum: int as int
{
    AUTH_OK = 0;
    AUTH_SASL = 10;
    AUTH_SASL_CONTINUE = 11;
    AUTH_SASL_FINAL = 12;
}