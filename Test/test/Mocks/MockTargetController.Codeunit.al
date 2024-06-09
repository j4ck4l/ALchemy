namespace ALchemy;

using Microsoft.HumanResources.Employee;
using Microsoft.Sales.Receivables;

codeunit 60160 MockTargetController implements ITargetController
{
    var
        Assert: Codeunit Assert;

    #region PrepareCustLedgEntry

    var
        _invoked_PrepareCustLedgEntry: Boolean;
        _invoked_PrepareCustLedgEntry_Employee: Record Employee;
        _invoked_PrepareCustLedgEntry_StartingDate: Date;
        _invoked_PrepareCustLedgEntry_EndingDate: Date;

    procedure PrepareCustLedgEntry(Employee: Record Employee; StartingDate: Date; EndingDate: Date; var CustLedgEntry: Record "Cust. Ledger Entry")
    begin
        _invoked_PrepareCustLedgEntry := true;
        _invoked_PrepareCustLedgEntry_Employee := Employee;
        _invoked_PrepareCustLedgEntry_StartingDate := StartingDate;
        _invoked_PrepareCustLedgEntry_EndingDate := EndingDate;

        CustLedgEntry."Entry No." := -1;
        CustLedgEntry."Profit (LCY)" := 1230;
    end;

    procedure AssertInvoked_PrepareCustLedgEntry(ExpectedEmployee: Record Employee; ExpectedStartingDate: Date; ExpectedEndingDate: Date)
    begin
        Assert.AreNotEqual('', ExpectedEmployee."No.", 'ExpectedEmployee."No." is not set');

        Assert.IsTrue(_invoked_PrepareCustLedgEntry, 'PrepareCustLedgEntry was not invoked');
        Assert.AreEqual(ExpectedEmployee."No.", _invoked_PrepareCustLedgEntry_Employee."No.", 'PrepareCustLedgEntry was not invoked with the expected Employee');
        Assert.AreEqual(ExpectedStartingDate, _invoked_PrepareCustLedgEntry_StartingDate, 'PrepareCustLedgEntry was not invoked with the expected StartingDate');
        Assert.AreEqual(ExpectedEndingDate, _invoked_PrepareCustLedgEntry_EndingDate, 'PrepareCustLedgEntry was not invoked with the expected EndingDate');
    end;

    #endregion

    #region CalculateBonus

    var
        _result_CalculateBonus: Decimal;
        _invoked_CalculateBonus_CustLedgEntry: Record "Cust. Ledger Entry";

    procedure CalculateBonus(Employee: Record Employee; var CustLedgEntry: Record "Cust. Ledger Entry") Bonus: Decimal
    begin
        _invoked_CalculateBonus_CustLedgEntry := CustLedgEntry;
        exit(_result_CalculateBonus);
    end;

    procedure SetResult_CalculateBonus(Result: Decimal)
    begin
        _result_CalculateBonus := Result;
    end;

    procedure AssertInvoked_CalculateBonus_ExpectedCustLedgEntry()
    begin
        Assert.AreEqual(-1, _invoked_CalculateBonus_CustLedgEntry."Entry No.", 'CalculateBonus was not invoked with a valid CustLedgEntry');
        Assert.AreEqual(1230, _invoked_CalculateBonus_CustLedgEntry."Profit (LCY)", 'CalculateBonus was not invoked with the expected CustLedgEntry');
    end;

    #endregion
}
