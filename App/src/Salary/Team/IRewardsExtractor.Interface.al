namespace ALchemy;

using Microsoft.HumanResources.Employee;

interface IRewardsExtractor
{
    Access = Internal;

    procedure ExtractRewardComponent(MonthlySalary: Record MonthlySalary): Decimal;
}
