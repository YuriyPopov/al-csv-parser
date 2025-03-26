function Render(data) {

    const d = JSON.parse(data);

    const paginationConfig = {
        limit: 50,

    };

    const el = document.getElementById("controlAddIn");
    const config = {
        resizable: true,
        autoWidth: true,
        sort: true,
        pagination: false,
        fixedHeader: true,
        search: true,
        columns: d.shift(),
        data: d       
    };

    if (el.childNodes.length === 0) {
        grid.updateConfig(config).render(el);
    }
    else {
        grid.updateConfig(config).forceRender();
    }
}

const grid = new gridjs.Grid();