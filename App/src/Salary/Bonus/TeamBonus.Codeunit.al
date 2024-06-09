namespace ALchemy;

using Microsoft.HumanResources.Employee;

codeunit 60113 TeamBonus implements IBonusCalculator, IRewardsExtractor
{
    Access = Internal;

    procedure CalculateBonus(Employee: Record Employee; Setup: Record SalarySetup; Salary: Decimal; StartingDate: Date; EndingDate: Date; AtDate: Date) Bonus: Decimal;
    var
        TeamController: Codeunit TeamController;
        this: Codeunit TeamBonus; // TODO BC25: This will become a built-in keyword; replace with it
    begin
        Bonus := TeamController.CalculateSubordinates(Employee."No.", Employee.TeamBonusPct, AtDate, this);
    end;

    internal procedure ExtractRewardComponent(MonthlySalary: Record MonthlySalary): Decimal
    begin
        exit(MonthlySalary.Bonus);
    end;
}
