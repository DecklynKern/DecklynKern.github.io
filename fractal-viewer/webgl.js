var VERTEX_SHADER = `
attribute vec2 position;
varying vec2 frag_position;

void main() {
    gl_Position = vec4(position.x, -position.y, 0, 1);
    frag_position = position;
}`;

var FRAGMENT_SHADER = "";
var gl;

var ESCAPE_TIME = new EscapeTime();
var LYAPUNOV = new Lyapunov();
var NEWTON = new Newton();
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
    NEWTON.setupGUI();

    initWebGL();
    loadProgram(ESCAPE_TIME);

}

function loadProgram(prgrm) {

    document.getElementById(program.options_panel).style.display = "none";

    program = prgrm;
    
    const fragment_request = new XMLHttpRequest();
    fragment_request.addEventListener("load", setupShader);
    fragment_request.open("GET", program.shader);
    fragment_request.send();

    document.getElementById(program.options_panel).style.display = "block";

}

function setupShader() {

    FRAGMENT_SHADER = this.responseText;
    initShaders(gl, VERTEX_SHADER, FRAGMENT_SHADER);

    const position_attr = gl.getAttribLocation(gl.program, "position");

    gl.vertexAttribPointer(position_attr, 2, gl.FLOAT, false, 0, 0);
    gl.enableVertexAttribArray(position_attr);

    magnitude.attr = gl.getUniformLocation(gl.program, "magnitude");
    centre_x.attr = gl.getUniformLocation(gl.program, "centre_x");
    centre_y.attr = gl.getUniformLocation(gl.program, "centre_y");

    samples.attr = gl.getUniformLocation(gl.program, "samples");

    program.setupAttrs();

    resetView();

}

function initWebGL() {
    
    const canvas = document.getElementById("fractal_canvas");
    gl = getWebGLContext(canvas);

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

        case "newton":
            loadProgram(NEWTON);

    }
}

function updateSamples(_ev) {
    samples.value = document.getElementById("samples").value;
    redraw();
}

function resetView() {

    magnitude.value = 2.0;

    if (program == LYAPUNOV) {
        centre_x.value = 2.0;
        centre_y.value = -2.0;

    } else {
        centre_x.value = 0.0;
        centre_y.value = 0.0;
    }

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
}

function onFractalClick(event) {
    centre_x.value += (event.x - 500) / 500 * magnitude.value;
    centre_y.value += (event.y - 500) / 500 * magnitude.value;
    redraw();
}