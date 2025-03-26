page 50100 "CSV Viewer"
{
    Caption = 'CSV Viewer';
    PageType = ListPlus;
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            usercontrol(GridJS; GridJS)
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Upload)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Image = ImportDatabase;
                Caption = 'Upload';
                ToolTip = 'Upload a .csv file to view its contents.';

                trigger OnAction()
                var
                    Csv: Codeunit "CSV Reader";
                    Stream: InStream;
                    FileName: Text;
                    currRecord: List of [Text];
                    Cloumns: JsonArray;
                    Data: JsonArray;
                    Row: JsonArray;
                    currField, textData : Text;
                begin
                    if not UploadIntoStream('', '', '', FileName, Stream) then
                        exit;

                    Csv.Init(Stream);

                    // if Reader.Read(currRecord) then
                    //     foreach currField in currRecord do
                    //         Cloumns.Add(currField);

                    while Csv.Read(currRecord) do begin
                        Clear(Row);
                        foreach currField in currRecord do
                            Row.Add(currField);
                        Data.Add(Row);
                    end;

                    // Cloumns.Add('1');
                    // Cloumns.Add('2');

                    // Row.Add('1');
                    // Row.Add('2');
                    // Data.Add(Row);

                    Data.WriteTo(textData);
                    CurrPage.GridJS.Render(textData);

                    // CurrPage.GridJS.Render(Data);
                end;
            }
        }
    }
    var
        foo: Integer;
}