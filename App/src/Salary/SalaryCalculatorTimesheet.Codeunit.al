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
        WorkHoursProvider: Interface IWorkHoursProvider;
        WorkHours: Decimal;
    begin
        Setup.TestField(MinimumHours);
        Setup.TestField(OvertimeThreshold);
        Employee.TestField("Resource No.");

        WorkHoursProvider := Employee.GetWorkHoursProvider();
        WorkHours := WorkHoursProvider.CalculateHours(Employee, StartingDate, EndingDate);

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