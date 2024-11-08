const CANVAS = document.getElementById("canvas");
const CANVAS_CONTEXT = CANVAS.getContext("2d");

const WHITE_KEY_INDEXES = [0, 2, 4, 5, 7, 9, 11, 12, 14, 16, 17, 19, 21];
const BLACK_KEY_INDEXES = [1, 3, -1, 6, 8, 10, -1, 13, 15, -1, 18, 20];

const KEY_INDEXES = {
    "c": 0,
    "c_sharp": 1,
    "d": 2,
    "d_sharp": 3,
    "e": 4,
    "f": 5,
    "f_sharp": 6,
    "g": 7,
    "g_sharp": 8,
    "a": 9,
    "a_sharp": 10,
    "b": 11,
    "b_sharp": 12
};

function reload() {

    const chordRoot = KEY_INDEXES[document.querySelector('input[name="note"]:checked').value];

    const selectedKeys = [chordRoot, chordRoot + 4, chordRoot + 7];

    CANVAS_CONTEXT.fillStyle = "rgba(0, 0, 0, 0)";
    CANVAS_CONTEXT.fillRect(0, 0, CANVAS.width, CANVAS.height);

    const keyWidth = CANVAS.width / 14;

    for (var key = 0; key < 14; key++) {

        if (selectedKeys.includes(WHITE_KEY_INDEXES[key])) {
            CANVAS_CONTEXT.fillStyle = "red";
        }
        else {
            CANVAS_CONTEXT.fillStyle = "white";
        }
        
        CANVAS_CONTEXT.strokeStyle = "black";
        CANVAS_CONTEXT.lineWidth = 3;

        const rect = [key * keyWidth + 3, 3, keyWidth, CANVAS.height];

        CANVAS_CONTEXT.strokeRect(...rect);
        CANVAS_CONTEXT.fillRect(...rect);

    }

    for (var sharp = 0; sharp < 14; sharp++) {

        if (sharp % 7 == 2 || sharp % 7 == 6) { 
            continue;
        }

        if (selectedKeys.includes(BLACK_KEY_INDEXES[sharp])) {
            CANVAS_CONTEXT.fillStyle = "red";
        }
        else {
            CANVAS_CONTEXT.fillStyle = "black";
        }
        
        const rect = [sharp * keyWidth + keyWidth * 5 / 6, 0, keyWidth / 2, CANVAS.height * 3 / 4];
        
        CANVAS_CONTEXT.strokeRect(...rect);
        CANVAS_CONTEXT.fillRect(...rect);

    }
}

reload()