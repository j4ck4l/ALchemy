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

    procedure CalculateMonthlySalaries()
    var
        AtDate: Date;
    begin
        AtDate := CalcDate('<CM>', WorkDate());
        DeleteMonthlySalaries(AtDate);
        CalculateMonthlySalaries(AtDate);
    end;

    internal procedure DeleteMonthlySalaries(AtDate: Date)
    var
        MonthlySalary: Record MonthlySalary;
    begin
        MonthlySalary.SetRange(Date, AtDate);
        MonthlySalary.DeleteAll(false);
    end;

    internal procedure CalculateMonthlySalaries(AtDate: Date)
    var
        Employee: Record Employee;
        MonthlySalary: Record MonthlySalary;
    begin
        Employee.SetRange(Status, Employee.Status::Active);
        if Employee.FindSet() then
            repeat
                MonthlySalary := Employee.CalculateSalary(AtDate);
                MonthlySalary.Insert(false);
            until Employee.Next() = 0;
    end;
}