namespace ALchemy;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.HumanResources.Employee;
using Microsoft.Finance.GeneralLedger.Ledger;

interface IPerformanceController
{
    Access = Internal;

    procedure GetAccounts(Setup: Record SalarySetup; var GLAccountIncome: Record "G/L Account"; var GLAccountExpense: Record "G/L Account");
    procedure CalculateBonus(Employee: Record Employee; Salary: Decimal; StartingDate: Date; EndingDate: Date; GLAccountIncome: Record "G/L Account"; GLAccountExpense: Record "G/L Account"; Controller: Interface IPerformanceController) Bonus: Decimal;
    procedure FilterGLEntry(var GLEntry: Record "G/L Entry"; GLAccountNo: Code[20]; StartingDate: Date; EndingDate: Date);
    procedure CalculateBonus(Income: Decimal; Expense: Decimal; ProfitPct: Decimal) Bonus: Decimal;
}
