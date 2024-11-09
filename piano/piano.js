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

const QUALITY_OFFSETS = {
    "major": [0, 4, 7],
    "minor": [0, 3, 7],
    "augmented": [0, 4, 8],
    "diminished": [0, 3, 6],
    "sus2": [0, 2, 7],
    "sus4": [0, 5, 7]
};

const ROOT_NAMES = {
    "c": "C",
    "c_sharp": "C#",
    "d": "D",
    "d_sharp": "D#",
    "e": "E",
    "f": "F",
    "f_sharp": "F#",
    "g": "G",
    "g_sharp": "G#",
    "a": "A",
    "a_sharp": "A#",
    "b": "B",
    "b_sharp": "B#"
};

const QUALITY_NAMES = {
    "major": "",
    "minor": "m",
    "augmented": "aug",
    "diminished": "dim",
    "sus2": "sus2",
    "sus4": "sus4"
}

function reload() {

    const chordRoot = document.querySelector("input[name='note']:checked").value;
    const chordQuality = document.querySelector("input[name='quality']:checked").value;
    
    const heldKeys = QUALITY_OFFSETS[chordQuality].map(offset => KEY_INDEXES[chordRoot] + offset);

    var chordName = ROOT_NAMES[chordRoot] + QUALITY_NAMES[chordQuality];

    document.getElementById("chord_name").innerText = chordName;

    drawKeys(heldKeys);
    
}

function drawKeys(heldKeys) {

    CANVAS_CONTEXT.fillStyle = "rgba(0, 0, 0, 0)";
    CANVAS_CONTEXT.fillRect(0, 0, CANVAS.width, CANVAS.height);

    const keyWidth = CANVAS.width / 14;

    for (var key = 0; key < 14; key++) {

        if (heldKeys.includes(WHITE_KEY_INDEXES[key])) {
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

        if (heldKeys.includes(BLACK_KEY_INDEXES[sharp])) {
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

document.querySelectorAll("input[type='radio']").forEach(button => {
    button.onchange = reload;
});

reload()