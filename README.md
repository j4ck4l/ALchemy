# 04 ISP: Interface Segregation Principle

In this exercise, you implement the improvements that follow the Interface Segregation Principle.

### Problem Statement

At this point your code follows a lot of best practices and good principles, but there are still issues. You have massive amounts of duplication across your implementation codeunits. Also, many of your implementation codeunits contain methods that do nothing. All of this indicates that your code probably violates the Interface Segregation Principle.

### Exercise Breakdown

This practice contains four separate exercises:

1. Fixing the `ISalaryCalculator` interface
2. Fixing the `ISeniorityBonus` interface
3. Removing duplication from team bonus and incentive calculation
4. Final refactoring

## Exercise 1: Fixing the `ISalaryCalculator` interface

In this exercise, you will apply the Interface Segregation Principle to the `ISalaryCalculator` interface.

### Scenario

The `ISalaryCalculator` interface contains three methods. The first one, `CalculateBaseSalary` contains the exact same code in four different implementation codeunits, and only one implementation provides a different calculation. The same is true about the `CalculateIncentive` method. The only method that provides five distinct implementations is `CalculateBonus`.

Obviously, the `ISalaryCalculator` interface violates the Interface Segregation Principle. You need to refactor it to follow the principle.

By splitting this interface into three distinct interfaces, you can eliminate all duplication from the `ISalaryCalculator` implementations.

### Challenge Yourself

1. Create three interfaces called `IBaseSalaryCalculator`, `IBonusCalculator` and `IIncentiveCalculator`, and move the three methods from the `ISalaryCalculator` interface into the matching new interface. Delete the `ISalaryCalculator` interface.
2. Create a new codeunit named `DefaultBaseSalaryCalculator` that implements the `IBaseSalaryCalculator` interface and copy the code from `CalculateBaseSalary` function in `SalaryCalculatorFixed` into it.
3. Create a new codeunit named `DefaultIncentiveCalculator` that implements the `IIncentiveCalculator` interface and copy the code from `CalculateIncentive` function in `SalaryCalculatorFixed` into it.
4. Delete the `SalaryCalculatorFixed` codeunit.
5. Rename each of remaining `SalaryCalculator...` codeunits into `BonusCalculator...`. In each of them, change the `implements` clause to `IBonusCalculator`, and then remove the `CalculateBaseSalary` and `CalculateIncentive` functions.
6. Create three new codeunits named `NoBaseSalary`, `NoBonus`, and `NoIncentive` that implement the respective interfaces. Inside each of the implementations, exit with 0 explicitly.
    > Hint: It's always better to indicate your intention explicitly when implementing interfaces. In this case, you could have just left the implementation bodies empty, but that doesn't explain your intention as well as `exit(0)` does.
7. For `SalesType` enum, change the `implements` clause to specify the three new calculator interfaces instead of the original one. Add the `DefaultImplementation` property and specify both default implementations (for base salary and incentives) as defaults. Then modify each of the salary types by changing implementations according to the changes you did before. Finally, for the `Performance` value, specify `NoBaseSalary` and `NoIncentive` as implementations for respective interfaces.

### Step-by-step instructions

#### Step 1: Split the `ISalaryCalculator` interface into three separate interfaces

1. Inside the `Salary` folder, create three subfolders, named `BaseSalary`, `Bonus` and `Incentive`.
2. In the `BaseSalary` folder, create a new file named `IBaseSalaryCalculator.Interface.al`.
3. Define the `IBaseSalaryCalculator` interface. Copy the `CalculateBaseSalary` method from the `ISalaryCalculator` interface into it.
    ```al
    namespace ALchemy;

    using Microsoft.HumanResources.Employee;

    interface IBaseSalaryCalculator
    {
        procedure CalculateBaseSalary(Employee: Record Employee; Setup: Record SalarySetup): Decimal;
    }
    ```
4. In the `Bonus` folder, create a new file named `IBonusCalculator.Interface.al`.
5. Define the `IBonusCalculator` interface.
6. Define the `CalculateBonus` method that takes an `Employee` record, `Setup` record, `Salary` decimal value, and `AtDate` date value as parameters and returns a decimal value.
    ```al
    namespace ALchemy;

    using Microsoft.HumanResources.Employee;

    interface IBonusCalculator
    {
        procedure CalculateBonus(Employee: Record Employee; Setup: Record SalarySetup; Salary: Decimal; StartingDate: Date; EndingDate: Date; AtDate: Date): Decimal;
    }
    ```
    > Hint: This is not the exact same method as in the `ISalaryCalculator` interface. The `AtDate` parameter was added to the method signature. This is done because previously bonus calculation was responsibility of two different interfaces (`ISalaryCalculator` and `ISeniorityBonus`) and these two interfaces operated on different date parameters. Now, we are merging these two interfaces into one to eliminate code duplication, and we want to pass all context available to the different implementations, so each implementation can operate on those parameters that are relevant to it.
7. In the `Incentive` folder, create a new file named `IIncentiveCalculator.Interface.al`.
8. Define the `IIncentiveCalculator` interface. Copy the `CalculateIncentive` method from the `ISalaryCalculator` interface into it.
    ```al
    namespace ALchemy;

    using Microsoft.HumanResources.Employee;

    interface IIncentiveCalculator
    {
        procedure CalculateIncentive(Employee: Record Employee; Setup: Record SalarySetup; Salary: Decimal; AtDate: Date): Decimal;
    }
    ```
9. In the `Salary` folder, delete the `ISalaryCalculator.Interface.al` file.

#### Step 2: Create the `DefaultBaseSalaryCalculator` codeunit

1. In the `BaseSalary` folder, create a new file named `DefaultBaseSalaryCalculator.Codeunit.al`.
2. Define the `DefaultBaseSalaryCalculator` codeunit that implements the `IBaseSalaryCalculator` interface.
3. Move the code from the `CalculateBaseSalary` function in the `SalaryCalculatorFixed` codeunit into the implementation inside `DefaultBaseSalaryCalculator`.
    ```al
    namespace ALchemy;

    using Microsoft.HumanResources.Employee;

    codeunit 60118 DefaultBaseSalaryCalculator implements IBaseSalaryCalculator
    {
        procedure CalculateBaseSalary(Employee: Record Employee; Setup: Record SalarySetup) Salary: Decimal;
        var
            Department: Record Department;
            DepartmentSenioritySetup: Record DepartmentSenioritySetup;
        begin
            Setup.TestField(BaseSalary);

            Salary := Employee.BaseSalary;

            if Employee.BaseSalary = 0 then begin
                Salary := Setup.BaseSalary;
                if Employee.DepartmentCode <> '' then begin
                    Department.Get(Employee.DepartmentCode);
                    Salary := Department.BaseSalary;
                    if DepartmentSenioritySetup.Get(Employee.DepartmentCode, Employee.Seniority) then
                        Salary := DepartmentSenioritySetup.BaseSalary;
                end;
            end;
        end;
    }
    ```

#### Step 3: Create the `DefaultIncentiveCalculator` codeunit

1. In the `Incentive` folder, create a new file named `DefaultIncentiveCalculator.Codeunit.al`.
2. Define the `DefaultIncentiveCalculator` codeunit that implements the `IIncentiveCalculator` interface.
3. Move the code from the `CalculateIncentive` function in the `SalaryCalculatorFixed` codeunit into the implementation inside `DefaultIncentiveCalculator`.
    ```al
    namespace ALchemy;

    using Microsoft.HumanResources.Employee;

    codeunit 60119 DefaultIncentiveCalculator implements IIncentiveCalculator
    {
        procedure CalculateIncentive(Employee: Record Employee; Setup: Record SalarySetup; Salary: Decimal; AtDate: Date) Incentive: Decimal;
        var
            YearsOfTenure: Integer;
        begin
            Setup.TestField(YearlyIncentivePct);
            YearsOfTenure := Round((AtDate - Employee."Employment Date") / 365, 1, '<');
            Incentive := Salary * (YearsOfTenure * Setup.YearlyIncentivePct) / 100;
        end;
    }
    ```

#### Step 4: Delete the `SalaryCalculatorFixed` codeunit

1. In the `Salary` folder, delete the `SalaryCalculatorFixed.Codeunit.al` file.

    > Hint: This codeunit is no longer needed, all code from it has been moved to the new codeunits.

#### Step 5: Define bonus calculator codeunits

1. Move the `SalaryCalculatorCommission` codeunit from the `Salary` folder to the `Bonus` folder.
2. Rename the `SalaryCalculatorCommission` codeunit to `BonusCalculatorCommission`.
3. Delete the `CalculateBaseSalary` and `CalculateIncentive` functions from the `BonusCalculatorCommission` codeunit.
4. Change the `implements` clause to `IBonusCalculator`.
5. Fix the `CalculateBonus` function signature to match the new method signature of the `IBonusCalculator` interface.
    ```pascal
    procedure CalculateBonus(Employee: Record Employee; Setup: Record SalarySetup; Salary: Decimal; StartingDate: Date; EndingDate: Date; AtDate: Date) Bonus: Decimal;
    ```
6. Repeat the same steps for the `SalaryCalculatorPerformance` codeunit, but rename it to `BonusCalculatorPerformance`.
7. Repeat the same steps for the `SalaryCalculatorTarget` codeunit, but rename it to `BonusCalculatorTarget`.
8. Repeat the same steps for the `SalaryCalculatorTimeSheet` codeunit, but rename it to `BonusCalculatorTimeSheet`.

#### Step 6: Create the `NoBaseSalary`, `NoBonus`, and `NoIncentive` codeunits

1. In the `BaseSalary` folder, create a new file named `NoBaseSalary.Codeunit.al`.
2. Define the `NoBaseSalary` codeunit that implements the `IBaseSalaryCalculator` interface.
3. Implement the `CalculateBaseSalary` method by exiting with 0.
    ```al
    namespace ALchemy;

    using Microsoft.HumanResources.Employee;

    codeunit 60120 NoBaseSalary implements IBaseSalaryCalculator
    {
        procedure CalculateBaseSalary(Employee: Record Employee; Setup: Record SalarySetup): Decimal;
        begin
            // Making it explicit
            exit(0);
        end;
    }
    ```
4. In the `Bonus` folder, create a new file named `NoBonus.Codeunit.al`.
5. Define the `NoBonus` codeunit that implements the `IBonusCalculator` interface.
6. Implement the `CalculateBonus` method by exiting with 0.
    ```al
    namespace ALchemy;

    using Microsoft.HumanResources.Employee;

    codeunit 60111 NoBonus implements IBonusCalculator
    {
        procedure CalculateBonus(Employee: Record Employee; Setup: Record SalarySetup; Salary: Decimal; StartingDate: Date; EndingDate: Date; AtDate: Date): Decimal;
        begin
            exit(0);
        end;
    }
    ```
7. In the `Incentive` folder, create a new file named `NoIncentive.Codeunit.al`.
8. Define the `NoIncentive` codeunit that implements the `IIncentiveCalculator` interface.
9. Implement the `CalculateIncentive` method by exiting with 0.
    ```al
    namespace ALchemy;

    using Microsoft.HumanResources.Employee;

    codeunit 60112 NoIncentive implements IIncentiveCalculator
    {
        procedure CalculateIncentive(Employee: Record Employee; Setup: Record SalarySetup; Salary: Decimal; AtDate: Date): Decimal;
        begin
            // Making it explicit
            exit(0);
        end;
    }
    ```

#### Step 7: Update the `SalesType` enum

1. In the `SalesType` enum, change the `implements` clause to specify the three new calculator interfaces instead of the original one.
   ```pascal
    enum 60101 SalaryType implements IBaseSalaryCalculator, IBonusCalculator, IIncentiveCalculator   
    ```
2. Add the `DefaultImplementation` property and specify both default implementations.
    ```pascal
    DefaultImplementation =
        IBaseSalaryCalculator = DefaultBaseSalaryCalculator,
        IIncentiveCalculator = DefaultIncentiveCalculator;
    ```
3. Modify the `Fixed` value to specify the `NoBonus` implementation for the `IBonusCalculator` interface.
    ```al
    value(1; Fixed)
    {
        Caption = 'Fixed Salary';
        Implementation = IBonusCalculator = NoBonus;
    }
    ```
4. Modify the `Timesheet` value to specify the `NoBonus` implementation for the `IBonusCalculator` interface.
    ```al
    value(2; Timesheet)
    {
        Caption = 'Timesheet Salary';
        Implementation = IBonusCalculator = BonusCalculatorTimesheet;
    }
    ```
5. Modify the `Commission` value to specify the `NoBonus` implementation for the `IBonusCalculator` interface.
    ```al
    value(3; Commission)
    {
        Caption = 'Commission Salary';
        Implementation = IBonusCalculator = BonusCalculatorCommission;
    }
    ```
6. Modify the `Target` value to specify the `NoBonus` implementation for the `IBonusCalculator` interface.
    ```al
    value(4; Target)
    {
        Caption = 'Target Salary';
        Implementation = IBonusCalculator = BonusCalculatorTarget;
    }
    ```
7. Modify the `Performance` value to specify the `NoBaseSalary` and `NoIncentive` implementations for the respective interfaces, as well as the `BonusCalculatorPerformance` implementation for the `IBonusCalculator` interface
    ```al
    value(5; Performance)
    {
        Caption = 'Performance Salary';
        Implementation =
            IBaseSalaryCalculator = NoBaseSalary,
            IBonusCalculator = BonusCalculatorPerformance,
            IIncentiveCalculator = NoIncentive;
    }
    ```

## Exercise 2: Fixing the `ISeniorityBonus` interface

In this exercise, you will apply the Interface Segregation Principle to the `ISeniorityBonus` interface.

### Scenario

The `ISeniorityBonus` interface has some problems, too. Two of the implementations share the exact same code for the `CalculateBonus` method. Also, two of the implementations provide no implementation for `CalculateIncentive` method. Again, this indicates problems with interface segregation.

A further problem that we can also identify is that there is no need to have multiple interfaces defining essentially the same methods. Since `CalculateBonus` and `CalculateIncentive` methods are already defined in their respective interfaces, then we could take advantage of those interfaces and in some way have the `Seniority` enum use them, too. Technically, if - instead of implementing the `ISeniorityBonus` interface, we make the `Seniority` enum implement `IBonusCalculator` and `IIncentiveCalculator`, and then provide matching implementations, we would resolve all duplication issues we have here.

However, this would not solve the problem we had earlier that we solved by adding the `ISeniorityBonus` interface. We cannot just assign different bonus and incentive calculators to different seniority levels, because the actual calculation depends both on seniority and salary calculation model.

The business logic says that bonus and incentive calculation depend first on seniority level, and only if seniority level does not provide its own implementation, should we select the calculation from the salary model. This is not something we can achieve simply by statically declaring interface implementations in `SalaryType` and `Seniority` enums - we need to write some code that makes this decision.

What we can do, though, is rethink our `ISeniorityBonus` interface to still take advantage of our new specific interfaces for bonus and incentive calculation. Instead of simply answering `true` or `false` to question *"do you provide your own implementation?"*, we could turn the `ISeniorityBonus` interface into a type of factory that we can use to create a relevant instance of `IBonusCalculator` and `IIncentiveCalculator` instance.

Since seniority level has precendence over salary model when deciding how to calculate bonus or incentives, the idea here is to ask the seniority to provide an instance of bonus and incentive calculators. If a seniority level provides its own implementation of these interfaces, it can return those instances, otherwise it can use the `Employee` record to retrieve those instances from their `SalaryType` field. This way we can elegantly solve the problem of interdependency between seniority and salary type and remove all code duplication at the same time.

### Challenge Yourself

1. Create two new codeunits called `TeamBonus` and `TeamIncentive` and have them implement the `IBonusCalculator` and `IIncentiveCalculator` interfaces respectively. Then move the relevant team bonus and incentive calculations from `SeniorityBonusManager` codeunit into them.
2. Delete the `ISeniorityBonus` interface and all codeunits that implement it.
3. Create a new `ISeniorityScheme` interface and have it declare two methods named `GetBonusCalculator` and `GetIncentiveCalculator` that return instances of `IBonusCalculator` and `IIncentiveCalculator` interfaces respectively.
4. Create a new codeunit called `DefaultSeniorityScheme` that implements the `ISeniorityScheme` interface. Exit both functions with `Employee.SalaryType` value.
    > Hint: This performs the implicit factory work by converting the `SalaryType` enum value to an instance of an interface you are returning from the method. You can use this seniority scheme for those seniority levels that do not provide their own implementation but fall back to salary model rules.
5. Create new codeunit called `SenioritySchemeNone` that implements the `ISeniorityScheme` interface. Exit both functions with an instance of `NoBonus` and `NoIncentive` codeunits respectively.
6. Create new codeunits called `SenioritySchemeManager` and `SenioritySchemeDirector` that implement the `ISeniorityScheme` interface, and have them return instances of `TeamBonus`, `TeamIncentive`, and `NoIncentive` as appropriate according to their business rules.
7. Update the `Seniority` enum to implement the `ISeniorityScheme` interface instead of `ISeniorityBonus` interface.

### Step-by-step instructions

#### Step 1: Create the `TeamBonus` and `TeamIncentive` codeunits

1. In the `Bonus` folder, create a new file named `TeamBonus.Codeunit.al`.
2. Define the `TeamBonus` codeunit that implements the `IBonusCalculator` interface.
3. Move the code from the `CalculateBonus` function in the `SeniorityBonusManager` codeunit into the implementation inside `TeamBonus`.
    ```al
    namespace ALchemy;

    using Microsoft.HumanResources.Employee;

    codeunit 60113 TeamBonus implements IBonusCalculator
    {
        procedure CalculateBonus(Employee: Record Employee; Setup: Record SalarySetup; Salary: Decimal; StartingDate: Date; EndingDate: Date; AtDate: Date) Bonus: Decimal;
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
    }
    ```
4. In the `Incentive` folder, create a new file named `TeamIncentive.Codeunit.al`.
5. Define the `TeamIncentive` codeunit that implements the `IIncentiveCalculator` interface.
6. Move the code from the `CalculateIncentive` function in the `SeniorityBonusManager` codeunit into the implementation inside `TeamIncentive`.
    ```al
    namespace ALchemy;

    using Microsoft.HumanResources.Employee;

    codeunit 60114 TeamIncentive implements IIncentiveCalculator
    {
        procedure CalculateIncentive(Employee: Record Employee; Setup: Record SalarySetup; Salary: Decimal; AtDate: Date) Incentive: Decimal;
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
    }
    ```

#### Step 2: Delete the `ISeniorityBonus` interface and its implementations

1. In the `Seniority` folder, delete the `SeniorityBonusManager.Codeunit.al`, `SeniorityBonusDirector.Codeunit.al`, `SeniorityBonusDefault.Codeunit.al`, and `ISeniorityBonus.Interface.al` files.

#### Step 3: Create the `ISeniorityScheme` interface

1. In the `Seniority` folder, create a subfolder named `Scheme`.
2. In the `Scheme` folder, create a new file named `ISeniorityScheme.Interface.al`.
3. Define the `ISeniorityScheme` interface.
4. Declare two methods named `GetBonusCalculator` and `GetIncentiveCalculator` that return instances of `IBonusCalculator` and `IIncentiveCalculator` interfaces respectively.
    ```al
    namespace ALchemy;

    using Microsoft.HumanResources.Employee;

    interface ISeniorityScheme
    {
        procedure GetBonusCalculator(Employee: Record Employee): Interface IBonusCalculator;
        procedure GetIncentiveCalculator(Employee: Record Employee): Interface IIncentiveCalculator;
    }
    ```

#### Step 4: Create the `DefaultSeniorityScheme` codeunit

1. In the `Scheme` folder, create a new file named `DefaultSeniorityScheme.Codeunit.al`.
2. Define the `DefaultSeniorityScheme` codeunit that implements the `ISeniorityScheme` interface.
3. Define the `GetBonusCalculator` method that returns an instance of `IBonusCalculator` interface, and exit with `Employee.SalaryType` value.
    ```pascal
    procedure GetBonusCalculator(Employee: Record Employee): Interface IBonusCalculator;
    begin
        exit(Employee.SalaryType);
    end;
    ```
4. Define the `GetIncentiveCalculator` method that returns an instance of `IIncentiveCalculator` interface, and exit with `Employee.SalaryType` value.
    ```pascal
    procedure GetIncentiveCalculator(Employee: Record Employee): Interface IIncentiveCalculator;
    begin
        exit(Employee.SalaryType);
    end;
    ```

#### Step 5: Create the `SenioritySchemeNone` codeunit

1. In the `Scheme` folder, create a new file named `SenioritySchemeNone.Codeunit.al`.
2. Define the `SenioritySchemeNone` codeunit that implements the `ISeniorityScheme` interface.
3. Define the `GetBonusCalculator` method that returns an instance of `IBonusCalculator` interface, and exit with `NoBonus` value.
    ```pascal
    procedure GetBonusCalculator(Employee: Record Employee): Interface IBonusCalculator;
    var
        NoBonus: Codeunit NoBonus;
    begin
        exit(NoBonus);
    end;
    ```
4. Define the `GetIncentiveCalculator` method that returns an instance of `IIncentiveCalculator` interface, and exit with `NoIncentive` value.
    ```pascal
    procedure GetIncentiveCalculator(Employee: Record Employee): Interface IIncentiveCalculator;
    var
        NoIncentive: Codeunit NoIncentive;
    begin
        exit(NoIncentive);
    end;
    ```

#### Step 6: Create the `SenioritySchemeManager` and `SenioritySchemeDirector` codeunits

1. In the `Scheme` folder, create a new file named `SenioritySchemeManager.Codeunit.al`.
2. Define the `SenioritySchemeManager` codeunit that implements the `ISeniorityScheme` interface.
3. Define the `GetBonusCalculator` method that returns an instance of `IBonusCalculator` interface, and exit with `TeamBonus` value.
    ```pascal
    procedure GetBonusCalculator(Employee: Record Employee): Interface IBonusCalculator;
    var
        TeamBonus: Codeunit TeamBonus;
    begin
        exit(TeamBonus);
    end;
    ```
4. Define the `GetIncentiveCalculator` method that returns an instance of `IIncentiveCalculator` interface, and exit with `TeamIncentive` value.
    ```pascal
    procedure GetIncentiveCalculator(Employee: Record Employee): Interface IIncentiveCalculator;
    var
        TeamIncentive: Codeunit TeamIncentive;
    begin
        exit(TeamIncentive);
    end;
    ```
5. In the `Scheme` folder, create a new file named `SenioritySchemeDirector.Codeunit.al`.
6. Define the `SenioritySchemeDirector` codeunit that implements the `ISeniorityScheme` interface.
7. Define the `GetBonusCalculator` method that returns an instance of `IBonusCalculator` interface, and exit with `TeamBonus` value.
    ```pascal
    procedure GetBonusCalculator(Employee: Record Employee): Interface IBonusCalculator;
    var
        TeamBonus: Codeunit TeamBonus;
    begin
        exit(TeamBonus);
    end;
    ```
8. Define the `GetIncentiveCalculator` method that returns an instance of `IIncentiveCalculator` interface, and exit with `NoIncentive` value.
    ```pascal
    procedure GetIncentiveCalculator(Employee: Record Employee): Interface IIncentiveCalculator;
    var
        NoIncentive: Codeunit NoIncentive;
    begin
        exit(NoIncentive);
    end;
    ```

#### Step 7: Update the `Seniority` enum

1. In the `Seniority` enum, change the `implements` clause to specify the `ISeniorityScheme` interface instead of the `ISeniorityBonus` interface.
    ```pascal
    enum 60100 Seniority implements ISeniorityScheme
    ```
2. Modify the `DefaultImplementation` and `UnknownValueImplementation` properties to specify the `DefaultSeniorityScheme` for the `ISeniorityScheme` interface.
    ```pascal
    DefaultImplementation = ISeniorityScheme = DefaultSeniorityScheme;
    UnknownValueImplementation = ISeniorityScheme = DefaultSeniorityScheme;
    ```
3. Modify the `Manager` value to specify the `SenioritySchemeManager` implementation for the `ISeniorityScheme` interface.
    ```al
    value(3; Manager)
    {
        Caption = 'Manager';
        Implementation = ISeniorityScheme = SenioritySchemeManager;
    }
    ```
4. Modify the `Director` value to specify the `SenioritySchemeDirector` implementation for the `ISeniorityScheme` interface.
    ```al
    value(4; Director)
    {
        Caption = 'Director';
        Implementation = ISeniorityScheme = SenioritySchemeDirector;
    }
    ```
5. Modify the `Executive` value to specify the `SenioritySchemeNone` implementation for the `ISeniorityScheme` interface.
    ```al
    value(5; Executive)
    {
        Caption = 'Executive';
        Implementation = ISeniorityScheme = SenioritySchemeNone;
    }
    ```

## Exercise 3: Removing duplication from team bonus and incentive calculation

In this exercise, you will remove duplication from the team bonus and incentive calculation.

### Scenario

The `TeamBonus` and `TeamIncentive` codeunits contain almost exactly the same code for calculating bonuses and incentives for subordinated team members. The only two differences are:
* Bonus calculation reads the `Bonus` field from the `MonthlySalary` table, while incentive calculation reads the `Incentive` field .
* Bonus calculation uses the `TeamBonusPct` field from the `Employee` record, while incentive calculation uses the `TeamIncentivePct` field.

The code can be much simplified by extracting the common logic into a separate codeunit.

### Challenge Yourself

1. Create a new interface named `IRewardsExtractor` with a single method named `ExtractRewardComponent`.
2. Create a new codeunit called `TeamController` with a single method named `CalculateSubordinates`. Copy the code from either `TeamBonus` or `TeamIncentive` codeunit into it. This method receives an instance of `IRewardsExtractor` interface as a parameter.
3. Modify the `TeamBonus` and `TeamIncentive` codeunits to implement the `IRewardsExtractor` interface. From the `ExtractRewardComponent` method, they return the `Bonus` and `Incentive` fields respectively.
4. Modify the `TeamBonus` and `TeamIncentive` codeunits to call the `CalculateSubordinates` method from the `TeamController` codeunit, passing themselves as the `IRewardsExtractor` instance.

### Step-by-step instructions

#### Step 1: Create the `IRewardsExtractor` interface

1. In the `Salary` folder, create a subfolder named `Team`.
2. Inside the `Team` folder, create a new file named `IRewardsExtractor.Interface.al`.
3. Define the `IRewardsExtractor` interface. It has a single method named `ExtractRewardComponent` that receives the `MonthlySalary` record as a parameter and returns a decimal value.
    ```al
    namespace ALchemy;

    using Microsoft.HumanResources.Employee;

    interface IRewardsExtractor
    {
        procedure ExtractRewardComponent(MonthlySalary: Record MonthlySalary): Decimal;
    }
    ```

#### Step 2: Create the `TeamController` codeunit

1. In the `Team` folder, create a new file named `TeamController.Codeunit.al`.
2. Define the `TeamController` codeunit.
3. Define the `CalculateSubordinates` method. It contains the code from either `TeamBonus` or `TeamIncentive` codeunit, and receives an instance of `IRewardsExtractor` interface as a parameter. It also receives a percentage value that is used to calculate the final reward.
    ```pascal
    procedure CalculateSubordinates(EmployeeNo: Code[20]; Percentage: Decimal; AtDate: Date; RewardsExtractor: Interface IRewardsExtractor) Result: Decimal;
    var
        SubordinateEmployee: Record Employee;
        MonthlySalary: Record MonthlySalary;
    begin
        SubordinateEmployee.SetRange("Manager No.", EmployeeNo);
        if SubordinateEmployee.FindSet() then
            repeat
                MonthlySalary.Reset();
                MonthlySalary.SetRange(EmployeeNo, SubordinateEmployee."No.");
                MonthlySalary.SetRange(Date, AtDate);
                if not MonthlySalary.FindFirst() then
                    MonthlySalary := SubordinateEmployee.CalculateSalary(AtDate);
                Result += RewardsExtractor.ExtractRewardComponent(MonthlySalary);
            until SubordinateEmployee.Next() = 0;
        Result := Result * (Percentage / 100);
    end;
    ```

#### Step 3: Modify the `TeamBonus` and `TeamIncentive` codeunits

1. Open the `TeamBonus` codeunit.
2. Modify the codeunit declaration by adding the `implements` clause to specify the `IRewardsExtractor` interface.
    ```pascal
    codeunit 60113 TeamBonus implements IBonusCalculator, IRewardsExtractor
    ```
3. Implement the `ExtractRewardComponent` method. It reads the `Bonus` field from the `MonthlySalary` record and returns it.
    ```pascal
    internal procedure ExtractRewardComponent(MonthlySalary: Record MonthlySalary): Decimal
    begin
        exit(MonthlySalary.Bonus);
    end;
    ```
4. Modify the `CalculateBonus` function to call the `CalculateSubordinates` method from the `TeamController` codeunit, passing itself as the `IRewardsExtractor` instance.
    ```pascal
    procedure CalculateBonus(Employee: Record Employee; Setup: Record SalarySetup; Salary: Decimal; StartingDate: Date; EndingDate: Date; AtDate: Date) Bonus: Decimal;
    var
        TeamController: Codeunit TeamController;
        this: Codeunit TeamBonus; // TODO BC25: This will become a built-in keyword; replace with it
    begin
        Bonus := TeamController.CalculateSubordinates(Employee."No.", Employee.TeamBonusPct, AtDate, this);
    end;
    ```
    > Hint: The upcoming version of BC (BC25) comes with `this` keyword that you can use to specify the current instance of the codeunit (much like you can refer to current record using `Rec` or current page using `CurrPage`). For now, we have to explicitly declare a variable instead. Since the codeunit is stateless, this presents no problem.
5. Open the `TeamIncentive` codeunit.
6. Modify the codeunit declaration by adding the `implements` clause to specify the `IRewardsExtractor` interface.
    ```pascal
    codeunit 60114 TeamIncentive implements IIncentiveCalculator, IRewardsExtractor
    ```
7. Implement the `ExtractRewardComponent` method. It reads the `Incentive` field from the `MonthlySalary` record and returns it.
    ```pascal
    internal procedure ExtractRewardComponent(MonthlySalary: Record MonthlySalary): Decimal
    begin
        exit(MonthlySalary.Incentive);
    end;
    ```
8. Modify the `CalculateIncentive` function to call the `CalculateSubordinates` method from the `TeamController` codeunit, passing itself as the `IRewardsExtractor` instance.
    ```pascal
    procedure CalculateIncentive(Employee: Record Employee; Setup: Record SalarySetup; Salary: Decimal; AtDate: Date) Incentive: Decimal;
    var
        TeamController: Codeunit TeamController;
        this: Codeunit TeamIncentive; // TODO BC25: This will become a built-in keyword; replace with it
    begin
        Incentive := TeamController.CalculateSubordinates(Employee."No.", Employee.TeamIncentivePct, AtDate, this);
    end;
    ```

## Exercise 4: Final refactoring

In this exercise, you will finalize the refactoring process by fixing the remaining compilation errors, and cleaning up the code.

### Scenario

Now that you have nicely sorted out all of your interface segregation issues, the code in `SalaryCalculate` codeunit doesn't compile anymore. Let's fix that.

### Challenge Yourself

1. At the beginning of the `CalculateSalary` function, obtain instances of `IBaseSalaryCalculator` and `ISeniorityScheme`from the `SalaryType` and `Seniority` fields, respectively.
2. Obtain instances of `IBonusCalculator` and `IIncentiveCalculator` from the `ISeniorityScheme` instance.
3. Simplify the `if...then` logic for bonus and incentive calculation by simply invoking the calculations on the instances you have obtained in the previous step. At this point, during execution, those variables will contain the correct implementation of `IBonusCalculator` and `IIncentiveCalculator` interfaces, because the factory methods in `ISeniorityScheme` took responsibility of providing them.
4. Delete the `SeniorityBonusNone` codeunit.

### Step-by-step instructions

#### Step 1: Obtain instances of `IBaseSalaryCalculator` and `ISeniorityScheme`

1. In the `Salary` folder, open the `SalaryCalculator.Codeunit.al` file.
2. At the beginning of the `CalculateSalary` function, replace the `Calculator` variable declaration with this:
    ```pascal
    BaseSalaryCalculator: Interface IBaseSalaryCalculator;
    ```
3. Replace the `SeniorityBonus` variable declaration with this:
    ```pascal
    SeniorityScheme: Interface ISeniorityScheme;
    ```
4. In the body of the `CalculateSalary` function, replace the `Calculator` and `SeniorityBonus` variable assignments with these:
    ```pascal
    BaseSalaryCalculator := Employee.SalaryType;
    SeniorityScheme := Employee.Seniority;
    ```

#### Step 2: Obtain instances of `IBonusCalculator` and `IIncentiveCalculator`

1. Declare two new variables at the beginning of the `CalculateSalary` function:
    ```pascal
    BonusCalculator: Interface IBonusCalculator;
    IncentiveCalculator: Interface IIncentiveCalculator;
    ```
2. Obtain instances of `IBonusCalculator` and `IIncentiveCalculator` from the `SeniorityScheme` instance:
    ```pascal
    BonusCalculator := SeniorityScheme.GetBonusCalculator(Employee);
    IncentiveCalculator := SeniorityScheme.GetIncentiveCalculator(Employee);
    ```

#### Step 3: Simplify the bonus and incentive calculation logic

1. Replace the base salary calculation logic with this:
    ```pascal
    Salary := BaseSalaryCalculator.CalculateBaseSalary(Employee, Setup);
    ```
2. Replace the `if...then` logic for bonus and incentive calculation with this:
    ```pascal
    Bonus := BonusCalculator.CalculateBonus(Employee, Setup, Salary, StartingDate, EndingDate, AtDate);
    Incentive := IncentiveCalculator.CalculateIncentive(Employee, Setup, Salary, AtDate);
    ```

#### Step 4: Delete the `SeniorityBonusNone` codeunit

1. In the `Seniority` folder, delete the `SeniorityBonusNone.Codeunit.al` file.
