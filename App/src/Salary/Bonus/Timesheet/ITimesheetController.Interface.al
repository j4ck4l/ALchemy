namespace ALchemy;

using Microsoft.HumanResources.Employee;

interface ITimesheetController
{
    Access = Internal;

    procedure GetWorkHoursProvider(var Employee: Record Employee) WorkHoursProvider: Interface IWorkHoursProvider;
    procedure CalculateBonus(Setup: Record SalarySetup; WorkHours: Decimal; Salary: Decimal) Bonus: Decimal;
}
