codeunit 50100 "CSV Reader"
{
    // start: line*
    // line: cell (DELIMITER cell)* NEWLINE
    // cell: scope+ | value
    // scope: SCOPE
    // value: VALUE

    var
        _scanner: Codeunit "CSV Scanner";
        _token: Codeunit "CSV Token";
        _result: List of [List of [Text]];

    procedure Init(Stream: InStream; Delimiter: Char)
    begin
        _scanner.Init(Stream, Delimiter, '"');
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

    local procedure value() Value: Text
    begin
        Value += _token.Value();
        Eat("CSV Token Type"::Value);
    end;

    local procedure scope() Value: Text
    begin
        repeat
            Value += _token.Value();
            Eat("CSV Token Type"::Scope);
            if _token.IsScope() then
                Value += '"';
        until not _token.IsScope();
    end;

    local procedure cell(): Text
    begin
        if _token.IsScope() then
            exit(scope())
        else
            exit(value());
    end;

    local procedure line() Line: List of [Text];
    begin
        Line.Add(cell());

        while _token.IsDelimiter() do begin
            Eat("CSV Token Type"::Delimiter);
            Line.Add(cell());
        end;

        if not _token.IsEOS() then
            Eat("CSV Token Type"::NewLine);
    end;

    procedure Read(): List of [List of [Text]];
    begin
        while not _token.IsEOS() do
            _result.Add(line());
        exit(_result);
    end;

}