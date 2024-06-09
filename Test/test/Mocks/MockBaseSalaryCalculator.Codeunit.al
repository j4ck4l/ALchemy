namespace ALchemy;

using Microsoft.HumanResources.Employee;

codeunit 60167 MockBaseSalaryCalculator implements IBaseSalaryCalculator
{
    var
        Assert: Codeunit Assert;

    var
        _invoked_CalculateBaseSalary: Boolean;
        _invoked_CalculateBaseSalary_Employee: Record Employee;
        _invoked_CalculateBaseSalary_Setup: Record SalarySetup;
        _result_CalculateBaseSalary: Decimal;

    procedure CalculateBaseSalary(Employee: Record Employee; Setup: Record SalarySetup): Decimal
    begin
        _invoked_CalculateBaseSalary := true;
        _invoked_CalculateBaseSalary_Employee := Employee;
        _invoked_CalculateBaseSalary_Setup := Setup;
        exit(_result_CalculateBaseSalary);
    end;

    procedure SetResult_CalculateBaseSalary(Value: Decimal)
    begin
        _result_CalculateBaseSalary := Value;
    end;

    procedure Assert_CalculateBaseSalary_Invoked(Employee: Record Employee; Setup: Record SalarySetup)
    begin
        Assert.AreNotEqual('', Employee."No.", 'Employee."No." is required (for this test)');
        Assert.AreNotEqual('', Setup.PrimaryKey, 'Setup.PrimaryKey is required (for this test)');

        Assert.IsTrue(_invoked_CalculateBaseSalary, 'CalculateBaseSalary was not invoked');
        Assert.AreEqual(Employee."No.", _invoked_CalculateBaseSalary_Employee."No.", 'CalculateBaseSalary was not invoked with the expected Employee');
        Assert.AreEqual(Setup.PrimaryKey, _invoked_CalculateBaseSalary_Setup.PrimaryKey, 'CalculateBaseSalary was not invoked with the expected Setup');
    end;
}
