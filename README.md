# 03 LSP: Liskov Substitution Principle

In this exercise, you implement the improvements that follow the Liskov Substitution Principle.

### Scenario

The customer wants to implement a new time tracking system. Instead of using Timesheets from BC, they want to use a new, automated, smart-card based cloud system named "Timetracker". Some employees will still keep using the old system, and eventually, after a [*canary release*](https://en.wikipedia.org/wiki/Feature_toggle#Canary_release) period, everyone will migrate to the new system, and abandon the old system.

The customer is not 100% convinced that the new system is going to pass this canary release, and maybe after a few months they realize that they want something else.

The solution you develop must be ready to accept any future time tracking system without much effort from your side.

## Exercise: Implement the Liskov Substitution Principle

### Challenge Yourself

1. Create a new interface called `IWorkHoursProvider` that will be used to get the work hours for a given employee. The interface should have a single method named `CalculateHours` that calculates the work hours for a given employee for a given period.
2. Create a codeunit called `BCWorkHoursProvider` that implements the `IWorkHoursProvider` interface. Move the code from `SalaryCalculatorTimesheet` that calculates work hours based on BC TimeSheet headers and lines into the implementation inside `BCWorkHoursProvider`.
3. You need another codeunit called `TimetrackingWorkHoursProvider` that implements the `IWorkHoursProvider` interface and reads the data from the Timetracker cloud system. This codeunit should implement the API protocol of Timetracker, read the data from the cloud, write it to the database, and return the calculated work hours.
> Hint: **DO NOT** create this codeunit. It is provided for you already. You can find it inside the `Timetracker` folder that already contains some more objects you need for Timetracker (setup table and page, a table to keep Timetracker entries, and a factbox to present those entries on the Employee card). The code in this codeunit is commented out. Just uncomment it and correct any compilation errors you may encounter due to different names you may have used in your solution so far.
4. Add a new field to the `Employee` table called `TimetrackerEmployeeId` of type `Text[10]`. This field will be used to store the ID of the employee in the Timetracker cloud system. Add the same field to the `Employee Card` page.
5. Add a new factbox to the `Employee Card` page named `Timetracker Data`. This factbox should show the `TimetrackerEntriesFactbox` page.
6. Add a new action to the `Employee Card` page named `Get Timetracker Data`. This action should call the `CalculateHours` method of the `TimetrackingWorkHoursProvider` codeunit and update the current page.
7. You need a way to provide the correct implementation of the `IWorkHoursProvider` interface to the `SalaryCalculatorTimesheet` codeunit. Create a new function in the `EmployeeExt` table extension that will serve as a factory for this interface. If an employee has a `TimetrackerEmployeeId` set, the function should return the `TimetrackingWorkHoursProvider` implementation, otherwise it should return the `BCWorkHoursProvider` implementation.
8. Modify the code in `SalaryCalculatorTimesheet` codeunit to retrieve the correct implementation of the `IWorkHoursProvider` interface and then call this interface to calculate work hours. You do this in place of the original code that used timesheets to calculate work hours.

### Step-by-step instructions

#### Step 1: Create the `IWorkHoursProvider` interface

1. In the `Worksheets` folder, create a new file named `IWorkHoursProvider.Interface.al`.
2. Define the `IWorkHoursProvider` interface with a single method named `CalculateHours` that takes an `Employee` record, `StartingDate` and `EndingDate` as parameters and returns a `Decimal` value.

    ```al
    namespace ALchemy;

    using Microsoft.HumanResources.Employee;

    interface IWorkHoursProvider
    {
        procedure CalculateHours(Employee: Record Employee; StartingDate: Date; EndingDate: Date): Decimal;
    }
    ```

#### Step 2: Create the `BCWorkHoursProvider` codeunit

1. In the `Worksheets` folder, create a new file named `BCWorkHoursProvider.Codeunit.al`.
2. Define the `BCWorkHoursProvider` codeunit that implements the `IWorkHoursProvider` interface.
3. Move the code from the `SalaryCalculatorTimesheet` codeunit that calculates work hours based on BC TimeSheet headers and lines into the implementation inside `BCWorkHoursProvider`.

    ```al
    namespace ALchemy;

    using Microsoft.HumanResources.Employee;
    using Microsoft.Projects.TimeSheet;

    codeunit 60109 BCWorkHoursProvider implements IWorkHoursProvider
    {
        procedure CalculateHours(Employee: Record Employee; StartingDate: Date; EndingDate: Date) WorkHours: Decimal;
        var
            TimeSheetHeader: Record "Time Sheet Header";
            TimeSheetLine: Record "Time Sheet Line";
        begin
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
        end;
    }
    ```

#### Step 3: Uncomment the `TimetrackingWorkHoursProvider` codeunit

1. In the `Timetracker` folder, open the `TimetrackingWorkHoursProvider.Codeunit.al` file.
2. Uncomment the code in this file.
3. Correct any compilation errors you may encounter due to different names you may have used in your solution so far.

#### Step 4: Add the `TimetrackerEmployeeId` field to the `Employee` table and page

1. In the `Employee` folder, open the `EmployeeExt.TableExt.al` file.
2. Add a new field to the `Employee` table called `TimetrackerEmployeeId` of type `Text[10]`.
    ```al
    field(60112; TimetrackerEmployeeId; Text[10])
    {
        Caption = 'Timetracker Employee Id';
        DataClassification = CustomerContent;
    }
    ```
3. In the `Employee` folder, open the `EmployeeCardExt.PageExt.al` file.
4. Inside the `Salary` group, add a new subgroup named `WorksheetSalary` after the `CoreSalary` subgroup:
    ```al
    group(WorksheetSalary)
    {
        Caption = 'Worksheet Salary';

        field(TimetrackerEmployeeId; Rec.TimetrackerEmployeeId)
        {
            ApplicationArea = All;
            ToolTip = 'Specifies the ID of this employee in the Timetracker cloud system.';
        }
    }
    ```

#### Step 5: Add the `Timetracker Data` factbox to the `Employee Card` page

1. Add last factbox to the `factboxes` area of the `EmployeeCard` page:
    ```al
    addlast(factboxes)
    {
        part("Employee Timetracker Data"; TimetrackerEntriesFactbox)
        {
            ApplicationArea = All;
            SubPageLink = "Employee No." = field("No.");
        }
    }
    ```

#### Step 6: Add the `Get Timetracker Data` action to the `Employee Card` page

1. Add a new action after the `Preview Salary` action. Invoke the `CalculateHours` method of the `TimetrackingWorkHoursProvider` codeunit and update the current page:
    ```al
    action(GetTimetrackerData)
    {
        Caption = 'Get Timetracker Data';
        Promoted = true;
        Image = Timesheet;
        ApplicationArea = All;
        ToolTip = 'Gets employee''s worksheet data from Timetracker.';

        trigger OnAction()
        var
            TimetrackerProvider: Codeunit TimetrackerWorkHoursProvider;
        begin
            TimetrackerProvider.CalculateHours(Rec, WorkDate(), WorkDate());
            CurrPage.Update(false);
        end;
    }
    ```


#### Step 7: Create the `GetWorkHoursProvider` function in the `Employee` table

1. In the `Employee` folder, open the `EmployeeExt.TableExt.al` file.
2. Add a new function named `GetWorkHoursProvider` that will serve as a factory for the `IWorkHoursProvider` interface. If an employee has a `TimetrackerEmployeeId` set, the function should return the `TimetrackingWorkHoursProvider` implementation, otherwise it should return the `BCWorkHoursProvider` implementation.
    ```al
    internal procedure GetWorkHoursProvider(): Interface IWorkHoursProvider
    var
        BCWorkHoursProvider: Codeunit BCWorkHoursProvider;
        TimetrackerWorkHoursProvider: Codeunit TimetrackerWorkHoursProvider;
    begin
        if Rec.TimetrackerEmployeeId <> '' then
            exit(TimetrackerWorkHoursProvider)
        else
            exit(BCWorkHoursProvider);
    end;
    ```

#### Step 8: Modify the `SalaryCalculatorTimesheet` codeunit

1. In the `Salary` folder, open the `SalaryCalculatorTimesheet.Codeunit.al` file.
2. In the `CalculateBonus` function, replace the two record local variables declarations with a single `IWorkHoursProvider` interface variable:
    ```al
    WorkHoursProvider: Interface IWorkHoursProvider;
    ```
3. In the `CalculateBonus` function, replace the code that calculates work hours based on BC TimeSheet headers and lines with a call to the `CalculateHours` method of the `WorkHoursProvider` interface relevant for the employee:
    ```al
    WorkHoursProvider := Employee.GetWorkHoursProvider();
    WorkHours := WorkHoursProvider.CalculateHours(Employee, StartingDate, EndingDate);
    ```

## Solution notes

At this point, you applied Liskov Substitution Principle by making it possible to substitute one type of work hours calculation with any other without changing `SalaryCalculatorTimesheet` (its consumer) ever in the future. As long as you retain your factory function in the `Employee` table, you can always just add more implementations of the `IWorkHoursProvider` interface and maintain the factory function accordingly. Substituting one workhours calculator with another one has no influence on correctness of the entire salary calculation process.

> Hint: you could have added an enum for this, it would have achieved the same. However, the point of this exercise was to show that enums are not the only way of addressing the dependency substitution problem, and that simple factory functions can often be used instead. It all depends on your end goals. If you intend for third parties to be able to add their own work hours providers, then you would have done it with an enum. If you intend to fully control the process, then the approach you just did works better (especially for canary release or other types of continuous deployment techniques).

## Configuring Timetracker

You can configure your Timetracker integration in the `TimetrackerSetup` page by providing the following info:

| Field       | Value                                                      |
| ----------- | ---------------------------------------------------------- |
| Service URL | `https://demo-timetracker.azurewebsites.net`               |
| Access Key  | `41gbjkHHRgdpXNFdOFLs71QLnOP0OXFe2z_XMzd0oNpRAzFudh-lHA==` |

You can use any of these employee IDs to configure the Timetracker integration for some employees. Do not pick the first one, just pick a random one.

```
9gIeqbZs
0Rqv01eg
xq3l0wlB
CyxFSeIU
rcvLIiLo
7J3GBTsQ
k5LOfSsz
cG1ZRcmy
mqGulwuc
4fHOMXm5
AQL9vMCI
QwKraAPf
66idIoXV
hEtGUtPs
ZCuClZ5H
4BHbJc56
3exRy1m8
vxuwlRMh
xjcoqK3U
O91YVS1W
0pHQ1PTk
Qlzdjexz
AvgLX00V
VjTXEqRF
sMVKduMb
qsU1me8V
m2LVznkD
38XeFnXh
hH5Atq95
XWSlpz4Q
tOjWmj8v
8sW4WHkS
aI6lB87j
MZHnmULv
OjiEKymc
qAM16m9U
VOCMrP38
lbzBaxC5
jCGg5qEI
5oDv0CIy
```

There is also a file named `Timetracker.http` that uses the [REST Client extension](https://marketplace.visualstudio.com/items?itemName=humao.rest-client) for Visual Studio Code. You can use this file to test the Timetracker API, learn about about its integration protocol, and see why the implementation in `TimetrackerWorkHoursProvider` codeunit is the way it is.
