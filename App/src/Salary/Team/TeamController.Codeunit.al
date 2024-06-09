namespace ALchemy;

using Microsoft.HumanResources.Employee;

codeunit 60101 TeamController
{
    Access = Internal;

    procedure CalculateSubordinates(EmployeeNo: Code[20]; Percentage: Decimal; AtDate: Date; RewardsExtractor: Interface IRewardsExtractor) Result: Decimal;
    var
        SubordinateEmployee: Record Employee;
        MonthlySalary: Record MonthlySalary;
    begin
        SubordinateEmployee.SetRange("Manager No.", EmployeeNo);
        if SubordinateEmployee.FindSet() then
            repeat
                MonthlySalary.Reset();
                MonthlySalary.SetRange(EmployeeNo, SubordinateEmployee."No.");
                MonthlySalary.SetRange(Date, AtDate);
                if not MonthlySalary.FindFirst() then
                    MonthlySalary := SubordinateEmployee.CalculateSalary(AtDate);
                Result += RewardsExtractor.ExtractRewardComponent(MonthlySalary);
            until SubordinateEmployee.Next() = 0;
        Result := Result * (Percentage / 100);
    end;
}
