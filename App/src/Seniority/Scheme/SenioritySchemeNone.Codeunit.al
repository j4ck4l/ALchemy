namespace ALchemy;

using Microsoft.HumanResources.Employee;

codeunit 60117 SenioritySchemeNone implements ISeniorityScheme
{
    procedure GetBonusCalculator(Employee: Record Employee): Interface IBonusCalculator;
    var
        NoBonus: Codeunit NoBonus;
    begin
        exit(NoBonus);
    end;

    procedure GetIncentiveCalculator(Employee: Record Employee): Interface IIncentiveCalculator;
    var
        NoIncentive: Codeunit NoIncentive;
    begin
        exit(NoIncentive);
    end;
}