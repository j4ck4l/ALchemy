namespace ALchemy;

using Microsoft.HumanResources.Employee;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Ledger;

codeunit 60108 BonusCalculatorPerformance implements IBonusCalculator, IPerformanceController
{
    Access = Internal;

    #region Controller Factory
    var
        _controller: Interface IPerformanceController;
        _controllerImplemented: Boolean;

    internal procedure Implement(Implementation: Interface IPerformanceController)
    begin
        _controller := Implementation;
        _controllerImplemented := true;
    end;

    local procedure GetController(): Interface IPerformanceController
    begin
        if not _controllerImplemented then
            Implement(this);

        exit(_controller);
    end;

    #endregion

    procedure CalculateBonus(Employee: Record Employee; Setup: Record SalarySetup; Salary: Decimal; StartingDate: Date; EndingDate: Date; AtDate: Date) Bonus: Decimal;
    begin
        Bonus := CalculateBonus(Employee, Setup, Salary, StartingDate, EndingDate, GetController());
    end;

    internal procedure CalculateBonus(Employee: Record Employee; Setup: Record SalarySetup; Salary: Decimal; StartingDate: Date; EndingDate: Date; Controller: Interface IPerformanceController) Bonus: Decimal;
    var
        GLAccountIncome, GLAccountExpense : Record "G/L Account";
    begin
        Controller.GetAccounts(Setup, GLAccountIncome, GLAccountExpense);
        Bonus := Controller.CalculateBonus(Employee, Salary, StartingDate, EndingDate, GLAccountIncome, GLAccountExpense, Controller);
    end;

    #region IPerformanceController implementation

    internal procedure GetAccounts(Setup: Record SalarySetup; var GLAccountIncome: Record "G/L Account"; var GLAccountExpense: Record "G/L Account")
    begin
        GLAccountIncome.Get(Setup.IncomeAccountNo);
        GLAccountExpense.Get(Setup.ExpenseAccountNo);
    end;

    internal procedure CalculateBonus(Employee: Record Employee; Salary: Decimal; StartingDate: Date; EndingDate: Date; GLAccountIncome: Record "G/L Account"; GLAccountExpense: Record "G/L Account"; Controller: Interface IPerformanceController) Bonus: Decimal;
    var
        GLEntryIncome, GLEntryExpense : Record "G/L Entry";
    begin
        Controller.FilterGLEntry(GLEntryIncome, GLAccountIncome."No.", StartingDate, EndingDate);
        Controller.FilterGLEntry(GLEntryExpense, GLAccountExpense."No.", StartingDate, EndingDate);
        Bonus := Controller.CalculateBonus(GLEntryIncome.Amount, GLEntryExpense.Amount, Employee.PerformanceBonusPct);
    end;

    internal procedure FilterGLEntry(var GLEntry: Record "G/L Entry"; GLAccountNo: Code[20]; StartingDate: Date; EndingDate: Date)
    begin
        GLEntry.SetRange("Posting Date", StartingDate, EndingDate);
        GLEntry.SetFilter("G/L Account No.", GLAccountNo);
        GLEntry.CalcSums(Amount);
    end;

    procedure CalculateBonus(Income: Decimal; Expense: Decimal; ProfitPct: Decimal) Bonus: Decimal;
    var
        Profit: Decimal;
    begin
        Profit := Income - Expense;
        if Profit = 0 then
            exit;
        Bonus := (ProfitPct / 100) * Profit;
    end;

    #endregion
}
