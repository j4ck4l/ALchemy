namespace ALchemy;

using Microsoft.HumanResources.Employee;

interface ISeniorityScheme
{
    procedure GetBonusCalculator(Employee: Record Employee): Interface IBonusCalculator;
    procedure GetIncentiveCalculator(Employee: Record Employee): Interface IIncentiveCalculator;
}
