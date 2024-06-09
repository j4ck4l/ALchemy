codeunit 60102 BonusCalculatorTimesheet implements IBonusCalculator
{
    procedure CalculateBonus(Employee: Record Employee; Setup: Record SalarySetup; Salary: Decimal; StartingDate: Date; EndingDate: Date; AtDate: Date) Bonus: Decimal;
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
}
