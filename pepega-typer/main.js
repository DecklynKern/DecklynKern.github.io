function generate() {

    var inputChars = document.getElementById("entry").value;

    if (document.getElementById("is-wide").checked) {
        prefix = "wide";
    }
    else {
        prefix = "";
    }
    
    var pepegaList = document.getElementById("pepega-list");
    pepegaList.innerHTML = "";

    var ps = 0;
    var es = 0;

    for (var c = inputChars.length - 1; c >= 0; c--) {

        switch (inputChars[c]) {
            case 'p':
                if (ps % 2 == 1) {
                    img = "0";
                }
                else {
                    img = "2";
                }
                ps += 1;
                break;
            case 'e':
                if (es % 2 == 1) {
                    img = "1";
                }
                else {
                    img = "3";
                }
                es += 1;
                break;
            case 'g':
                img = "4";
                break;
            case 'a':
                img = "5";
                break;
            case ' ':
                img = "6";
                break;
            default:
                continue;
        }

        image = document.createElement("img");
        image.src = "images\\" + prefix + img + ".png"

        pepegaList.insertBefore(image, pepegaList.firstElementChild);

    }

    html2canvas(pepegaList, {backgroundColor:null}).then(canvas => {
        pepegaList.innerHTML = "";
        pepegaList.appendChild(canvas);
    });

}