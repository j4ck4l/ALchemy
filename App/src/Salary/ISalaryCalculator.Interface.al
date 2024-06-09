namespace ALchemy;

using Microsoft.HumanResources.Employee;

interface ISalaryCalculator
{
    procedure CalculateBaseSalary(Employee: Record Employee; Setup: Record SalarySetup): Decimal;
    procedure CalculateBonus(Employee: Record Employee; Setup: Record SalarySetup; Salary: Decimal; StartingDate: Date; EndingDate: Date): Decimal;
    procedure CalculateIncentive(Employee: Record Employee; Setup: Record SalarySetup; Salary: Decimal; AtDate: Date): Decimal;
}
