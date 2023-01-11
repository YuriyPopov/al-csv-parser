codeunit 50101 "CSV Scanner"
{
    var
        _stream: InStream;
        _delimiter: Char;
        _scope: Char;
        _currChar: Char;
        _nextChar: Char;

    local procedure Advance(): Boolean
    begin
        if _stream.EOS() then begin
            _currChar := _nextChar;
            _nextChar := 0;
            exit(_currChar = 0);
        end;

        if _nextChar = 0 then
            _stream.Read(_currChar)
        else
            _currChar := _nextChar;

        if not _stream.EOS() then
            _stream.Read(_nextChar);

        exit(true);
    end;

    local procedure EOS(var Token: Codeunit "CSV Token"): Boolean
    begin
        Token.Init("CSV Token Type"::EOS);
    end;

    local procedure NewLine(var Token: Codeunit "CSV Token"): Boolean
    begin
        Token.Init("CSV Token Type"::NewLine);
        Advance();
        exit(true);
    end;

    local procedure Skip(var Token: Codeunit "CSV Token"): Boolean
    begin
        Advance();
        exit(NextToken(Token));
    end;

    local procedure Delimiter(var Token: Codeunit "CSV Token"): Boolean
    begin
        Token.Init("CSV Token Type"::Delimiter);
        Advance();
        exit(true)
    end;

    local procedure Scope(var Token: Codeunit "CSV Token"): Boolean
    var
        CurrToken: Text;
    begin
        Advance();
        while (_currChar <> _scope) and not (_currChar in [0, 10, 13]) do begin
            CurrToken += _currChar;
            Advance();
        end;

        if _currChar = _scope then
            Advance();

        Token.Init("CSV Token Type"::Scope, CurrToken);
        exit(true);
    end;

    local procedure Value(var Token: Codeunit "CSV Token"): Boolean
    var
        CurrToken: Text;
    begin
        while not (_currChar in [_delimiter, 0, 10, 13]) do begin
            CurrToken += _currChar;
            Advance();
        end;

        Token.Init("CSV Token Type"::Value, CurrToken);
        exit(true);
    end;

    procedure NextToken(var Token: Codeunit "CSV Token"): Boolean
    begin
        case _currChar of
            0:
                exit(EOS(Token));
            10:
                exit(NewLine(Token));
            13, 32:
                exit(Skip(Token));
            _delimiter:
                exit(Delimiter(Token));
            _scope:
                exit(Scope(Token))
            else
                exit(Value(Token));
        end;
    end;

    procedure Init(Stream: InStream; Delimiter: Char; Scope: Char)
    begin
        _stream := Stream;
        _delimiter := Delimiter;
        _scope := Scope;
        _currChar := 0;
        _nextChar := 0;
        Advance();
    end;
}