namespace ALchemy;

using Microsoft.HumanResources.Employee;
using Microsoft.Sales.Receivables;

interface ITargetController
{
    Access = Internal;

    procedure PrepareCustLedgEntry(Employee: Record Employee; StartingDate: Date; EndingDate: Date; var CustLedgEntry: Record "Cust. Ledger Entry");
    procedure CalculateBonus(Employee: Record Employee; var CustLedgEntry: Record "Cust. Ledger Entry"): Decimal;
}