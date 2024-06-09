namespace ALchemy;

using Microsoft.HumanResources.Employee;

codeunit 60169 MockIncentiveCalculator implements IIncentiveCalculator
{
    var
        Assert: Codeunit Assert;

    var
        _invoked_CalculateIncentive: Boolean;
        _invoked_CalculateIncentive_Employee: Record Employee;
        _invoked_CalculateIncentive_Setup: Record SalarySetup;
        _invoked_CalculateIncentive_Salary: Decimal;
        _invoked_CalculateIncentive_AtDate: Date;
        _result_CalculateIncentive: Decimal;

    procedure CalculateIncentive(Employee: Record Employee; Setup: Record SalarySetup; Salary: Decimal; AtDate: Date): Decimal
    begin
        _invoked_CalculateIncentive := true;
        _invoked_CalculateIncentive_Employee := Employee;
        _invoked_CalculateIncentive_Setup := Setup;
        _invoked_CalculateIncentive_Salary := Salary;
        _invoked_CalculateIncentive_AtDate := AtDate;
        exit(_result_CalculateIncentive);
    end;

    procedure SetResult_CalculateIncentive(Value: Decimal)
    begin
        _result_CalculateIncentive := Value;
    end;

    procedure Assert_CalculateIncentive_Invoked(Employee: Record Employee; Setup: Record SalarySetup; Salary: Decimal; AtDate: Date)
    begin
        Assert.AreNotEqual('', Employee."No.", 'Employee."No." is required (for this test)');
        Assert.AreNotEqual('', Setup.PrimaryKey, 'Setup.PrimaryKey is required (for this test)');
        Assert.AreNotEqual(0, Salary, 'Salary is required (for this test)');
        Assert.AreNotEqual(0, AtDate, 'AtDate is required (for this test)');

        Assert.IsTrue(_invoked_CalculateIncentive, 'CalculateIncentive was not invoked');
        Assert.AreEqual(Employee."No.", _invoked_CalculateIncentive_Employee."No.", 'CalculateIncentive was not invoked with the expected Employee');
        Assert.AreEqual(Setup.PrimaryKey, _invoked_CalculateIncentive_Setup.PrimaryKey, 'CalculateIncentive was not invoked with the expected Setup');
        Assert.AreEqual(Salary, _invoked_CalculateIncentive_Salary, 'CalculateIncentive was not invoked with the expected Salary');
        Assert.AreEqual(AtDate, _invoked_CalculateIncentive_AtDate, 'CalculateIncentive was not invoked with the expected AtDate');
    end;
}