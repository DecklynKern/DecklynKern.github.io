function allowDrop(ev) { // don't look here this is all bad
  ev.preventDefault();
}

function drag(ev) {
  ev.dataTransfer.setData("text", ev.target.id);
}

function drop(ev) {
  ev.preventDefault();
  var data = ev.dataTransfer.getData("text");

  if(ev.target.tagName == "IMG") {
  	ev.target.parentElement.parentElement.insertBefore(document.getElementById(data), ev.target.parentElement);
  } else {
  	ev.target.children[0].appendChild(document.getElementById(data));
  }
}

function addRow(text, color) {

	tableBody = document.getElementById("tiertable").tBodies[0];
	row = document.createElement("tr");
	row.className = "tierrow";
	tier = tableBody.children.length;
	row.id = "tier" + tier;

	row.innerHTML = `
		<td class="tiertitle" bgcolor="` + color + `" onclick="setCurrentTier('` + tier + `')">
			` + text + `
		</td>
		<td class="tierslot" ondrop="drop(event)" ondragover="allowDrop(event)">
			<ul class="tierlist">
			</ul>
		</td>
	`;
	tableBody.appendChild(row);

}

function addImage(row, src) {

	img = document.createElement("li");
	img.id = src;
	img.innerHTML = `<img id="` + src + `" class="char-image" src = "` + src + `" draggable="true" ondragstart="drag(event)">`
	document.getElementById("tier" + row).children[1].children[0].appendChild(img);
}

function setCurrentTier(tier) {

	oldTier = document.getElementById("currenttier").value;

	if(oldTier != "0") {
		document.getElementById("tier" + oldTier).children[1].style.backgroundColor = "#444";
	}

	if(oldTier != tier) {
		document.getElementById("currenttier").value = tier;
		document.getElementById("tier" + tier).children[1].style.backgroundColor = "#555";
		document.getElementById("nameentry").value = document.getElementById("tier" + tier).children[0].innerHTML.trim();

	} else {
		document.getElementById("currenttier").value = "0";
	}
}

function setText() {
	tier = document.getElementById("currenttier").value;
	document.getElementById("tier" + tier).children[0].innerHTML = document.getElementById("nameentry").value;
}

function setColour(color) {
	document.getElementById("tier" + document.getElementById("currenttier").value).children[0].style.backgroundColor = color;
}