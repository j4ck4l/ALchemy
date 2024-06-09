namespace ALchemy;

using Microsoft.HumanResources.Employee;

codeunit 60118 DefaultBaseSalaryCalculator implements IBaseSalaryCalculator
{
    procedure CalculateBaseSalary(Employee: Record Employee; Setup: Record SalarySetup) Salary: Decimal;
    var
        Department: Record Department;
        DepartmentSenioritySetup: Record DepartmentSenioritySetup;
    begin
        Setup.TestField(BaseSalary);

        Salary := Employee.BaseSalary;

        if Employee.BaseSalary <> 0 then
            exit;

        Salary := Setup.BaseSalary;
        if Employee.DepartmentCode = '' then
            exit;

        Department.Get(Employee.DepartmentCode);
        Salary := Department.BaseSalary;
        if DepartmentSenioritySetup.Get(Employee.DepartmentCode, Employee.Seniority) then
            Salary := DepartmentSenioritySetup.BaseSalary;
    end;
}
