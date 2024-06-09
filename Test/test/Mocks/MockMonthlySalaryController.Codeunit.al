namespace ALchemy;

using Microsoft.HumanResources.Employee;

codeunit 60172 MockMonthlySalaryController implements IMonthlySalaryController
{
    Access = Internal;

    var
        Assert: Codeunit Assert;

    procedure DeleteMonthlySalaries(var MonthlySalary: Record MonthlySalary; AtDate: Date)
    begin

    end;

    procedure CalculateMonthlySalaries(var MonthlySalary: Record MonthlySalary; AtDate: Date)
    begin

    end;

    #region ProcessEmployees

    var
        _invoked_ProcessEmployees: Boolean;
        _invoked_ProcessEmployees_Employee: Record Employee;
        _invoked_ProcessEmployees_AtDate: Date;

    procedure ProcessEmployees(var Employee: Record Employee; var MonthlySalary: Record MonthlySalary; AtDate: Date; Controller: Interface IMonthlySalaryController)
    begin
        _invoked_ProcessEmployees := true;
        _invoked_ProcessEmployees_Employee.CopyFilters(Employee);
        _invoked_ProcessEmployees_AtDate := AtDate;
    end;

    procedure AssertInvoked_ProcessEmployees(Filters: Text; AtDate: Date)
    begin
        Assert.IsTrue(_invoked_ProcessEmployees, 'ProcessEmployees was not invoked');
        Assert.AreEqual(Filters, _invoked_ProcessEmployees_Employee.GetFilters(), 'Employee filters do not match');
        Assert.AreEqual(AtDate, _invoked_ProcessEmployees_AtDate, 'AtDate parameter does not match');
    end;

    #endregion

    #region ProcessEmployee

    var
        _invoked_ProcessEmployee_Count: Integer;
        _invoked_ProcessEmployee_Employee: List of [Code[20]];
        _invoked_ProcessEmployee_AtDate: Date;
        _assertInvoked_ProcessEmployee_Count: Integer;

    procedure ProcessEmployee(var Employee: Record Employee; var MonthlySalary: Record MonthlySalary; AtDate: Date)
    begin
        if _invoked_ProcessEmployee_Count > 0 then
            Assert.AreEqual(_invoked_ProcessEmployee_AtDate, AtDate, 'All employees must be processed with the same AtDate');

        _invoked_ProcessEmployee_Count += 1;
        _invoked_ProcessEmployee_Employee.Add(Employee."No.");
        _invoked_ProcessEmployee_AtDate := AtDate;
    end;

    procedure AssertInvoked_ProcessEmployee(Count: Integer; EmployeeNo: Code[10]; AtDate: Date)
    begin
        _assertInvoked_ProcessEmployee_Count += 1;
        Assert.AreEqual(Count, _invoked_ProcessEmployee_Count, 'ProcessEmployee was not invoked the expected number of times');
        Assert.AreEqual(AtDate, _invoked_ProcessEmployee_AtDate, 'AtDate parameter does not match');
        Assert.AreEqual(EmployeeNo, _invoked_ProcessEmployee_Employee.Get(_assertInvoked_ProcessEmployee_Count), 'Employee parameter does not match');
    end;

    #endregion

}
