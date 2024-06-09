namespace ALchemy;

using Microsoft.HumanResources.Employee;

interface IBaseSalaryCalculator
{
    procedure CalculateBaseSalary(Employee: Record Employee; Setup: Record SalarySetup): Decimal;
}