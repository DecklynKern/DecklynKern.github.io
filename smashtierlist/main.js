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
		tier = document.getElementById("tier" + tier);
		tier.children[1].style.backgroundColor = "#555";
		document.getElementById("colorselector").value = "#" + colourToHex(tier.children[0].style.backgroundColor);

	} else {
		document.getElementById("currenttier").value = "0";
	}
}

function setColour(color) {
	document.getElementById("tier" + document.getElementById("currenttier").value).children[0].style.backgroundColor = color;
	hex = colourToHex(color);
	if(hex.startsWith("#")){
		document.getElementById("colorselector").value = hex;
	} else{
		document.getElementById("colorselector").value = "#" + hex;
	}
}

function createImage() {
	
	tag = document.getElementById("tagentry").value;
	char = document.getElementById("charentry").value.trim().toLowerCase().replaceAll(" ", "").replaceAll("&", "and").replaceAll(".", "").replaceAll("/", "").replaceAll("-", "");
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
			<img class="deleteimagebutton" src="deletebutton.png" onclick="deleteImage(this)" onmouseover="setDeleteButtonVisibility(this, true)" onmouseout="setDeleteButtonVisibility(this, false)">
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

function colourToHex(rgb) {

	split = rgb.split(",");

	if(split.length == 1){
		return split[0];

	} else{
		
		r = parseInt(split[0].split("(")[1]).toString(16);
		g = parseInt(split[1]).toString(16);
		b = parseInt(split[2].split(")")[0]).toString(16);

		if(r.length == 1) {r = "0" + r};
		if(g.length == 1) {g = "0" + g};
		if(b.length == 1) {b = "0" + b};

		return r + g + b;
	}
}

function loadParams() {

	obj = JSON.parse(atob(new URLSearchParams(window.location.search).get("d")));

	for(i = 0; i < obj[0].length; i++) {
		addImage(0, obj[0][i][0], characterNames[obj[0][i][1]]);
	}

	for(i = 1; i < obj.length; i++) {

		r = obj[i];
		rowTitle = r[0];
		color = r[1];

		if(i == document.getElementById("tiertable").children.length) {
			addRow(rowTitle, color);
			tierRow = document.getElementById("tiertable").children[i];

		} else {
			tierRow = document.getElementById("tiertable").children[i];
			tierRow.children[0].style.backgroundColor = color;
			tierRow.children[0].style.backgroundColor = "#" + color;
			tierRow.children[0].innerHTML = rowTitle;
		}

		for(j = 0; j < r[2].length; j++) {
			addImage(i, r[2][j][0], characterNames[r[2][j][1]]);
		}
	}
}

function createLink() {

	url = window.location.href.split("?")[0];
	obj = [[]];

	sidelist = document.getElementById("createdimagelist").children[0];

	for(i = 0; i < sidelist.children.length; i++) {
		image = sidelist.children[i];
		tag = image.children[2].innerHTML;
		imgUrl = image.children[0].src.split("/");
		char = characterNames.indexOf(imgUrl[imgUrl.length - 1].split(".")[0]);
		obj[0].push([tag, char]);
	}

	for(i = 1; i < document.getElementById("tiertable").children.length; i++) {

		row = document.getElementById("tiertable").children[i];
		rowTitle = row.children[0].innerHTML.trim();

		obj.push([rowTitle, colourToHex(row.children[0].style.backgroundColor), []]);

		for(j = 0; j < row.children[1].children[0].children.length; j++) {
			image = row.children[1].children[0].children[j];
			tag = image.children[2].innerHTML;
			imgUrl = image.children[0].src.split("/");
			char = characterNames.indexOf(imgUrl[imgUrl.length - 1].split(".")[0]);
			obj[i][2].push([tag, char]);
		}
	}

	string = btoa(JSON.stringify(obj)).replaceAll("=", "");
	console.log(JSON.stringify(obj));

	document.getElementById("linkbox").innerHTML = url + "?d=" + string;
}