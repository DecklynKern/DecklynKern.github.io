function addPerson() {

    var name = document.createElement("div");
    name.className = "namerow";

    name.innerHTML = `
        <div class="name">
            new person
        </div>
        <button onClick=deleteName(this)>
            X
        </button>
    `

    document.getElementById("namelist").appendChild(name);

}

function deleteName(button) {
    button.parentElement.remove();
}

function generateGroups() {
    var table = document.getElementById("nametable");
    table.remove();
    table = document.createElement("table");
    table.id = "nametable";

    var headerRow = table.insertRow();

    var numGroups = document.getElementById("groupnum").value;

    for (i = 0; i < numGroups; i++) {
        var header = headerRow.insertCell(i);
        header.innerHTML = "Group " + (i + 1);
        header.className = "tableheader";
    }
    headerRow.insertCell(numGroups);

    var names = [];
    var namelist = document.getElementById("namelist");

    for (i = 0; i < namelist.childElementCount; i++) {
        names.push(namelist.children[i].children[0].innerHTML);
    }

    while (names.length % numGroups > 0) {
        names.push("");
    }

    var col = 0;

    for (i = 0; i < names.length; i++) {
        if (col == 0) {
            try{
                row.insertCell(numGroups);
            } catch {}
            var row = table.insertRow();
        }
        row.insertCell(col).innerHTML = names[i];
        col += 1;
        col %= numGroups;
    }

    row.insertCell(numGroups);

    document.getElementById("mainpage").appendChild(table);
}