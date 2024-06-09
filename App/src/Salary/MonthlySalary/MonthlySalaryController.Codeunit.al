namespace ALchemy;

using Microsoft.HumanResources.Employee;

codeunit 60115 MonthlySalaryController implements IMonthlySalaryController
{
    Access = Internal;

    #region Controller factory
    var
        _controller: Interface IMonthlySalaryController;
        _implemented_Controller: Boolean;

    local procedure GetController(): Interface IMonthlySalaryController
    begin
        if not _implemented_Controller then
            Implement(this);

        exit(_controller);
    end;

    internal procedure Implement(Controller: Interface IMonthlySalaryController)
    begin
        _controller := Controller;
        _implemented_Controller := true;
    end;

    #endregion

    internal procedure DeleteMonthlySalaries(var MonthlySalary: Record MonthlySalary; AtDate: Date)
    begin
        MonthlySalary.SetRange(Date, AtDate);
        MonthlySalary.DeleteAll(false);
    end;

    internal procedure CalculateMonthlySalaries(var MonthlySalary: Record MonthlySalary; AtDate: Date)
    begin
        CalculateMonthlySalaries(MonthlySalary, AtDate, GetController());
    end;

    internal procedure CalculateMonthlySalaries(var MonthlySalary: Record MonthlySalary; AtDate: Date; Controller: Interface IMonthlySalaryController)
    var
        Employee: Record Employee;
    begin
        Employee.SetRange(Status, Employee.Status::Active);
        Controller.ProcessEmployees(Employee, MonthlySalary, AtDate, Controller);
    end;

    internal procedure ProcessEmployees(var Employee: Record Employee; var MonthlySalary: Record MonthlySalary; AtDate: Date; Controller: Interface IMonthlySalaryController)
    begin
        if Employee.FindSet() then
            repeat
                Controller.ProcessEmployee(Employee, MonthlySalary, AtDate);
            until Employee.Next() = 0;
    end;

    internal procedure ProcessEmployee(var Employee: Record Employee; var MonthlySalary: Record MonthlySalary; AtDate: Date)
    begin
        MonthlySalary := Employee.CalculateSalary(AtDate);
        MonthlySalary.Insert(false);
    end;

}
