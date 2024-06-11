# 05 DIP: Dependency Inversion Principle

In this exercise, you implement the improvements that follow the Dependency Inversion Principle.

## Scenario

When looking at your `SalaryCalculate` codeunit, you notice two general issues:
1. It has a very tight coupling to the input. You make an assumption that all salary, bonus, and incentive calculations are based on the same input parameters. This assumption is not always true. It's easy to imagine new bonus or incentive models which require more parameters and more context than you are currently passing into them. Just like you have a concept of *interface pollution* in the context of ISP (Interface Segregation Principle), there is a concept of parameter pollution. By adding extra parameters to your interface method signatures, you are forcing *all* implementers to use those parameters, even if they don't need them. This is also not extensible. It's easy to imagine that third parties will come up with new salary, bonus, or incentive models which require parameters of their own, that you cannot even foresee - there would be no way at all for them to implement their requirements with the current state of design.
2. It has too many concerns by doing too much work inside of itself. It's concerned both with calculating the salary and the way *how* the results would be used. It assumes that the only scenario in which you want to calculate salary is to write to the `MonthlySalary` table. This assumption makes your solution very rigid. What if you want to use results in different scenarios, such as writing to an external file, sending them to an external web service, or passing them onto another object such as a report. It's reasonable to expect that third parties may want to do something else with the results of the calculation, even if you can't see it for yourself at the moment.

There are two more SRP violations in this calculation as it is now:
1. You assume that all salary calculation models will be monthly, and you have date formulas that select the period hardcoded in the function itself. If you want to use weekly, daily, quarterly, or whatever other type of calculation, you cannot do it at all.
2. You make your calculation method be concerned with assigning values it is not in control of. Date of calculation is the input parameter, and the function is using it also as an output. That violates separation of concerns principle because how output will be used should not ever be a concern of the function providing that output. Output of the calculation is salary, bonus, and incentive - everything else belongs somewhere else.

To address these issues you can use the dependency inversion principle. You can make everything a bit more abstract by defining two new abstractions:
* Input abstraction in the form of a new `CalculationParameters` table, which will hold all necessary parameters for salary, bonus, and incentive calculations. This table will be used as a parameter for all calculation methods. That way, third parties that want to add more parameters that are useful to their implementation can create table extension objects that support those parameters, and thus make them available to their calculation models.
* Output abstraction in the form of a new `CalculationResult` table, which will hold the results of the salary, bonus, and incentive calculations.

Finally, you also want to design a new facility for storing results in whatever way anybody in the future may want to store them. For now, you are only storing them in the database, but since you can already foresee third parties wanting to use different ways of calculating salaries, you may also anticipate that they may want to do something else with results.


## Challenge Yourself

1. Create a new temporary table named `CalculationParameters`. In it, define all fields necessary by all existing salary, bonus, and incentive calculation models.
2. Change the signatures of all methods declared in all calculation interfaces, where methods receive `Setup`, `StartingDate`, `EndingDate`, and/or `AtDate` parameters, to receive a `CalculationParameters` record instead.
3. Correct all compilation errors in codeunits that implement interfaces you modified in the previous step to make sure that all implementations of the interfaces are updated to the new method signatures, and that their logic is updated to use the new `CalculationParameters` record.
    > Hint: Make sure to only correct those compilation errors. You'll fix others later.
4. Create a new interface named `IParametersProvider` with a single method named `GetParameters` that returns a `CalculationParameters` record.
5. In the `CalculationParameters` record, create a new method named `Initialize` that receives an instance of `IParametersProvider` and initializes the internal state of the record (`Rec`) from that instance. Also, retain the reference to the `IParametersProvider` instance in the internal state, and create a method named `GetProvider` that returns that reference to the caller.
    > Hint: You will need this reference for subordinate calculations. Since the current design of the slution demands that team bonus and incentives are calculated by doing the fresh calculation for each subordinate team member, and since the calculation starts with `IParametersProvider` rather than `CalculationParameters`, you need this reference for later calls.
6. Create a new codeunit named `MonthlyParametersProvider` that implements the `IParametersProvider` interface. Additionally, this codeunit has a method to initialize the `CalculationParameters` record with the necessary values for monthly calculations.
7. Update the `SalaryCalculate` codeunit to take advantage of the new `CalculationParameters` record and the `IParametersProvider` interface to perform its work.
8. Update the `TeamController` codeunit to use the new `IParemetersProvider` interface to calculate team bonuses and incentives.
9. In `MonthlySalary` table, define a new method named `GetParametersProvider` that returns an instance of `IParametersProvider` that is initialized with the necessary values for monthly calculations.
10. Fix the remaining compilation errors in `EmployeeCardExt`, `EmployeeExt`, and `MonthlySalary` to take advantage of the new `IParametersProvider` interface and the `CalculationParameters` record. Also, in `MonthlySalary` codeunit, there is a bug in code, that existing tests didn't catch! Try to see if you can spot it (running tests could help you).
11. Create a new temporary table named `CalculationResult` that has fields to keep the results of the salary, bonus, and incentive calculations.
    > Hint: You only need these three fields on this table, as only those fields represent the results of a calculation. Any other fields, like employee ID, date, etc., are actually parameters, not results of salary calculation, the calculation result should not be concerned with them. (Applying the separation of concerns to keep the design cleaner).
12. Update the `SalaryCalculate` codeunit to return a `CalculationResult` record instead of a `MonthlySalary` record.
13. Update the `CalculateSalary` method of `EmployeeExt` table to return a `CalculationResult` record instead of a `MonthlySalary` record.
    > Hint: Don't fix any resulting compilation errors yet. At this point you can either do a quick hack and incur some technical debt by just converting from `CalculationResult` to `MonthlySalary` or you can design it to be more future proof and retain the clean design you have built up until this point.
14. Modify the `IRewardsExtractor` interface to use the new `CalculationResult` record instead of the `MonthlySalary` record, and then update any objects that implement it.
15. Create a new interface named `ISalaryWriter` that has a single method named `WriteSalary` that receives a `CalculationResult` record. Also, update the `CalculationResult` table to have a method that writes the calculation by using a given `ISalaryWriter` instance.
16. Update the `TeamController` codeunit to use the `CalculationResult` record instead of the `MonthlySalary` record to calculate team bonus or incentive.
17. Create a new codeunit named `MonthlySalaryWriter` that implements the `ISalaryWriter` interface. In it, define a method that writes the calculation result to the database.
18. Update the `MonthlySalary` table to change how `CalculateMonthlySalaries` function works. It should use the new `CalculationResult` record instead of the `MonthlySalary` record to hold the result, but it should also take advantage of the `ISalaryWriter` interface to write the result to the database.
19. Fix remaining compilation errors in the `EmployeeExt` table extension and have it take advantage of the new calculation process design with `ISalaryWriter` and `CalculationResult` record.

## Step-by-step instructions

### Step 1: Create `CalculationParameters` table

1. In the `Salary` folder, create a new file named `CalculationParameters.Table.al`.
2. Define a new table named `CalculationParameters`, set its type to `Temporary`.
3. Copy all fields from the `SalarySetup` table, except for the primary key. Then define the following additional fields
    ```al
    field(8; AtDate; Date) { }
    field(9; StartingDate; Date) { }
    field(10; EndingDate; Date) { }
    ```

### Step 2: Change method signatures

1. Open the `IBaseSalaryCalculator` interface.
2. Change the `CalculateBaseSalary` method signature to receive a `CalculationParameters` record instead of existing parameters:
    ```pascal
    procedure CalculateBaseSalary(Employee: Record Employee; var Parameters: Record CalculationParameters): Decimal;
    ```
3.  Open the `IBonusCalculator` interface.
4.  Change the `CalculateBonus` method signature to receive a `CalculationParameters` record instead of existing parameters:
    ```pascal
    procedure CalculateBonus(Employee: Record Employee; Salary: Decimal; var Parameters: Record CalculationParameters): Decimal;
    ```
    > Hint: Retain the `Salary` parameter in the method signature.
5. Open the `IIncentiveCalculator` interface.
6. Change the `CalculateIncentive` method signature to receive a `CalculationParameters` record instead of existing parameters:
    ```pascal
    procedure CalculateIncentive(Employee: Record Employee; Salary: Decimal; var Parameters: Record CalculationParameters): Decimal
    ```
    > Hint: Retain the `Salary` parameter in the method signature.
7. Open the `IWorkHoursProvider` interface.
8. Change the `CalculateHours` method signature to receive a `CalculationParameters` record instead of existing parameters:
    ```pascal
    procedure CalculateHours(Employee: Record Employee; var Parameters: Record CalculationParameters): Decimal;
    ```

### Step 3: Update implementations

1. Update the `DefaultBaseSalaryCalculator` codeunit to use the `Parameters` record instead of existing parameters. Use the `Parameters` record instead of previous parameters to perform the calculation:
    ```pascal
    procedure CalculateBaseSalary(Employee: Record Employee; var Parameters: Record CalculationParameters) Salary: Decimal;
    var
        Department: Record Department;
        DepartmentSenioritySetup: Record DepartmentSenioritySetup;
    begin
        Parameters.TestField(BaseSalary);

        Salary := Employee.BaseSalary;

        if Employee.BaseSalary = 0 then begin
            Salary := Parameters.BaseSalary;
            if Employee.DepartmentCode <> '' then begin
                Department.Get(Employee.DepartmentCode);
                Salary := Department.BaseSalary;
                if DepartmentSenioritySetup.Get(Employee.DepartmentCode, Employee.Seniority) then
                    Salary := DepartmentSenioritySetup.BaseSalary;
            end;
        end;
    end;
    ```
2. Update the `NoBaseSalary` codeunit to use the new signature. No need to change anything in the body.
3. Update the `BonusCalculatorCommission` codeunit to use the `Parameters` record instead of existing parameters. Use the `Parameters` record instead of previous parameters to perform the calculation:
    ```pascal
    procedure CalculateBonus(Employee: Record Employee; Salary: Decimal; var Parameters: Record CalculationParameters) Bonus: Decimal;
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
    begin
        Employee.TestField("Salespers./Purch. Code");

        CustLedgEntry.SetRange("Posting Date", Parameters.StartingDate, Parameters.EndingDate);
        CustLedgEntry.SetRange("Salesperson Code", Employee."Salespers./Purch. Code");
        CustLedgEntry.SetFilter("Document Type", '%1|%2', "Gen. Journal Document Type"::Invoice, "Gen. Journal Document Type"::"Credit Memo");
        CustLedgEntry.CalcSums("Profit (LCY)");
        Bonus := (Employee.CommissionBonusPct / 100) * CustLedgEntry."Profit (LCY)";
    end;
    ```
4. Update the `BonusCalculatorPerformance` codeunit to to use the `Parameters` record instead of existing parameters. Use the `Parameters` record instead of previous parameters to perform the calculation:
    ```pascal
    procedure CalculateBonus(Employee: Record Employee; Salary: Decimal; var Parameters: Record CalculationParameters) Bonus: Decimal;
    var
        GLAccount: Record "G/L Account";
        GLEntry: Record "G/L Entry";
        Income: Decimal;
        Expense: Decimal;
        Profit: Decimal;
    begin
        GLEntry.SetRange("Posting Date", Parameters.StartingDate, Parameters.EndingDate);

        GLAccount.Get(Parameters.IncomeAccountNo);
        GLEntry.SetFilter("G/L Account No.", GLAccount.Totaling);
        GLEntry.CalcSums(Amount);
        Income := GLEntry.Amount;

        GLAccount.Get(Parameters.ExpenseAccountNo);
        GLEntry.SetFilter("G/L Account No.", GLAccount.Totaling);
        GLEntry.CalcSums(Amount);
        Expense := GLEntry.Amount;

        Profit := Income - Expense;
        if (Profit > 0) then
            Bonus := (Employee.PerformanceBonusPct / 100) * Profit;
    end;
    ```
5. Update the `BonusCalculatorTarget` codeunit to use the `Parameters` record instead of existing parameters. Use the `Parameters` record instead of previous parameters to perform the calculation:
    ```pascal
    procedure CalculateBonus(Employee: Record Employee; Salary: Decimal; var Parameters: Record CalculationParameters) Bonus: Decimal;
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
    begin
        Employee.TestField("Salespers./Purch. Code");

        CustLedgEntry.SetRange("Posting Date", Parameters.StartingDate, Parameters.EndingDate);
        CustLedgEntry.SetRange("Salesperson Code", Employee."Salespers./Purch. Code");
        CustLedgEntry.SetFilter("Document Type", '%1|%2', "Gen. Journal Document Type"::Invoice, "Gen. Journal Document Type"::"Credit Memo");
        CustLedgEntry.CalcSums("Sales (LCY)");
        Bonus := Employee.TargetBonus * (CustLedgEntry."Sales (LCY)" / Employee.TargetRevenue);
        if (Bonus > Employee.MaximumTargetBonus) and (Employee.MaximumTargetBonus > 0) then
            Bonus := Employee.MaximumTargetBonus
        else
            if (Bonus < Employee.MaximumTargetMalus) and (Employee.MaximumTargetMalus < 0) then
                Bonus := Employee.MaximumTargetMalus;
    end;
    ```
6. Update the `BonusCalculatorTimesheet` codeunit to use the `Parameters` record instead of existing parameters. Use the `Parameters` record instead of previous parameters to perform the calculation:
    ```pascal
    procedure CalculateBonus(Employee: Record Employee; Salary: Decimal; var Parameters: Record CalculationParameters) Bonus: Decimal;
    var
        WorkHoursProvider: Interface IWorkHoursProvider;
        WorkHours: Decimal;
    begin
        Parameters.TestField(MinimumHours);
        Parameters.TestField(OvertimeThreshold);
        Employee.TestField("Resource No.");

        WorkHoursProvider := Employee.GetWorkHoursProvider();
        WorkHours := WorkHoursProvider.CalculateHours(Employee, Parameters);

        if WorkHours < Parameters.MinimumHours then
            Bonus := -Salary * (1 - WorkHours / Parameters.MinimumHours)
        else
            if (WorkHours > Parameters.OvertimeThreshold) then
                Bonus := Salary * (WorkHours / Parameters.OvertimeThreshold - 1);
    end;
    ```
7. Update the `NoBonus` codeunit to use the new signature. No need to change anything in the body.
8. Update the `TeamBonusCalculator` codeunit to use the `Parameters` record instead of existing parameters. Use the `Parameters` record instead of previous parameters to perform the calculation:
    ```pascal
    procedure CalculateBonus(Employee: Record Employee; Salary: Decimal; var Parameters: Record CalculationParameters) Bonus: Decimal;
    var
        TeamController: Codeunit TeamController;
        this: Codeunit TeamBonus; // TODO BC25: This will become a built-in keyword; replace with it
    begin
        Bonus := TeamController.CalculateSubordinates(Employee."No.", Employee.TeamBonusPct, Parameters.AtDate, this);
    end;
    ```
9. Update the `DefaultIncentiveCalculator` codeunit to use the `Parameters` record instead of existing parameters. Use the `Parameters` record instead of previous parameters to perform the calculation:
    ```pascal
    procedure CalculateIncentive(Employee: Record Employee; Salary: Decimal; var Parameters: Record CalculationParameters) Incentive: Decimal
    var
        YearsOfTenure: Integer;
    begin
        Parameters.TestField(YearlyIncentivePct);
        YearsOfTenure := Round((Parameters.AtDate - Employee."Employment Date") / 365, 1, '<');
        Incentive := Salary * (YearsOfTenure * Parameters.YearlyIncentivePct) / 100;
    end;
    ```
10. Update the `NoIncentive` codeunit to use the new signature. No need to change anything in the body.
11. Update the `TeamIncentiveCalculator` codeunit to use the `Parameters` record instead of existing parameters. Use the `Parameters` record instead of previous parameters to perform the calculation:
    ```pascal
    procedure CalculateIncentive(Employee: Record Employee; Salary: Decimal; var Parameters: Record CalculationParameters) Incentive: Decimal
    var
        TeamController: Codeunit TeamController;
        this: Codeunit TeamIncentive; // TODO BC25: This will become a built-in keyword; replace with it
    begin
        Incentive := TeamController.CalculateSubordinates(Employee."No.", Employee.TeamIncentivePct, Parameters.AtDate, this);
    end;
    ```
12. Update the `BCWorkHoursProvider` codeunit to use the new signature:
    ```pascal
    procedure CalculateHours(Employee: Record Employee; var Parameters: Record CalculationParameters) WorkHours: Decimal;
    ```
13. Use the `Parameters` record instead of previous parameters to set filters in these two lines:
    ```pascal
    TimeSheetHeader.SetRange("Starting Date", Parameters.StartingDate, Parameters.EndingDate);
    TimeSheetHeader.SetRange("Ending Date", Parameters.StartingDate, Parameters.EndingDate);
    ```
14. Update the `TimetrackerWorkHoursProvider` codeunit to use the `Parameters` record instead of existing parameters. It requires only the signature update:
    ```pascal
    procedure CalculateHours(Employee: Record Employee; var Parameters: Record CalculationParameters): Decimal;
    ```

### Step 4: Create `IParametersProvider` interface

1. In the `Salary` folder, create a new file named `IParametersProvider.Interface.al`.
2. Define a new interface named `IParametersProvider` with a single method named `GetParameters` that returns a `CalculationParameters` record:
    ```al
    namespace ALchemy;

    interface IParametersProvider
    {
        procedure GetParameters(): Record CalculationParameters;
    }
    ```

### Step 5: Update `CalculationParameters` record

1. Open the `CalculationParameters` table.
2. Define a new global variable named `_provider` of type `Interface IParametersProvider`.
    ```al
    var
        _provider: Interface IParametersProvider;
    ```
3. Create a new method named `Initialize` that initializes the internal state of the record from the provided `IParametersProvider` instance and retains the reference to the provider it received:
    ```pascal
    procedure Initialize(Provider: Interface IParametersProvider)
    begin
        Rec := Provider.GetParameters();
        _provider := Provider;
    end;
    ```
4. Create a new method named `GetProvider` that returns the reference to the `IParametersProvider` instance:
    ```pascal
    procedure GetProvider(): Interface IParametersProvider
    begin
        exit(_provider);
    end;
    ```

### Step 6: Create `MonthlyParametersProvider` codeunit

1. In the `MonthlySalary` folder, create a new file named `MonthlyParametersProvider.Codeunit.al`.
2. Define a new codeunit named `MonthlyParametersProvider` that implements the `IParametersProvider` interface.
3. Define a private variable named `_parameters` of type `Record CalculationParameters`.
    ```pascal
    var
        _parameters: Record CalculationParameters;
    ```
4. From the `GetParameters` method, return the `_parameters` record:
    ```pascal
    procedure GetParameters(): Record CalculationParameters;
    begin
        exit(_parameters);
    end;
    ```
5. Create a new method named `Initialize` that initializes the `_parameters` record with the necessary values for monthly calculations:
    ```pascal
    procedure Initialize(Setup: Record SalarySetup; AtDate: Date)
    begin
        _parameters.BaseSalary := Setup.BaseSalary;
        _parameters.MinimumHours := Setup.MinimumHours;
        _parameters.OvertimeThreshold := Setup.OvertimeThreshold;
        _parameters.YearlyIncentivePct := Setup.YearlyIncentivePct;
        _parameters.IncomeAccountNo := Setup.IncomeAccountNo;
        _parameters.ExpenseAccountNo := Setup.ExpenseAccountNo;
        _parameters.AtDate := AtDate;
        _parameters.StartingDate := CalcDate('<CM+1D-1M>', AtDate);
        _parameters.EndingDate := CalcDate('<CM>', AtDate);
    end;
    ```

### Step 7: Update `SalaryCalculate` codeunit

1. Open the `SalaryCalculate` codeunit.
2. Change the signature of the first `CalculateSalary` method overload to receive an `IParametersProvider` interface instead of existing parameters:
    ```pascal
    procedure CalculateSalary(var Employee: Record Employee; ParametersProvider: Interface IParametersProvider) Result: Record MonthlySalary
    ```
3. Replace the `Setup` local variable declaration with a new one named `Parameters` of type `Record CalculationParameters`.
    ```pascal
    var
        Parameters: Record CalculationParameters;
    ```
4. Move all interface local variables from the second `CalculateSalary` method overload to the first one.
    > Hint: Just cut them from the second overload and paste them into the first one. You want to perform these assignments in the "entry point" overload method, to allow your calculation method to only be concerned with actual calculation.
5. In the first overload, assign the `Parameters` record by calling the `GetParameters` method on the `ParametersProvider` interface.
    ```pascal
    Parameters := ParametersProvider.GetParameters();
    ```
6. Move all code that extracts interfaces from the `Employee` record to the first overload.
    ```pascal
    BaseSalaryCalculator := Employee.SalaryType;
    SeniorityScheme := Employee.Seniority;
    BonusCalculator := SeniorityScheme.GetBonusCalculator(Employee);
    IncentiveCalculator := SeniorityScheme.GetIncentiveCalculator(Employee);
    ```
7. Change the signature of the second `CalculateSalary` method overload to receive a `CalculationParameters` record instead of existing parameters. Also, it should receive the relevant interface variables to perform its work:
    ```pascal
    internal procedure CalculateSalary(var Employee: Record Employee; var Parameters: Record CalculationParameters; BaseSalaryCalculator: Interface IBaseSalaryCalculator; BonusCalculator: Interface IBonusCalculator; IncentiveCalculator: Interface IIncentiveCalculator) Result: Record MonthlySalary
    ```
8. Modify the code inside this method overload to use the `Parameters` record instead of existing parameters.
    ```pascal
    Salary := BaseSalaryCalculator.CalculateBaseSalary(Employee, Parameters);
    Bonus := BonusCalculator.CalculateBonus(Employee, Salary, Parameters);
    Incentive := IncentiveCalculator.CalculateIncentive(Employee, Salary, Parameters);

    Result.EmployeeNo := Employee."No.";
    Result.Date := Parameters.AtDate;
    Result.Salary := Salary;
    Result.Bonus := Bonus;
    Result.Incentive := Incentive;
    ```
9. In the first overload, update the call to the second overload to pass the `Parameters` record and the relevant interface variables.
    ```pascal
        Result := CalculateSalary(Employee, Parameters, BaseSalaryCalculator, BonusCalculator, IncentiveCalculator);
    ```

### Step 8: Update `TeamController` codeunit

1. Open the `TeamController` codeunit.
2. Change the signature of the `CalculateSubordinates` method to receive an `IParametersProvider` interface instead of existing `AtDate` parameter:
    ```pascal
    procedure CalculateSubordinates(EmployeeNo: Code[20]; Percentage: Decimal; ParametersProvider: Interface IParametersProvider; RewardsExtractor: Interface IRewardsExtractor) Result: Decimal;
    ```
3. Declare a new local variable named `AtDate` of type `Date`.
    ```pascal
    var
        AtDate: Date;
    ```
4. At the beginning of the body of the `CalculateSubordinates` method, assign the `AtDate` variable by calling the `GetParameters` method on the `ParametersProvider` interface.
    ```pascal
        AtDate := ParametersProvider.GetParameters().AtDate;
    ```
5. Update the call to `CalculateSalary` to pass the `ParametersProvider` interface instead of the `AtDate` parameter.
    ```pascal
        MonthlySalary := SubordinateEmployee.CalculateSalary(ParametersProvider);
    ```

### Step 9: Update `MonthlySalary` table

1. Open the `MonthlySalary` table.
2. Define a new method named `GetParametersProvider` that returns an instance of `IParametersProvider` that is initialized with the necessary values for monthly calculations:
    ```pascal

    procedure GetParametersProvider(): Interface IParametersProvider
    var
        Setup: Record SalarySetup;
        MonthlyParametersProvider: Codeunit MonthlyParametersProvider;
    begin
        Setup.Get();
        MonthlyParametersProvider.Initialize(Setup, Today());
        exit(MonthlyParametersProvider);
    end;
    ```

### Step 10: Fix remaining compilation errors

1. Open the `EmployeeCardExt` page extension.
2. In the `GetTimetrackerData` action, replace the `OnAction` trigger with this code:
    ```pascal
    trigger OnAction()
    var
        Parameters: Record CalculationParameters;
        TimetrackerProvider: Codeunit TimetrackerWorkHoursProvider;
    begin
        TimetrackerProvider.CalculateHours(Rec, Parameters);
        CurrPage.Update(false);
    end;
    ```
    > Hint: It passes a blank parameter to the Timetracker calculator - it doesn't need this parameter, but it's required by the interface.
3. Open the `EmployeeExt` table extension.
4. Replace the two methods with compilation errors with these:
    ```pascal
    internal procedure CalculateSalary(ParametersProvider: Interface IParametersProvider) Salary: Record MonthlySalary
    var
        Calculate: Codeunit SalaryCalculate;
    begin
        exit(Calculate.CalculateSalary(Rec, ParametersProvider))
    end;

    internal procedure PreviewSalary()
    var
        TempMonthlySalary: Record MonthlySalary temporary;
    begin
        TempMonthlySalary := Rec.CalculateSalary(TempMonthlySalary.GetParametersProvider());
        TempMonthlySalary.Insert();
        Page.RunModal(Page::MonthlySalaryPreview, TempMonthlySalary);
    end;
    ```
5. Open the `MonthlySalary` table.
6. Update the invocation to the `CalculateSalary` method in the `CalculateSalary` trigger to pass the `GetParametersProvider` method result.
    ```pascal
    MonthlySalary := Employee.CalculateSalary(GetParametersProvider());
    ```
7. Fix the bug in the `CalculateMonthlySalaries` function! Yes, there was a bug that existing tests didn't catch. Change this line to use `Today()` instead of `WorkDate()`:
    ```pascal
        AtDate := CalcDate('<CM>', Today());
    ```
    > Hint: There was a bug in tests that didn't catch the problem with the inconsistency of the solution sometimes using `Today()` and sometimes `WorkDate()`. Either change all instances to use `WorkDate()` or have them all use `Today()`, but they must all be consistent.

### Step 11: Create `CalculationResult` table

1. In the `Salary` folder, create a new file named `CalculationResult.Table.al`.
2. Define a new table named `CalculationResult` with the following fields:
    ```al
        field(1; Salary; Decimal) { }
        field(2; Bonus; Decimal) { }
        field(3; Incentive; Decimal) { }
    ```

### Step 12: Update `SalaryCalculate` codeunit

1. Open the `SalaryCalculate` codeunit.
2. Change the return type of the first `CalculateSalary` method overload to return a `CalculationResult` record instead of a `MonthlySalary` record:
    ```pascal
    procedure CalculateSalary(var Employee: Record Employee; ParametersProvider: Interface IParametersProvider) Result: Record CalculationResult
    ```
3. Change the return type of the second `CalculateSalary` method overload to return a `CalculationResult` record instead of a `MonthlySalary` record:
    ```pascal
    internal procedure CalculateSalary(var Employee: Record Employee; var Parameters: Record CalculationParameters; BaseSalaryCalculator: Interface IBaseSalaryCalculator; BonusCalculator: Interface IBonusCalculator; IncentiveCalculator: Interface IIncentiveCalculator) Result: Record CalculationResult
    ```
4. Modify the result assignment in the second `CalculateSalary` method overload by removing the non-existent fields from the `MonthlySalary` record:
    ```pascal
    Result.Salary := Salary;
    Result.Bonus := Bonus;
    Result.Incentive := Incentive;
    ```

### Step 13: Update `EmployeeExt` table

1. Open the `EmployeeExt` table extension.
2. Change the return type of the `CalculateSalary` method to return a `CalculationResult` record instead of a `MonthlySalary` record:
    ```pascal
    internal procedure CalculateSalary(ParametersProvider: Interface IParametersProvider) Result: Record CalculationResult
    ```

### Step 14: Update `IRewardsExtractor` interface

1. Open the `IRewardsExtractor` interface.
2. Change the `ExtractRewards` method signature to receive a `CalculationResult` record instead of a `MonthlySalary` record:
    ```pascal
    procedure ExtractRewardComponent(Result: Record CalculationResult): Decimal;
    ```
3. Open the `TeamBonus` codeunit.
4. Change the `ExtractRewardComponent` method to receive a `CalculationResult` record instead of a `MonthlySalary` record and update it accordingly:
    ```pascal
    internal procedure ExtractRewardComponent(Result: Record CalculationResult): Decimal
    begin
        exit(Result.Bonus);
    end;
    ```
5. Open the `TeamIncentive` codeunit.
6. Change the `ExtractRewardComponent` method to receive a `CalculationResult` record instead of a `MonthlySalary` record and update it accordingly:
    ```pascal
    internal procedure ExtractRewardComponent(Result: Record CalculationResult): Decimal
    begin
        exit(Result.Incentive);
    end;
    ```

### Step 15: Create `ISalaryWriter` interface

1. In the `Salary` folder, create a new file named `ISalaryWriter.Interface.al`.
2. Define a new interface named `ISalaryWriter` with a single method named `WriteSalary` that receives a `CalculationResult` record:
    ```al
    namespace ALchemy;

    interface ISalaryWriter
    {
        procedure WriteSalary(CalculationResult: Record CalculationResult);
    }
    ```
3. Open the `CalculationResult` table.
4. Define a new method named `Write` that receives an instance of `ISalaryWriter` and writes the calculation by using that instance:
    ```pascal
    procedure Write(Writer: Interface ISalaryWriter)
    begin
        Writer.WriteSalary(Rec);
    end;
    ```

### Step 16: Update `TeamController` codeunit

1. Open the `TeamController` codeunit.
2. Inside the `CalculateSubordinates` method, add a new local variable named `CalculationResult` of type `Record CalculationResult`.
    ```pascal
    CalculationResult: Record CalculationResult;
    ```
3. Change the block of code that increments the `Results` variable based on retrieved or calculated monthly salary record, and replace it with this code:
    ```pascal
    if MonthlySalary.FindFirst() then
        CalculationResult := MonthlySalary.ToCalculationResult()
    else
        CalculationResult := SubordinateEmployee.CalculateSalary(ParametersProvider);
    Result += RewardsExtractor.ExtractRewardComponent(CalculationResult);
    ```
    > Hint: This code not only updates the logic to support the change in the input and return types of different methods, but also communicates its purpose better. Previously the variable `MonthlySalary` was used to both loop through records in the database and hold fresh calculation results, which not only looks convoluted, but could be a potential source of bugs if somebody decides to change the logic to use that variable for further operations. This "variable recylcing" is not a good thing, and now we have two separate variables, each of which serves its own separate purpose. More separation of concerns, if you want.

### Step 17: Create `MonthlySalaryWriter` codeunit

1. In the `MonthlySalary` folder, create a new file named `MonthlySalaryWriter.Codeunit.al`.
2. Paste the following code into it:
   ```al
    codeunit 60116 MonthlySalaryWriter implements ISalaryWriter
    {
        var
            _monthlySalary: Record MonthlySalary;
            _employee: Record Employee;
            _atDate: Date;
            _writeToDatabase: Boolean;

        procedure Initialize(Employee: Record Employee; AtDate: Date)
        begin
            Initialize(Employee, AtDate, true);
        end;

        procedure Initialize(Employee: Record Employee; AtDate: Date; WriteToDatabase: Boolean)
        begin
            _employee := Employee;
            _atDate := AtDate;
            _writeToDatabase := WriteToDatabase;
        end;

        procedure GetMonthlySalary(): Record MonthlySalary
        begin
            exit(_monthlySalary);
        end;

        procedure WriteSalary(CalculationResult: Record CalculationResult)
        var
            MonthlySalary: Record MonthlySalary;
        begin
            MonthlySalary.EmployeeNo := _employee."No.";
            MonthlySalary.Date := _atDate;
            MonthlySalary.Salary := CalculationResult.Salary;
            MonthlySalary.Bonus := CalculationResult.Bonus;
            MonthlySalary.Incentive := CalculationResult.Incentive;

            if _writeToDatabase then
                MonthlySalary.Insert(false);

            _monthlySalary := MonthlySalary;
        end;
    }
   ```
    > Hint: Read it and try to understand how it will be used and why it's designed the way it is.

### Step 18: Update `MonthlySalary` table

1. Open the `MonthlySalary` table.
2. In the `CalculateMonthlySalaries` function, rename the `MonthlySalary` variable declaration to the `Result` variable declaration to be of type `Record CalculationResult` instead of `Record MonthlySalary`.
    ```pascal
    Result: Record CalculationResult;
    ```
3. Declare a new variable named `MonthlySalaryWriter` of type `Codeunit MonthlySalaryWriter`.
    ```pascal
    MonthlySalaryWriter: Codeunit MonthlySalaryWriter;
    ```
4. Change the contents of the `repeat..until` loop to use the `MonthlySalaryWriter` variable to write the calculation result to the database.
    ```pascal
    Result := Employee.CalculateSalary(GetParametersProvider());
    MonthlySalaryWriter.Initialize(Employee, AtDate);
    Result.Write(MonthlySalaryWriter);
    ```

### Step 19: Fix remaining compilation errors

1. Open the `EmployeeExt` table extension.
2. Change the signature of the `CalculateSalary` method to return a `CalculationResult` record instead of a `MonthlySalary` record:
    ```pascal
    internal procedure CalculateSalary(ParametersProvider: Interface IParametersProvider) Result: Record CalculationResult
    ```
3. In the `PreviewSalary` method, define two new local variables named `MonthlySalaryWriter` and `CalculationResult`:
    ```pascal
    Result: Record CalculationResult;
    MonthlySalaryWriter: Codeunit MonthlySalaryWriter;
    ```
4. Change the body of the function to use the `MonthlySalaryWriter` variable to update the temporary table it shows in the preview:
    ```pascal
    MonthlySalaryWriter.Initialize(Rec, Today(), false);
    Result := Rec.CalculateSalary(TempMonthlySalary.GetParametersProvider());
    Result.Write(MonthlySalaryWriter);

    TempMonthlySalary := MonthlySalaryWriter.GetMonthlySalary();
    TempMonthlySalary.Insert();

    Page.RunModal(Page::MonthlySalaryPreview, TempMonthlySalary);
    ```
