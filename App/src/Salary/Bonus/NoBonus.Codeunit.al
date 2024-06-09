namespace ALchemy;

using Microsoft.HumanResources.Employee;

codeunit 60111 NoBonus implements IBonusCalculator
{
    Access = Internal;

    procedure CalculateBonus(Employee: Record Employee; Setup: Record SalarySetup; Salary: Decimal; StartingDate: Date; EndingDate: Date; AtDate: Date): Decimal;
    begin
        // Making it explicit
        exit(0);
    end;
}
