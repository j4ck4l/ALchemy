codeunit 60102 SalaryCalculatorTimesheet implements ISalaryCalculator
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

    procedure CalculateIncentive(Employee: Record Employee; Setup: Record SalarySetup; Salary: Decimal; AtDate: Date) Incentive: Decimal;
    var
        YearsOfTenure: Integer;
    begin
        Setup.TestField(YearlyIncentivePct);
        YearsOfTenure := Round((AtDate - Employee."Employment Date") / 365, 1, '<');
        Incentive := Salary * (YearsOfTenure * Setup.YearlyIncentivePct) / 100;
    end;
}