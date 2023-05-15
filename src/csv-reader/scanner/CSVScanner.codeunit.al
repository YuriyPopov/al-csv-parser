codeunit 50101 "CSV Scanner"
{
    var
        _stream: codeunit DotNet_Stream;
        _reader: Codeunit DotNet_BinaryReader;
        _delimiter: Char;
        _currChar: Char;
        _nextChar: Char;

    local procedure EOS(): Boolean
    begin
        exit(_stream.Position() = _stream.Length());
    end;

    local procedure Advance(): Boolean
    begin
        if EOS() then begin
            _currChar := _nextChar;
            _nextChar := 0;
            exit(_currChar = 0);
        end;

        if _nextChar = 0 then
            _currChar := _reader.ReadChar()
        else
            _currChar := _nextChar;

        if not EOS() then
            _nextChar := _reader.ReadChar();

        exit(true);
    end;

    local procedure Skip(var Token: Codeunit "CSV Token"): Boolean
    begin
        Advance();
        exit(NextToken(Token));
    end;

    local procedure InitToken(Type: Enum "CSV Token Type"; var Token: Codeunit "CSV Token"): Boolean
    begin
        Token.Init(Type);
        exit(true);
    end;

    local procedure InitToken(Type: Enum "CSV Token Type"; Value: Text; var Token: Codeunit "CSV Token"): Boolean
    begin
        Token.Init(Type, Value);
        exit(true);
    end;

    local procedure EndOfFile(var Token: Codeunit "CSV Token"): Boolean
    begin
        Token.Init("CSV Token Type"::EOF);
    end;

    local procedure NewLine(var Token: Codeunit "CSV Token"): Boolean
    begin
        Advance();
        exit(InitToken("CSV Token Type"::NEWLINE, Token));
    end;

    local procedure Delimiter(var Token: Codeunit "CSV Token"): Boolean
    begin
        Advance();
        exit(InitToken("CSV Token Type"::DELIMITER, Token))
    end;

    local procedure Subfield(var Token: Codeunit "CSV Token"): Boolean
    var
        CurrToken: Text;
    begin
        Advance();

        while not (_currChar in [0, 34]) do begin
            CurrToken += _currChar;
            Advance();
        end;

        if _currChar = 34 then
            Advance()
        else
            exit(InitToken("CSV Token Type"::FIELD, '"' + CurrToken, Token));

        exit(InitToken("CSV Token Type"::SUBFIELD, CurrToken, Token));
    end;

    local procedure Field(var Token: Codeunit "CSV Token"): Boolean
    var
        CurrToken: Text;
    begin
        while not (_currChar in [_delimiter, 0, 10, 13]) do begin
            CurrToken += _currChar;
            Advance();
        end;

        exit(InitToken("CSV Token Type"::FIELD, CurrToken, Token));
    end;

    procedure NextToken(var Token: Codeunit "CSV Token"): Boolean
    begin
        case _currChar of
            0:
                exit(EndOfFile(Token));
            _delimiter:
                exit(Delimiter(Token));
            10:
                exit(NewLine(Token));
            13:
                if _nextChar = 10 then begin
                    Advance();
                    exit(NewLine(Token))
                end else
                    Skip(Token);
            34:
                exit(Subfield(Token));
            else
                exit(Field(Token));
        end;
    end;

    procedure Init(Stream: InStream; Delimiter: Char)
    begin
        _stream.FromInStream(Stream);
        _reader.BinaryReader(_stream);
        _delimiter := Delimiter;
        _currChar := 0;
        _nextChar := 0;
        Advance();
    end;
}