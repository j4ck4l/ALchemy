namespace ALchemy;

using Microsoft.HumanResources.Employee;

interface IWorkHoursProvider
{
    procedure CalculateHours(Employee: Record Employee; StartingDate: Date; EndingDate: Date): Decimal;
}
