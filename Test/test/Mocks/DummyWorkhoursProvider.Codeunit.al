namespace ALchemy;

using Microsoft.HumanResources.Employee;

codeunit 60170 DummyWorkhoursProvider implements IWorkHoursProvider
{
    procedure CalculateHours(Employee: Record Employee; StartingDate: Date; EndingDate: Date): Decimal
    begin
    end;
}