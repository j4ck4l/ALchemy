namespace ALchemy;

using Microsoft.HumanResources.Employee;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Ledger;

codeunit 60108 SalaryCalculatorPerformance implements ISalaryCalculator
{
    procedure CalculateBaseSalary(Employee: Record Employee; Setup: Record SalarySetup) Salary: Decimal;
    begin
    end;

    procedure CalculateBonus(Employee: Record Employee; Setup: Record SalarySetup; Salary: Decimal; StartingDate: Date; EndingDate: Date) Bonus: Decimal;
    var
        GLAccount: Record "G/L Account";
        GLEntry: Record "G/L Entry";
        Income: Decimal;
        Expense: Decimal;
        Profit: Decimal;
    begin
        GLEntry.SetRange("Posting Date", StartingDate, EndingDate);

        GLAccount.Get(Setup.IncomeAccountNo);
        GLEntry.SetFilter("G/L Account No.", GLAccount.Totaling);
        GLEntry.CalcSums(Amount);
        Income := GLEntry.Amount;

        GLAccount.Get(Setup.ExpenseAccountNo);
        GLEntry.SetFilter("G/L Account No.", GLAccount.Totaling);
        GLEntry.CalcSums(Amount);
        Expense := GLEntry.Amount;

        Profit := Income - Expense;
        if (Profit > 0) then
            Bonus := (Employee.PerformanceBonusPct / 100) * Profit;
    end;

    procedure CalculateIncentive(Employee: Record Employee; Setup: Record SalarySetup; Salary: Decimal; AtDate: Date) Incentive: Decimal;
    begin
    end;
}