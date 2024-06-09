namespace ALchemy;

enum 60101 SalaryType implements IBaseSalaryCalculator, IBonusCalculator, IIncentiveCalculator
{
    Caption = 'Salary Type';
    Extensible = true;

    DefaultImplementation =
        IBaseSalaryCalculator = DefaultBaseSalaryCalculator,
        IIncentiveCalculator = DefaultIncentiveCalculator;

    value(1; Fixed)
    {
        Caption = 'Fixed Salary';
        Implementation = IBonusCalculator = NoBonus;
    }

    value(2; Timesheet)
    {
        Caption = 'Timesheet Salary';
        Implementation = IBonusCalculator = BonusCalculatorTimesheet;
    }

    value(3; Commission)
    {
        Caption = 'Commission Salary';
        Implementation = IBonusCalculator = BonusCalculatorCommission;
    }

    value(4; Target)
    {
        Caption = 'Target Salary';
        Implementation = IBonusCalculator = BonusCalculatorTarget;
    }

    value(5; Performance)
    {
        Caption = 'Performance Salary';
        Implementation =
            IBaseSalaryCalculator = NoBaseSalary,
            IBonusCalculator = BonusCalculatorPerformance,
            IIncentiveCalculator = NoIncentive;
    }
}
