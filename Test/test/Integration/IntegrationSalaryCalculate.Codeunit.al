/*
These tests are integration tests. Most of them are still valid and useful, but some of them are redundant and in a real-life
project they should eventually be removed.

The purpose of integration tests is to show that the solution as a whole works. When the code is not SOLID, the integration
tests need to cover all possible path, and this causes a lot of redundancy in code coverage, requires a lot of setup, a lot
of "givens", and writing those tests takes more time because many times those "givens" aren't obvious and need to be figured
out during the test writing.

When code is SOLID, we have already covered all the logical paths in the unit tests, and the integration tests are only there
as a final check to show that components are correctly integrated. They mostly need to cover only the "happy path". In this
test codeunit, there are several "happy path" tests (because they cover all possible paths through code, and the code itself
contains many "happy paths", e.g. staff with undertime, lead with overtime, trainee, etc.). In a real-life project, we would
keep only the most comprehensive "happy path" test, and leave out all the rest - your unit tests + that one integration test
prove that your solution as a whole works.

In this workshop project, the only reason why these tests are kept here is to show the difference in efficiency between unit
tests (which are many, but have almost no redundancy in coverage and are all very fast), and integration tests (which for
non-SOLID code are either still relatively numerous and relatively slow, or are very few and cover only a small percentage
of the code).
*/

namespace ALchemy;

using Microsoft.Projects.TimeSheet;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Sales.Receivables;
using Microsoft.CRM.Team;
using Microsoft.Foundation.NoSeries;
using Microsoft.HumanResources.Employee;
using Microsoft.Projects.Resources.Resource;

codeunit 60152 "Integration - Salary Calculate"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        LibraryERM: Codeunit "Library - ERM";
        LibraryRes: Codeunit "Library - Resource";
        LibraryHR: Codeunit "Library - Human Resource";
        LibrarySales: Codeunit "Library - Sales";
        IsInitialized: Boolean;
        TimeSheetNos: Code[20];

    [Test]
    procedure Test_FixedSalary_Employee()
    var
        Employee: Record Employee;
        Department: Record Department;
        Resource: Record Resource;
        Salesperson: Record "Salesperson/Purchaser";
        Salary: Record MonthlySalary;
    begin
        // [SCENARIO] Salary calculation - fixed salary defined on employee level
        Initialize();

        // [GIVEN] A resource to be used by the employee
        LibraryRes.CreateResourceNew(Resource);

        // [GIVEN] A salesperson to be used by the employee
        LibrarySales.CreateSalesperson(Salesperson);

        // [GIVEN] A department to be used by the employee
        if not Department.FindFirst() then begin
            Department.Init();
            Department."Code" := 'DEPT';
            Department.Insert();
        end;
        Department.BaseSalary := 1300;
        Department.Modify();

        // [GIVEN] A staff employee with fixed salary calculation
        LibraryHR.CreateEmployee(Employee);
        Employee."Resource No." := Resource."No.";
        Employee."Salespers./Purch. Code" := Salesperson."Code";
        Employee.DepartmentCode := Department."Code";
        Employee.Seniority := Seniority::Staff;
        Employee.SalaryType := SalaryType::Fixed;
        Employee.BaseSalary := 2000;
        Employee."Employment Date" := CalcDate('<CM-62M>', Today());
        Employee.Modify(false);

        // [WHEN] Calculating Salary
        Salary := Employee.CalculateSalary(Today);

        // [THEN] Salary must not be adjusted from base salary
        Assert.AreEqual(2000, Salary.Salary, 'Salary calculated incorrectly');
        Assert.AreEqual(0, Salary.Bonus, 'Bonus calculated incorrectly');
        Assert.AreEqual(200, Salary.Incentive, 'Incentive calculated incorrectly');
    end;

    [Test]
    procedure Test_FixedSalary_Setup()
    var
        Employee: Record Employee;
        Resource: Record Resource;
        Salesperson: Record "Salesperson/Purchaser";
        Salary: Record MonthlySalary;
        Setup: Record SalarySetup;
    begin
        // [SCENARIO] Salary calculation - fixed salary not defined on employee level, default taken from setup, no incentive
        Initialize();

        // [GIVEN] A resource to be used by the employee
        LibraryRes.CreateResourceNew(Resource);

        // [GIVEN] A salesperson to be used by the employee
        LibrarySales.CreateSalesperson(Salesperson);

        // [GIVEN] A staff employee with fixed salary calculation
        LibraryHR.CreateEmployee(Employee);
        Employee."Resource No." := Resource."No.";
        Employee."Salespers./Purch. Code" := Salesperson."Code";
        Employee.Seniority := Seniority::Staff;
        Employee.SalaryType := SalaryType::Fixed;
        Employee.BaseSalary := 0;
        Employee."Employment Date" := CalcDate('<CM-1M>', Today());
        Employee.Modify(false);

        // [GIVEN] Salary setup with default base salary
        if not Setup.Get() then
            Setup.Insert();
        Setup.BaseSalary := 1500;
        Setup.Modify();

        // [WHEN] Calculating Salary
        Salary := Employee.CalculateSalary(Today);

        // [THEN] Salary must not be adjusted from base salary
        Assert.AreEqual(1500, Salary.Salary, 'Salary calculated incorrectly');
        Assert.AreEqual(0, Salary.Bonus, 'Bonus calculated incorrectly');
        Assert.AreEqual(0, Salary.Incentive, 'Incentive calculated incorrectly');
    end;

    [Test]
    procedure Test_FixedSalary_Department()
    var
        Employee: Record Employee;
        Department: Record Department;
        Resource: Record Resource;
        Salesperson: Record "Salesperson/Purchaser";
        Salary: Record MonthlySalary;
    begin
        // [SCENARIO] Salary calculation - fixed salary defined on department level
        Initialize();

        // [GIVEN] A resource to be used by the employee
        LibraryRes.CreateResourceNew(Resource);

        // [GIVEN] A salesperson to be used by the employee
        LibrarySales.CreateSalesperson(Salesperson);

        // [GIVEN] A department to be used by the employee
        if not Department.FindFirst() then begin
            Department.Init();
            Department."Code" := 'DEPT';
            Department.Insert();
        end;
        Department.BaseSalary := 1300;
        Department.Modify();

        // [GIVEN] A staff employee with fixed salary calculation
        LibraryHR.CreateEmployee(Employee);
        Employee."Resource No." := Resource."No.";
        Employee."Salespers./Purch. Code" := Salesperson."Code";
        Employee.DepartmentCode := Department."Code";
        Employee.Seniority := Seniority::Staff;
        Employee.SalaryType := SalaryType::Fixed;
        Employee.BaseSalary := 0;
        Employee."Employment Date" := CalcDate('<CM-38M>', Today());
        Employee.Modify(false);

        // [WHEN] Calculating Salary
        Salary := Employee.CalculateSalary(Today);

        // [THEN] Salary must not be adjusted from base salary
        Assert.AreEqual(1300, Salary.Salary, 'Salary calculated incorrectly');
        Assert.AreEqual(0, Salary.Bonus, 'Bonus calculated incorrectly');
        Assert.AreEqual(78, Salary.Incentive, 'Incentive calculated incorrectly');
    end;

    [Test]
    procedure Test_TimesheetSalary_Staff_Undertime_NegativeBonus()
    var
        Employee: Record Employee;
        Resource: Record Resource;
        Salesperson: Record "Salesperson/Purchaser";
        TimeSheetHeader: Record "Time Sheet Header";
        TimeSheetLine: Record "Time Sheet Line";
        Salary: Record MonthlySalary;
    begin
        // [SCENARIO] Salary calculation - staff employee with timesheet salary calculation, undertime (negative bonus)
        Initialize();

        // [GIVEN] A resource to be used by the employee
        LibraryRes.CreateResourceNew(Resource);

        // [GIVEN] A salesperson to be used by the employee
        LibrarySales.CreateSalesperson(Salesperson);

        // [GIVEN] A staff employee with timesheet salary calculation
        LibraryHR.CreateEmployee(Employee);
        Employee."Resource No." := Resource."No.";
        Employee."Salespers./Purch. Code" := Salesperson."Code";
        Employee.Seniority := Seniority::Staff;
        Employee.SalaryType := SalaryType::Timesheet;
        Employee.BaseSalary := 2000;
        Employee."Employment Date" := CalcDate('<CM-6M>', Today());
        Employee.Modify(false);

        // [GIVEN] Time sheet entries for current month less than minimum hours
        CreateTimeSheetHeader(TimeSheetHeader, Resource."No.");
        CreateTimeSheetLine(TimeSheetHeader, TimeSheetLine, 55);
        CreateTimeSheetLine(TimeSheetHeader, TimeSheetLine, 50);

        // [WHEN] Calculating Salary
        Salary := Employee.CalculateSalary(Today);

        // [THEN] Salary must not be adjusted from base salary
        Assert.AreEqual(2000, Salary.Salary, 'Salary calculated incorrectly');
        Assert.AreEqual(-250, Salary.Bonus, 'Bonus calculated incorrectly');
        Assert.AreEqual(0, Salary.Incentive, 'Incentive calculated incorrectly');
    end;

    [Test]
    procedure Test_TimesheetSalary_Staff_Undertime_NoBonus()
    var
        Employee: Record Employee;
        Resource: Record Resource;
        Salesperson: Record "Salesperson/Purchaser";
        TimeSheetHeader: Record "Time Sheet Header";
        TimeSheetLine: Record "Time Sheet Line";
        Salary: Record MonthlySalary;
    begin
        // [SCENARIO] Salary calculation - staff employee with timesheet salary calculation, undertime but above minimum hours (no bonus)
        Initialize();

        // [GIVEN] A resource to be used by the employee
        LibraryRes.CreateResourceNew(Resource);

        // [GIVEN] A salesperson to be used by the employee
        LibrarySales.CreateSalesperson(Salesperson);

        // [GIVEN] A staff employee with timesheet salary calculation
        LibraryHR.CreateEmployee(Employee);
        Employee."Resource No." := Resource."No.";
        Employee."Salespers./Purch. Code" := Salesperson."Code";
        Employee.Seniority := Seniority::Staff;
        Employee.SalaryType := SalaryType::Timesheet;
        Employee.BaseSalary := 2000;
        Employee."Employment Date" := CalcDate('<CM-6M>', Today());
        Employee.Modify(false);

        // [GIVEN] Time sheet entries for current month less than minimum hours
        CreateTimeSheetHeader(TimeSheetHeader, Resource."No.");
        CreateTimeSheetLine(TimeSheetHeader, TimeSheetLine, 55);
        CreateTimeSheetLine(TimeSheetHeader, TimeSheetLine, 50);
        CreateTimeSheetLine(TimeSheetHeader, TimeSheetLine, 20);

        // [WHEN] Calculating Salary
        Salary := Employee.CalculateSalary(Today);

        // [THEN] Salary must not be adjusted from base salary
        Assert.AreEqual(2000, Salary.Salary, 'Salary calculated incorrectly');
        Assert.AreEqual(0, Salary.Bonus, 'Bonus calculated incorrectly');
        Assert.AreEqual(0, Salary.Incentive, 'Incentive calculated incorrectly');
    end;

    [Test]
    procedure Test_TimesheetSalary_Lead_Overtime_NoBonus()
    var
        Employee: Record Employee;
        Resource: Record Resource;
        Salesperson: Record "Salesperson/Purchaser";
        TimeSheetHeader: Record "Time Sheet Header";
        TimeSheetLine: Record "Time Sheet Line";
        Salary: Record MonthlySalary;
    begin
        // [SCENARIO] Salary calculation - lead employee with timesheet salary calculation, overtime but below threshold (no bonus)
        Initialize();

        // [GIVEN] A resource to be used by the employee
        LibraryRes.CreateResourceNew(Resource);

        // [GIVEN] A salesperson to be used by the employee
        LibrarySales.CreateSalesperson(Salesperson);

        // [GIVEN] A lead employee with timesheet salary calculation
        LibraryHR.CreateEmployee(Employee);
        Employee."Resource No." := Resource."No.";
        Employee."Salespers./Purch. Code" := Salesperson."Code";
        Employee.Seniority := Seniority::Lead;
        Employee.SalaryType := SalaryType::Timesheet;
        Employee.BaseSalary := 2000;
        Employee."Employment Date" := CalcDate('<CM-6M>', Today());
        Employee.Modify(false);

        // [GIVEN] Time sheet entries for current month less than minimum hours
        CreateTimeSheetHeader(TimeSheetHeader, Resource."No.");
        CreateTimeSheetLine(TimeSheetHeader, TimeSheetLine, 55);
        CreateTimeSheetLine(TimeSheetHeader, TimeSheetLine, 50);
        CreateTimeSheetLine(TimeSheetHeader, TimeSheetLine, 20);
        CreateTimeSheetLine(TimeSheetHeader, TimeSheetLine, 45);

        // [WHEN] Calculating Salary
        Salary := Employee.CalculateSalary(Today);

        // [THEN] Salary must not be adjusted from base salary
        Assert.AreEqual(2000, Salary.Salary, 'Salary calculated incorrectly');
        Assert.AreEqual(0, Salary.Bonus, 'Bonus calculated incorrectly');
        Assert.AreEqual(0, Salary.Incentive, 'Incentive calculated incorrectly');
    end;

    [Test]
    procedure Test_TimesheetSalary_Lead_Overtime_Bonus()
    var
        Employee: Record Employee;
        Resource: Record Resource;
        Salesperson: Record "Salesperson/Purchaser";
        TimeSheetHeader: Record "Time Sheet Header";
        TimeSheetLine: Record "Time Sheet Line";
        Salary: Record MonthlySalary;
    begin
        // [SCENARIO] Salary calculation - lead employee with timesheet salary calculation, overtime above threshold (bonus)
        Initialize();

        // [GIVEN] A resource to be used by the employee
        LibraryRes.CreateResourceNew(Resource);

        // [GIVEN] A salesperson to be used by the employee
        LibrarySales.CreateSalesperson(Salesperson);

        // [GIVEN] A lead employee with timesheet salary calculation
        LibraryHR.CreateEmployee(Employee);
        Employee."Resource No." := Resource."No.";
        Employee."Salespers./Purch. Code" := Salesperson."Code";
        Employee.Seniority := Seniority::Lead;
        Employee.SalaryType := SalaryType::Timesheet;
        Employee.BaseSalary := 2000;
        Employee."Employment Date" := CalcDate('<CM-6M>', Today());
        Employee.Modify(false);

        // [GIVEN] Time sheet entries for current month less than minimum hours
        CreateTimeSheetHeader(TimeSheetHeader, Resource."No.");
        CreateTimeSheetLine(TimeSheetHeader, TimeSheetLine, 55);
        CreateTimeSheetLine(TimeSheetHeader, TimeSheetLine, 50);
        CreateTimeSheetLine(TimeSheetHeader, TimeSheetLine, 20);
        CreateTimeSheetLine(TimeSheetHeader, TimeSheetLine, 45);
        CreateTimeSheetLine(TimeSheetHeader, TimeSheetLine, 46);

        // [WHEN] Calculating Salary
        Salary := Employee.CalculateSalary(Today);

        // [THEN] Salary must not be adjusted from base salary
        Assert.AreEqual(2000, Salary.Salary, 'Salary calculated incorrectly');
        Assert.AreEqual(400, Salary.Bonus, 'Bonus calculated incorrectly');
        Assert.AreEqual(0, Salary.Incentive, 'Incentive calculated incorrectly');
    end;

    [Test]
    procedure Test_TimesheetSalary_Executive_Overtime_NoTeam_NoBonus()
    var
        Employee: Record Employee;
        Resource: Record Resource;
        Salesperson: Record "Salesperson/Purchaser";
        TimeSheetHeader: Record "Time Sheet Header";
        TimeSheetLine: Record "Time Sheet Line";
        Salary: Record MonthlySalary;
    begin
        // [SCENARIO] Salary calculation - executive employee with timesheet salary calculation, overtime above threshold, no team (no bonus)
        Initialize();

        // [GIVEN] A resource to be used by the employee
        LibraryRes.CreateResourceNew(Resource);

        // [GIVEN] A salesperson to be used by the employee
        LibrarySales.CreateSalesperson(Salesperson);

        // [GIVEN] An executive employee with timesheet salary calculation
        LibraryHR.CreateEmployee(Employee);
        Employee."Resource No." := Resource."No.";
        Employee."Salespers./Purch. Code" := Salesperson."Code";
        Employee.Seniority := Seniority::Executive;
        Employee.SalaryType := SalaryType::Timesheet;
        Employee.BaseSalary := 2000;
        Employee."Employment Date" := CalcDate('<CM-6M>', Today());
        Employee.Modify(false);

        // [GIVEN] Time sheet entries for current month less than minimum hours
        CreateTimeSheetHeader(TimeSheetHeader, Resource."No.");
        CreateTimeSheetLine(TimeSheetHeader, TimeSheetLine, 55);
        CreateTimeSheetLine(TimeSheetHeader, TimeSheetLine, 50);
        CreateTimeSheetLine(TimeSheetHeader, TimeSheetLine, 20);
        CreateTimeSheetLine(TimeSheetHeader, TimeSheetLine, 45);
        CreateTimeSheetLine(TimeSheetHeader, TimeSheetLine, 46);

        // [WHEN] Calculating Salary
        Salary := Employee.CalculateSalary(Today);

        // [THEN] Salary must not be adjusted from base salary
        Assert.AreEqual(2000, Salary.Salary, 'Salary calculated incorrectly');
        Assert.AreEqual(0, Salary.Bonus, 'Bonus calculated incorrectly');
        Assert.AreEqual(0, Salary.Incentive, 'Incentive calculated incorrectly');
    end;

    [Test]
    procedure Test_TimesheetSalary_Director_Overtime_Team_BonusNoIncentives()
    var
        Employee, TeamMember, TeamMember2 : Record Employee;
        Resource, TeamMemberResource, TeamMemberResource2 : Record Resource;
        Salesperson, TeamMemberSalesperson, TeamMemberSalesperson2 : Record "Salesperson/Purchaser";
        TimeSheetHeader: Record "Time Sheet Header";
        TimeSheetLine: Record "Time Sheet Line";
        Salary: Record MonthlySalary;
    begin
        // [SCENARIO] Salary calculation - director employee with timesheet salary calculation, team with bonus (bonus, no incentive)
        Initialize();

        // [GIVEN] A resource to be used by the employee
        LibraryRes.CreateResourceNew(Resource);

        // [GIVEN] A resource to be used by the team member
        LibraryRes.CreateResourceNew(TeamMemberResource);

        // [GIVEN] A resource to be used by the team member
        LibraryRes.CreateResourceNew(TeamMemberResource2);

        // [GIVEN] A salesperson to be used by the employee
        LibrarySales.CreateSalesperson(Salesperson);

        // [GIVEN] A salesperson to be used by the team member
        LibrarySales.CreateSalesperson(TeamMemberSalesperson);

        // [GIVEN] A salesperson to be used by the team member
        LibrarySales.CreateSalesperson(TeamMemberSalesperson2);

        // [GIVEN] An director employee with timesheet salary calculation
        LibraryHR.CreateEmployee(Employee);
        Employee."Resource No." := Resource."No.";
        Employee."Salespers./Purch. Code" := Salesperson."Code";
        Employee.Seniority := Seniority::Director;
        Employee.SalaryType := SalaryType::Timesheet;
        Employee.BaseSalary := 2000;
        Employee."Employment Date" := CalcDate('<CM-62M>', Today());
        Employee.TeamBonusPct := 10;
        Employee.TeamIncentivePct := 15;
        Employee.Modify(false);

        // [GIVEN] A team member with timesheet salary calculation
        LibraryHR.CreateEmployee(TeamMember);
        TeamMember."Resource No." := TeamMemberResource."No.";
        TeamMember."Salespers./Purch. Code" := TeamMemberSalesperson."Code";
        TeamMember.Seniority := Seniority::Staff;
        TeamMember.SalaryType := SalaryType::Timesheet;
        TeamMember.BaseSalary := 2000;
        TeamMember."Employment Date" := CalcDate('<CM-62M>', Today());
        TeamMember."Manager No." := Employee."No.";
        TeamMember.Modify(false);

        // [GIVEN] A team member with timesheet salary calculation
        LibraryHR.CreateEmployee(TeamMember2);
        TeamMember2."Resource No." := TeamMemberResource2."No.";
        TeamMember2."Salespers./Purch. Code" := TeamMemberSalesperson2."Code";
        TeamMember2.Seniority := Seniority::Staff;
        TeamMember2.SalaryType := SalaryType::Timesheet;
        TeamMember2.BaseSalary := 2000;
        TeamMember2."Employment Date" := CalcDate('<CM-38M>', Today());
        TeamMember2."Manager No." := Employee."No.";
        TeamMember2.Modify(false);

        // [GIVEN] Time sheet entries for current month for first team member, over the threshold
        CreateTimeSheetHeader(TimeSheetHeader, TeamMemberResource."No.");
        CreateTimeSheetLine(TimeSheetHeader, TimeSheetLine, 55);
        CreateTimeSheetLine(TimeSheetHeader, TimeSheetLine, 50);
        CreateTimeSheetLine(TimeSheetHeader, TimeSheetLine, 20);
        CreateTimeSheetLine(TimeSheetHeader, TimeSheetLine, 45);
        CreateTimeSheetLine(TimeSheetHeader, TimeSheetLine, 46);

        // [GIVEN] Time sheet entries for current month for another team member, over the threshold
        CreateTimeSheetHeader(TimeSheetHeader, TeamMemberResource2."No.");
        CreateTimeSheetLine(TimeSheetHeader, TimeSheetLine, 55);
        CreateTimeSheetLine(TimeSheetHeader, TimeSheetLine, 50);
        CreateTimeSheetLine(TimeSheetHeader, TimeSheetLine, 20);
        CreateTimeSheetLine(TimeSheetHeader, TimeSheetLine, 45);
        CreateTimeSheetLine(TimeSheetHeader, TimeSheetLine, 28);

        // [WHEN] Calculating Salary
        Salary := Employee.CalculateSalary(Today);

        // [THEN] Salary must not be adjusted from base salary
        Assert.AreEqual(2000, Salary.Salary, 'Salary calculated incorrectly');
        Assert.AreEqual(60, Salary.Bonus, 'Bonus calculated incorrectly');
        Assert.AreEqual(0, Salary.Incentive, 'Incentive calculated incorrectly');
    end;

    [Test]
    procedure Test_TimesheetSalary_Manager_Overtime_Team_BonusIncentives()
    var
        Employee, TeamMember, TeamMember2 : Record Employee;
        Resource, TeamMemberResource, TeamMemberResource2 : Record Resource;
        Salesperson, TeamMemberSalesperson, TeamMemberSalesperson2 : Record "Salesperson/Purchaser";
        TimeSheetHeader: Record "Time Sheet Header";
        TimeSheetLine: Record "Time Sheet Line";
        Salary: Record MonthlySalary;
    begin
        // [SCENARIO] Salary calculation - manager employee with timesheet salary calculation, team with bonus (bonus, incentive)
        Initialize();

        // [GIVEN] A resource to be used by the employee
        LibraryRes.CreateResourceNew(Resource);

        // [GIVEN] A resource to be used by the team member
        LibraryRes.CreateResourceNew(TeamMemberResource);

        // [GIVEN] A resource to be used by the team member
        LibraryRes.CreateResourceNew(TeamMemberResource2);

        // [GIVEN] A salesperson to be used by the employee
        LibrarySales.CreateSalesperson(Salesperson);

        // [GIVEN] A salesperson to be used by the team member
        LibrarySales.CreateSalesperson(TeamMemberSalesperson);

        // [GIVEN] A salesperson to be used by the team member
        LibrarySales.CreateSalesperson(TeamMemberSalesperson2);

        // [GIVEN] An manager employee with timesheet salary calculation
        LibraryHR.CreateEmployee(Employee);
        Employee."Resource No." := Resource."No.";
        Employee."Salespers./Purch. Code" := Salesperson."Code";
        Employee.Seniority := Seniority::Manager;
        Employee.SalaryType := SalaryType::Timesheet;
        Employee.BaseSalary := 2000;
        Employee."Employment Date" := CalcDate('<CM-62M>', Today());
        Employee.TeamBonusPct := 10;
        Employee.TeamIncentivePct := 15;
        Employee.Modify(false);

        // [GIVEN] A team member with timesheet salary calculation
        LibraryHR.CreateEmployee(TeamMember);
        TeamMember."Resource No." := TeamMemberResource."No.";
        TeamMember."Salespers./Purch. Code" := TeamMemberSalesperson."Code";
        TeamMember.Seniority := Seniority::Staff;
        TeamMember.SalaryType := SalaryType::Timesheet;
        TeamMember.BaseSalary := 2000;
        TeamMember."Employment Date" := CalcDate('<CM-62M>', Today());
        TeamMember."Manager No." := Employee."No.";
        TeamMember.Modify(false);

        // [GIVEN] A team member with timesheet salary calculation
        LibraryHR.CreateEmployee(TeamMember2);
        TeamMember2."Resource No." := TeamMemberResource2."No.";
        TeamMember2."Salespers./Purch. Code" := TeamMemberSalesperson2."Code";
        TeamMember2.Seniority := Seniority::Staff;
        TeamMember2.SalaryType := SalaryType::Timesheet;
        TeamMember2.BaseSalary := 2000;
        TeamMember2."Employment Date" := CalcDate('<CM-38M>', Today());
        TeamMember2."Manager No." := Employee."No.";
        TeamMember2.Modify(false);

        // [GIVEN] Time sheet entries for current month for first team member, over the threshold
        CreateTimeSheetHeader(TimeSheetHeader, TeamMemberResource."No.");
        CreateTimeSheetLine(TimeSheetHeader, TimeSheetLine, 55);
        CreateTimeSheetLine(TimeSheetHeader, TimeSheetLine, 50);
        CreateTimeSheetLine(TimeSheetHeader, TimeSheetLine, 20);
        CreateTimeSheetLine(TimeSheetHeader, TimeSheetLine, 45);
        CreateTimeSheetLine(TimeSheetHeader, TimeSheetLine, 46);

        // [GIVEN] Time sheet entries for current month for another team member, over the threshold
        CreateTimeSheetHeader(TimeSheetHeader, TeamMemberResource2."No.");
        CreateTimeSheetLine(TimeSheetHeader, TimeSheetLine, 55);
        CreateTimeSheetLine(TimeSheetHeader, TimeSheetLine, 50);
        CreateTimeSheetLine(TimeSheetHeader, TimeSheetLine, 20);
        CreateTimeSheetLine(TimeSheetHeader, TimeSheetLine, 45);
        CreateTimeSheetLine(TimeSheetHeader, TimeSheetLine, 28);

        // [WHEN] Calculating Salary
        Salary := Employee.CalculateSalary(Today);

        // [THEN] Salary must not be adjusted from base salary
        Assert.AreEqual(2000, Salary.Salary, 'Salary calculated incorrectly');
        Assert.AreEqual(60, Salary.Bonus, 'Bonus calculated incorrectly');
        Assert.AreEqual(48, Salary.Incentive, 'Incentive calculated incorrectly');
    end;

    [Test]
    procedure Test_Trainee_NoBonusNoIncentive()
    var
        Employee: Record Employee;
        Resource: Record Resource;
        Salesperson: Record "Salesperson/Purchaser";
        TimeSheetHeader: Record "Time Sheet Header";
        TimeSheetLine: Record "Time Sheet Line";
        Salary: Record MonthlySalary;
    begin
        // [SCENARIO] Salary calculation - trainee that otherwise meets bonus and incentive criteria - no bonus or incentive calculated
        Initialize();

        // [GIVEN] A resource to be used by the employee
        LibraryRes.CreateResourceNew(Resource);

        // [GIVEN] A salesperson to be used by the employee
        LibrarySales.CreateSalesperson(Salesperson);

        // [GIVEN] A lead employee with timesheet salary calculation
        LibraryHR.CreateEmployee(Employee);
        Employee."Resource No." := Resource."No.";
        Employee."Salespers./Purch. Code" := Salesperson."Code";
        Employee.Seniority := Seniority::Trainee;
        Employee.SalaryType := SalaryType::Timesheet;
        Employee.BaseSalary := 2000;
        Employee."Employment Date" := CalcDate('<CM-62M>', Today());
        Employee.Modify(false);

        // [GIVEN] Time sheet entries for current month less than minimum hours
        CreateTimeSheetHeader(TimeSheetHeader, Resource."No.");
        CreateTimeSheetLine(TimeSheetHeader, TimeSheetLine, 55);
        CreateTimeSheetLine(TimeSheetHeader, TimeSheetLine, 50);
        CreateTimeSheetLine(TimeSheetHeader, TimeSheetLine, 20);
        CreateTimeSheetLine(TimeSheetHeader, TimeSheetLine, 45);
        CreateTimeSheetLine(TimeSheetHeader, TimeSheetLine, 46);

        // [WHEN] Calculating Salary
        Salary := Employee.CalculateSalary(Today);

        // [THEN] Salary must not be adjusted from base salary
        Assert.AreEqual(2000, Salary.Salary, 'Salary calculated incorrectly');
        Assert.AreEqual(0, Salary.Bonus, 'Bonus calculated incorrectly');
        Assert.AreEqual(0, Salary.Incentive, 'Incentive calculated incorrectly');
    end;

    [Test]
    procedure Test_CommissionSalary()
    var
        Employee: Record Employee;
        Resource: Record Resource;
        Salesperson: Record "Salesperson/Purchaser";
        CustLedgEntry: Record "Cust. Ledger Entry";
        Salary: Record MonthlySalary;
    begin
        // [SCENARIO] Salary calculation
        Initialize();

        // [GIVEN] A resource to be used by the employee
        LibraryRes.CreateResourceNew(Resource);

        // [GIVEN] A salesperson to be used by the employee
        LibrarySales.CreateSalesperson(Salesperson);

        // [GIVEN] A staff employee with commission salary calculation
        LibraryHR.CreateEmployee(Employee);
        Employee."Resource No." := Resource."No.";
        Employee."Salespers./Purch. Code" := Salesperson."Code";
        Employee.Seniority := Seniority::Staff;
        Employee.SalaryType := SalaryType::Commission;
        Employee.BaseSalary := 2000;
        Employee.CommissionBonusPct := 25;
        Employee."Employment Date" := CalcDate('<CM-6M>', Today());
        Employee.Modify(false);

        // [GIVEN] Two customer ledger entries
        if CustLedgEntry.FindLast() then;
        CustLedgEntry.Init();
        CustLedgEntry."Entry No." += 1;
        CustLEdgEntry."Document Type" := "Gen. Journal Document Type"::Invoice;
        CustLedgEntry."Posting Date" := Today();
        CustLedgEntry."Salesperson Code" := Salesperson."Code";
        CustLedgEntry."Profit (LCY)" := 150;
        CustLedgEntry.Insert(false);
        CustLedgEntry."Entry No." += 1;
        CustLedgEntry."Profit (LCY)" := 100;
        CustLedgEntry.Insert(false);

        // [WHEN] Calculating Salary
        Salary := Employee.CalculateSalary(Today);

        // [THEN] Salary must not be adjusted from base salary
        Assert.AreEqual(2000, Salary.Salary, 'Salary calculated incorrectly');
        Assert.AreEqual(62.5, Salary.Bonus, 'Bonus calculated incorrectly');
        Assert.AreEqual(0, Salary.Incentive, 'Incentive calculated incorrectly');
    end;

    [Test]
    procedure Test_TargetSalary()
    var
        Employee: Record Employee;
        Resource: Record Resource;
        Salesperson: Record "Salesperson/Purchaser";
        CustLedgEntry: Record "Cust. Ledger Entry";
        Salary: Record MonthlySalary;
    begin
        // [SCENARIO] Salary calculation
        Initialize();

        // [GIVEN] A resource to be used by the employee
        LibraryRes.CreateResourceNew(Resource);

        // [GIVEN] A salesperson to be used by the employee
        LibrarySales.CreateSalesperson(Salesperson);

        // [GIVEN] A staff employee with commission salary calculation
        LibraryHR.CreateEmployee(Employee);
        Employee."Resource No." := Resource."No.";
        Employee."Salespers./Purch. Code" := Salesperson."Code";
        Employee.Seniority := Seniority::Staff;
        Employee.SalaryType := SalaryType::Target;
        Employee.BaseSalary := 2000;
        Employee.TargetRevenue := 125000;
        Employee.TargetBonus := 1000;
        Employee.MaximumTargetBonus := 1500;
        Employee."Employment Date" := CalcDate('<CM-37M>', Today());
        Employee.Modify(false);

        // [GIVEN] Two customer ledger entries
        if CustLedgEntry.FindLast() then;
        CustLedgEntry.Init();
        CustLedgEntry."Entry No." += 1;
        CustLEdgEntry."Document Type" := "Gen. Journal Document Type"::Invoice;
        CustLedgEntry."Posting Date" := Today();
        CustLedgEntry."Salesperson Code" := Salesperson."Code";
        CustLedgEntry."Sales (LCY)" := 80000;
        CustLedgEntry.Insert(false);
        CustLedgEntry."Entry No." += 1;
        CustLedgEntry."Sales (LCY)" := 70000;
        CustLedgEntry.Insert(false);

        // [WHEN] Calculating Salary
        Salary := Employee.CalculateSalary(Today);

        // [THEN] Salary must not be adjusted from base salary
        Assert.AreEqual(2000, Salary.Salary, 'Salary calculated incorrectly');
        Assert.AreEqual(1200, Salary.Bonus, 'Bonus calculated incorrectly');
        Assert.AreEqual(120, Salary.Incentive, 'Incentive calculated incorrectly');
    end;

    local procedure CreateTimeSheetHeader(var TimeSheetHeader: Record "Time Sheet Header"; ResourceNo: Code[20])
    var
        NoSeries: Codeunit "No. Series";
    begin
        TimeSheetHeader."No." := NoSeries.GetNextNo(TimeSheetNos, Today(), true);
        TimeSheetHeader."Starting Date" := Today();
        TimeSheetHeader."Ending Date" := Today();
        TimeSheetHeader."Resource No." := ResourceNo;
        TimeSheetHeader.Insert(false);
    end;

    local procedure CreateTimeSheetLine(TimeSheetHeader: Record "Time Sheet Header"; var TimeSheetLine: Record "Time Sheet Line"; Quantity: Decimal)
    var
        TimeSheetDetail: Record "Time Sheet Detail";
    begin
        TimeSheetLine.SetRange("Time Sheet No.", TimeSheetHeader."No.");
        if not TimeSheetLine.FindLast() then;

        TimeSheetLine.Init();
        TimeSheetLine."Time Sheet No." := TimeSheetHeader."No.";
        TimeSheetLine."Line No." += 10000;
        TimeSheetLine.Status := TimeSheetLine.Status::Approved;
        TimeSheetLine.Insert(false);

        TimeSheetDetail."Time Sheet No." := TimeSheetLine."Time Sheet No.";
        TimeSheetDetail."Time Sheet Line No." := TimeSheetLine."Line No.";
        TimeSheetDetail.Date := Today();
        TimeSheetDetail.Quantity := Quantity;
        TimeSheetDetail.Insert(false);
    end;

    local procedure InitializeSetup()
    var
        SalarySetup: Record SalarySetup;
    begin
        if not SalarySetup.Get() then
            SalarySetup.Insert();

        SalarySetup.BaseSalary := 1000;
        SalarySetup.MinimumHours := 120;
        SalarySetup.OvertimeThreshold := 180;
        SalarySetup.YearlyIncentivePct := 2;
        SalarySetup.Modify();
    end;

    local procedure InitializeTimeSheetNos()
    begin
        TimesheetNos := LibraryERM.CreateNoSeriesCode();
    end;

    local procedure Initialize()
    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Integration - Salary Calculate");

        if IsInitialized then exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Integration - Salary Calculate");

        InitializeSetup();
        InitializeTimeSheetNos();

        IsInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Integration - Salary Calculate");
    end;
}
