namespace ALchemy;

using Microsoft.HumanResources.Employee;

codeunit 60105 DefaultSeniorityScheme implements ISeniorityScheme
{
    procedure GetBonusCalculator(Employee: Record Employee): Interface IBonusCalculator;
    begin
        exit(Employee.SalaryType);
    end;

    procedure GetIncentiveCalculator(Employee: Record Employee): Interface IIncentiveCalculator;
    begin
        exit(Employee.SalaryType);
    end;
}
