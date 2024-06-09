namespace ALchemy;

using Microsoft.HumanResources.Employee;

codeunit 60112 NoIncentive implements IIncentiveCalculator
{
    procedure CalculateIncentive(Employee: Record Employee; Setup: Record SalarySetup; Salary: Decimal; AtDate: Date): Decimal;
    begin
        // Making it explicit
        exit(0);
    end;
}
