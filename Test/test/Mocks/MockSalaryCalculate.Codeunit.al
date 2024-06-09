namespace ALchemy;

using Microsoft.HumanResources.Employee;

codeunit 60165 MockSalaryCalculate implements ISalaryCalculate
{
    Access = Internal;

    var
        Assert: Codeunit Assert;

    var
        _result_CalculateSalary: Record MonthlySalary;
        _invoked_CalculateSalary_Employee: Record Employee;
        _invoked_CalculateSalary_AtDate: Date;

    procedure CalculateSalary(var Employee: Record Employee; AtDate: Date) Result: Record MonthlySalary
    begin
        _invoked_CalculateSalary_Employee := Employee;
        _invoked_CalculateSalary_AtDate := AtDate;
        exit(_result_CalculateSalary);
    end;

    procedure SetResult_CalculateSalary(Result: Record MonthlySalary)
    begin
        _result_CalculateSalary := Result;
    end;

    procedure AssertInvoked_CalculateSalary(Employee: Record Employee; AtDate: Date)
    begin
        Assert.AreNotEqual('', Employee."No.", 'Employee."No." is required');

        Assert.AreEqual(Employee."No.", _invoked_CalculateSalary_Employee."No.", 'CalculateSalary was not invoked with the expected Employee');
        Assert.AreEqual(AtDate, _invoked_CalculateSalary_AtDate, 'CalculateSalary was not invoked with the expected AtDate');
    end;
}
