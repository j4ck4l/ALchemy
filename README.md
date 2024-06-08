# 01 SRP: Single Responsibility Principle

In this exercise, you implement the improvements that follow the Single Responsibility Principle (SRP).

## Challenge **Yourself**

1. In `SalaryCalculate` codeunit, create three new functions: one to calculate base salary, one to calculate bonus, and one to calculate incentives. Then, delegate the work for base salary calculation, bonus calculation, and incentive calculation into those functions by removing it from the original function into these new functions. Call these new functions from the original function.
2. Define three new functions for calculating timesheet-based, commission, and target bonuses. Then, delegate the work for calculating these bonuses into these new functions by removing it from the bonus calculation function you created in the previous step. Call these new functions from the bonus calculation function for staff and lead levels.
3. Create a new function for calculating manager bonus and delegate the code responsible for calculating manager bonus into this function. Do the same for incentive calculation.
4. Move any relevant `TestField` invocations from the original place into relevant places in the new functions you created. With this, you make sure that the responsibility for testing individual fields needed for an individual function is only happening inside that function, and not in a central place like before.
5. Make sure that the `CalculateSalary` function inside `SalaryCalculate` codeunit never reads the `Setup` record from the database. Instead, have this function receive the `Setup` record as a parameter, and create an overload of the function that does not receive the `Setup` record as a parameter. This overload should call the other overload, passing the `Setup` record as a parameter. This achieves that we don't break any existing code that calls the `CalculateSalary` function, while making database retrieval no longer the responsibility of this main salary calculation function.
6. In `MonthlySalary` table, move the `AtDate` declaration from local variables into the function's signature as a parameter. Then create an overload for `CalculateMonthlySalaries` that retains the original signature. Move the `AtDate` calculation from original `CalculateMonthlySalaries` to this new overload, and invoke the original by passing `AtDate` into it as a parameter.
7. Create a new function to delete monthly salaries for the specified date, move the code from `CalculateMonthlySalaries` that deletes the monthly salaries for the specified date into this new function, and call this new function from `CalculateMonthlySalaries`.

## Step-by-Step Instructions

## Step 1: Delegate work

1. Open the `SalaryCalculate` codeunit.
2. Create a new internal function named `CalculateBaseSalary` that returns a `Decimal` value named `Salary`.
    ```pascal
    internal procedure CalculateBaseSalary(Employee: Record Employee; Setup: Record SalarySetup) Salary: Decimal
    ```
3. Create a new internal function named `CalculateBonus` that returns a `Decimal` value named `Bonus`.
    ```pascal
    internal procedure CalculateBonus(Employee: Record Employee; Setup: Record SalarySetup; Salary: Decimal; AtDate: Date) Bonus: Decimal
    ```
4. Create a new internal function named `CalculateIncentive` that returns a `Decimal` value named `Incentives`.
    ```pascal
    internal procedure CalculateIncentive(Employee: Record Employee; Setup: Record SalarySetup; Salary: Decimal; AtDate: Date) Incentive: Decimal
    ```
5. Cut the code that calculates the base salary from the `CalculateSalary` function and paste it into the `CalculateBaseSalary` function. The code is the block that follows the `// Calculate base salary` comment.
6. Cut the code that calculates the bonus from the `CalculateSalary` function and paste it into the `CalculateBonus` function. The code is the block that follows the `// Calculate bonus` comment.
7. Cut the code that calculates the incentives from the `CalculateSalary` function and paste it into the `CalculateIncentive` function. The code is the block that follows the `// Calculate incentives` comment.
8. In the `CalculateSalary` function, call the `CalculateBaseSalary`, `CalculateBonus`, and `CalculateIncentive` functions to calculate the salary, bonus, and incentives, and assign the results to the `Salary`, `Bonus`, and `Incentive` variables, respectively.

## Step 2: Define more clear bonus calculation responsibilities

1. Create a new internal function named `CalculateBonusTimesheet` that returns a `Decimal` value named `Bonus`.
    ```pascal
    internal procedure CalculateBonusTimesheet(Employee: Record Employee; Setup: Record SalarySetup; Salary: Decimal; StartingDate: Date; EndingDate: Date) Bonus: Decimal
    ```
2. Create a new internal function named `CalculateBonusCommission` that returns a `Decimal` value named `Bonus`.
   ```pascal
   internal procedure CalculateBonusCommission(Employee: Record Employee; Salary: Decimal; StartingDate: Date; EndingDate: Date) Bonus: Decimal
   ```
3. Create a new internal function named `CalculateBonusTarget` that returns a `Decimal` value named `Bonus`.
   ```pascal
   internal procedure CalculateBonusTarget(Employee: Record Employee; Salary: Decimal; StartingDate: Date; EndingDate: Date) Bonus: Decimal
   ```
4. Cut the code that calculates the timesheet-based bonus from the `CalculateBonus` function and paste it into the `CalculateBonusTimesheet` function. Call this function from the `CalculateBonus` function where you cut the code.
5. Cut the code that calculates the commission bonus from the `CalculateBonus` function and paste it into the `CalculateBonusCommission` function. Call this function from the `CalculateBonus` function where you cut the code.
6. Cut the code that calculates the target bonus from the `CalculateBonus` function and paste it into the `CalculateBonusTarget` function. Call this function from the `CalculateBonus` function where you cut the code.

## Step 3: Delegate manager bonus calculation

1. Create a new internal function named `CalculateManagerBonus` that returns a `Decimal` value named `Bonus`.
    ```pascal
    internal procedure CalculateManagerBonus(Employee: Record Employee; AtDate: Date) Bonus: Decimal
    ```
2. Create a new internal function named `CalculateTeamIncentive` that returns a `Decimal` value named `Incentive`.
    ```pascal
    internal procedure CalculateTeamIncentive(Employee: Record Employee; AtDate: Date) Incentive: Decimal
    ```
3. Cut the code that calculates the manager bonus from the `CalculateBonus` function and paste it into the `CalculateManagerBonus` function. Call this function from the `CalculateBonus` function where you cut the code.
4. Cut the code that calculates the team incentive from the `CalculateIncentive` function and paste it into the `CalculateTeamIncentive` function. Call this function from the `CalculateIncentive` function where you cut the code.

## Step 4: Move `TestField` invocations

1. Move `Setup.TestField(BaseSalary)` call from `CalculateSalary` to `CalculateBaseSalary`.
2. Move `Setup.TestField` calls for fields `MinimumHours` and `OvertimeThreshold` from `CalculateBonus` to `CalculateBonusTimesheet`.
3. Move `Setup.TestField(YearlyIncentivePct)` call from `CalculateIncentive` to `CalculateIncentive`.
4. Move `Employee.TestField("Resource No.")` call from `CalculateManagerBonus` to `CalculateBonusTimesheet`.
5. Cut `Employee.TestField("Salespers./Purch. Code")` call from `CalculateTeamIncentive` and paste it to both `CalculateBonusCommission` and `CalculateBonusTarget`.

## Step 5: Create an overload for `CalculateSalary`

1. Change the signature of the `CalculateSalary` function to accept a `Setup` record as a parameter.
    ```pascal
    internal procedure CalculateSalary(Employee: Record Employee; Setup: Record SalarySetup; AtDate: Date) Result: Record MonthlySalary
    ```
2. Remove the `Setup` local variable from the `CalculateSalary` function, and remove the `Setup.Get()` call.
2. Create an overload for the `CalculateSalary` function that has the original signature, reads the `Setup` record from the database, and calls the other overload by passing the `Setup` record as a parameter.
    ```pascal
    procedure CalculateSalary(var Employee: Record Employee; AtDate: Date) Result: Record MonthlySalary
    var
        Setup: Record SalarySetup;
    begin
        Setup.Get();
        Result := CalculateSalary(Employee, Setup, AtDate);
    end;
    ```

## Step 6: Improve responsibilities in `MonthlySalary` table

1. Change the signature of the `CalculateMonthlySalaries` function to accept an `AtDate` parameter. Also, remove the `AtDate` local variable from the function.
    ```pascal
    internal procedure CalculateMonthlySalaries(AtDate: Date)
    ```
2. Create an overload for the `CalculateMonthlySalaries` function that has the original signature. Cut the `AtDate` calculation from the original function and paste it into this new overload. Call the original function by passing `AtDate` as a parameter
    ```pascal
    procedure CalculateMonthlySalaries()
    var
        AtDate: Date;
    begin
        AtDate := CalcDate('<CM>', WorkDate());
        CalculateMonthlySalaries(AtDate);
    end;
    ```
3. Create a new internal function named `DeleteMonthlySalaries` that accepts an `AtDate` parameter.
    ```pascal
    internal procedure DeleteMonthlySalaries(AtDate: Date)
    ```
4. Cut the code that deletes the monthly salaries for the specified date from the `CalculateMonthlySalaries` function and paste it into the `DeleteMonthlySalaries` function. Call this new function from the `CalculateMonthlySalaries` function.
    ```pascal
    procedure CalculateMonthlySalaries()
    var
        AtDate: Date;
    begin
        AtDate := CalcDate('<CM>', WorkDate());
        DeleteMonthlySalaries(AtDate);
        CalculateMonthlySalaries(AtDate);
    end;
    ```    