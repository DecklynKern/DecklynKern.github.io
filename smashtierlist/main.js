// don't look here this is all bad
function allowDrop(ev) {
  ev.preventDefault();
}

function drag(ev) {
  ev.dataTransfer.setData("text", ev.target.parentElement.id);
}

function drop(ev) {

  ev.preventDefault();
  var data = ev.dataTransfer.getData("text");

  if(ev.target.parentElement.className == "imagelistelem") {
  	ev.target.parentElement.parentElement.insertBefore(document.getElementById(data), ev.target.parentElement);

  } else if (ev.target.tagName == "DIV" && (ev.target.className == "tierslot" || ev.target.className == "imagelist")) {
  	ev.target.children[0].appendChild(document.getElementById(data));
  
  } else if (ev.target.tagName == "UL" && ev.target.className == "tierlist") {
  	ev.target.appendChild(document.getElementById(data));
  }
}

function addRow(text, color) {

	tableBody = document.getElementById("tiertable");
	row = document.createElement("div");
	row.className = "tierrow";

	if(tableBody.children.length == 1) {
		tier = 1;

	} else {
		tier = tableBody.children[tableBody.children.length - 1].id.slice(4) - 0 + 1;
	
	}
	row.id = "tier" + tier;

	row.innerHTML = `
		<div class="tiertitle" onclick="setCurrentTier('` + tier + `')">
			` + text + `
		</div>
		<div class="tierslot" ondrop="drop(event)" ondragover="allowDrop(event)" onclick="setCurrentTier('` + tier + `')">
			<ul class="tierlist">
			</ul>
		</div>`;

	row.children[0].style.backgroundColor = color;
	tableBody.appendChild(row);
}

function deleteRow() {

	tier = document.getElementById("tier" + document.getElementById("currenttier").value);

	for(i=0; i < tier.children[1].children[0].children.length; i++) {
		document.getElementById("createdimagelist").children[0].appendChild(tier.children[1].children[0].children[i]);
	}

	document.getElementById("tiertable").removeChild(tier);

}

function setCurrentTier(tier) {

	document.getElementById("edittiertext").innerHTML = "Edit tier"

	oldTier = document.getElementById("currenttier").value;

	if(oldTier != "0") {
		try{
			document.getElementById("tier" + oldTier).children[1].style.backgroundColor = "#444";
		} catch {
		}
	}

	if(oldTier != tier) {
		document.getElementById("currenttier").value = tier;
		document.getElementById("tier" + tier).children[1].style.backgroundColor = "#555";

	} else {
		document.getElementById("currenttier").value = "0";
	}
}

function setColour(color) {
	document.getElementById("tier" + document.getElementById("currenttier").value).children[0].style.backgroundColor = color;
}

function createImage() {
	
	tag = document.getElementById("tagentry").value;
	char = document.getElementById("charentry").value.trim().toLowerCase().replace(" ", "").replace(".", "").replace("/", "").replace("-", "");
	addImage(0, tag, char);
}

function addImage(tier, tag, char) {

	aliassedChar = aliasMap.get(char);

	if(aliassedChar != undefined) {
		char = aliassedChar;
	}

	if(characterNames.includes(char)) {

		document.getElementById("tagentry").value = "";
		document.getElementById("charentry").value = "";

		img = document.createElement("li");
		path = "char images\\" + char + ".png";
		img.id = tag + Math.random();
		img.className = "imagelistelem"

		img.innerHTML = `
			<img class="char-image" src = "` + path + `" draggable="true" ondragstart="drag(event)" onmouseover="setDeleteButtonVisibility(this, true)" onmouseout="setDeleteButtonVisibility(this, false)">
			<img class="deleteimagebutton" src="deletebutton.png" onclick="deleteImage(this)" onmouseover="setDeleteButtonVisibility(this, true)">
			<p class="tagtext">` + tag + `</p>`

		if(tier == 0){
			document.getElementById("createdimagelist").children[0].appendChild(img);

		} else {
			document.getElementById("tier" + tier).children[1].children[0].appendChild(img);

		}
	}
}

function setDeleteButtonVisibility(img, visible) {
	if(visible) {
		img.parentElement.children[1].style.visibility = "visible";
	} else {
		img.parentElement.children[1].style.visibility = "hidden";
	}
}

function deleteImage(button) {
	button.parentElement.remove();
}

function loadParams() {

	obj = JSON.parse(atob(new URLSearchParams(window.location.search).get("d")));

	for(i = 0; i < obj["rows"].length; i++) {

		r = obj["rows"][i];
		rowTitle = r[0];
		color = r[1];

		if(i == document.getElementById("tiertable").children.length - 1) {
			addRow(rowTitle, color);
			tierRow = document.getElementById("tiertable").children[i + 1];

		} else {
			tierRow = document.getElementById("tiertable").children[i + 1];
			tierRow.children[0].style.backgroundColor = color
			tierRow.children[0].innerHTML = rowTitle;
		}

		for(j = 0; j < r[2].length; j++) {
			addImage(i + 1, r[2][j][0], r[2][j][1]);
		}
	}
}

function createLink() {

	url = window.location.href.split("?")[0];
	obj = {"rows": []};

	for(i = 1; i < document.getElementById("tiertable").children.length; i++) {

		row = document.getElementById("tiertable").children[i];
		rowTitle = row.children[0].innerHTML.trim();

		obj["rows"].push([rowTitle, row.children[0].style.backgroundColor, []]);

		for(j = 0; j < row.children[1].children[0].children.length; j++) {
			image = row.children[1].children[0].children[j];
			tag = image.children[2].innerHTML;
			imgUrl = image.children[0].src.split("/");
			char = imgUrl[imgUrl.length - 1].split(".")[0];
			obj["rows"][i - 1][2].push([tag, char]);
		}
	}

	string = btoa(JSON.stringify(obj));

	document.getElementById("linkbox").innerHTML = url + "?d=" + string;
}