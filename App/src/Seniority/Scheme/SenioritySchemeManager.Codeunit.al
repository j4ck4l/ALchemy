namespace ALchemy;

using Microsoft.HumanResources.Employee;

codeunit 60106 SenioritySchemeManager implements ISeniorityScheme
{
    procedure GetBonusCalculator(Employee: Record Employee): Interface IBonusCalculator;
    var
        TeamBonus: Codeunit TeamBonus;
    begin
        exit(TeamBonus);
    end;

    procedure GetIncentiveCalculator(Employee: Record Employee): Interface IIncentiveCalculator;
    var
        TeamIncentive: Codeunit TeamIncentive;
    begin
        exit(TeamIncentive);
    end;
}
