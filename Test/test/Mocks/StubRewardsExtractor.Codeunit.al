namespace ALchemy;

codeunit 60164 StubRewardsExtractor implements IRewardsExtractor
{
    procedure ExtractRewardComponent(MonthlySalary: Record MonthlySalary): Decimal
    begin
        exit(MonthlySalary.Incentive * 0.12);
    end;
}
