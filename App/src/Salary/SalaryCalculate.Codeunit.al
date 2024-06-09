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
        BaseSalaryCalculator: Interface IBaseSalaryCalculator;
        SeniorityScheme: Interface ISeniorityScheme;
        BonusCalculator: Interface IBonusCalculator;
        IncentiveCalculator: Interface IIncentiveCalculator;
        Salary: Decimal;
        Bonus: Decimal;
        Incentive: Decimal;
        StartingDate: Date;
        EndingDate: Date;
    begin
        BaseSalaryCalculator := Employee.SalaryType;
        SeniorityScheme := Employee.Seniority;
        BonusCalculator := SeniorityScheme.GetBonusCalculator(Employee);
        IncentiveCalculator := SeniorityScheme.GetIncentiveCalculator(Employee);

        StartingDate := CalcDate('<CM+1D-1M>', AtDate);
        EndingDate := CalcDate('<CM>', AtDate);

        Salary := BaseSalaryCalculator.CalculateBaseSalary(Employee, Setup);
        Bonus := BonusCalculator.CalculateBonus(Employee, Setup, Salary, StartingDate, EndingDate, AtDate);
        Incentive := IncentiveCalculator.CalculateIncentive(Employee, Setup, Salary, AtDate);

        Result.EmployeeNo := Employee."No.";
        Result.Date := AtDate;
        Result.Salary := Salary;
        Result.Bonus := Bonus;
        Result.Incentive := Incentive;
    end;
}
