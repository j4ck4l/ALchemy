# 02 OCP: Open Closed Principle

In this exercise, you implement the improvements that follow the Open Closed Principle.

### Scenario

The customer has decided to implement a new salary calculation model. This one has no base salary at all, and calculates bonus based on company performance. It rewards the employees in special roles, who are willing to take personal responsibility in the company's overall success, by allowing them to share on the profits on the company.

You realize that to accommodate for this change, you need to change existing code, potentially breaking both the code and tests. You anticipate that in the future the customer may want to implement even more different salary calculation models, and want to make sure that any future additions follow the Open Closed Principle.

### Design Notes

Even though the customer requirement only requires the new performance salary calculation model, you can already notice that the solution design is very rigid. Bonus and incentive calculations do not depend on salary model, but on a combination of a salary model and seniority, and you can reasonably anticipate that new seniority levels could be introduced.

This means that not only you should cater for extensibility of salary models, but also for extensibility of seniority levels. In other words, you should make it possible to extend both salary models and seniority levels without requiring changes to existing code (open for extension, closed for modification).

In nutshell, there are company-wide policies of how bonus and incentive are calculated, but certain seniority levels provide their own calculation for bonus and incentive, and override the default bonus and incentive calculation.

> Hint: While working on this exercise, you'll see that you are generating a lot of duplication, and duplication is never good. However, you'll fix that in one of the next exercises. In real life, duplicated code very often occurs and when it does, it's usually an indicator of other problems. We'll cover those problems when we talk about Liskov Substitution Principle and Interface Segregation Principle. So, for now, just keep the duplication when you see it.

### Exercise breakdown

This practice contains three separate exercises:

1. Implementing the Open Closed Principle for salary calculation
2. Adding a new salary calculation model without changing existing code
3. Implementing the Open Closed Principle for seniority levels

## Exercise 1: Implementing the Open Closed Principle for salary calculation

In this exercise, you will refactor the existing code to follow the Open Closed Principle. The existing solution is rigid and does not allow for easy extensibility. For example, adding a new salary calculation model would require changes to the existing `SalaryCalculate` codeunit, which could potentially break the existing code and tests.

Your goal is to refactor the solution in such a way that you can extend it with new functionality, such as new salary calculation models or new seniority levels, without having to change any of the existing objects. This kind of extensibility is both simpler to implement, and much more robust, as it does not represent a risk of breaking existing code.

### Challenge Yourself

1. Create a new interface named `ISalaryCalculator` with methods for calculating base salary, bonus, and incentive. Use the same signatures these methods have in the `SalaryCalculate` codeunit.
2. Create four codeunits, one each for fixed, timesheet, commission, and target calculation models. All four must implement `ISalaryCalculator`. Copy the relevant code from `SalaryCalculate` codeunit into these codeunits, so that each of those codeunits performs the full work of what the original functions did in `SalaryCalculate` where you copied them from.
3. Modify the `SalaryType` enum to implement your new interface. Provide a matching implementation for each of the enum values.
4. Modify the code inside the `CalculateSalary` function in the `SalaryCalculate` codeunit to retrieve the correct implementation of `ISalaryCalculator` interface from `SalaryType`, and then invoke the methods from the interface, instead of calling local functions you copied into interface implementations.

### Step-by-Step Instructions

#### Step 1: Create a new interface

1. Inside the `Salary` folder, create a new file named `ISalaryCalculator.Interface.al`.
2. Define the new interface `ISalaryCalculator`.
3. Copy the signatures of the `CalculateBaseSalary`, `CalculateBonus`, and `CalculateIncentive` methods from the `SalaryCalculate` codeunit.
4. Paste the method signatures into the `ISalaryCalculator` interface.
5. The interface should look like this:
    ```al
    namespace ALchemy;

    using Microsoft.HumanResources.Employee;

    interface ISalaryCalculator
    {
        procedure CalculateBaseSalary(Employee: Record Employee; Setup: Record SalarySetup): Decimal;
        procedure CalculateBonus(Employee: Record Employee; Setup: Record SalarySetup; Salary: Decimal; StartingDate: Date; EndingDate: Date): Decimal;
        procedure CalculateIncentive(Employee: Record Employee; Setup: Record SalarySetup; Salary: Decimal; AtDate: Date): Decimal;
    }
    ```

#### Step 2: Create the salary calculator codeunits

1. Inside the `Salary` folder, create four new files named `SalaryCalculatorFixed.Codeunit.al`, `SalaryCalculatorTimesheet.Codeunit.al`, `SalaryCalculatorCommission.Codeunit.al`, and `SalaryCalculatorTarget.Codeunit.al`.
2. Inside each of the four new files, define a new codeunit that implements the `ISalaryCalculator` interface.
3. Copy the `CalculateBaseSalary` method from the `SalaryCalculate` codeunit and paste it into each of the four new codeunits.
4. In the `SalaryCalculatorFixed` codeunit, define the `CalculateIncentive` function and write the following code in it:
    ```pascal
    procedure CalculateIncentive(Employee: Record Employee; Setup: Record SalarySetup; Salary: Decimal; AtDate: Date) Incentive: Decimal;
    var
        YearsOfTenure: Integer;
    begin
        Setup.TestField(YearlyIncentivePct);
        YearsOfTenure := Round((AtDate - Employee."Employment Date") / 365, 1, '<');
        Incentive := Salary * (YearsOfTenure * Setup.YearlyIncentivePct) / 100;
    end;
    ```

    > Hint: You can notice that this code does not match all of the incentive calculation code. As you may have realized already, there is a dependency on seniority levels for incentive calculation. Individual seniority levels may provide different incentive calculation logic, and in this codeunit you simply want to keep the default incentive calculation logic. You will address seniority specific incentive calculation in a later exercise. The same applies to bonus calculation.

5. Copy this function into the remaining for salary calculator codeunits.
6. In the `SalaryCalculatorFixed` codeunit, define the `CalculateBonus` function and leave the body empty:
    ```pascal
    procedure CalculateBonus(Employee: Record Employee; Setup: Record SalarySetup; Salary: Decimal; StartingDate: Date; EndingDate: Date): Decimal;
    begin
    end;
    ```
7. In the `SalaryCalculatorTimesheet` codeunit, define the `CalculateBonus` function and move the relevant timesheet bonus calculation code from the `SalaryCalculate` codeunit:
    ```pascal
    procedure CalculateBonus(Employee: Record Employee; Setup: Record SalarySetup; Salary: Decimal; StartingDate: Date; EndingDate: Date) Bonus: Decimal;
    var
        TimeSheetHeader: Record "Time Sheet Header";
        TimeSheetLine: Record "Time Sheet Line";
        WorkHours: Decimal;
    begin
        Setup.TestField(MinimumHours);
        Setup.TestField(OvertimeThreshold);
        Employee.TestField("Resource No.");

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

        if WorkHours < Setup.MinimumHours then
            Bonus := -Salary * (1 - WorkHours / Setup.MinimumHours)
        else
            if (WorkHours > Setup.OvertimeThreshold) then
                Bonus := Salary * (WorkHours / Setup.OvertimeThreshold - 1);
    end;
    ```
8. In the `SalaryCalculatorCommission` codeunit, define the `CalculateBonus` function and move the relevant commission bonus calculation code from the `SalaryCalculate` codeunit:
    ```pascal
    procedure CalculateBonus(Employee: Record Employee; Setup: Record SalarySetup; Salary: Decimal; StartingDate: Date; EndingDate: Date) Bonus: Decimal;
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
    begin
        Employee.TestField("Salespers./Purch. Code");

        CustLedgEntry.SetRange("Posting Date", StartingDate, EndingDate);
        CustLedgEntry.SetRange("Salesperson Code", Employee."Salespers./Purch. Code");
        CustLedgEntry.SetFilter("Document Type", '%1|%2', "Gen. Journal Document Type"::Invoice, "Gen. Journal Document Type"::"Credit Memo");
        CustLedgEntry.CalcSums("Profit (LCY)");
        Bonus := (Employee.CommissionBonusPct / 100) * CustLedgEntry."Profit (LCY)";
    end;
    ```
9. In the `SalaryCalculatorTarget` codeunit, define the `CalculateBonus` function and move the relevant target bonus calculation code from the `SalaryCalculate` codeunit:
    ```pascal
    procedure CalculateBonus(Employee: Record Employee; Setup: Record SalarySetup; Salary: Decimal; StartingDate: Date; EndingDate: Date) Bonus: Decimal;
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
    begin
        Employee.TestField("Salespers./Purch. Code");

        CustLedgEntry.SetRange("Posting Date", StartingDate, EndingDate);
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

#### Step 3: Modify the `SalaryType` enum to implement interface

1. Open the `SalaryType` enum in the `Salary` folder.
2. Add the `implements ISalaryCalculator` clause to the enum declaration.
3. For each of the enum values, provide a matching implementation of the `ISalaryCalculator` interface.
    ```al
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
    }
    ```

#### Step 4: Modify the `CalculateSalary` function

1. Open the `SalaryCalculate` codeunit in the `Salary` folder.
2. In the `CalculateSalary` function, define a new local variable named `Calculator` of type `Interface ISalaryCalculator`. Also, define two new local variables of type `Date`, named `StartingDate` and `EndingDate`.
3. Assign the `Calculator` variable the implementation of the `ISalaryCalculator` interface from the `SalaryType` enum:
    ```pascal
    Calculator := Employee.SalaryType;
    ```
4. Calculate the `StartingDate` and `EndingDate` variables based on the `AtDate` parameter (move the code from the `CalculateBonus` function):
    ```pascal
    StartingDate := CalcDate('<CM+1D-1M>', AtDate);
    EndingDate := CalcDate('<CM>', AtDate);
    ```
5. Replace the calls to the `CalculateBaseSalary`, `CalculateBonus`, and `CalculateIncentive` functions with calls to the corresponding methods of the `ISalaryCalculator` interface:
    ```pascal
    Salary := Calculator.CalculateBaseSalary(Employee, Setup);
    Bonus := Calculator.CalculateBonus(Employee, Setup, Salary, StartingDate, EndingDate);
    Incentive := Calculator.CalculateIncentive(Employee, Setup, Salary, AtDate);
    ```

## Exercise 2: Adding a new salary calculation model without changing existing code

In this exercise, you will add a new salary calculation model without changing any of the existing code. This exercise will demonstrate how the Open Closed Principle allows you to extend the functionality of the system without modifying existing objects.

> Hint: You can notice how easy it is to add new salary calculation models without changing any existing code when the solution is desiged correctly. This is the power of the Open Closed Principle.

### Challenge Yourself

1. Add new fields for income account no. and expense account no. to the `SalarySetup` table. Both fields should have a relation to the `G/L Account` table, and allow users to select only total accounts. Add both fields to the `SalarySetup` page as well.
2. Add a new field for performance bonus percentage to the `Employee` table. Make sure to allow editing this field only if employee's salary type is set to `Performance`, and only if the employee is not in `Trainee` or `Executive` seniority levels. Add this field to the `Employee Card` page as well.
3. Create a new codeunit named `SalaryCalculatorPerformance` that implements the `ISalaryCalculator` interface and provide the new performance-based salary calculation logic. The performance bonus should be calculated as a percentage of the company's profits for the period for which the salary is calculated.
4. Add a new value to the `SalaryType` enum named `Performance` and provide an implementation of the `ISalaryCalculator` interface for this value that points to  the `SalaryCalculatorPerformance` codeunit.

### Step-by-Step Instructions

#### Step 1: Add new fields to the `SalarySetup` table and page

1. Open the `SalarySetup` table and add two new fields of type `Code[20]` named `IncomeAccountNo` and `ExpenseAccountNo`. For both fields, set this property:
   ```
   TableRelation = "G/L Account" where("Account Type" = const(Total));
   ```
2. Open the `SalarySetup` page and add a new group named `Performance` below the `Incentive` group. Inside the `Performance` group, add two new fields you have added to the `SalarySetup` table in the previous step:
   ```al
    group(Performance)
    {
        Caption = 'Performance Calculation';

        field(IncomeAccountNo; Rec.IncomeAccountNo)
        {
            ToolTip = 'Specifies the income account no.';
        }

        field(ExpenseAccountNo; Rec.ExpenseAccountNo)
        {
            ToolTip = 'Specifies the expense account no.';
        }
    }
   ```

#### Step 2: Add new fields to the `Employee` table and page

1. Open the `Employee` table and add a new field of type `Decimal` named `PerformanceBonusPct`. Define the `OnValidate` trigger for the `PerformanceBonusPct` field to allow modifying this field only if the employee's salary type is set to `Performance`, and the employee is not in `Trainee` or `Executive` seniority levels:
   ```al
    field(60109; PerformanceBonusPct; Decimal)
    {
        Caption = 'Performance Bonus %';
        DataClassification = CustomerContent;
        MinValue = 0;

        trigger OnValidate()
        begin
            Rec.TestField(SalaryType, SalaryType::Performance);
            if Rec.Seniority in [Seniority::Trainee, Seniority::Executive] then
                Rec.FieldError(Seniority);
        end;
    }
   ```
2. Open the `Employee Card` page and add a new group named `Performance` below the `TargetSalary` group. Inside the `Performance` group, add the new field you have added to the `Employee` table in the previous step:
   ```al
    group(PerformanceSalary)
    {
        Caption = 'Performance Salary';
        Editable = Rec.SalaryType = SalaryType::Performance;

        field(PerformanceBonusPct; Rec.PerformanceBonusPct)
        {
            ApplicationArea = All;
            ToolTip = 'Specifies the performance bonus percentage for the employee.';
        }
    }
   ```

#### Step 3: Implement the performance-based salary calculation logic

1. In the `Salary` folder, create a new file named `SalaryCalculatorPerformance.Codeunit.al`.
2. Define the new `SalaryCalculatorPerformance` codeunit that implements the `ISalaryCalculator` interface.
3. For the `CalculateBaseSalary` method and the `CalculateIncentive` method, leave the body empty:
    ```pascal
    procedure CalculateBaseSalary(Employee: Record Employee; Setup: Record SalarySetup) Salary: Decimal;
    begin
    end;

    procedure CalculateIncentive(Employee: Record Employee; Setup: Record SalarySetup; Salary: Decimal; AtDate: Date) Incentive: Decimal;
    begin
    end;
    ```
4. Define the `CalculateBonus` method and write the code that totals the company's profits for the period for which the salary is calculated, and calculates the performance bonus as a percentage of the total profits:
    ```pascal
    procedure CalculateBonus(Employee: Record Employee; Setup: Record SalarySetup; Salary: Decimal; StartingDate: Date; EndingDate: Date) Bonus: Decimal;
    var
        GLAccount: Record "G/L Account";
        GLEntry: Record "G/L Entry";
        Income: Decimal;
        Expense: Decimal;
        Profit: Decimal;
    begin
        GLEntry.SetRange("Posting Date", StartingDate, EndingDate);

        GLAccount.Get(Setup.IncomeAccountNo);
        GLEntry.SetFilter("G/L Account No.", GLAccount.Totaling);
        GLEntry.CalcSums(Amount);
        Income := GLEntry.Amount;

        GLAccount.Get(Setup.ExpenseAccountNo);
        GLEntry.SetFilter("G/L Account No.", GLAccount.Totaling);
        GLEntry.CalcSums(Amount);
        Expense := GLEntry.Amount;

        Profit := Income - Expense;
        if (Profit > 0) then
            Bonus := (Employee.PerformanceBonusPct / 100) * Profit;
    end;
    ```

#### Step 4: Add a new value to the `SalaryType` enum

1. Open the `SalaryType` enum in the `Salary` folder and add a new value named `Performance`:
    ```al
    value(5; Performance)
    {
        Caption = 'Performance Salary';
        Implementation = ISalaryCalculator = SalaryCalculatorPerformance;
    }
    ```

## Exercise 3: Implementing the Open Closed Principle for seniority levels

You notice that while you correctly managed to get rid of any explicit decisions (`case` blocks) that handled `SalaryType`, you still have many decision points that introduce logical branching around the `Seniority` of an employee. For example, bonus is different for managers and directors than for other levels, and incentives are different for managers than for other levels. Adding more seniority levels in the future would require you to modify your code, and extending it by third-party apps would be outright impossible. Both of these things violate the Open Closed Principle, so you decide to fix that, too!

In this exercise, you will refactor the existing code to follow the Open Closed Principle for seniority levels. 

Your goal is to refactor the solution in such a way that the direct dependency on seniority levels is removed from the existing code, and that the solution follows the Open Closed Principle for seniority levels. Even though at this point you don't foresee any new seniority levels being added, this kind of design change will both make existing code more robust, and make it easier to add new seniority levels in the future if such a need arises.

> Hint: In a real-life project, omitting to do this refactoring for seniority levals, and keeping them tightly coupled with salary calculation logic would amount to a ***technical debt***. This is because the code would be harder to maintain, and any future changes would be more risky and more expensive to implement. In short, this debt would come back to haunt you sooner or later and would cost you more to maintain in the long run than it would cost you to design it correctly in the first place.

### Challenge Yourself

1. Create a new interface named `ISeniorityBonus`. Create methods `ProvidesBonusCalculation` and `ProvidesIncentiveCalculation` that return a boolean value indicating whether the seniority level provides its own bonus and incentive calculation logic. Then create two methods `CalculateBonus` and `CalculateIncentive` that calculate bonus and incentive for the seniority level.
2. Create a default implementation that returns `false` from both `Provides...` methods, and has no code inside the other two methods. 
3. Create a manager implementation that returns `true` from both `Provides...` methods. Copy the code from `CalculateManagerBonus` and `CalculateTeamIncentive` functions from the `SalaryCalculate` codeunit into the `CalculateBonus` and `CalculateIncentive` methods of the manager implementation.
4. Create a director implementation that returns `true` from both `Provides...` methods. Copy the code from `CalculateManagerBonus` function into the `CalculateBonus` function, just like you did in the previous step. Do not provide any calculation for `CalculateIncentive` as directors don't have incentives.
   > Hint: You may want to explicitly return `0` from the `CalculateIncentive` method in the director implementation. Even though AL runtime will implicitly return `0` if you don't provide a return statement, it's a good practice to be explicit about your intentions in the code. This way, you make it easier for other developers to understand your code, you eliminate any assumptions or confunsion about what your intentions were, and you make it easier to maintain the code in the future.
5. Create an implementation that returns `true` from both `Provides...` methods. From both `CalculateBonus` and `CalculateIncentive` methods, return `0`. You will use this for executives and trainees, as they don't have any special bonus or incentive calculation logic.
6. Modify the `Seniority` enum to implement the new `ISeniorityBonus` interface. Assign the default implementation codeunit to both default and unknown implementations of `ISeniorityBonus` interface. Assign the manager implementation to the `Manager` value, and the director implementation to the `Director` value.
7. In `SalaryCalculate` retrieve the correct implementation of `ISeniorityBonus` interface from `Seniority` of the employee, and then invoke the `CalculateBonus` and `CalculateIncentive` from `ISeniorityBonus` if it provides own implementation, and otherwise call it from `ISalaryCalculator`. Do the same for incentive calculation.
8. Then clean up the `SalaryCalculate` codeunit by removing the functions and `using` declarations you no longer use.

### Step-by-Step Instructions

#### Step 1: Create a new interface

1. Inside the `Seniority` folder, create a new file named `ISeniorityBonus.Interface.al`.
2. Define the new interface `ISeniorityBonus` with methods for checking if the seniority level provides its own bonus and incentive calculation logic, and for calculating bonus and incentive:
   ```al
    namespace ALchemy;

    using Microsoft.HumanResources.Employee;

    interface ISeniorityBonus
    {
        procedure ProvidesBonusCalculation(): Boolean;
        procedure ProvidesIncentiveCalculation(): Boolean;
        procedure CalculateBonus(Employee: Record Employee; AtDate: Date): Decimal;
        procedure CalculateIncentive(Employee: Record Employee; AtDate: Date): Decimal
    }
    ```

#### Step 2: Create the default implementation

1. Inside the `Seniority` folder, create a new file named `SeniorityBonusDefault.Codeunit.al`.
2. Define the new `SeniorityBonusDefault` codeunit that implements the `ISeniorityBonus` interface.
3. For the `ProvidesBonusCalculation` and `ProvidesIncentiveCalculation` methods, return `false`:
    ```pascal
    procedure ProvidesBonusCalculation(): Boolean;
    begin
        exit(false);
    end;

    procedure ProvidesIncentiveCalculation(): Boolean;
    begin
        exit(false);
    end;
    ```
4. For the `CalculateBonus` and `CalculateIncentive` methods, leave the body empty:
    ```pascal
    procedure CalculateBonus(Employee: Record Employee; AtDate: Date) Bonus: Decimal;
    begin
    end;

    procedure CalculateIncentive(Employee: Record Employee; AtDate: Date) Incentive: Decimal;
    begin
    end;
    ```

#### Step 3: Create the manager implementation

1. Inside the `Seniority` folder, create a new file named `SeniorityBonusManager.Codeunit.al`.
2. Define the new `SeniorityBonusManager` codeunit that implements the `ISeniorityBonus` interface.
3. For the `ProvidesBonusCalculation` and `ProvidesIncentiveCalculation` methods, return `true`:
    ```pascal
    procedure ProvidesBonusCalculation(): Boolean;
    begin
        exit(true);
    end;

    procedure ProvidesIncentiveCalculation(): Boolean;
    begin
        exit(true);
    end;
    ```
4. For the `CalculateBonus` method, copy the code from the `CalculateManagerBonus` function from the `SalaryCalculate` codeunit:
    ```pascal
    procedure CalculateBonus(Employee: Record Employee; AtDate: Date) Bonus: Decimal;
    var
        SubordinateEmployee: Record Employee;
        MonthlySalary: Record MonthlySalary;
    begin
        SubordinateEmployee.SetRange("Manager No.", Employee."No.");
        if SubordinateEmployee.FindSet() then
            repeat
                MonthlySalary.Reset();
                MonthlySalary.SetRange(EmployeeNo, SubordinateEmployee."No.");
                MonthlySalary.SetRange(Date, AtDate);
                if not MonthlySalary.FindFirst() then
                    MonthlySalary := SubordinateEmployee.CalculateSalary(AtDate);
                Bonus += MonthlySalary.Bonus;
            until SubordinateEmployee.Next() = 0;
        Bonus := Bonus * (1 + Employee.TeamBonusPct / 100);
    end;
    ```
5. For the `CalculateIncentive` method, copy the code from the `CalculateTeamIncentive` function from the `SalaryCalculate` codeunit:
    ```pascal
    procedure CalculateIncentive(Employee: Record Employee; AtDate: Date) Incentive: Decimal;
    var
        SubordinateEmployee: Record Employee;
        MonthlySalary: Record MonthlySalary;
    begin
        SubordinateEmployee.SetRange("Manager No.", Employee."No.");
        if SubordinateEmployee.FindSet() then
            repeat
                MonthlySalary.Reset();
                MonthlySalary.SetRange(EmployeeNo, SubordinateEmployee."No.");
                MonthlySalary.SetRange(Date, AtDate);
                if not MonthlySalary.FindFirst() then
                    MonthlySalary := SubordinateEmployee.CalculateSalary(AtDate);
                Incentive += MonthlySalary.Incentive;
            until SubordinateEmployee.Next() = 0;
        Incentive := Incentive * (1 + Employee.TeamIncentivePct / 100);
    end;
    ```

#### Step 4: Create the director implementation

1. Inside the `Seniority` folder, create a new file named `SeniorityBonusDirector.Codeunit.al`.
2. Define the new `SeniorityBonusDirector` codeunit that implements the `ISeniorityBonus` interface.
3. For the `ProvidesBonusCalculation` and `ProvidesIncentiveCalculation` methods, return `true`:
    ```pascal
    procedure ProvidesBonusCalculation(): Boolean;
    begin
        exit(true);
    end;

    procedure ProvidesIncentiveCalculation(): Boolean;
    begin
        exit(false);
    end;
    ```
4. For the `CalculateBonus` method, copy the code from the `CalculateManagerBonus` function from the `SalaryCalculate` codeunit:
    ```pascal
    procedure CalculateBonus(Employee: Record Employee; AtDate: Date) Bonus: Decimal;
    var
        SubordinateEmployee: Record Employee;
        MonthlySalary: Record MonthlySalary;
    begin
        SubordinateEmployee.SetRange("Manager No.", Employee."No.");
        if SubordinateEmployee.FindSet() then
            repeat
                MonthlySalary.Reset();
                MonthlySalary.SetRange(EmployeeNo, SubordinateEmployee."No.");
                MonthlySalary.SetRange(Date, AtDate);
                if not MonthlySalary.FindFirst() then
                    MonthlySalary := SubordinateEmployee.CalculateSalary(AtDate);
                Bonus += MonthlySalary.Bonus;
            until SubordinateEmployee.Next() = 0;
        Bonus := Bonus * (1 + Employee.TeamBonusPct / 100);
    end;
    ```
5. For the `CalculateIncentive` method, return `0`:
    ```pascal
    procedure CalculateIncentive(Employee: Record Employee; AtDate: Date) Incentive: Decimal;
    begin
        // No incentive for directors (making it explicitly obvious)
        Incentive := 0;
    end;
    ```

#### Step 5: Create the executive implementation

1. Inside the `Seniority` folder, create a new file named `SeniorityBonusNone.Codeunit.al`.
2. Define the new `SeniorityBonusNone` codeunit that implements the `ISeniorityBonus` interface.
3. For the `ProvidesBonusCalculation` and `ProvidesIncentiveCalculation` methods, return `true`:
    ```pascal
    procedure ProvidesBonusCalculation(): Boolean;
    begin
        exit(true);
    end;

    procedure ProvidesIncentiveCalculation(): Boolean;
    begin
        exit(true);
    end;
    ```
4. For the `CalculateBonus` and `CalculateIncentive` methods, return `0`:
    ```pascal
    procedure CalculateBonus(Employee: Record Employee; AtDate: Date): Decimal;
    begin
        // Making it explicit
        exit(0);
    end;

    procedure CalculateIncentive(Employee: Record Employee; AtDate: Date): Decimal;
    begin
        // Making it explicit
        exit(0);
    end;
    ```

#### Step 6: Modify the `Seniority` enum to implement the new `ISeniorityBonus` interface

1. Open the `Seniority` enum in the `Seniority` folder.
2. Add the `implements ISeniorityBonus` clause to the enum declaration.
3. Define the `DefaultImplementation` and `UnknownImplementation` values to point to the `SeniorityBonusDefault` codeunit:
    ```al
    DefaultImplementation = ISeniorityBonus = SeniorityBonusDefault;
    UnknownValueImplementation = ISeniorityBonus = SeniorityBonusDefault;
    ```
4. For the `Trainee` value, assign the `SeniorityBonusNone` codeunit:
    ```al
    value(0; Trainee)
    {
        Caption = 'Trainee';
        Implementation = ISeniorityBonus = SeniorityBonusNone;
    }
    ```
4. For the `Manager` value, assign the `SeniorityBonusManager` codeunit:
    ```al
    value(3; Manager)
    {
        Caption = 'Manager';
        Implementation = ISeniorityBonus = SeniorityBonusManager;
    }
    ```
5. For the `Director` value, assign the `SeniorityBonusDirector` codeunit:
    ```al
    value(4; Director)
    {
        Caption = 'Director';
        Implementation = ISeniorityBonus = SeniorityBonusDirector;
    }
    ```
6. For the `Executive` value, assign the `SeniorityBonusNone` codeunit:
    ```al
    value(5; Executive)
    {
        Caption = 'Executive';
        Implementation = ISeniorityBonus = SeniorityBonusNone;
    }
    ```

#### Step 7: Modify the `SalaryCalculate` codeunit

1. Open the `SalaryCalculate` codeunit in the `Salary` folder.
2. Define a new local variable named `SeniorityBonus` of type `Interface ISeniorityBonus`:
    ```al
    SeniorityBonus: Interface ISeniorityBonus;
    ```
3. Assign the `SeniorityBonus` variable the implementation of the `ISeniorityBonus` interface from the `Seniority` enum:
    ```al
    SeniorityBonus := Employee.Seniority;
    ```
4. Replace the calls to the `CalculateBonus` and `CalculateIncentive` functions with calls to the corresponding methods of the `ISeniorityBonus` interface if the seniority level provides its own implementation, and otherwise call it from the `ISalaryCalculator` interface:
    ```al
    if SeniorityBonus.ProvidesBonusCalculation() then
        Bonus := SeniorityBonus.CalculateBonus(Employee, AtDate)
    else
        Bonus := Calculator.CalculateBonus(Employee, Setup, Salary, StartingDate, EndingDate);

    if SeniorityBonus.ProvidesIncentiveCalculation() then
        Incentive := SeniorityBonus.CalculateIncentive(Employee, AtDate)
    else
        Incentive := Calculator.CalculateIncentive(Employee, Setup, Salary, AtDate);
    ```

#### Step 8: Clean up the `SalaryCalculate` codeunit

1. Remove the `CalculateBaseSalary`, `CalculateBonus`, `CalculateBonusTimesheet`, `CalculateBonusCommission`, `CalculateBonusTarget`, `CalculateIncentive`, and `CalculateTeamIncentive` functions from the `SalaryCalculate` codeunit.
2. Remove all `using` declarations except for `Microsoft.HumanResources.Employee`.
