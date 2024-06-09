namespace ALchemy;

using Microsoft.HumanResources.Employee;
using Microsoft.Sales.Receivables;
using Microsoft.Finance.GeneralLedger.Journal;

codeunit 60104 SalaryCalculatorTarget implements ISalaryCalculator
{
    procedure CalculateBaseSalary(Employee: Record Employee; Setup: Record SalarySetup) Salary: Decimal;
    var
        Department: Record Department;
        DepartmentSenioritySetup: Record DepartmentSenioritySetup;
    begin
        Setup.TestField(BaseSalary);

        Salary := Employee.BaseSalary;

        if Employee.BaseSalary = 0 then begin
            Salary := Setup.BaseSalary;
            if Employee.DepartmentCode <> '' then begin
                Department.Get(Employee.DepartmentCode);
                Salary := Department.BaseSalary;
                if DepartmentSenioritySetup.Get(Employee.DepartmentCode, Employee.Seniority) then
                    Salary := DepartmentSenioritySetup.BaseSalary;
            end;
        end;
    end;

    procedure CalculateBonus(Employee: Record Employee; Setup: Record SalarySetup; Salary: Decimal; StartingDate: Date; EndingDate: Date) Bonus: Decimal;
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
    begin
        Employee.TestField("Salespers./Purch. Code");

        CustLedgEntry.SetRange("Posting Date", StartingDate, EndingDate);
        CustLedgEntry.SetRange("Salesperson Code", Employee."Salespers./Purch. Code");
        CustLedgEntry.SetFilter("Document Type", '%1|%2', "Gen. Journal Document Type"::Invoice, "Gen. Journal Document Type"::"Credit Memo");
        CustLedgEntry.CalcSums("Sales (LCY)");
        Bonus := Employee.TargetBonus * (CustLedgEntry."Sales (LCY)" / Employee.TargetRevenue);
        if (Bonus > Employee.MaximumTargetBonus) and (Employee.MaximumTargetBonus > 0) then
            Bonus := Employee.MaximumTargetBonus
        else
            if (Bonus < Employee.MaximumTargetMalus) and (Employee.MaximumTargetMalus < 0) then
                Bonus := Employee.MaximumTargetMalus;
    end;

    procedure CalculateIncentive(Employee: Record Employee; Setup: Record SalarySetup; Salary: Decimal; AtDate: Date) Incentive: Decimal;
    var
        YearsOfTenure: Integer;
    begin
        Setup.TestField(YearlyIncentivePct);
        YearsOfTenure := Round((AtDate - Employee."Employment Date") / 365, 1, '<');
        Incentive := Salary * (YearsOfTenure * Setup.YearlyIncentivePct) / 100;
    end;
}