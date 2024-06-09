namespace ALchemy;

using Microsoft.HumanResources.Employee;

interface ITeamController
{
    Access = Internal;

    procedure CalculateSubordinates(EmployeeNo: Code[20]; Percentage: Decimal; AtDate: Date; RewardsExtractor: Interface IRewardsExtractor; Controller: Interface ITeamController) Result: Decimal;
    procedure FilterSubordinates(EmployeeNo: Code[20]; var SubordinateEmployee: Record Employee);
    procedure ProcessSubordinates(var SubordinateEmployee: Record Employee; Percentage: Decimal; AtDate: Date; RewardsExtractor: Interface IRewardsExtractor; Controller: Interface ITeamController) Result: Decimal;
    procedure GetSubordinateReward(var SubordinateEmployee: Record Employee; AtDate: Date; RewardsExtractor: Interface IRewardsExtractor; Controller: Interface ITeamController): Decimal;
    procedure FindMonthlySalary(var MonthlySalary: Record MonthlySalary; SubordinateEmployeeNo: Code[20]; AtDate: Date): Boolean;
    procedure CalculateReward(Bonus: Decimal; Percentage: Decimal): Decimal;
}
