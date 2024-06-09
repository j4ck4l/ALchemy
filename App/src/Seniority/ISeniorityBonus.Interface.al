namespace ALchemy;

using Microsoft.HumanResources.Employee;

interface ISeniorityBonus
{
    procedure ProvidesBonusCalculation(): Boolean;
    procedure ProvidesIncentiveCalculation(): Boolean;
    procedure CalculateBonus(Employee: Record Employee; AtDate: Date): Decimal;
    procedure CalculateIncentive(Employee: Record Employee; AtDate: Date): Decimal
}
