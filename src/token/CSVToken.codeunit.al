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

    procedure IsEOS(): Boolean
    begin
        exit(_type = "CSV Token Type"::EOS);
    end;

    procedure IsValue(): Boolean
    begin
        exit(_type = "CSV Token Type"::Value);
    end;

    procedure IsScope(): Boolean
    begin
        exit(_type = "CSV Token Type"::Scope);
    end;

    procedure IsDelimiter(): Boolean
    begin
        exit(_type = "CSV Token Type"::Delimiter);
    end;

    procedure IsNewLine(): Boolean
    begin
        exit(_type = "CSV Token Type"::NewLine);
    end;

    procedure Repr(): Text
    begin
        case _type of
            "CSV Token Type"::EOS, "CSV Token Type"::NewLine, "CSV Token Type"::Delimiter:
                exit(StrSubstNo('%1', Format(_type)));
            "CSV Token Type"::Value, "CSV Token Type"::Scope:
                exit(StrSubstNo('%1 (%2)', Format(_type), _value));
        end;
    end;
}