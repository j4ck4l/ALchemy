namespace ALchemy;

using Microsoft.HumanResources.Employee;

table 60101 MonthlySalary
{
    Caption = 'Monthly Salary';
    DataClassification = CustomerContent;
    LookupPageId = MonthlySalaries;
    DrillDownPageId = MonthlySalaries;

    fields
    {
        field(1; EntryNo; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }

        field(2; EmployeeNo; Code[20])
        {
            Caption = 'Employee No.';
            TableRelation = Employee;
        }

        field(3; Date; Date)
        {
            Caption = 'Date';
        }

        field(4; Salary; Decimal)
        {
            Caption = 'Salary Amount';
        }

        field(5; Bonus; Decimal)
        {
            Caption = 'Bonus Amount';
        }

        field(6; Incentive; Decimal)
        {
            Caption = 'Incentive Amount';
        }
    }

    #region Controller factory
    var
        _controller: Interface IMonthlySalaryController;
        _implemented_Controller: Boolean;

    local procedure GetController(): Interface IMonthlySalaryController
    var
        Controller: Codeunit MonthlySalaryController;
    begin
        if not _implemented_Controller then
            Implement(Controller);

        exit(_controller)
    end;

    internal procedure Implement(Controller: Interface IMonthlySalaryController)
    begin
        _controller := Controller;
        _implemented_Controller := true;
    end;


    #endregion

    procedure CalculateMonthlySalaries()
    var
        Controller: Interface IMonthlySalaryController;
        AtDate: Date;
    begin
        Controller := GetController();

        AtDate := CalcDate('<CM>', WorkDate());
        Controller.DeleteMonthlySalaries(Rec, AtDate);
        Controller.CalculateMonthlySalaries(Rec, AtDate);
    end;
}
