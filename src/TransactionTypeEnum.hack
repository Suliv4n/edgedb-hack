namespace Edgedb;

enum TransactionTypeEnum : string as string {
    NOT_IN_TRANSACTION = 'I';
    IN_TRANSACTION = 'T';
    IN_FAILED_TRANSACTION = 'E';
}