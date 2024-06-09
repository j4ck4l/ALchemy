namespace ALchemy;

using Microsoft.HumanResources.Employee;

interface IIncentiveCalculator
{
    procedure CalculateIncentive(Employee: Record Employee; Setup: Record SalarySetup; Salary: Decimal; AtDate: Date): Decimal
}
