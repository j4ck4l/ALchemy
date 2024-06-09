namespace ALchemy;

using Microsoft.HumanResources.Employee;

codeunit 60100 SalaryCalculate
{
    procedure CalculateSalary(var Employee: Record Employee; AtDate: Date) Result: Record MonthlySalary
    var
        Setup: Record SalarySetup;
    begin
        Setup.Get();
        Result := CalculateSalary(Employee, Setup, AtDate);
    end;

    internal procedure CalculateSalary(var Employee: Record Employee; Setup: Record SalarySetup; AtDate: Date) Result: Record MonthlySalary
    var
        Calculator: Interface ISalaryCalculator;
        SeniorityBonus: Interface ISeniorityBonus;
        Salary: Decimal;
        Bonus: Decimal;
        Incentive: Decimal;
        StartingDate: Date;
        EndingDate: Date;
    begin
        Calculator := Employee.SalaryType;
        SeniorityBonus := Employee.Seniority;

        StartingDate := CalcDate('<CM+1D-1M>', AtDate);
        EndingDate := CalcDate('<CM>', AtDate);

        Salary := Calculator.CalculateBaseSalary(Employee, Setup);

        if SeniorityBonus.ProvidesBonusCalculation() then
            Bonus := SeniorityBonus.CalculateBonus(Employee, AtDate)
        else
            Bonus := Calculator.CalculateBonus(Employee, Setup, Salary, StartingDate, EndingDate);

        if SeniorityBonus.ProvidesIncentiveCalculation() then
            Incentive := SeniorityBonus.CalculateIncentive(Employee, AtDate)
        else
            Incentive := Calculator.CalculateIncentive(Employee, Setup, Salary, AtDate);

        Result.EmployeeNo := Employee."No.";
        Result.Date := AtDate;
        Result.Salary := Salary;
        Result.Bonus := Bonus;
        Result.Incentive := Incentive;
    end;
}
