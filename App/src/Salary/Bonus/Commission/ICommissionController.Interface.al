namespace ALchemy;

using Microsoft.HumanResources.Employee;
using Microsoft.Sales.Receivables;

interface ICommissionController
{
    Access = Internal;

    procedure PrepareCustLedgEntry(Employee: Record Employee; StartingDate: Date; EndingDate: Date; var CustLedgEntry: Record "Cust. Ledger Entry");
    procedure CalculateBonus(Percentage: Decimal; var CustLedgEntry: Record "Cust. Ledger Entry") Bonus: Decimal;
}