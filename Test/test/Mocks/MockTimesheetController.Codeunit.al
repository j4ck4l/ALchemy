namespace ALchemy;

using Microsoft.HumanResources.Employee;

codeunit 60161 MockTimesheetController implements ITimesheetController
{
    var
        Assert: Codeunit Assert;

    procedure GetWorkHoursProvider(var Employee: Record Employee): Interface IWorkHoursProvider
    var
        Stub: Codeunit StubWorkhoursProvider;
    begin
        exit(Stub);
    end;

    #region CalculateBonus

    var
        _invoked_CalculateBonus: Boolean;
        _invoked_CalculateBonus_Setup: Record SalarySetup;
        _invoked_CalculateBonus_WorkHours: Decimal;
        _invoked_CalculateBonus_Salary: Decimal;
        _result_CalculateBonus: Decimal;

    procedure CalculateBonus(Setup: Record SalarySetup; WorkHours: Decimal; Salary: Decimal) Bonus: Decimal
    begin
        _invoked_CalculateBonus := true;
        _invoked_CalculateBonus_Setup := Setup;
        _invoked_CalculateBonus_WorkHours := WorkHours;
        _invoked_CalculateBonus_Salary := Salary;

        Bonus := _result_CalculateBonus;
    end;

    procedure SetResult_CalculateBonus(Value: Decimal)
    begin
        _result_CalculateBonus := Value;
    end;

    procedure AssertInvoked_CalculateBonus(Setup: Record SalarySetup; Salary: Decimal)
    begin
        Assert.AreNotEqual('', Setup.PrimaryKey, 'Setup parameter is not set');

        Assert.IsTrue(_invoked_CalculateBonus, 'CalculateBonus was not invoked');
        Assert.AreEqual(Setup.PrimaryKey, _invoked_CalculateBonus_Setup.PrimaryKey, 'Setup parameter does not match');
        Assert.AreEqual(Salary, _invoked_CalculateBonus_Salary, 'Salary parameter does not match');
        Assert.AreEqual(77, _invoked_CalculateBonus_WorkHours, 'WorkHours parameter does not match'); // From stub
    end;

    #endregion
}
