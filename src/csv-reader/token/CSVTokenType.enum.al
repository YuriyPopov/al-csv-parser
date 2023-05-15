enum 50101 "CSV Token Type"
{
    Extensible = false;

    value(0; EOF) { }
    value(10; NEWLINE) { }
    value(20; DELIMITER) { }
    value(30; FIELD) { }
    value(40; SUBFIELD) { }
}