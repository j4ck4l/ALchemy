namespace ALchemy;

using Microsoft.HumanResources.Employee;
using Microsoft.Sales.Receivables;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.GeneralLedger.Account;

codeunit 60156 "Test - SalaryType"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        Fixtures: Codeunit Fixtures;

    [Test]
    procedure Test_SalaryType_Fixed()
    var
        Salary: Interface IBaseSalaryCalculator;
        Bonus: Interface IBonusCalculator;
        Incentive: Interface IIncentiveCalculator;
    begin
        Salary := SalaryType::Fixed;
        Bonus := SalaryType::Fixed;
        Incentive := SalaryType::Fixed;

        Assert.AreEqual(Format(Codeunit::DefaultBaseSalaryCalculator), Format(Salary), 'Incorrect base salary calculator returned');
        Assert.AreEqual(Format(Codeunit::NoBonus), Format(Bonus), 'Incorrect bonus calculator returned');
        Assert.AreEqual(Format(Codeunit::DefaultIncentiveCalculator), Format(Incentive), 'Incorrect incentive calculator returned');
    end;

    [Test]
    procedure Test_SalaryType_Timesheet()
    var
        Salary: Interface IBaseSalaryCalculator;
        Bonus: Interface IBonusCalculator;
        Incentive: Interface IIncentiveCalculator;
    begin
        Salary := SalaryType::Timesheet;
        Bonus := SalaryType::Timesheet;
        Incentive := SalaryType::Timesheet;

        Assert.AreEqual(Format(Codeunit::DefaultBaseSalaryCalculator), Format(Salary), 'Incorrect base salary calculator returned');
        Assert.AreEqual(Format(Codeunit::BonusCalculatorTimesheet), Format(Bonus), 'Incorrect bonus calculator returned');
        Assert.AreEqual(Format(Codeunit::DefaultIncentiveCalculator), Format(Incentive), 'Incorrect incentive calculator returned');
    end;

    [Test]
    procedure Test_SalaryType_Commission()
    var
        Salary: Interface IBaseSalaryCalculator;
        Bonus: Interface IBonusCalculator;
        Incentive: Interface IIncentiveCalculator;
    begin
        Salary := SalaryType::Commission;
        Bonus := SalaryType::Commission;
        Incentive := SalaryType::Commission;

        Assert.AreEqual(Format(Codeunit::DefaultBaseSalaryCalculator), Format(Salary), 'Incorrect base salary calculator returned');
        Assert.AreEqual(Format(Codeunit::BonusCalculatorCommission), Format(Bonus), 'Incorrect bonus calculator returned');
        Assert.AreEqual(Format(Codeunit::DefaultIncentiveCalculator), Format(Incentive), 'Incorrect incentive calculator returned');
    end;

    [Test]
    procedure Test_SalaryType_Target()
    var
        Salary: Interface IBaseSalaryCalculator;
        Bonus: Interface IBonusCalculator;
        Incentive: Interface IIncentiveCalculator;
    begin
        Salary := SalaryType::Target;
        Bonus := SalaryType::Target;
        Incentive := SalaryType::Target;

        Assert.AreEqual(Format(Codeunit::DefaultBaseSalaryCalculator), Format(Salary), 'Incorrect base salary calculator returned');
        Assert.AreEqual(Format(Codeunit::BonusCalculatorTarget), Format(Bonus), 'Incorrect bonus calculator returned');
        Assert.AreEqual(Format(Codeunit::DefaultIncentiveCalculator), Format(Incentive), 'Incorrect incentive calculator returned');
    end;

    [Test]
    procedure Test_SalaryType_Performance()
    var
        Salary: Interface IBaseSalaryCalculator;
        Bonus: Interface IBonusCalculator;
        Incentive: Interface IIncentiveCalculator;
    begin
        Salary := SalaryType::Performance;
        Bonus := SalaryType::Performance;
        Incentive := SalaryType::Performance;

        Assert.AreEqual(Format(Codeunit::NoBaseSalary), Format(Salary), 'Incorrect base salary calculator returned');
        Assert.AreEqual(Format(Codeunit::BonusCalculatorPerformance), Format(Bonus), 'Incorrect bonus calculator returned');
        Assert.AreEqual(Format(Codeunit::NoIncentive), Format(Incentive), 'Incorrect incentive calculator returned');
    end;

    [Test]
    procedure Test_DefaultBaseSalaryCalculator_CalculateBaseSalary_TestfieldBaseSalary()
    var
        Setup: Record SalarySetup;
        Employee: Record Employee;
        DefaultBaseSalaryCalculator: Codeunit DefaultBaseSalaryCalculator;
    begin
        asserterror DefaultBaseSalaryCalculator.CalculateBaseSalary(Employee, Setup);
        Assert.ExpectedErrorCode('TestField');
        Assert.IsSubstring(GetLastErrorText(), Setup.FieldCaption(BaseSalary));
    end;

    [Test]
    procedure Test_DefaultBaseSalaryCalculator_CalculateBaseSalary_EmployeeSalary()
    var
        Setup: Record SalarySetup;
        Employee: Record Employee;
        DefaultBaseSalaryCalculator: Codeunit DefaultBaseSalaryCalculator;
        BaseSalary: Decimal;
    begin
        Setup.BaseSalary := 1000;
        Employee.BaseSalary := 1300;

        BaseSalary := DefaultBaseSalaryCalculator.CalculateBaseSalary(Employee, Setup);

        Assert.AreEqual(1300, BaseSalary, 'Incorrect base salary returned');
    end;

    [Test]
    procedure Test_DefaultBaseSalaryCalculator_CalculateBaseSalary_SetupBaseSalary()
    var
        Setup: Record SalarySetup;
        Employee: Record Employee;
        DefaultBaseSalaryCalculator: Codeunit DefaultBaseSalaryCalculator;
        BaseSalary: Decimal;
    begin
        Setup.BaseSalary := 1000;
        Employee.BaseSalary := 0;

        BaseSalary := DefaultBaseSalaryCalculator.CalculateBaseSalary(Employee, Setup);

        Assert.AreEqual(1000, BaseSalary, 'Incorrect base salary returned');
    end;

    [Test]
    procedure Test_DefaultBaseSalaryCalculator_CalculateBaseSalary_DepartmentBaseSalary()
    var
        Setup: Record SalarySetup;
        Employee: Record Employee;
        DefaultBaseSalaryCalculator: Codeunit DefaultBaseSalaryCalculator;
        BaseSalary: Decimal;
    begin
        Setup.BaseSalary := 1000;
        Employee.BaseSalary := 0;
        Employee.DepartmentCode := Fixtures.Department.Code;
        Employee.Seniority := Seniority::Lead;

        BaseSalary := DefaultBaseSalaryCalculator.CalculateBaseSalary(Employee, Setup);

        Assert.AreEqual(1111, BaseSalary, 'Incorrect base salary returned');
    end;

    [Test]
    procedure Test_DefaultBaseSalaryCalculator_CalculateBaseSalary_DepartmentSeniorityBaseSalary()
    var
        Setup: Record SalarySetup;
        Employee: Record Employee;
        DefaultBaseSalaryCalculator: Codeunit DefaultBaseSalaryCalculator;
        BaseSalary: Decimal;
    begin
        Setup.BaseSalary := 1000;
        Employee.BaseSalary := 0;
        Employee.DepartmentCode := Fixtures.Department.Code;
        Employee.Seniority := Fixtures.DepartmentSenioritySetup.Seniority;

        BaseSalary := DefaultBaseSalaryCalculator.CalculateBaseSalary(Employee, Setup);

        Assert.AreEqual(2222, BaseSalary, 'Incorrect base salary returned');
    end;

    [Test]
    procedure Test_NoBaseSalary_CalculateBaseSalary()
    var
        Setup: Record SalarySetup;
        Employee: Record Employee;
        NoBaseSalary: Codeunit NoBaseSalary;
        BaseSalary: Decimal;
    begin
        Setup.BaseSalary := 1000;
        Employee.BaseSalary := 1300;

        BaseSalary := NoBaseSalary.CalculateBaseSalary(Employee, Setup);

        Assert.AreEqual(0, BaseSalary, 'Incorrect base salary returned');
    end;

    [Test]
    procedure Test_BonusCalculatorCommission_TestField()
    var
        Employee: Record Employee;
        Setup: Record SalarySetup;
        BonusCalculatorCommission: Codeunit BonusCalculatorCommission;
    begin
        asserterror BonusCalculatorCommission.CalculateBonus(Employee, Setup, 0, Today(), Today(), Today());
        Assert.ExpectedErrorCode('TestField');
        Assert.IsSubstring(GetLastErrorText(), Employee.FieldCaption("Salespers./Purch. Code"));
    end;

    [Test]
    procedure Test_BonusCalculatorCommission_Controller_PrepareCustLedgEntry()
    var
        Employee: Record Employee;
        CustLedgEntry: Record "Cust. Ledger Entry";
        BonusCalculatorCommission: Codeunit BonusCalculatorCommission;
        StartingDate: Date;
        EndingDate: Date;
    begin
        StartingDate := CalcDate('<-10D>', Today());
        EndingDate := CalcDate('<+10D>', Today());
        Employee."Salespers./Purch. Code" := 'DUMMY';

        BonusCalculatorCommission.PrepareCustLedgEntry(Employee, StartingDate, EndingDate, CustLedgEntry);

        Assert.AreEqual(StartingDate, CustLedgEntry.GetRangeMin("Posting Date"), 'Incorrect starting date filter');
        Assert.AreEqual(EndingDate, CustLedgEntry.GetRangeMax("Posting Date"), 'Incorrect ending date filter');
        Assert.AreEqual('DUMMY', CustLedgEntry.GetFilter("Salesperson Code"), 'Incorrect salesperson code filter');
        Assert.AreEqual(StrSubstNo('%1|%2', "Gen. Journal Document Type"::Invoice, "Gen. Journal Document Type"::"Credit Memo"), CustLedgEntry.GetFilter("Document Type"), 'Incorrect document type filter');
    end;

    [Test]
    procedure Test_BonusCalculatorCommission_Controller_CalculateBonus()
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
        BonusCalculatorCommission: Codeunit BonusCalculatorCommission;
        Bonus: Decimal;
    begin
        CustLedgEntry."Profit (LCY)" := 1230;

        Bonus := BonusCalculatorCommission.CalculateBonus(10, CustLedgEntry);

        Assert.AreEqual(123, Bonus, 'Incorrect bonus calculated');
    end;

    [Test]
    procedure Test_BonusCalculatorCommission_CalculateBonus_TestField()
    var
        Employee: Record Employee;
        Setup: Record SalarySetup;
        BonusCalculatorCommission: Codeunit BonusCalculatorCommission;
    begin
        asserterror BonusCalculatorCommission.CalculateBonus(Employee, Setup, 0, Today(), Today(), Today());
        Assert.ExpectedErrorCode('TestField');
        Assert.IsSubstring(GetLastErrorText(), Employee.FieldCaption("Salespers./Purch. Code"));
    end;

    [Test]
    procedure Test_BonusCalculatorCommission_CalculateBonus()
    var
        Employee: Record Employee;
        Setup: Record SalarySetup;
        BonusCalculatorCommission: Codeunit BonusCalculatorCommission;
        MockController: Codeunit MockCommissionController;
        StartingDate: Date;
        EndingDate: Date;
        Bonus: Decimal;
    begin
        StartingDate := CalcDate('<-10D>', Today());
        EndingDate := CalcDate('<+10D>', Today());
        Employee."No." := 'DUMMY';
        Employee."Salespers./Purch. Code" := 'DUMMY';
        MockController.SetResult_CalculateBonus(234);
        BonusCalculatorCommission.Implement(MockController);

        Bonus := BonusCalculatorCommission.CalculateBonus(Employee, Setup, 0, StartingDate, EndingDate, Today());

        Assert.AreEqual(234, Bonus, 'Incorrect bonus calculated');
        MockController.AssertInvoked_PrepareCustLedgEntry(Employee, StartingDate, EndingDate);
        MockController.AssertInvoked_CalculateBonus_ExpectedCustLedgEntry();
    end;

    [Test]
    procedure Test_BonusCalculatorCommission_CalculateBonus_DI()
    var
        Employee: Record Employee;
        Setup: Record SalarySetup;
        BonusCalculatorCommission: Codeunit BonusCalculatorCommission;
        MockController: Codeunit MockCommissionController;
        StartingDate: Date;
        EndingDate: Date;
        Bonus: Decimal;
    begin
        StartingDate := CalcDate('<-20D>', Today());
        EndingDate := CalcDate('<+20D>', Today());
        Employee."No." := 'DUMMY_DI';
        MockController.SetResult_CalculateBonus(345);

        Bonus := BonusCalculatorCommission.CalculateBonus(Employee, StartingDate, EndingDate, MockController);

        Assert.AreEqual(345, Bonus, 'Incorrect bonus calculated');
        MockController.AssertInvoked_PrepareCustLedgEntry(Employee, StartingDate, EndingDate);
        MockController.AssertInvoked_CalculateBonus_ExpectedCustLedgEntry();
    end;

    [Test]
    procedure Test_BonusCalculatorPerformance_FilterGLEntry()
    var
        GLEntry: Record "G/L Entry";
        BonusCalculatorPerformance: Codeunit BonusCalculatorPerformance;
        StartingDate: Date;
        EndingDate: Date;
    begin
        StartingDate := CalcDate('<-11D>', Today());
        EndingDate := CalcDate('<+11D>', Today());

        BonusCalculatorPerformance.FilterGLEntry(GLEntry, 'INCOME', StartingDate, EndingDate);

        Assert.AreEqual(StartingDate, GLEntry.GetRangeMin("Posting Date"), 'Incorrect starting date filter');
        Assert.AreEqual(EndingDate, GLEntry.GetRangeMax("Posting Date"), 'Incorrect ending date filter');
        Assert.AreEqual('INCOME', GLEntry.GetFilter("G/L Account No."), 'Incorrect G/L account filter');
        Assert.AreEqual(0, GLEntry.Amount, 'Incorrect amount filter');
    end;

    [Test]
    procedure Test_BonusCalculatorPerformance_CalculateBonus_0Pct()
    var
        BonusCalculatorPerformance: Codeunit BonusCalculatorPerformance;
        Bonus: Decimal;
    begin
        Bonus := BonusCalculatorPerformance.CalculateBonus(1000, 500, 0);

        Assert.AreEqual(0, Bonus, 'Incorrect bonus calculated');
    end;

    [Test]
    procedure Test_BonusCalculatorPerformance_CalculateBonus_0Amt()
    var
        BonusCalculatorPerformance: Codeunit BonusCalculatorPerformance;
        Bonus: Decimal;
    begin
        Bonus := BonusCalculatorPerformance.CalculateBonus(1000, 1000, 10);

        Assert.AreEqual(0, Bonus, 'Incorrect bonus calculated');
    end;

    [Test]
    procedure Test_BonusCalculatorPerformance_CalculateBonus_Non0()
    var
        BonusCalculatorPerformance: Codeunit BonusCalculatorPerformance;
        Bonus: Decimal;
    begin
        Bonus := BonusCalculatorPerformance.CalculateBonus(1000, 550, 22);

        Assert.AreEqual(99, Bonus, 'Incorrect bonus calculated');
    end;

    [Test]
    procedure Test_BonusCalculatorPerformance_CalculateBonus_Collaboration()
    var
        Employee: Record Employee;
        GLAccountIncome, GLAccountExpense : Record "G/L Account";
        BonusCalculatorPerformance: Codeunit BonusCalculatorPerformance;
        MockController: Codeunit MockPerformanceController;
        StartingDate: Date;
        EndingDate: Date;
        Bonus: Decimal;
    begin
        StartingDate := CalcDate('<-20D>', Today());
        EndingDate := CalcDate('<+20D>', Today());
        Employee."No." := 'DUMMY';
        Employee.PerformanceBonusPct := 33;
        GLAccountIncome."No." := 'DUMMY_INCOME';
        GLAccountExpense."No." := 'DUMMY_EXPENSE';
        MockController.SetAmount_FilterGLEntry(900);
        MockController.SetAmount_FilterGLEntry(300);
        MockController.SetResult_CalculateBonus(789);

        Bonus := BonusCalculatorPerformance.CalculateBonus(Employee, 1000, StartingDate, EndingDate, GLAccountIncome, GLAccountExpense, MockController);

        Assert.AreEqual(789, Bonus, 'Incorrect bonus calculated');
        MockController.AssertInvoked_FilterGLEntry('DUMMY_INCOME', StartingDate, EndingDate);
        MockController.AssertInvoked_FilterGLEntry('DUMMY_EXPENSE', StartingDate, EndingDate);
        MockController.AssertInvoked_CalculateBonus(900, 300, Employee.PerformanceBonusPct);
    end;

    [Test]
    procedure Test_BonusCalculatorPerformance_CalculateBonus_DI()
    var
        Employee: Record Employee;
        Setup: Record SalarySetup;
        BonusCalculatorPerformance: Codeunit BonusCalculatorPerformance;
        MockController: Codeunit MockPerformanceController;
        StartingDate: Date;
        EndingDate: Date;
        Bonus: Decimal;
    begin
        StartingDate := CalcDate('<-33D>', Today());
        EndingDate := CalcDate('<+33D>', Today());
        Employee."No." := 'DUMMY_DI';
        Setup.IncomeAccountNo := 'DUMMY_INCOME_DI';
        Setup.ExpenseAccountNo := 'DUMMY_EXPENSE_DI';
        MockController.SetResult_CalculateBonus_DI(468);

        Bonus := BonusCalculatorPerformance.CalculateBonus(Employee, Setup, 1000, StartingDate, EndingDate, MockController);

        Assert.AreEqual(468, Bonus, 'Incorrect bonus calculated');
        MockController.AssertInvoked_CalculateBonus_DI(Employee."No.", 1000, StartingDate, EndingDate, 'DUMMY_INCOME_DI', 'DUMMY_EXPENSE_DI');
    end;

    [Test]
    procedure Test_BonusCalculatorPerformance_CalculateBonus()
    var
        Employee: Record Employee;
        Setup: Record SalarySetup;
        BonusCalculatorPerformance: Codeunit BonusCalculatorPerformance;
        MockController: Codeunit MockPerformanceController;
        StartingDate: Date;
        EndingDate: Date;
        Bonus: Decimal;
    begin
        StartingDate := CalcDate('<-34D>', Today());
        EndingDate := CalcDate('<+34D>', Today());
        Employee."No." := 'DUMMY';
        Setup.IncomeAccountNo := 'DUMMY_INCOME';
        Setup.ExpenseAccountNo := 'DUMMY_EXPENSE';
        MockController.SetResult_CalculateBonus_DI(975);
        BonusCalculatorPerformance.Implement(MockController);

        Bonus := BonusCalculatorPerformance.CalculateBonus(Employee, Setup, 999, StartingDate, EndingDate, Today());

        Assert.AreEqual(975, Bonus, 'Incorrect bonus calculated');
        MockController.AssertInvoked_CalculateBonus_DI(Employee."No.", 999, StartingDate, EndingDate, 'DUMMY_INCOME', 'DUMMY_EXPENSE');
    end;

    [Test]
    procedure Test_BonusCalculatorTarget_CalculateBonus_ExceedsMaximum_MaximumDefined()
    var
        Employee: Record Employee;
        CustLedgEntry: Record "Cust. Ledger Entry";
        BonusCalculatorTarget: Codeunit BonusCalculatorTarget;
        Bonus: Decimal;
    begin
        Employee.TargetBonus := 1000;
        Employee.TargetRevenue := 10000;
        Employee.MaximumTargetBonus := 500;
        CustLedgEntry."Sales (LCY)" := 6000;

        Bonus := BonusCalculatorTarget.CalculateBonus(Employee, CustLedgEntry);

        Assert.AreEqual(500, Bonus, 'Incorrect bonus calculated');
    end;

    [Test]
    procedure Test_BonusCalculatorTarget_CalculateBonus_ExceedsMaximum_MaximumNotDefined()
    var
        Employee: Record Employee;
        CustLedgEntry: Record "Cust. Ledger Entry";
        BonusCalculatorTarget: Codeunit BonusCalculatorTarget;
        Bonus: Decimal;
    begin
        Employee.TargetBonus := 1000;
        Employee.TargetRevenue := 10000;
        Employee.MaximumTargetBonus := 0;
        CustLedgEntry."Sales (LCY)" := 6000;

        Bonus := BonusCalculatorTarget.CalculateBonus(Employee, CustLedgEntry);

        Assert.AreEqual(600, Bonus, 'Incorrect bonus calculated');
    end;

    [Test]
    procedure Test_BonusCalculatorTarget_CalculateBonus_DoesNotExceedMaximum()
    var
        Employee: Record Employee;
        CustLedgEntry: Record "Cust. Ledger Entry";
        BonusCalculatorTarget: Codeunit BonusCalculatorTarget;
        Bonus: Decimal;
    begin
        Employee.TargetBonus := 1000;
        Employee.TargetRevenue := 10000;
        Employee.MaximumTargetBonus := 500;
        CustLedgEntry."Sales (LCY)" := 4000;

        Bonus := BonusCalculatorTarget.CalculateBonus(Employee, CustLedgEntry);

        Assert.AreEqual(400, Bonus, 'Incorrect bonus calculated');
    end;

    [Test]
    procedure Test_BonusCalculatorTarget_CalculateBonus_ExceedsMinimum_MinimumDefined()
    var
        Employee: Record Employee;
        CustLedgEntry: Record "Cust. Ledger Entry";
        BonusCalculatorTarget: Codeunit BonusCalculatorTarget;
        Bonus: Decimal;
    begin
        Employee.TargetBonus := 1000;
        Employee.TargetRevenue := 10000;
        Employee.MaximumTargetMalus := -500;
        CustLedgEntry."Sales (LCY)" := -6000;

        Bonus := BonusCalculatorTarget.CalculateBonus(Employee, CustLedgEntry);

        Assert.AreEqual(-500, Bonus, 'Incorrect bonus calculated');
    end;

    [Test]
    procedure Test_BonusCalculatorTarget_CalculateBonus_ExceedsMinimum_MinimumNotDefined()
    var
        Employee: Record Employee;
        CustLedgEntry: Record "Cust. Ledger Entry";
        BonusCalculatorTarget: Codeunit BonusCalculatorTarget;
        Bonus: Decimal;
    begin
        Employee.TargetBonus := 1000;
        Employee.TargetRevenue := 10000;
        Employee.MaximumTargetMalus := 0;
        CustLedgEntry."Sales (LCY)" := -6000;

        Bonus := BonusCalculatorTarget.CalculateBonus(Employee, CustLedgEntry);

        Assert.AreEqual(-600, Bonus, 'Incorrect bonus calculated');
    end;

    [Test]
    procedure Test_BonusCalculatorTarget_CalculateBonus_DoesNotExceedMinimum()
    var
        Employee: Record Employee;
        CustLedgEntry: Record "Cust. Ledger Entry";
        BonusCalculatorTarget: Codeunit BonusCalculatorTarget;
        Bonus: Decimal;
    begin
        Employee.TargetBonus := 1000;
        Employee.TargetRevenue := 10000;
        Employee.MaximumTargetMalus := -600;
        CustLedgEntry."Sales (LCY)" := -5000;

        Bonus := BonusCalculatorTarget.CalculateBonus(Employee, CustLedgEntry);

        Assert.AreEqual(-500, Bonus, 'Incorrect bonus calculated');
    end;

    [Test]
    procedure Test_BonusCalculatorTarget_Controller_PrepareCustLedgEntry()
    var
        Employee: Record Employee;
        CustLedgEntry: Record "Cust. Ledger Entry";
        BonusCalculatorTarget: Codeunit BonusCalculatorTarget;
        StartingDate: Date;
        EndingDate: Date;
    begin
        StartingDate := CalcDate('<-10D>', Today());
        EndingDate := CalcDate('<+10D>', Today());
        Employee."Salespers./Purch. Code" := 'DUMMY';

        BonusCalculatorTarget.PrepareCustLedgEntry(Employee, StartingDate, EndingDate, CustLedgEntry);

        Assert.AreEqual(StartingDate, CustLedgEntry.GetRangeMin("Posting Date"), 'Incorrect starting date filter');
        Assert.AreEqual(EndingDate, CustLedgEntry.GetRangeMax("Posting Date"), 'Incorrect ending date filter');
        Assert.AreEqual('DUMMY', CustLedgEntry.GetFilter("Salesperson Code"), 'Incorrect salesperson code filter');
        Assert.AreEqual(StrSubstNo('%1|%2', "Gen. Journal Document Type"::Invoice, "Gen. Journal Document Type"::"Credit Memo"), CustLedgEntry.GetFilter("Document Type"), 'Incorrect document type filter');
    end;

    [Test]
    procedure Test_BonusCalculatorTarget_CalculateBonus_TestField()
    var
        Employee: Record Employee;
        Setup: Record SalarySetup;
        BonusCalculatorTarget: Codeunit BonusCalculatorTarget;
    begin
        asserterror BonusCalculatorTarget.CalculateBonus(Employee, Setup, 0, Today(), Today(), Today());
        Assert.ExpectedErrorCode('TestField');
        Assert.IsSubstring(GetLastErrorText(), Employee.FieldCaption("Salespers./Purch. Code"));
    end;

    [Test]
    procedure Test_BonusCalculatorTarget_CalculateBonus()
    var
        Employee: Record Employee;
        Setup: Record SalarySetup;
        BonusCalculatorTarget: Codeunit BonusCalculatorTarget;
        MockController: Codeunit MockTargetController;
        StartingDate: Date;
        EndingDate: Date;
        Bonus: Decimal;
    begin
        StartingDate := CalcDate('<-10D>', Today());
        EndingDate := CalcDate('<+10D>', Today());
        Employee."No." := 'DUMMY';
        Employee."Salespers./Purch. Code" := 'DUMMY';
        MockController.SetResult_CalculateBonus(234);
        BonusCalculatorTarget.Implement(MockController);

        Bonus := BonusCalculatorTarget.CalculateBonus(Employee, Setup, 0, StartingDate, EndingDate, Today());

        Assert.AreEqual(234, Bonus, 'Incorrect bonus calculated');
        MockController.AssertInvoked_PrepareCustLedgEntry(Employee, StartingDate, EndingDate);
        MockController.AssertInvoked_CalculateBonus_ExpectedCustLedgEntry();
    end;

    [Test]
    procedure Test_BonusCalculatorTarget_CalculateBonus_DI()
    var
        Employee: Record Employee;
        Setup: Record SalarySetup;
        BonusCalculatorTarget: Codeunit BonusCalculatorTarget;
        MockController: Codeunit MockTargetController;
        StartingDate: Date;
        EndingDate: Date;
        Bonus: Decimal;
    begin
        StartingDate := CalcDate('<-20D>', Today());
        EndingDate := CalcDate('<+20D>', Today());
        Employee."No." := 'DUMMY_DI';
        MockController.SetResult_CalculateBonus(345);

        Bonus := BonusCalculatorTarget.CalculateBonus(Employee, StartingDate, EndingDate, MockController);

        Assert.AreEqual(345, Bonus, 'Incorrect bonus calculated');
        MockController.AssertInvoked_PrepareCustLedgEntry(Employee, StartingDate, EndingDate);
        MockController.AssertInvoked_CalculateBonus_ExpectedCustLedgEntry();
    end;

    [Test]
    procedure Test_NoBonus_CalculateBonus()
    var
        Employee: Record Employee;
        Setup: Record SalarySetup;
        NoBonus: Codeunit NoBonus;
        Bonus: Decimal;
    begin
        Bonus := NoBonus.CalculateBonus(Employee, Setup, 1000, Today(), Today(), Today());
        Assert.AreEqual(0, Bonus, 'Incorrect bonus calculated');
    end;

    [Test]
    procedure Test_BonusCalculatorTimesheet_Controller_GetWorkHoursProvider_BC()
    var
        Employee: Record Employee;
        WorkHoursProvider: Interface IWorkHoursProvider;
        BonusCalculatorTimesheet: Codeunit BonusCalculatorTimesheet;
    begin
        WorkHoursProvider := BonusCalculatorTimesheet.GetWorkHoursProvider(Employee);

        Assert.AreEqual(Format(Codeunit::BCWorkHoursProvider), Format(WorkHoursProvider), 'Incorrect work hours provider returned');
    end;

    [Test]
    procedure Test_BonusCalculatorTimesheet_Controller_GetWorkHoursProvider_Timetracker()
    var
        Employee: Record Employee;
        WorkHoursProvider: Interface IWorkHoursProvider;
        BonusCalculatorTimesheet: Codeunit BonusCalculatorTimesheet;
    begin
        Employee.TimetrackerEmployeeId := 'DUMMY';

        WorkHoursProvider := BonusCalculatorTimesheet.GetWorkHoursProvider(Employee);

        Assert.AreEqual(Format(Codeunit::TimetrackerWorkHoursProvider), Format(WorkHoursProvider), 'Incorrect work hours provider returned');
    end;

    [Test]
    procedure Test_BonusCalculatorTimesheet_Controller_GetWorkHoursProvider_Factory()
    var
        Employee: Record Employee;
        WorkHoursProvider: Interface IWorkHoursProvider;
        BonusCalculatorTimesheet: Codeunit BonusCalculatorTimesheet;
        DummyWorkhoursProvider: Codeunit DummyWorkhoursProvider;
    begin
        Employee.Implement(DummyWorkhoursProvider);

        WorkHoursProvider := BonusCalculatorTimesheet.GetWorkHoursProvider(Employee);

        Assert.AreEqual(Format(DummyWorkhoursProvider), Format(WorkHoursProvider), 'Incorrect work hours provider returned');
    end;

    [Test]
    procedure Test_BonusCalculatorTimesheet_Controller_CalculateBonus_UnderMinimumHours()
    var
        Setup: Record SalarySetup;
        BonusCalculatorTimesheet: Codeunit BonusCalculatorTimesheet;
        Bonus: Decimal;
    begin
        Setup.MinimumHours := 40;

        Bonus := BonusCalculatorTimesheet.CalculateBonus(Setup, 30, 1000);

        Assert.AreEqual(-250, Bonus, 'Incorrect bonus calculated');
    end;

    [Test]
    procedure Test_BonusCalculatorTimesheet_Controller_CalculateBonus_OverOvertimeThreshold()
    var
        Setup: Record SalarySetup;
        BonusCalculatorTimesheet: Codeunit BonusCalculatorTimesheet;
        Bonus: Decimal;
    begin
        Setup.MinimumHours := 40;
        Setup.OvertimeThreshold := 50;

        Bonus := BonusCalculatorTimesheet.CalculateBonus(Setup, 60, 1000);

        Assert.AreEqual(200, Bonus, 'Incorrect bonus calculated');
    end;

    [Test]
    procedure Test_BonusCalculatorTimesheet_Controller_CalculateBonus_BetweenMinimumHoursAndOvertimeThreshold()
    var
        Setup: Record SalarySetup;
        BonusCalculatorTimesheet: Codeunit BonusCalculatorTimesheet;
        Bonus: Decimal;
    begin
        Setup.MinimumHours := 40;
        Setup.OvertimeThreshold := 50;

        Bonus := BonusCalculatorTimesheet.CalculateBonus(Setup, 45, 1000);

        Assert.AreEqual(0, Bonus, 'Incorrect bonus calculated');
    end;

    [Test]
    procedure Test_BonusCalculatorTimesheet_CalculateBonus_TestField_MinimumHours()
    var
        Setup: Record SalarySetup;
        Employee: Record Employee;
        BonusCalculatorTimesheet: Codeunit BonusCalculatorTimesheet;
        MockController: Codeunit MockTimesheetController;
    begin
        asserterror BonusCalculatorTimesheet.CalculateBonus(Employee, Setup, 0, Today(), Today(), MockController);

        Assert.ExpectedErrorCode('TestField');
        Assert.IsSubstring(GetLastErrorText(), Setup.FieldCaption(MinimumHours));
    end;

    [Test]
    procedure Test_BonusCalculatorTimesheet_CalculateBonus_TestField_OvertimeThreshold()
    var
        Setup: Record SalarySetup;
        Employee: Record Employee;
        BonusCalculatorTimesheet: Codeunit BonusCalculatorTimesheet;
        MockController: Codeunit MockTimesheetController;
    begin
        Setup.MinimumHours := 40;

        asserterror BonusCalculatorTimesheet.CalculateBonus(Employee, Setup, 0, Today(), Today(), MockController);

        Assert.ExpectedErrorCode('TestField');
        Assert.IsSubstring(GetLastErrorText(), Setup.FieldCaption(OvertimeThreshold));
    end;

    [Test]
    procedure Test_BonusCalculatorTimesheet_CalculateBonus_TestField_ResourceNo()
    var
        Setup: Record SalarySetup;
        Employee: Record Employee;
        BonusCalculatorTimesheet: Codeunit BonusCalculatorTimesheet;
        MockController: Codeunit MockTimesheetController;
    begin
        Setup.MinimumHours := 40;
        Setup.OvertimeThreshold := 50;

        asserterror BonusCalculatorTimesheet.CalculateBonus(Employee, Setup, 0, Today(), Today(), MockController);

        Assert.ExpectedErrorCode('TestField');
        Assert.IsSubstring(GetLastErrorText(), Employee.FieldCaption("Resource No."));
    end;

    [Test]
    procedure Test_BonusCalculatorTimesheet_CalculateBonus_DI()
    var
        Employee: Record Employee;
        Setup: Record SalarySetup;
        BonusCalculatorTimesheet: Codeunit BonusCalculatorTimesheet;
        MockController: Codeunit MockTimesheetController;
        Bonus: Decimal;
    begin
        Employee."No." := 'DUMMY_DI';
        Employee."Resource No." := 'DUMMY_DI';
        Setup.PrimaryKey := 'DUMMY_DI';
        Setup.MinimumHours := 40;
        Setup.OvertimeThreshold := 50;
        MockController.SetResult_CalculateBonus(345);

        Bonus := BonusCalculatorTimesheet.CalculateBonus(Employee, Setup, 393, Today(), Today(), MockController);

        Assert.AreEqual(345, Bonus, 'Incorrect bonus calculated');
        MockController.AssertInvoked_CalculateBonus(Setup, 393);
    end;

    [Test]
    procedure Test_TeamController_CalculateReward()
    var
        TeamController: Codeunit TeamController;
        Reward: Decimal;
    begin
        Reward := TeamController.CalculateReward(50, 25);

        Assert.AreEqual(12.5, Reward, 'Incorrect reward calculated');
    end;

    [Test]
    procedure Test_TeamController_FindMonthlySalary_Finds()
    var
        MonthlySalaryTemp: Record MonthlySalary temporary;
        TeamController: Codeunit TeamController;
        Found: Boolean;
    begin
        MonthlySalaryTemp.SetRange(EntryNo, 11);
        MonthlySalaryTemp.EmployeeNo := 'DUMMY';
        MonthlySalaryTemp.Date := Today();
        MonthlySalaryTemp.Insert(false);

        Found := TeamController.FindMonthlySalary(MonthlySalaryTemp, 'DUMMY', Today());

        Assert.IsTrue(Found, 'Monthly salary not found');
        Assert.AreEqual('', MonthlySalaryTemp.GetFilter(EntryNo), 'Incorrect entry no filter');
        Assert.AreEqual('DUMMY', MonthlySalaryTemp.GetFilter(EmployeeNo), 'Incorrect employee no filter');
        Assert.AreEqual(Today(), MonthlySalaryTemp.GetRangeMax(Date), 'Incorrect date filter');
        Assert.AreEqual(Today(), MonthlySalaryTemp.GetRangeMin(Date), 'Incorrect date filter');
    end;

    [Test]
    procedure Test_TeamController_FindMonthlySalary_NotFinds()
    var
        MonthlySalaryTemp: Record MonthlySalary temporary;
        TeamController: Codeunit TeamController;
        Found: Boolean;
    begin
        MonthlySalaryTemp.SetRange(EntryNo, 11);
        MonthlySalaryTemp.EmployeeNo := 'DUMMY1';
        MonthlySalaryTemp.Date := Today();
        MonthlySalaryTemp.Insert(false);

        Found := TeamController.FindMonthlySalary(MonthlySalaryTemp, 'DUMMY', CalcDate('<-1D>', Today()));

        Assert.IsFalse(Found, 'Monthly salary found');
    end;

    [Test]
    procedure Test_TeamController_GetSubordinateReward_FindsMonthlySalary()
    var
        Employee: Record Employee;
        MonthlySalary: Record MonthlySalary;
        TeamController: Codeunit TeamController;
        MockController: Codeunit MockTeamController;
        StubRewardsExtractor: Codeunit StubRewardsExtractor;
        Reward: Decimal;
    begin
        Employee."No." := 'DUMMY';
        Employee."Manager No." := 'DUMMY_MANAGER';
        MonthlySalary.EmployeeNo := 'DUMMY';
        MonthlySalary.Date := CalcDate('<CM+12D>', Today());
        MonthlySalary.Incentive := 150;
        MockController.SetResult_FindMonthlySalary(MonthlySalary, true);

        Reward := TeamController.GetSubordinateReward(Employee, MonthlySalary.Date, StubRewardsExtractor, MockController);

        Assert.AreEqual(18, Reward, 'Incorrect reward calculated');
        MockController.AssertInvoked_FindMonthlySalary('DUMMY', MonthlySalary.Date);
    end;

    [Test]
    procedure Test_TeamController_GetSubordinateReward_DoesNotFindMonthlySalary()
    var
        Employee: Record Employee;
        MonthlySalary: Record MonthlySalary;
        TeamController: Codeunit TeamController;
        MockController: Codeunit MockTeamController;
        MockSalaryCalculate: Codeunit MockSalaryCalculate;
        StubRewardsExtractor: Codeunit StubRewardsExtractor;
        Reward: Decimal;
    begin
        Employee."No." := 'DUMMY';
        Employee."Manager No." := 'DUMMY_MANAGER';
        MonthlySalary.EmployeeNo := 'DUMMY';
        MonthlySalary.Date := CalcDate('<CM+12D>', Today());
        MonthlySalary.Incentive := 250;
        MockSalaryCalculate.SetResult_CalculateSalary(MonthlySalary);
        Employee.Implement(MockSalaryCalculate);

        MockController.SetResult_FindMonthlySalary(MonthlySalary, false);

        Reward := TeamController.GetSubordinateReward(Employee, MonthlySalary.Date, StubRewardsExtractor, MockController);

        Assert.AreEqual(30, Reward, 'Incorrect reward calculated');
        MockController.AssertInvoked_FindMonthlySalary('DUMMY', MonthlySalary.Date);
    end;

    [Test]
    procedure Test_TeamController_ProcessSubordinates()
    var
        EmployeeTmp: Record Employee temporary;
        TeamController: Codeunit TeamController;
        MockController: Codeunit MockTeamController;
        StubRewardsExtractor: Codeunit StubRewardsExtractor;
        Reward: Decimal;
    begin
        EmployeeTmp."No." := 'DUMMY01';
        EmployeeTmp.BaseSalary := 123;
        EmployeeTmp.Insert(false);
        EmployeeTmp."No." := 'DUMMY02';
        EmployeeTmp.BaseSalary := 177;
        EmployeeTmp.Insert(false);

        Reward := TeamController.ProcessSubordinates(EmployeeTmp, 25, Today(), StubRewardsExtractor, MockController);

        Assert.AreEqual(75, Reward, 'Incorrect reward calculated');
    end;

    [Test]
    procedure Test_TeamController_FilterSubordinates()
    var
        Employee: Record Employee;
        TeamController: Codeunit TeamController;
    begin
        TeamController.FilterSubordinates('DUMMY', Employee);

        Assert.AreEqual('DUMMY', Employee.GetFilter("Manager No."), 'Incorrect manager no filter');
    end;

    [Test]
    procedure Test_TeamController_CalculateSubordinates_DI()
    var
        TeamController: Codeunit TeamController;
        StubRewardsExtractor: Codeunit StubRewardsExtractor;
        MockController: Codeunit MockTeamController;
        Result: Decimal;
    begin
        MockController.SetResult_ProcessSubordinates(3345);

        Result := TeamController.CalculateSubordinates('DUMMY', 25, Today(), StubRewardsExtractor, MockController);

        Assert.AreEqual(3345, Result, 'Incorrect result calculated');
        MockController.AssertInvoked_FilterSubordinates('DUMMY');
    end;

    [Test]
    procedure Test_TeamController_CalculateSubordinates()
    var
        TeamController: Codeunit TeamController;
        StubRewardsExtractor: Codeunit StubRewardsExtractor;
        MockController: Codeunit MockTeamController;
        Result: Decimal;
    begin
        MockController.SetResult_ProcessSubordinates(4456);
        TeamController.Implement(MockController);

        Result := TeamController.CalculateSubordinates('DUMMY', 25, Today(), StubRewardsExtractor);

        Assert.AreEqual(4456, Result, 'Incorrect result calculated');
        MockController.AssertInvoked_FilterSubordinates('DUMMY');
    end;

    [Test]
    procedure Test_TeamBonus_ExtractRewardComponent()
    var
        MonthlySalary: Record MonthlySalary;
        TeamBonus: Codeunit TeamBonus;
        Reward: Decimal;
    begin
        MonthlySalary.Incentive := 123;
        MonthlySalary.Bonus := 456;

        Reward := TeamBonus.ExtractRewardComponent(MonthlySalary);

        Assert.AreEqual(456, Reward, 'Incorrect reward extracted');
    end;

    [Test]
    procedure Test_TeamBonus_CalculateBonus()
    var
        Employee: Record Employee;
        TeamBonus: Codeunit TeamBonus;
        MockController: Codeunit MockTeamController;
        StubRewardsExtractor: Codeunit StubRewardsExtractor;
        AtDate: Date;
        Bonus: Decimal;
    begin
        Employee."No." := 'DUMMY';
        Employee.TeamBonusPct := 34;
        AtDate := CalcDate('<CM+12D>', Today());
        MockController.SetResult_CalculateSubordinates(33);

        Bonus := TeamBonus.CalculateBonus(Employee, AtDate, MockController, StubRewardsExtractor);

        Assert.AreEqual(33, Bonus, 'Incorrect bonus calculated');
        MockController.AssertInvoked_CalculateSubordinates('DUMMY', 34, AtDate);
    end;

    [Test]
    procedure Test_DefaultInctiveCalculator_CalculateIncentive_TestField()
    var
        Employee: Record Employee;
        Setup: Record SalarySetup;
        DefaultIncentiveCalculator: Codeunit DefaultIncentiveCalculator;
    begin
        asserterror DefaultIncentiveCalculator.CalculateIncentive(Employee, Setup, 0, Today());

        Assert.ExpectedErrorCode('TestField');
        Assert.IsSubstring(GetLastErrorText(), Setup.FieldCaption(YearlyIncentivePct));
    end;

    [Test]
    procedure Test_DefaultInctiveCalculator_CalculateIncentive()
    var
        Employee: Record Employee;
        Setup: Record SalarySetup;
        DefaultIncentiveCalculator: Codeunit DefaultIncentiveCalculator;
        AtDate: Date;
        Incentive: Decimal;
    begin
        AtDate := Today();
        Employee."Employment Date" := CalcDate('<CM-62M>', AtDate);
        Setup.YearlyIncentivePct := 7;

        Incentive := DefaultIncentiveCalculator.CalculateIncentive(Employee, Setup, 1000, AtDate);

        Assert.AreEqual(350, Incentive, 'Incorrect incentive calculated');
    end;

    procedure Test_NoIncentive_CalculateIncentive()
    var
        Employee: Record Employee;
        Setup: Record SalarySetup;
        NoIncentive: Codeunit NoIncentive;
        Incentive: Decimal;
    begin
        Incentive := NoIncentive.CalculateIncentive(Employee, Setup, 1000, Today());
        Assert.AreEqual(0, Incentive, 'Incorrect incentive calculated');
    end;

    [Test]
    procedure Test_TeamIncentive_ExtractRewardComponent()
    var
        MonthlySalary: Record MonthlySalary;
        TeamIncentive: Codeunit TeamIncentive;
        Reward: Decimal;
    begin
        MonthlySalary.Incentive := 123;
        MonthlySalary.Bonus := 456;

        Reward := TeamIncentive.ExtractRewardComponent(MonthlySalary);

        Assert.AreEqual(123, Reward, 'Incorrect reward extracted');
    end;

    [Test]
    procedure Test_TeamIncentive_CalculateIncentive()
    var
        Employee: Record Employee;
        TeamIncentive: Codeunit TeamIncentive;
        MockController: Codeunit MockTeamController;
        StubRewardsExtractor: Codeunit StubRewardsExtractor;
        AtDate: Date;
        Incentive: Decimal;
    begin
        Employee."No." := 'DUMMY';
        Employee.TeamIncentivePct := 45;
        AtDate := CalcDate('<CM+12D>', Today());
        MockController.SetResult_CalculateSubordinates(44);

        Incentive := TeamIncentive.CalculateIncentive(Employee, AtDate, MockController, StubRewardsExtractor);

        Assert.AreEqual(44, Incentive, 'Incorrect incentive calculated');
        MockController.AssertInvoked_CalculateSubordinates('DUMMY', 45, AtDate);
    end;

}
