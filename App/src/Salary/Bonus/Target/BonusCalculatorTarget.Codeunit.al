namespace ALchemy;

using Microsoft.HumanResources.Employee;
using Microsoft.Sales.Receivables;
using Microsoft.Finance.GeneralLedger.Journal;

codeunit 60104 BonusCalculatorTarget implements IBonusCalculator, ITargetController
{
    Access = Internal;

    #region Controller Factory
    var
        _controller: Interface ITargetController;
        _controllerImplemented: Boolean;

    internal procedure Implement(Implementation: Interface ITargetController)
    begin
        _controller := Implementation;
        _controllerImplemented := true;
    end;

    local procedure GetController(): Interface ITargetController
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

    internal procedure CalculateBonus(Employee: Record Employee; StartingDate: Date; EndingDate: Date; Controller: Interface ITargetController) Bonus: Decimal;
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
    begin
        Controller.PrepareCustLedgEntry(Employee, StartingDate, EndingDate, CustLedgEntry);
        Bonus := Controller.CalculateBonus(Employee, CustLedgEntry);
    end;

    #region ITargetController implementation

    internal procedure PrepareCustLedgEntry(Employee: Record Employee; StartingDate: Date; EndingDate: Date; var CustLedgEntry: Record "Cust. Ledger Entry");
    begin
        CustLedgEntry.SetRange("Posting Date", StartingDate, EndingDate);
        CustLedgEntry.SetRange("Salesperson Code", Employee."Salespers./Purch. Code");
        CustLedgEntry.SetFilter("Document Type", '%1|%2', "Gen. Journal Document Type"::Invoice, "Gen. Journal Document Type"::"Credit Memo");
        CustLedgEntry.CalcSums("Sales (LCY)");
    end;

    internal procedure CalculateBonus(Employee: Record Employee; var CustLedgEntry: Record "Cust. Ledger Entry"): Decimal;
    var
        Bonus: Decimal;
    begin
        Bonus := Employee.TargetBonus * (CustLedgEntry."Sales (LCY)" / Employee.TargetRevenue);
        if (Bonus > Employee.MaximumTargetBonus) and (Employee.MaximumTargetBonus > 0) then
            exit(Employee.MaximumTargetBonus);

        if (Bonus < Employee.MaximumTargetMalus) and (Employee.MaximumTargetMalus < 0) then
            exit(Employee.MaximumTargetMalus);

        exit(Bonus);
    end;

    #endregion
}
