namespace ALchemy;

using Microsoft.HumanResources.Employee;
using Microsoft.Sales.Receivables;
using Microsoft.Finance.GeneralLedger.Journal;

codeunit 60103 BonusCalculatorCommission implements IBonusCalculator, ICommissionController
{
    Access = Internal;

    #region Controller Factory
    var
        _controller: Interface ICommissionController;
        _controllerImplemented: Boolean;

    internal procedure Implement(Implementation: Interface ICommissionController)
    begin
        _controller := Implementation;
        _controllerImplemented := true;
    end;

    local procedure GetController(): Interface ICommissionController
    begin
        if not _controllerImplemented then
            Implement(this);

        exit(_controller);
    end;

    #endregion

    procedure CalculateBonus(Employee: Record Employee; Setup: Record SalarySetup; Salary: Decimal; StartingDate: Date; EndingDate: Date; AtDate: Date) Bonus: Decimal;
    begin
        Employee.TestField("Salespers./Purch. Code");
        Bonus := CalculateBonus(Employee, StartingDate, EndingDate, GetController());
    end;

    internal procedure CalculateBonus(Employee: Record Employee; StartingDate: Date; EndingDate: Date; Controller: Interface ICommissionController) Bonus: Decimal;
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
    begin
        Controller.PrepareCustLedgEntry(Employee, StartingDate, EndingDate, CustLedgEntry);
        Bonus := Controller.CalculateBonus(Employee.CommissionBonusPct, CustLedgEntry);
    end;

    #region ICommissionController implementation

    internal procedure PrepareCustLedgEntry(Employee: Record Employee; StartingDate: Date; EndingDate: Date; var CustLedgEntry: Record "Cust. Ledger Entry");
    begin
        CustLedgEntry.SetRange("Posting Date", StartingDate, EndingDate);
        CustLedgEntry.SetRange("Salesperson Code", Employee."Salespers./Purch. Code");
        CustLedgEntry.SetFilter("Document Type", '%1|%2', "Gen. Journal Document Type"::Invoice, "Gen. Journal Document Type"::"Credit Memo");
        CustLedgEntry.CalcSums("Profit (LCY)");
    end;

    internal procedure CalculateBonus(Percentage: Decimal; var CustLedgEntry: Record "Cust. Ledger Entry") Bonus: Decimal;
    begin
        Bonus := (Percentage / 100) * CustLedgEntry."Profit (LCY)";
    end;

    #endregion
}
