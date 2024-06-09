namespace ALchemy;

using Microsoft.HumanResources.Employee;

codeunit 60101 TeamController implements ITeamController
{
    Access = Internal;

    #region Controller Factory
    var
        _controller: Interface ITeamController;
        _controllerImplemented: Boolean;

    internal procedure Implement(Implementation: Interface ITeamController)
    begin
        _controller := Implementation;
        _controllerImplemented := true;
    end;

    local procedure GetController(): Interface ITeamController
    begin
        if not _controllerImplemented then
            Implement(this);

        exit(_controller);
    end;

    #endregion

    procedure CalculateSubordinates(EmployeeNo: Code[20]; Percentage: Decimal; AtDate: Date; RewardsExtractor: Interface IRewardsExtractor) Result: Decimal;
    begin
        Result := CalculateSubordinates(EmployeeNo, Percentage, AtDate, RewardsExtractor, GetController());
    end;

    procedure CalculateSubordinates(EmployeeNo: Code[20]; Percentage: Decimal; AtDate: Date; RewardsExtractor: Interface IRewardsExtractor; Controller: Interface ITeamController) Result: Decimal;
    var
        SubordinateEmployee: Record Employee;
    begin
        Controller.FilterSubordinates(EmployeeNo, SubordinateEmployee);
        Result := Controller.ProcessSubordinates(SubordinateEmployee, Percentage, AtDate, RewardsExtractor, Controller);
    end;

    internal procedure FilterSubordinates(EmployeeNo: Code[20]; var SubordinateEmployee: Record Employee);
    begin
        SubordinateEmployee.SetRange("Manager No.", EmployeeNo);
    end;

    internal procedure ProcessSubordinates(var SubordinateEmployee: Record Employee; Percentage: Decimal; AtDate: Date; RewardsExtractor: Interface IRewardsExtractor; Controller: Interface ITeamController) Result: Decimal
    begin
        if SubordinateEmployee.FindSet(false) then
            repeat
                Result += Controller.GetSubordinateReward(SubordinateEmployee, AtDate, RewardsExtractor, Controller);
            until SubordinateEmployee.Next() = 0;
        Result := Controller.CalculateReward(Result, Percentage);
    end;

    internal procedure GetSubordinateReward(var SubordinateEmployee: Record Employee; AtDate: Date; RewardsExtractor: Interface IRewardsExtractor; Controller: Interface ITeamController): Decimal;
    var
        MonthlySalary: Record MonthlySalary;
    begin
        if not Controller.FindMonthlySalary(MonthlySalary, SubordinateEmployee."No.", AtDate) then
            MonthlySalary := SubordinateEmployee.CalculateSalary(AtDate);
        exit(RewardsExtractor.ExtractRewardComponent(MonthlySalary));
    end;

    internal procedure FindMonthlySalary(var MonthlySalary: Record MonthlySalary; SubordinateEmployeeNo: Code[20]; AtDate: Date): Boolean;
    begin
        MonthlySalary.Reset();
        MonthlySalary.SetRange(EmployeeNo, SubordinateEmployeeNo);
        MonthlySalary.SetRange(Date, AtDate);
        exit(MonthlySalary.FindFirst());
    end;

    internal procedure CalculateReward(Bonus: Decimal; Percentage: Decimal): Decimal;
    begin
        exit(Bonus * (Percentage / 100));
    end;
}
