namespace ALchemy;

enum 60101 SalaryType implements ISalaryCalculator
{
    Caption = 'Salary Type';
    Extensible = true;

    value(1; Fixed)
    {
        Caption = 'Fixed Salary';
        Implementation = ISalaryCalculator = SalaryCalculatorFixed;
    }

    value(2; Timesheet)
    {
        Caption = 'Timesheet Salary';
        Implementation = ISalaryCalculator = SalaryCalculatorTimesheet;
    }

    value(3; Commission)
    {
        Caption = 'Commission Salary';
        Implementation = ISalaryCalculator = SalaryCalculatorCommission;
    }

    value(4; Target)
    {
        Caption = 'Target Salary';
        Implementation = ISalaryCalculator = SalaryCalculatorTarget;
    }

    value(5; Performance)
    {
        Caption = 'Performance Salary';
        Implementation = ISalaryCalculator = SalaryCalculatorPerformance;
    }
}
