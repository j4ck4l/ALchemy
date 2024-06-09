namespace ALchemy;

using Microsoft.HumanResources.Employee;

codeunit 60114 TeamIncentive implements IIncentiveCalculator, IRewardsExtractor
{
    Access = Internal;

    procedure CalculateIncentive(Employee: Record Employee; Setup: Record SalarySetup; Salary: Decimal; AtDate: Date) Incentive: Decimal;
    var
        TeamController: Codeunit TeamController;
    begin
        Incentive := CalculateIncentive(Employee, AtDate, TeamController, this);
    end;

    procedure CalculateIncentive(Employee: Record Employee; AtDate: Date; Controller: Interface ITeamController; RewardsExtractor: Interface IRewardsExtractor) Bonus: Decimal;
    begin
        exit(Controller.CalculateSubordinates(Employee."No.", Employee.TeamIncentivePct, AtDate, RewardsExtractor, Controller));
    end;

    internal procedure ExtractRewardComponent(MonthlySalary: Record MonthlySalary): Decimal
    begin
        exit(MonthlySalary.Incentive);
    end;
}
