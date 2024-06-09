namespace ALchemy;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.HumanResources.Employee;
using Microsoft.Finance.GeneralLedger.Ledger;

codeunit 60159 MockPerformanceController implements IPerformanceController
{
    var
        Assert: Codeunit Assert;

    #region GetAccounts

    var
        _invoked_GetAccounts: Boolean;

    internal procedure GetAccounts(Setup: Record SalarySetup; var GLAccountIncome: Record "G/L Account"; var GLAccountExpense: Record "G/L Account")
    begin
        _invoked_GetAccounts := true;
        GLAccountIncome."No." := Setup.IncomeAccountNo;
        GLAccountExpense."No." := Setup.ExpenseAccountNo;
    end;

    procedure AssertInvoked_GetAccounts()
    begin
        Assert.IsTrue(_invoked_GetAccounts, 'GetAccounts was not invoked');
    end;

    #endregion

    var
        _invoked_CalculateBonus_DI: Boolean;
        _invoked_CalculateBonus_Employee: Record Employee;
        _invoked_CalculateBonus_Salary: Decimal;
        _invoked_CalculateBonus_StartingDate: Date;
        _invoked_CalculateBonus_EndingDate: Date;
        _invoked_CalculateBonus_GLAccountIncome: Record "G/L Account";
        _invoked_CalculateBonus_GLAccountExpense: Record "G/L Account";
        _result_CalculateBonus_DI: Decimal;

    internal procedure CalculateBonus(Employee: Record Employee; Salary: Decimal; StartingDate: Date; EndingDate: Date; GLAccountIncome: Record "G/L Account"; GLAccountExpense: Record "G/L Account"; Controller: Interface IPerformanceController) Bonus: Decimal
    begin
        _invoked_CalculateBonus_DI := true;
        _invoked_CalculateBonus_Employee := Employee;
        _invoked_CalculateBonus_Salary := Salary;
        _invoked_CalculateBonus_StartingDate := StartingDate;
        _invoked_CalculateBonus_EndingDate := EndingDate;
        _invoked_CalculateBonus_GLAccountIncome := GLAccountIncome;
        _invoked_CalculateBonus_GLAccountExpense := GLAccountExpense;

        exit(_result_CalculateBonus_DI);
    end;

    procedure SetResult_CalculateBonus_DI(Result: Decimal)
    begin
        _result_CalculateBonus_DI := Result;
    end;

    procedure AssertInvoked_CalculateBonus_DI(EmployeeNo: Code[20]; Salary: Decimal; StartingDate: Date; EndingDate: Date; GLAccountNoIncome: Code[20]; GLAccountNoExpense: Code[20])
    begin
        Assert.AreNotEqual('', EmployeeNo, 'EmployeeNo is empty');
        Assert.AreNotEqual('', GLAccountNoIncome, 'GLAccountNoIncome is empty');
        Assert.AreNotEqual('', GLAccountNoExpense, 'GLAccountNoExpense is empty');

        Assert.IsTrue(_invoked_CalculateBonus_DI, 'CalculateBonus was not invoked');
        Assert.AreEqual(EmployeeNo, _invoked_CalculateBonus_Employee."No.", 'CalculateBonus was not invoked with the expected Employee');
        Assert.AreEqual(Salary, _invoked_CalculateBonus_Salary, 'CalculateBonus was not invoked with the expected Salary');
        Assert.AreEqual(StartingDate, _invoked_CalculateBonus_StartingDate, 'CalculateBonus was not invoked with the expected StartingDate');
        Assert.AreEqual(EndingDate, _invoked_CalculateBonus_EndingDate, 'CalculateBonus was not invoked with the expected EndingDate');
        Assert.AreEqual(GLAccountNoIncome, _invoked_CalculateBonus_GLAccountIncome."No.", 'CalculateBonus was not invoked with the expected GLAccountIncome');
        Assert.AreEqual(GLAccountNoExpense, _invoked_CalculateBonus_GLAccountExpense."No.", 'CalculateBonus was not invoked with the expected GLAccountExpense');
    end;

    #region FilterGLEntry

    var
        _invokedCount_FilterGLEntry: Integer;
        _assertedCount_FilterGLEntry: Integer;
        _invoked_FilterGLEntry_GLAcountNo: List of [Code[20]];
        _invoked_FilterGLEntry_StartDate: List of [Date];
        _invoked_FilterGLEntry_EndDate: List of [Date];
        _amount_FilterGLEntry: List of [Decimal];

    internal procedure FilterGLEntry(var GLEntry: Record "G/L Entry"; GLAccountNo: Code[20]; StartingDate: Date; EndingDate: Date)
    begin
        _invokedCount_FilterGLEntry += 1;
        _invoked_FilterGLEntry_GLAcountNo.Add(GLAccountNo);
        _invoked_FilterGLEntry_StartDate.Add(StartingDate);
        _invoked_FilterGLEntry_EndDate.Add(EndingDate);

        GLEntry."Entry No." := -_invokedCount_FilterGLEntry;
        GLEntry."G/L Account No." := GLAccountNo;
        GLEntry.Amount := _amount_FilterGLEntry.Get(_invokedCount_FilterGLEntry);
    end;

    internal procedure SetAmount_FilterGLEntry(Amount: Decimal)
    begin
        _amount_FilterGLEntry.Add(Amount);
    end;

    internal procedure AssertInvoked_FilterGLEntry(GLAccountNo: Code[20]; StartingDate: Date; EndingDate: Date)
    begin
        _assertedCount_FilterGLEntry += 1;
        Assert.AreEqual(2, _invokedCount_FilterGLEntry, 'FilterGLEntry was not invoked');
        Assert.AreEqual(GLAccountNo, _invoked_FilterGLEntry_GLAcountNo.Get(_assertedCount_FilterGLEntry), 'FilterGLEntry was not invoked with the expected GLAccountNo');
        Assert.AreEqual(StartingDate, _invoked_FilterGLEntry_StartDate.Get(_assertedCount_FilterGLEntry), 'FilterGLEntry was not invoked with the expected StartingDate');
        Assert.AreEqual(EndingDate, _invoked_FilterGLEntry_EndDate.Get(_assertedCount_FilterGLEntry), 'FilterGLEntry was not invoked with the expected EndingDate');
    end;

    #endregion

    #region CalculateBonus

    var
        _invoked_CalculateBonus: Boolean;
        _invoked_CalculateBonus_Income: Decimal;
        _invoked_CalculateBonus_Expense: Decimal;
        _invoked_CalculateBonus_ProfitPct: Decimal;
        _result_CalculateBonus: Decimal;

    internal procedure CalculateBonus(Income: Decimal; Expense: Decimal; ProfitPct: Decimal) Bonus: Decimal;
    begin
        _invoked_CalculateBonus := true;
        _invoked_CalculateBonus_Income := Income;
        _invoked_CalculateBonus_Expense := Expense;
        _invoked_CalculateBonus_ProfitPct := ProfitPct;
        exit(_result_CalculateBonus);
    end;

    procedure SetResult_CalculateBonus(Result: Decimal)
    begin
        _result_CalculateBonus := Result;
    end;

    procedure AssertInvoked_CalculateBonus(Income: Decimal; Expense: Decimal; ProfitPct: Decimal)
    begin
        Assert.IsTrue(_invoked_CalculateBonus, 'CalculateBonus was not invoked');
        Assert.AreEqual(Income, _invoked_CalculateBonus_Income, 'CalculateBonus was not invoked with the expected Income');
        Assert.AreEqual(Expense, _invoked_CalculateBonus_Expense, 'CalculateBonus was not invoked with the expected Expense');
        Assert.AreEqual(ProfitPct, _invoked_CalculateBonus_ProfitPct, 'CalculateBonus was not invoked with the expected ProfitPct');
    end;

    #endregion
}
