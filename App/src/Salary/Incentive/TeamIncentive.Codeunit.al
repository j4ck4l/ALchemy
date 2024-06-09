namespace ALchemy;

using Microsoft.HumanResources.Employee;

codeunit 60114 TeamIncentive implements IIncentiveCalculator, IRewardsExtractor
{
    Access = Internal;

    procedure CalculateIncentive(Employee: Record Employee; Setup: Record SalarySetup; Salary: Decimal; AtDate: Date) Incentive: Decimal;
    var
        TeamController: Codeunit TeamController;
        this: Codeunit TeamIncentive; // TODO BC25: This will become a built-in keyword; replace with it
    begin
        Incentive := TeamController.CalculateSubordinates(Employee."No.", Employee.TeamIncentivePct, AtDate, this);
    end;

    internal procedure ExtractRewardComponent(MonthlySalary: Record MonthlySalary): Decimal
    begin
        exit(MonthlySalary.Incentive);
    end;
}
