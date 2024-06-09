namespace ALchemy;

using Microsoft.HumanResources.Employee;

codeunit 60168 MockBonusCalculator implements IBonusCalculator
{
    var
        Assert: Codeunit Assert;

    var
        _invoked_CalculateBonus: Boolean;
        _invoked_CalculateBonus_Employee: Record Employee;
        _invoked_CalculateBonus_Setup: Record SalarySetup;
        _invoked_CalculateBonus_Salary: Decimal;
        _invoked_CalculateBonus_StartingDate: Date;
        _invoked_CalculateBonus_EndingDate: Date;
        _invoked_CalculateBonus_AtDate: Date;
        _result_CalculateBonus: Decimal;

    procedure CalculateBonus(Employee: Record Employee; Setup: Record SalarySetup; Salary: Decimal; StartingDate: Date; EndingDate: Date; AtDate: Date): Decimal
    begin
        _invoked_CalculateBonus := true;
        _invoked_CalculateBonus_Employee := Employee;
        _invoked_CalculateBonus_Setup := Setup;
        _invoked_CalculateBonus_Salary := Salary;
        _invoked_CalculateBonus_StartingDate := StartingDate;
        _invoked_CalculateBonus_EndingDate := EndingDate;
        _invoked_CalculateBonus_AtDate := AtDate;
        exit(_result_CalculateBonus);
    end;

    procedure SetResult_CalculateBonus(Value: Decimal)
    begin
        _result_CalculateBonus := Value;
    end;

    procedure Assert_CalculateBonus_Invoked(Employee: Record Employee; Setup: Record SalarySetup; Salary: Decimal; StartingDate: Date; EndingDate: Date; AtDate: Date)
    begin
        Assert.AreNotEqual('', Employee."No.", 'Employee."No." is required (for this test)');
        Assert.AreNotEqual('', Setup.PrimaryKey, 'Setup.PrimaryKey is required (for this test)');
        Assert.AreNotEqual(0, Salary, 'Salary is required (for this test)');
        Assert.AreNotEqual(0, StartingDate, 'StartingDate is required (for this test)');
        Assert.AreNotEqual(0, EndingDate, 'EndingDate is required (for this test)');
        Assert.AreNotEqual(0, AtDate, 'AtDate is required (for this test)');

        Assert.IsTrue(_invoked_CalculateBonus, 'CalculateBonus was not invoked');
        Assert.AreEqual(Employee."No.", _invoked_CalculateBonus_Employee."No.", 'CalculateBonus was not invoked with the expected Employee');
        Assert.AreEqual(Setup.PrimaryKey, _invoked_CalculateBonus_Setup.PrimaryKey, 'CalculateBonus was not invoked with the expected Setup');
        Assert.AreEqual(Salary, _invoked_CalculateBonus_Salary, 'CalculateBonus was not invoked with the expected Salary');
        Assert.AreEqual(StartingDate, _invoked_CalculateBonus_StartingDate, 'CalculateBonus was not invoked with the expected StartingDate');
        Assert.AreEqual(EndingDate, _invoked_CalculateBonus_EndingDate, 'CalculateBonus was not invoked with the expected EndingDate');
        Assert.AreEqual(AtDate, _invoked_CalculateBonus_AtDate, 'CalculateBonus was not invoked with the expected AtDate');
    end;
}