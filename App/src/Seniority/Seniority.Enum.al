namespace ALchemy;

enum 60100 Seniority implements ISeniorityScheme
{
    Caption = 'Employee Type';
    Extensible = true;

    DefaultImplementation = ISeniorityScheme = DefaultSeniorityScheme;
    UnknownValueImplementation = ISeniorityScheme = DefaultSeniorityScheme;

    value(0; Trainee)
    {
        Caption = 'Trainee';
        Implementation = ISeniorityScheme = SenioritySchemeNone;
    }

    value(1; Staff)
    {
        Caption = 'Staff';
    }

    value(2; Lead)
    {
        Caption = 'Lead';
    }

    value(3; Manager)
    {
        Caption = 'Manager';
        Implementation = ISeniorityScheme = SenioritySchemeManager;
    }

    value(4; Director)
    {
        Caption = 'Director';
        Implementation = ISeniorityScheme = SenioritySchemeDirector;
    }

    value(5; Executive)
    {
        Caption = 'Executive';
        Implementation = ISeniorityScheme = SenioritySchemeNone;
    }
}
