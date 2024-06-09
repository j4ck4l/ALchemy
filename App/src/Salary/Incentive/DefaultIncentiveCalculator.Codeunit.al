namespace ALchemy;

using Microsoft.HumanResources.Employee;

codeunit 60119 DefaultIncentiveCalculator implements IIncentiveCalculator
{
    procedure CalculateIncentive(Employee: Record Employee; Setup: Record SalarySetup; Salary: Decimal; AtDate: Date) Incentive: Decimal;
    var
        YearsOfTenure: Integer;
    begin
        Setup.TestField(YearlyIncentivePct);
        YearsOfTenure := Round((AtDate - Employee."Employment Date") / 365, 1, '<');
        Incentive := Salary * (YearsOfTenure * Setup.YearlyIncentivePct) / 100;
    end;
}