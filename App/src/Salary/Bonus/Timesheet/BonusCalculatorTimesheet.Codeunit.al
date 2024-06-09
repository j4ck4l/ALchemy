namespace ALchemy;

using Microsoft.HumanResources.Employee;

codeunit 60102 BonusCalculatorTimesheet implements IBonusCalculator, ITimesheetController
{
    Access = Internal;

    #region Controller Factory
    var
        _controller: Interface ITimesheetController;
        _controllerImplemented: Boolean;

    internal procedure Implement(Implementation: Interface ITimesheetController)
    begin
        _controller := Implementation;
        _controllerImplemented := true;
    end;

    local procedure GetController(): Interface ITimesheetController
    begin
        if not _controllerImplemented then
            Implement(this);

        exit(_controller);
    end;

    #endregion

    procedure CalculateBonus(Employee: Record Employee; Setup: Record SalarySetup; Salary: Decimal; StartingDate: Date; EndingDate: Date; AtDate: Date) Bonus: Decimal;
    begin
        Bonus := CalculateBonus(Employee, Setup, Salary, StartingDate, EndingDate, GetController());
    end;

    internal procedure CalculateBonus(Employee: Record Employee; Setup: Record SalarySetup; Salary: Decimal; StartingDate: Date; EndingDate: Date; Controller: Interface ITimesheetController) Bonus: Decimal;
    var
        WorkHoursProvider: Interface IWorkHoursProvider;
        WorkHours: Decimal;
    begin
        Setup.TestField(MinimumHours);
        Setup.TestField(OvertimeThreshold);
        Employee.TestField("Resource No.");

        WorkHoursProvider := Controller.GetWorkHoursProvider(Employee);
        WorkHours := WorkHoursProvider.CalculateHours(Employee, StartingDate, EndingDate);
        Bonus := Controller.CalculateBonus(Setup, WorkHours, Salary);
    end;

    #region ITimesheetController implementation

    internal procedure GetWorkHoursProvider(var Employee: Record Employee) WorkHoursProvider: Interface IWorkHoursProvider
    begin
        exit(Employee.GetWorkHoursProvider());
    end;

    internal procedure CalculateBonus(Setup: Record SalarySetup; WorkHours: Decimal; Salary: Decimal): Decimal
    begin
        if WorkHours < Setup.MinimumHours then
            exit(-Salary * (1 - WorkHours / Setup.MinimumHours));

        if (WorkHours > Setup.OvertimeThreshold) then
            exit(Salary * (WorkHours / Setup.OvertimeThreshold - 1));

        exit(0);
    end;

    #endregion
}
