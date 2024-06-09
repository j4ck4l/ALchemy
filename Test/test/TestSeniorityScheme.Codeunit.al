namespace ALchemy;

using Microsoft.HumanResources.Employee;

codeunit 60155 "Test - Seniority Scheme"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;

    [Test]
    procedure Test_DefaultSeniorityScheme_GetBonusCalculator()
    var
        DefaultSeniorityScheme: Codeunit DefaultSeniorityScheme;
        Employee: Record Employee;
    begin
        Employee.SalaryType := SalaryType::Commission;
        Assert.AreEqual(Format(Codeunit::BonusCalculatorCommission), Format(DefaultSeniorityScheme.GetBonusCalculator(Employee)), 'Incorrect bonus calculator returned');
    end;

    [Test]
    procedure Test_DefaultSeniorityScheme_GetIncentiveCalculator()
    var
        DefaultSeniorityScheme: Codeunit DefaultSeniorityScheme;
        Employee: Record Employee;
    begin
        Employee.SalaryType := SalaryType::Performance;
        Assert.AreEqual(Format(Codeunit::NoIncentive), Format(DefaultSeniorityScheme.GetIncentiveCalculator(Employee)), 'Incorrect incentive calculator returned');
    end;

    [Test]
    procedure Test_SenioritySchemeDirector_GetBonusCalculator()
    var
        SenioritySchemeDirector: Codeunit SenioritySchemeDirector;
        Employee: Record Employee;
    begin
        Assert.AreEqual(Format(Codeunit::TeamBonus), Format(SenioritySchemeDirector.GetBonusCalculator(Employee)), 'Incorrect bonus calculator returned');
    end;

    [Test]
    procedure Test_SenioritySchemeDirector_GetIncentiveCalculator()
    var
        SenioritySchemeDirector: Codeunit SenioritySchemeDirector;
        Employee: Record Employee;
    begin
        Assert.AreEqual(Format(Codeunit::NoIncentive), Format(SenioritySchemeDirector.GetIncentiveCalculator(Employee)), 'Incorrect incentive calculator returned');
    end;

    [Test]
    procedure Test_SenioritySchemeManager_GetBonusCalculator()
    var
        SenioritySchemeManager: Codeunit SenioritySchemeManager;
        Employee: Record Employee;
    begin
        Assert.AreEqual(Format(Codeunit::TeamBonus), Format(SenioritySchemeManager.GetBonusCalculator(Employee)), 'Incorrect bonus calculator returned');
    end;

    [Test]
    procedure Test_SenioritySchemeManager_GetIncentiveCalculator()
    var
        SenioritySchemeManager: Codeunit SenioritySchemeManager;
        Employee: Record Employee;
    begin
        Assert.AreEqual(Format(Codeunit::TeamIncentive), Format(SenioritySchemeManager.GetIncentiveCalculator(Employee)), 'Incorrect incentive calculator returned');
    end;

    [Test]
    procedure Test_SenioritySchemeNone_GetBonusCalculator()
    var
        SenioritySchemeNone: Codeunit SenioritySchemeNone;
        Employee: Record Employee;
    begin
        Assert.AreEqual(Format(Codeunit::NoBonus), Format(SenioritySchemeNone.GetBonusCalculator(Employee)), 'Incorrect bonus calculator returned');
    end;

    [Test]
    procedure Test_SenioritySchemeNone_GetIncentiveCalculator()
    var
        SenioritySchemeNone: Codeunit SenioritySchemeNone;
        Employee: Record Employee;
    begin
        Assert.AreEqual(Format(Codeunit::NoIncentive), Format(SenioritySchemeNone.GetIncentiveCalculator(Employee)), 'Incorrect incentive calculator returned');
    end;

    [Test]
    procedure Test_SeniorityScheme_Trainee()
    var
        Scheme: Interface ISeniorityScheme;
    begin
        Scheme := Seniority::Trainee;
        Assert.AreEqual(Format(Codeunit::SenioritySchemeNone), Format(Scheme), 'Incorrect seniority scheme returned');
    end;

    [Test]
    procedure Test_SeniorityScheme_Staff()
    var
        Scheme: Interface ISeniorityScheme;
    begin
        Scheme := Seniority::Staff;
        Assert.AreEqual(Format(Codeunit::DefaultSeniorityScheme), Format(Scheme), 'Incorrect seniority scheme returned');
    end;

    [Test]
    procedure Test_SeniorityScheme_Lead()
    var
        Scheme: Interface ISeniorityScheme;
    begin
        Scheme := Seniority::Lead;
        Assert.AreEqual(Format(Codeunit::DefaultSeniorityScheme), Format(Scheme), 'Incorrect seniority scheme returned');
    end;

    [Test]
    procedure Test_SeniorityScheme_Manager()
    var
        Scheme: Interface ISeniorityScheme;
    begin
        Scheme := Seniority::Manager;
        Assert.AreEqual(Format(Codeunit::SenioritySchemeManager), Format(Scheme), 'Incorrect seniority scheme returned');
    end;

    [Test]
    procedure Test_SeniorityScheme_Director()
    var
        Scheme: Interface ISeniorityScheme;
    begin
        Scheme := Seniority::Director;
        Assert.AreEqual(Format(Codeunit::SenioritySchemeDirector), Format(Scheme), 'Incorrect seniority scheme returned');
    end;

    [Test]
    procedure Test_SeniorityScheme_Executive()
    var
        Scheme: Interface ISeniorityScheme;
    begin
        Scheme := Seniority::Executive;
        Assert.AreEqual(Format(Codeunit::SenioritySchemeNone), Format(Scheme), 'Incorrect seniority scheme returned');
    end;

}
