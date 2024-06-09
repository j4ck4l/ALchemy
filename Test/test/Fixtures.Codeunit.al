namespace ALchemy;

codeunit 60157 Fixtures
{
    #region Department
    var
        _initializedDepartment: Boolean;
        _department: Record Department;

    procedure InitializeDepartment()
    var
        Found: Boolean;
    begin
        if _initializedDepartment then
            exit;

        _department.Code := 'DUMMY';
        Found := _department.Get(_department.Code);
        _department.BaseSalary := 1111;
        if not Found then
            _department.Insert(false)
        else
            _department.Modify(false);

        _initializedDepartment := true;
    end;

    procedure Department(): Record Department
    begin
        InitializeDepartment();
        exit(_department);
    end;

    #endregion

    #region DepartmentSenioritySetup
    var
        _initializedDepartmentSenioritySetup: Boolean;
        _departmentSenioritySetup: Record DepartmentSenioritySetup;

    procedure InitializeDepartmentSenioritySetup()
    var
        Found: Boolean;
    begin
        if _initializedDepartmentSenioritySetup then
            exit;

        _departmentSenioritySetup.DepartmentCode := Department().Code;
        _departmentSenioritySetup.Seniority := Seniority::Director;
        Found := _departmentSenioritySetup.Get(_departmentSenioritySetup.DepartmentCode, _departmentSenioritySetup.Seniority);
        _departmentSenioritySetup.BaseSalary := 2222;
        if not Found then
            _departmentSenioritySetup.Insert(false)
        else
            _departmentSenioritySetup.Modify(false);

        _initializedDepartmentSenioritySetup := true;
    end;

    procedure DepartmentSenioritySetup(): Record DepartmentSenioritySetup
    begin
        InitializeDepartmentSenioritySetup();
        exit(_departmentSenioritySetup);
    end;

    #endregion

}
