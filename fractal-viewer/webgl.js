const VERTEX_SHADER = `#version 300 es
in vec2 position;
out vec2 frag_position;

void main() {
    gl_Position = vec4(position.x, -position.y, 0, 1);
    frag_position = position;
}`;

var FRAGMENT_SHADER = "";
var gl;

const ESCAPE_TIME = new EscapeTime();
const LYAPUNOV = new Lyapunov();
const ROOT_FINDING = new RootFinding();
const RECURSIVE = new Recursive();
var program = ESCAPE_TIME;

var mouse_down = false;

var magnitude = new Param(2.0);
var centre_x = new Param(0.0);
var centre_y = new Param(0.0);
var samples = new Param(1);

function main() {

    document.getElementById("program").onchange = updateProgram;

    document.onkeydown = keyhandler;

    document.onmousedown = function(_ev) {mouse_down = true};
    document.onmouseup = function(_ev) {mouse_down = false};

    document.getElementById("samples").onchange = updateSamples;

    document.getElementById("fractal_canvas").onclick = onFractalClick;

    ESCAPE_TIME.setupGUI();
    LYAPUNOV.setupGUI();
    ROOT_FINDING.setupGUI();
    RECURSIVE.setupGUI();

    initWebGL();
    loadProgram(ESCAPE_TIME);

}

function loadProgram(prgrm) {

    document.getElementById(program.options_panel).style.display = "none";

    program = prgrm;
    
    const fragment_request = new XMLHttpRequest();
    fragment_request.addEventListener("load", receiveShader);
    fragment_request.open("GET", program.shader);
    fragment_request.send();

    document.getElementById(program.options_panel).style.display = "block";

}

function receiveShader() {
    program.baseShader = this.responseText;
    setupShader();
    resetView();
}

function setupShader() {

    FRAGMENT_SHADER = program.getShader();
    initShaders(gl, VERTEX_SHADER, FRAGMENT_SHADER);

    const position_attr = gl.getAttribLocation(gl.program, "position");

    gl.vertexAttribPointer(position_attr, 2, gl.FLOAT, false, 0, 0);
    gl.enableVertexAttribArray(position_attr);

    magnitude.getAttr("magnitude");
    centre_x.getAttr("centre_x");
    centre_y.getAttr("centre_y");

    samples.getAttr("samples");

    program.setupAttrs();

}

function initWebGL() {
    
    const canvas = document.getElementById("fractal_canvas");
    gl = canvas.getContext("webgl2");

    const vertices = new Float32Array([
        -1.0,  1.0,
        -1.0, -1.0,
         1.0,  1.0,
         1.0, -1.0
    ]);

    const vertexBuffer = gl.createBuffer();

    gl.bindBuffer(gl.ARRAY_BUFFER, vertexBuffer);
    gl.bufferData(gl.ARRAY_BUFFER, vertices, gl.STATIC_DRAW);

}

function redraw() {

    magnitude.loadFloat();
    centre_x.loadFloat();
    centre_y.loadFloat();

    samples.loadInt();

    program.loadAttrs();

    gl.clear(gl.COLOR_BUFFER_BIT);
    gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);

}

function updateProgram() {

    switch (document.getElementById("program").value) {

        case "escape-time":
            loadProgram(ESCAPE_TIME);
            break;

        case "lyapunov":
            loadProgram(LYAPUNOV);
            break;

        case "root-finding":
            loadProgram(ROOT_FINDING);
            break;

        case "recursive":
            loadProgram(RECURSIVE);

    }
}

function updateSamples(event) {
    samples.value = event.target.value;
    redraw();
}

function updateDisplayText() {
    
    var text;
    
    if (program == ESCAPE_TIME || program == ROOT_FINDING) {
        text = `z = ${formatComplex(centre_x.value, centre_y.value)}`;

    } else if (program == LYAPUNOV || program == RECURSIVE) {
        text = `centre = (${centre_x.value.toPrecision(6)}, ${centre_y.value.toPrecision(6)})`;
    }

    document.getElementById("display_text").innerHTML = text + `<br>Zoom = ${(1 / magnitude.value).toPrecision(5)}`;

}

function resetView() {

    magnitude.value = 2.0;

    if (program == LYAPUNOV) {
        centre_x.value = 2.0;
        centre_y.value = -2.0;

    } else if (program == RECURSIVE) {
        centre_x.value = 0.5;
        centre_y.value = -0.5;
        magnitude.value = 0.5;

    } else {
        centre_x.value = 0.0;
        centre_y.value = 0.0;
    }

    updateDisplayText();
    redraw();
}

function keyhandler(event) {
    
    switch (event.keyCode) {
        
        case 82: // R
        resetView();
        break;
        
        case 87: // W
        centre_y.value -= 0.5 * magnitude.value;
        redraw();
        break;
        
        case 83: // S
        centre_y.value += 0.5 * magnitude.value;
        redraw();
        break;

        case 65: // A
        centre_x.value -= 0.5 * magnitude.value;
        redraw();
        break;

        case 68: // D
        centre_x.value += 0.5 * magnitude.value;
        redraw();
        break;
        
        case 187: // +
        magnitude.value /= 1.5;
        redraw();
        break;

        case 189: // -
            magnitude.value *= 1.5;
            redraw();
            break;
            
    }
    
    updateDisplayText();

}

function onFractalClick(event) {
    centre_x.value += (event.x - 500) / 500 * magnitude.value;
    centre_y.value += (event.y - 500) / 500 * magnitude.value;
    redraw();
}