namespace ALchemy;

using Microsoft.HumanResources.Employee;

codeunit 60107 SenioritySchemeDirector implements ISeniorityScheme
{
    procedure GetBonusCalculator(Employee: Record Employee): Interface IBonusCalculator;
    var
        TeamBonus: Codeunit TeamBonus;
    begin
        exit(TeamBonus);
    end;

    procedure GetIncentiveCalculator(Employee: Record Employee): Interface IIncentiveCalculator;
    var
        NoIncentive: Codeunit NoIncentive;
    begin
        exit(NoIncentive);
    end;
}
