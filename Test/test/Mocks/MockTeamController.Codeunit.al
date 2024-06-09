namespace ALchemy;

using Microsoft.HumanResources.Employee;

codeunit 60163 MockTeamController implements ITeamController
{
    Access = Internal;

    var
        Assert: Codeunit Assert;

    #region CalculateSubordinates

    var
        _invoked_CalculateSubordinates_EmployeeNo: Code[20];
        _invoked_CalculateSubordinates_Percentage: Decimal;
        _invoked_CalculateSubordinates_AtDate: Date;
        _result_CalculateSubordinates: Decimal;

    procedure CalculateSubordinates(EmployeeNo: Code[20]; Percentage: Decimal; AtDate: Date; RewardsExtractor: Interface IRewardsExtractor; Controller: Interface ITeamController) Result: Decimal;
    begin
        _invoked_CalculateSubordinates_EmployeeNo := EmployeeNo;
        _invoked_CalculateSubordinates_Percentage := Percentage;
        _invoked_CalculateSubordinates_AtDate := AtDate;
        exit(_result_CalculateSubordinates);
    end;

    procedure SetResult_CalculateSubordinates(Result: Decimal)
    begin
        _result_CalculateSubordinates := Result;
    end;

    procedure AssertInvoked_CalculateSubordinates(EmployeeNo: Code[20]; Percentage: Decimal; AtDate: Date)
    begin
        Assert.AreNotEqual('', EmployeeNo, 'EmployeeNo is required');
        Assert.AreNotEqual(0, Percentage, 'Percentage is required');
        Assert.AreNotEqual(0D, Percentage, 'Percentage is required');

        Assert.AreEqual(EmployeeNo, _invoked_CalculateSubordinates_EmployeeNo, 'CalculateSubordinates was not invoked with the expected EmployeeNo');
        Assert.AreEqual(Percentage, _invoked_CalculateSubordinates_Percentage, 'CalculateSubordinates was not invoked with the expected Percentage');
        Assert.AreEqual(AtDate, _invoked_CalculateSubordinates_AtDate, 'CalculateSubordinates was not invoked with the expected AtDate');
    end;

    #endregion

    #region FilterSubordinates

    var
        _invoked_FilterSubordinates_EmployeeNo: Code[20];

    procedure FilterSubordinates(EmployeeNo: Code[20]; var SubordinateEmployee: Record Employee)
    begin
        _invoked_FilterSubordinates_EmployeeNo := EmployeeNo;
    end;

    procedure AssertInvoked_FilterSubordinates(EmployeeNo: Code[20])
    begin
        Assert.AreNotEqual('', EmployeeNo, 'EmployeeNo is required');
        Assert.AreEqual(EmployeeNo, _invoked_FilterSubordinates_EmployeeNo, 'FilterSubordinates was not invoked with the expected EmployeeNo');
    end;

    #endregion

    #region ProcessSubordinates

    var
        _result_ProcessSubordinates: Decimal;

    procedure ProcessSubordinates(var SubordinateEmployee: Record Employee; Percentage: Decimal; AtDate: Date; RewardsExtractor: Interface IRewardsExtractor; Controller: Interface ITeamController) Result: Decimal
    begin
        exit(_result_ProcessSubordinates);
    end;

    procedure SetResult_ProcessSubordinates(Result: Decimal)
    begin
        _result_ProcessSubordinates := Result;
    end;

    #endregion

    procedure GetSubordinateReward(var SubordinateEmployee: Record Employee; AtDate: Date; RewardsExtractor: Interface IRewardsExtractor; Controller: Interface ITeamController): Decimal
    begin
        exit(SubordinateEmployee.BaseSalary);
    end;

    #region FindMonthlySalary

    var
        _invoked_FindMonthlySalary_SubordinateEmployeeNo: Code[20];
        _invoked_FindMonthlySalary_AtDate: Date;
        _result_FindMonthlySalary: Boolean;
        _result_FindMonthlySalary_MonthlySalary: Record MonthlySalary;

    procedure FindMonthlySalary(var MonthlySalary: Record MonthlySalary; SubordinateEmployeeNo: Code[20]; AtDate: Date): Boolean
    begin
        _invoked_FindMonthlySalary_SubordinateEmployeeNo := SubordinateEmployeeNo;
        _invoked_FindMonthlySalary_AtDate := AtDate;
        MonthlySalary := _result_FindMonthlySalary_MonthlySalary;
        exit(_result_FindMonthlySalary);
    end;

    procedure SetResult_FindMonthlySalary(MonthlySalary: Record MonthlySalary; Result: Boolean)
    begin
        _result_FindMonthlySalary_MonthlySalary := MonthlySalary;
        _result_FindMonthlySalary := Result;
    end;

    procedure AssertInvoked_FindMonthlySalary(SubordinateEmployeeNo: Code[20]; AtDate: Date)
    begin
        Assert.AreEqual(SubordinateEmployeeNo, _invoked_FindMonthlySalary_SubordinateEmployeeNo, 'FindMonthlySalary was not invoked with the expected SubordinateEmployeeNo');
        Assert.AreEqual(AtDate, _invoked_FindMonthlySalary_AtDate, 'FindMonthlySalary was not invoked with the expected AtDate');
    end;

    #endregion

    procedure CalculateReward(Bonus: Decimal; Percentage: Decimal): Decimal
    begin
        exit(Bonus * (Percentage / 100));
    end;
}
