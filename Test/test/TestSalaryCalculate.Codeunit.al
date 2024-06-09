namespace ALchemy;

using Microsoft.HumanResources.Employee;

codeunit 60166 "Test - Salary Calculate"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;

    [Test]
    procedure Test_SalaryCalculate_CalculateSalary()
    var
        Employee: Record Employee;
        Setup: Record SalarySetup;
        Result: Record MonthlySalary;
        SalaryCalculate: Codeunit SalaryCalculate;
        MockBaseSalaryCalculator: Codeunit MockBaseSalaryCalculator;
        MockBonusCalculator: Codeunit MockBonusCalculator;
        MockIncentiveCalculator: Codeunit MockIncentiveCalculator;
        AtDate: Date;
        Salary, Bonus, Incentive : Decimal;
    begin
        Employee."No." := 'DUMMY_EMP';
        Setup.PrimaryKey := 'DUMMY_STP';
        AtDate := Today();

        Salary := Random(100000) / 100;
        Bonus := Random(10000) / 100;
        Incentive := Random(10000) / 100;
        MockBaseSalaryCalculator.SetResult_CalculateBaseSalary(Salary);
        MockBonusCalculator.SetResult_CalculateBonus(Bonus);
        MockIncentiveCalculator.SetResult_CalculateIncentive(Incentive);

        Result := SalaryCalculate.CalculateSalary(Employee, Setup, AtDate, MockBaseSalaryCalculator, MockBonusCalculator, MockIncentiveCalculator);

        Assert.AreEqual(Employee."No.", Result.EmployeeNo, 'EmployeeNo');
        Assert.AreEqual(AtDate, Result.Date, 'Date');
        Assert.AreEqual(Salary, Result.Salary, 'Salary');
        Assert.AreEqual(Bonus, Result.Bonus, 'Bonus');
        Assert.AreEqual(Incentive, Result.Incentive, 'Incentive');
        MockBaseSalaryCalculator.Assert_CalculateBaseSalary_Invoked(Employee, Setup);
        MockBonusCalculator.Assert_CalculateBonus_Invoked(Employee, Setup, Salary, CalcDate('<CM+1D-1M>', AtDate), CalcDate('<CM>', AtDate), AtDate);
        MockIncentiveCalculator.Assert_CalculateIncentive_Invoked(Employee, Setup, Salary, AtDate);
    end;

    [Test]
    procedure Test_Employee_CalculateSalary()
    var
        Employee: Record Employee;
        MonthlySalary, Result : Record MonthlySalary;
        MockSalaryCalculate: Codeunit MockSalaryCalculate;
    begin
        MonthlySalary.Date := 20230101D;
        MonthlySalary.EmployeeNo := 'DUMMY';
        MonthlySalary.Salary := 1000;
        MonthlySalary.Bonus := 100;
        MonthlySalary.Incentive := 10;
        MockSalaryCalculate.SetResult_CalculateSalary(MonthlySalary);
        Employee.Implement(MockSalaryCalculate);

        Result := Employee.CalculateSalary(WorkDate());

        Assert.AreEqual(Result.Date, MonthlySalary.Date, 'Date not assigned correctly');
        Assert.AreEqual(Result.EmployeeNo, MonthlySalary.EmployeeNo, 'EmployeeNo not assigned correctly');
        Assert.AreEqual(Result.Salary, MonthlySalary.Salary, 'Salary not assigned correctly');
        Assert.AreEqual(Result.Bonus, MonthlySalary.Bonus, 'Bonus not assigned correctly');
        Assert.AreEqual(Result.Incentive, MonthlySalary.Incentive, 'Incentive not assigned correctly');
    end;
}
