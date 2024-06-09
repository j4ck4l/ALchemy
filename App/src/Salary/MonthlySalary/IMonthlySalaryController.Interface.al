namespace ALchemy;

using Microsoft.HumanResources.Employee;

interface IMonthlySalaryController
{
    Access = Internal;

    procedure DeleteMonthlySalaries(var MonthlySalary: Record MonthlySalary; AtDate: Date);
    procedure CalculateMonthlySalaries(var MonthlySalary: Record MonthlySalary; AtDate: Date);
    procedure ProcessEmployees(var Employee: Record Employee; var MonthlySalary: Record MonthlySalary; AtDate: Date; Controller: Interface IMonthlySalaryController);
    procedure ProcessEmployee(var Employee: Record Employee; var MonthlySalary: Record MonthlySalary; AtDate: Date);
}
