codeunit 50102 "CSV Token"
{
    var
        _type: Enum "CSV Token Type";
        _value: Text;

    procedure Init(Type: Enum "CSV Token Type")
    begin
        _type := Type;
        _value := '';
    end;

    procedure Init(Type: Enum "CSV Token Type"; Value: Text)
    begin
        _type := Type;
        _value := Value;
    end;

    procedure Value(): Text
    begin
        exit(_value);
    end;

    procedure Type(): Enum "CSV Token Type"
    begin
        exit(_type);
    end;

    procedure IsEOF(): Boolean
    begin
        exit(_type = "CSV Token Type"::EOF);
    end;

    procedure Repr(): Text
    begin
        if _type in ["CSV Token Type"::FIELD, "CSV Token Type"::SUBFIELD] then
            exit(StrSubstNo('%1 (%2)', Format(_type), _value))
        else
            exit(StrSubstNo('%1', Format(_type)));
    end;
}