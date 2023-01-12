codeunit 50100 "CSV Reader"
{
    // start: record*
    // record: field (DELIMITER field)* NEWLINE
    // field: quoted_field 
    //      | simple_field  
    //      | empty
    // quoted_field: SUBFIELD+
    // simple_field: FIELD
    // empty:

    var
        _scanner: Codeunit "CSV Scanner";
        _token: Codeunit "CSV Token";
        _result: List of [List of [Text]];

    procedure Init(Stream: InStream; Delimiter: Char)
    begin
        _scanner.Init(Stream, Delimiter);
        _scanner.NextToken(_token);
    end;

    local procedure Eat(TokenType: Enum "CSV Token Type")
    var
        ParserErr: Label 'Parser error';
    begin
        if _token.Type() = TokenType then
            _scanner.NextToken(_token)
        else
            Error(ParserErr);
    end;

    local procedure quoted_field() Result: Text
    begin
        repeat
            Result += _token.Value();
            Eat("CSV Token Type"::SUBFIELD);
            if _token.Type() = "CSV Token Type"::SUBFIELD then
                Result += '"';
        until _token.Type() <> "CSV Token Type"::SUBFIELD;
    end;

    local procedure simple_field() Result: Text
    begin
        Result := _token.Value();
        Eat("CSV Token Type"::FIELD);
    end;

    local procedure empty(): Text
    begin
    end;

    local procedure field(): Text
    begin
        case _token.Type() of
            "CSV Token Type"::SUBFIELD:
                exit(quoted_field());
            "CSV Token Type"::FIELD:
                exit(simple_field());
            else
                empty();
        end;
    end;

    local procedure record() Result: List of [Text]
    begin
        Result.Add(field());

        while _token.Type() = "CSV Token Type"::DELIMITER do begin
            Eat("CSV Token Type"::DELIMITER);
            Result.Add(field());
        end;

        if _token.Type() <> "CSV Token Type"::EOF then
            Eat("CSV Token Type"::NEWLINE);
    end;

    procedure Read(): List of [List of [Text]]
    begin
        while not _token.IsEOF() do
            _result.Add(record());

        exit(_result);
    end;

}