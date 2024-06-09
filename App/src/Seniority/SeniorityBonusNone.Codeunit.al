namespace ALchemy;

using Microsoft.HumanResources.Employee;

codeunit 60115 SeniorityBonusNone implements ISeniorityBonus
{
    procedure ProvidesBonusCalculation(): Boolean;
    begin
        exit(true);
    end;

    procedure ProvidesIncentiveCalculation(): Boolean;
    begin
        exit(true);
    end;

    procedure CalculateBonus(Employee: Record Employee; AtDate: Date): Decimal;
    begin
        // Making it explicit
        exit(0);
    end;

    procedure CalculateIncentive(Employee: Record Employee; AtDate: Date): Decimal;
    begin
        // Making it explicit
        exit(0);
    end;
}
