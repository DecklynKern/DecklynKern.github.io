function addPerson() {

    var name = document.createElement("div");

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
        headerRow.insertCell(i).innerHTML = "Group " + (i + 1);
    }

    var names = [];

    var namelist = document.getElementById("namelist");

    for (i = 0; i < namelist.childElementCount; i++) {
        names.push(namelist.children[i].children[0].innerHTML);
    }

    var col = 0;

    for (i = 0; i < names.length; i++) {
        if (col == 0) {
            var row = table.insertRow();
        }
        row.insertCell(col).innerHTML = names[i];
        col += 1;
        col %= numGroups;
    }

    document.getElementById("mainpage").appendChild(table);
}