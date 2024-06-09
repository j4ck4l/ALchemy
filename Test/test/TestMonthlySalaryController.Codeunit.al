codeunit 60171 "Test - MonthlySalaryController"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;

    [Test]
    procedure Test_ProcessEmployee()
    var
        Employee: Record Employee;
        MonthlySalaryTmp: Record MonthlySalary temporary;
        MonthlySalaryController: Codeunit MonthlySalaryController;
        MockSalaryCalculate: Codeunit MockSalaryCalculate;
        AtDate: Date;
    begin
        Employee."No." := 'DUMMY';
        Employee.Implement(MockSalaryCalculate);
        AtDate := Today();

        MonthlySalaryController.ProcessEmployee(Employee, MonthlySalaryTmp, AtDate);

        MonthlySalaryTmp.Find();
        MockSalaryCalculate.AssertInvoked_CalculateSalary(Employee, AtDate);
    end;

    [Test]
    procedure Test_ProcessEmployees()
    var
        EmployeeTmp: Record Employee temporary;
        MonthlySalaryTmp: Record MonthlySalary temporary;
        MonthlySalaryController: Codeunit MonthlySalaryController;
        MockMonthlySalaryController: Codeunit MockMonthlySalaryController;
    begin
        EmployeeTmp."No." := 'DUMMY_1';
        EmployeeTmp.Status := "Employee Status"::Active;
        EmployeeTmp.Insert();
        EmployeeTmp."No." := 'DUMMY_2';
        EmployeeTmp.Insert();
        EmployeeTmp."No." := 'DUMMY_3';
        EmployeeTmp.Insert();
        EmployeeTmp.Status := "Employee Status"::Inactive;

        MonthlySalaryController.ProcessEmployees(EmployeeTmp, MonthlySalaryTmp, 20240102D, MockMonthlySalaryController);

        MockMonthlySalaryController.AssertInvoked_ProcessEmployee(3, 'DUMMY_1', 20240102D);
        MockMonthlySalaryController.AssertInvoked_ProcessEmployee(3, 'DUMMY_2', 20240102D);
        MockMonthlySalaryController.AssertInvoked_ProcessEmployee(3, 'DUMMY_3', 20240102D);
    end;

    [Test]
    procedure Test_CalculateMonthlySalaries()
    var
        MonthlySalaryTmp: Record MonthlySalary temporary;
        Employee: Record Employee;
        MonthlySalaryController: Codeunit MonthlySalaryController;
        MockMonthlySalaryController: Codeunit MockMonthlySalaryController;
        AtDate: Date;
    begin
        AtDate := 20240102D;
        Employee.SetRange(Status, Employee.Status::Active);
        MonthlySalaryController.Implement(MockMonthlySalaryController);

        MonthlySalaryController.CalculateMonthlySalaries(MonthlySalaryTmp, AtDate, MockMonthlySalaryController);

        MockMonthlySalaryController.AssertInvoked_ProcessEmployees(Employee.GetFilters(), AtDate);
    end;

    [Test]
    procedure Test_DeleteMonthlySalaries()
    var
        MonthlySalaryTmp: Record MonthlySalary temporary;
        MonthlySalary: Record MonthlySalary;
        MonthlySalaryController: Codeunit MonthlySalaryController;
    begin
        MonthlySalaryTmp.EntryNo := 1;
        MonthlySalaryTmp.Date := 20240102D;
        MonthlySalaryTmp.Insert();
        MonthlySalaryTmp.EntryNo := 2;
        MonthlySalaryTmp.Insert();
        MonthlySalaryTmp.Date := 20230102D;
        MonthlySalaryTmp.EntryNo := 3;
        MonthlySalaryTmp.Insert();

        MonthlySalaryController.DeleteMonthlySalaries(MonthlySalaryTmp, 20240102D);

        MonthlySalary.SetRange(Date, 20240102D);
        Assert.AreEqual(MonthlySalary.GetFilters(), MonthlySalaryTmp.GetFilters(), 'Incorrect monthly salaries were deleted');
        Assert.AreEqual(0, MonthlySalaryTmp.Count, 'Incorrect monthly salaries were deleted');
        MonthlySalaryTmp.Reset();
        Assert.AreEqual(1, MonthlySalaryTmp.Count, 'Incorrect monthly salaries were deleted');
    end;
}
