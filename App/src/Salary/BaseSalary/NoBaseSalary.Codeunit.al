namespace ALchemy;

using Microsoft.HumanResources.Employee;

codeunit 60120 NoBaseSalary implements IBaseSalaryCalculator
{
    procedure CalculateBaseSalary(Employee: Record Employee; Setup: Record SalarySetup): Decimal;
    begin
        // Making it explicit
        exit(0);
    end;
}