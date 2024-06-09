namespace ALchemy;

using Microsoft.HumanResources.Employee;

codeunit 60105 SeniorityBonusDefault implements ISeniorityBonus
{
    procedure ProvidesBonusCalculation(): Boolean;
    begin
        exit(false);
    end;

    procedure ProvidesIncentiveCalculation(): Boolean;
    begin
        exit(false);
    end;

    procedure CalculateBonus(Employee: Record Employee; AtDate: Date): Decimal;
    begin
    end;

    procedure CalculateIncentive(Employee: Record Employee; AtDate: Date): Decimal;
    begin
    end;
}
