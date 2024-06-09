namespace ALchemy;

using Microsoft.HumanResources.Employee;

codeunit 60113 TeamBonus implements IBonusCalculator, IRewardsExtractor
{
    Access = Internal;

    procedure CalculateBonus(Employee: Record Employee; Setup: Record SalarySetup; Salary: Decimal; StartingDate: Date; EndingDate: Date; AtDate: Date) Bonus: Decimal;
    var
        TeamController: Codeunit TeamController;
    begin
        Bonus := CalculateBonus(Employee, AtDate, TeamController, this);
    end;

    procedure CalculateBonus(Employee: Record Employee; AtDate: Date; Controller: Interface ITeamController; RewardsExtractor: Interface IRewardsExtractor) Bonus: Decimal;
    begin
        exit(Controller.CalculateSubordinates(Employee."No.", Employee.TeamBonusPct, AtDate, RewardsExtractor, Controller));
    end;

    internal procedure ExtractRewardComponent(MonthlySalary: Record MonthlySalary): Decimal
    begin
        exit(MonthlySalary.Bonus);
    end;
}
