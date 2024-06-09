namespace ALchemy;

using Microsoft.HumanResources.Employee;
using Microsoft.Projects.TimeSheet;

codeunit 60109 BCWorkHoursProvider implements IWorkHoursProvider
{
    procedure CalculateHours(Employee: Record Employee; StartingDate: Date; EndingDate: Date) WorkHours: Decimal;
    var
        TimeSheetHeader: Record "Time Sheet Header";
        TimeSheetLine: Record "Time Sheet Line";
    begin
        TimeSheetHeader.SetRange("Resource No.", Employee."Resource No.");
        TimeSheetHeader.SetRange("Starting Date", StartingDate, EndingDate);
        TimeSheetHeader.SetRange("Ending Date", StartingDate, EndingDate);
        if TimeSheetHeader.FindSet() then
            repeat
                TimeSheetLine.Reset();
                TimeSheetLine.SetRange("Time Sheet No.", TimeSheetHeader."No.");
                TimeSheetLine.SetRange(Status, TimeSheetLine.Status::Approved);
                TimeSheetLine.SetAutoCalcFields("Total Quantity");
                if TimeSheetLine.FindSet() then
                    repeat
                        WorkHours += TimeSheetLine."Total Quantity";
                    until TimeSheetLine.Next() = 0;
            until TimeSheetHeader.Next() = 0;
    end;
}
