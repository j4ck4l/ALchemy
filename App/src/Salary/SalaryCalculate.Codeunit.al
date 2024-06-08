namespace ALchemy;

using Microsoft.HumanResources.Employee;
using Microsoft.Projects.TimeSheet;
using Microsoft.Sales.Receivables;
using Microsoft.Finance.GeneralLedger.Journal;

codeunit 60100 SalaryCalculate
{
    procedure CalculateSalary(var Employee: Record Employee; AtDate: Date) Result: Record MonthlySalary
    var
        Setup: Record SalarySetup;
    begin
        Setup.Get();
        Result := CalculateSalary(Employee, Setup, AtDate);
    end;

    internal procedure CalculateSalary(Employee: Record Employee; Setup: Record SalarySetup; AtDate: Date) Result: Record MonthlySalary
    var
        Salary: Decimal;
        Bonus: Decimal;
        Incentive: Decimal;
    begin
        Salary := CalculateBaseSalary(Employee, Setup);
        Bonus := CalculateBonus(Employee, Setup, Salary, AtDate);
        Incentive := CalculateIncentive(Employee, Setup, Salary, AtDate);

        Result.EmployeeNo := Employee."No.";
        Result.Date := AtDate;
        Result.Salary := Salary;
        Result.Bonus := Bonus;
        Result.Incentive := Incentive;
    end;

    internal procedure CalculateBaseSalary(Employee: Record Employee; Setup: Record SalarySetup) Salary: Decimal
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

    internal procedure CalculateBonus(Employee: Record Employee; Setup: Record SalarySetup; Salary: Decimal; AtDate: Date) Bonus: Decimal
    var
        StartingDate: Date;
        EndingDate: Date;
    begin
        StartingDate := CalcDate('<CM+1D-1M>', AtDate);
        EndingDate := CalcDate('<CM>', AtDate);

        if Employee.Seniority in [Seniority::Staff, Seniority::Lead] then
            case Employee.SalaryType of
                SalaryType::Timesheet:
                    Bonus := CalculateBonusTimesheet(Employee, Setup, Salary, StartingDate, EndingDate);
                SalaryType::Commission:
                    Bonus := CalculateBonusCommission(Employee, Salary, StartingDate, EndingDate);
                SalaryType::Target:
                    Bonus := CalculateBonusTarget(Employee, Salary, StartingDate, EndingDate);
            end
        else
            if Employee.Seniority in [Seniority::Manager, Seniority::Director] then
                Bonus := CalculateManagerBonus(Employee, AtDate);
    end;

    internal procedure CalculateBonusTimesheet(Employee: Record Employee; Setup: Record SalarySetup; Salary: Decimal; StartingDate: Date; EndingDate: Date) Bonus: Decimal;
    var
        TimeSheetHeader: Record "Time Sheet Header";
        TimeSheetLine: Record "Time Sheet Line";
        WorkHours: Decimal;
    begin
        Setup.TestField(MinimumHours);
        Setup.TestField(OvertimeThreshold);
        Employee.TestField("Resource No.");

        TimeSheetHeader.SetRange("Resource No.", Employee."Resource No.");
        TimeSheetHeader.SetRange("Starting Date", StartingDate, EndingDate);
        TimeSheetHeader.SetRange("Ending Date", StartingDate, EndingDate);
        if TimeSheetHeader.FindSet() then
            repeat
                TimeSheetLine.Reset();
                TimeSheetLine.SetRange("Time Sheet No.", TimeSheetHeader."No.");
                TimeSheetLine.SetRange(Status, TimeSheetLine.Status::Approved);
                TimeSheetLine.SetAutoCalcFields("Total Quantity");
                if TimeSheetLine.FindSet() then
                    repeat
                        WorkHours += TimeSheetLine."Total Quantity";
                    until TimeSheetLine.Next() = 0;
            until TimeSheetHeader.Next() = 0;

        if WorkHours < Setup.MinimumHours then
            Bonus := -Salary * (1 - WorkHours / Setup.MinimumHours)
        else
            if (WorkHours > Setup.OvertimeThreshold) then
                Bonus := Salary * (WorkHours / Setup.OvertimeThreshold - 1);
    end;

    internal procedure CalculateBonusCommission(Employee: Record Employee; Salary: Decimal; StartingDate: Date; EndingDate: Date) Bonus: Decimal;
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
    begin
        Employee.TestField("Salespers./Purch. Code");

        CustLedgEntry.SetRange("Posting Date", StartingDate, EndingDate);
        CustLedgEntry.SetRange("Salesperson Code", Employee."Salespers./Purch. Code");
        CustLedgEntry.SetFilter("Document Type", '%1|%2', "Gen. Journal Document Type"::Invoice, "Gen. Journal Document Type"::"Credit Memo");
        CustLedgEntry.CalcSums("Profit (LCY)");
        Bonus := (Employee.CommissionBonusPct / 100) * CustLedgEntry."Profit (LCY)";
    end;

    internal procedure CalculateBonusTarget(Employee: Record Employee; Salary: Decimal; StartingDate: Date; EndingDate: Date) Bonus: Decimal;
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

    internal procedure CalculateManagerBonus(Employee: Record Employee; AtDate: Date) Bonus: Decimal
    var
        SubordinateEmployee: Record Employee;
        MonthlySalary: Record MonthlySalary;
    begin
        SubordinateEmployee.SetRange("Manager No.", Employee."No.");
        if SubordinateEmployee.FindSet() then
            repeat
                MonthlySalary.Reset();
                MonthlySalary.SetRange(EmployeeNo, SubordinateEmployee."No.");
                MonthlySalary.SetRange(Date, AtDate);
                if not MonthlySalary.FindFirst() then
                    MonthlySalary := SubordinateEmployee.CalculateSalary(AtDate);
                Bonus += MonthlySalary.Bonus;
            until SubordinateEmployee.Next() = 0;
        Bonus := Bonus * (Employee.TeamBonusPct / 100);
    end;

    internal procedure CalculateIncentive(Employee: Record Employee; Setup: Record SalarySetup; Salary: Decimal; AtDate: Date) Incentive: Decimal
    var
        YearsOfTenure: Integer;
    begin
        Setup.TestField(YearlyIncentivePct);
        if Employee.Seniority in [Seniority::Staff, Seniority::Lead] then begin
            YearsOfTenure := Round((AtDate - Employee."Employment Date") / 365, 1, '<');
            Incentive := Salary * (YearsOfTenure * Setup.YearlyIncentivePct) / 100;
        end else
            if Employee.Seniority = Seniority::Manager then
                Incentive := CalculateTeamIncentive(Employee, AtDate);
    end;

    internal procedure CalculateTeamIncentive(Employee: Record Employee; AtDate: Date) Incentive: Decimal
    var
        SubordinateEmployee: Record Employee;
        MonthlySalary: Record MonthlySalary;
    begin
        Incentive := 0;
        SubordinateEmployee.SetRange("Manager No.", Employee."No.");
        if SubordinateEmployee.FindSet() then
            repeat
                MonthlySalary.Reset();
                MonthlySalary.SetRange(EmployeeNo, SubordinateEmployee."No.");
                MonthlySalary.SetRange(Date, AtDate);
                if not MonthlySalary.FindFirst() then
                    MonthlySalary := SubordinateEmployee.CalculateSalary(AtDate);
                Incentive += MonthlySalary.Incentive;
            until SubordinateEmployee.Next() = 0;
        Incentive := Incentive * (Employee.TeamIncentivePct / 100);
    end;
}
