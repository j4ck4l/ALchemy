namespace ALchemy;

enum 60100 Seniority implements ISeniorityBonus
{
    Caption = 'Employee Type';
    Extensible = true;

    DefaultImplementation = ISeniorityBonus = SeniorityBonusDefault;
    UnknownValueImplementation = ISeniorityBonus = SeniorityBonusDefault;

    value(0; Trainee)
    {
        Caption = 'Trainee';
        Implementation = ISeniorityBonus = SeniorityBonusNone;
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
        Implementation = ISeniorityBonus = SeniorityBonusManager;
    }

    value(4; Director)
    {
        Caption = 'Director';
        Implementation = ISeniorityBonus = SeniorityBonusDirector;
    }

    value(5; Executive)
    {
        Caption = 'Executive';
        Implementation = ISeniorityBonus = SeniorityBonusNone;
    }
}
