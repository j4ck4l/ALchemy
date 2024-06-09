namespace ALchemy;

using Microsoft.HumanResources.Employee;

codeunit 60162 StubWorkhoursProvider implements IWorkHoursProvider
{
    procedure CalculateHours(Employee: Record Employee; StartingDate: Date; EndingDate: Date) Hours: Decimal
    begin
        Hours := 77;
    end;
}
