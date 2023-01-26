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
        _header: List of [Text];
        _record: List of [Text];

    procedure Init(Stream: InStream; Delimiter: Char; HasHeader: Boolean)
    begin
        _scanner.Init(Stream, Delimiter);
        _scanner.NextToken(_token);
        Clear(_record);
        Clear(_header);
        if HasHeader and not _token.IsEOF() then
            _header := record();
    end;

    procedure Init(Stream: InStream; Delimiter: Char)
    begin
        Init(Stream, Delimiter, false);
    end;

    procedure Init(Stream: InStream; HasHeader: Boolean)
    begin
        Init(Stream, ',', HasHeader);
    end;

    procedure Init(Stream: InStream)
    begin
        Init(Stream, ',', false);
    end;

    procedure Header(ColumnNumber: Integer): Text
    begin
        exit(_header.Get(ColumnNumber));
    end;

    procedure Header(ColumnNumber: Integer; var Result: Text): Boolean
    begin
        exit(_header.Get(ColumnNumber, Result));
    end;

    procedure Get(ColumnNumber: Integer): Text
    begin
        exit(_record.Get(ColumnNumber));
    end;

    procedure Get(ColumnNumber: Integer; var Result: Text): Boolean
    begin
        exit(_record.Get(ColumnNumber, Result));
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

    local procedure field(): Text
    begin
        case _token.Type() of
            "CSV Token Type"::SUBFIELD:
                exit(quoted_field());
            "CSV Token Type"::FIELD:
                exit(simple_field());
        end;
    end;

    local procedure record() Result: List of [Text]
    begin
        Result.Add(field());

        while _token.Type() = "CSV Token Type"::DELIMITER do begin
            Eat("CSV Token Type"::DELIMITER);
            Result.Add(field());
        end;

        if not _token.IsEOF() then
            Eat("CSV Token Type"::NEWLINE);
    end;

    procedure Read(): Boolean
    begin
        if _token.IsEOF() then
            exit(false);

        _record := record();
        exit(true);
    end;

    procedure Read(var Record: List of [Text]) Result: Boolean
    var
        currField: Text;
    begin
        Result := Read();
        if not Result then
            exit;

        Clear(Record);
        foreach currField in _record do
            Record.Add(currField);
    end;

    procedure Read(var Buffer: Record "CSV Buffer")
    var
        currField: Text;
        lineNo: Integer;
        fieldNo: Integer;
    begin
        Buffer.DeleteAll();
        while Read() do begin
            lineNo += 1;
            fieldNo := 0;
            foreach currField in _record do begin
                fieldNo += 1;
                Buffer.InsertEntry(lineNo, fieldNo, CopyStr(currField, 1, MaxStrLen(Buffer.Value)));
            end;
        end;
    end;

}