controladdin GridJs
{
    StartupScript = 'src\csv-viewer\gridjs\js\controlStartup.js';
    Scripts = 'src\csv-viewer\gridjs\js\gridjs.umd.js', 'src\csv-viewer\gridjs\js\control.js';
    StyleSheets = 'src\csv-viewer\gridjs\css\mermaid.min.css', 'src\csv-viewer\gridjs\css\control.css';
    HorizontalStretch = true;
    HorizontalShrink = true;
    VerticalStretch = true;
    VerticalShrink = true;
    // MinimumHeight = 400;
    RequestedHeight = 500;
    // RequestedWidth = 1000;

    procedure Render(data: Text)
    procedure Render(data: JsonArray)

    // procedure Render(columns: JsonArray; data: JsonArray)
}