namespace ALchemy;

using Microsoft.HumanResources.Employee;

codeunit 60106 SeniorityBonusManager implements ISeniorityBonus
{
    procedure ProvidesBonusCalculation(): Boolean;
    begin
        exit(true);
    end;

    procedure ProvidesIncentiveCalculation(): Boolean;
    begin
        exit(true);
    end;

    procedure CalculateBonus(Employee: Record Employee; AtDate: Date) Bonus: Decimal;
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

    procedure CalculateIncentive(Employee: Record Employee; AtDate: Date) Incentive: Decimal;
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
                Incentive += MonthlySalary.Incentive;
            until SubordinateEmployee.Next() = 0;
        Incentive := Incentive * (Employee.TeamIncentivePct / 100);
    end;
}
