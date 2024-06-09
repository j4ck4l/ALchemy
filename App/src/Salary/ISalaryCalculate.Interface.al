namespace ALchemy;

using Microsoft.HumanResources.Employee;

interface ISalaryCalculate
{
    procedure CalculateSalary(var Employee: Record Employee; AtDate: Date) Result: Record MonthlySalary;
}
