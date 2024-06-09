namespace ALchemy;

using Microsoft.HumanResources.Employee;

interface IBonusCalculator
{
    procedure CalculateBonus(Employee: Record Employee; Setup: Record SalarySetup; Salary: Decimal; StartingDate: Date; EndingDate: Date; AtDate: Date): Decimal;
}
