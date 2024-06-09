namespace ALchemy;

using Microsoft.Projects.TimeSheet;
using Microsoft.HumanResources.Employee;

codeunit 60154 "Test - IWorkHoursProvider"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;

    [Test]
    procedure Test_BCWorkHoursProvider_CalculateHours()
    var
        Employee: Record Employee;
        BCWorkHoursProvider: Codeunit BCWorkHoursProvider;
        WorkHours: Decimal;
        S: Codeunit NoBonus;
    begin
        // Assemble
        CreateTimeSheetHeader('DUMMY_RES_01', 3, 18);
        CreateTimeSheetHeader('DUMMY_RES_02', 2, 10);
        CreateTimeSheetHeader('DUMMY_RES_03', 1, 6);
        Employee."Resource No." := 'DUMMY_RES_01';

        // Act
        WorkHours := BCWorkHoursProvider.CalculateHours(Employee, Today(), Today());

        // Assert
        Assert.AreEqual(18, WorkHours, 'Work hours for DUMMY_RES_01 should be 18');
    end;

    local procedure CreateTimeSheetHeader(ResourceNo: Code[20]; Lines: Integer; TotalQuantity: Decimal)
    var
        TimeSheetHeader: Record "Time Sheet Header";
        TimeSheetLine: Record "Time Sheet Line";
        TimeSheetDetail: Record "Time Sheet Detail";
    begin
        TimeSheetHeader."No." := ResourceNo;
        if TimeSheetHeader.Find() then
            TimeSheetHeader.Delete();

        TimeSheetHeader."Starting Date" := Today();
        TimeSheetHeader."Ending Date" := Today();
        TimeSheetHeader."Resource No." := ResourceNo;
        TimeSheetHeader.Insert(false);

        TotalQuantity := TotalQuantity / Lines;

        while Lines > 0 do begin
            Lines -= 1;

            TimeSheetLine.Init();
            TimeSheetLine."Time Sheet No." := TimeSheetHeader."No.";
            TimeSheetLine."Line No." += 10000;
            TimeSheetLine.Status := TimeSheetLine.Status::Approved;
            TimeSheetLine.Insert(false);

            TimeSheetDetail."Time Sheet No." := TimeSheetLine."Time Sheet No.";
            TimeSheetDetail."Time Sheet Line No." := TimeSheetLine."Line No.";
            TimeSheetDetail.Date := Today();
            TimeSheetDetail.Quantity := TotalQuantity;
            TimeSheetDetail.Insert(false);
        end;
    end;
}
