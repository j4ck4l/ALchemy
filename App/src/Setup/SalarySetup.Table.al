namespace ALchemy;

using Microsoft.Finance.GeneralLedger.Account;

table 60100 SalarySetup
{
    Caption = 'Salary Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; PrimaryKey; Code[10])
        {
            Caption = 'Primary Key';
            NotBlank = true;
        }

        field(2; BaseSalary; Decimal)
        {
            Caption = 'Base Salary';
        }

        field(3; MinimumHours; Decimal)
        {
            Caption = 'Minimum Hours';
        }

        field(4; OvertimeThreshold; Decimal)
        {
            Caption = 'Overtime Threshold';
        }

        field(5; YearlyIncentivePct; Decimal)
        {
            Caption = 'Yearly Incentive %';
        }

        field(6; IncomeAccountNo; Code[20])
        {
            Caption = 'Revenue Account No.';
            TableRelation = "G/L Account" where("Account Type" = const(Total));
        }

        field(7; ExpenseAccountNo; Code[20])
        {
            Caption = 'Expense Account No.';
            TableRelation = "G/L Account" where("Account Type" = const(Total));
        }
    }

    keys
    {
        key(PK; PrimaryKey)
        {
            Clustered = true;
        }
    }

}
