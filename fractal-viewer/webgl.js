var VERTEX_SHADER = "";
var FRAGMENT_SHADER = "";
var gl;

var magnitude = 2.0;
var magnitude_attr;

var max_iterations = 30;
var max_iterations_attr;

var origin_real = 0.0;
var origin_real_attr;

var origin_imag = 0.0;
var origin_imag_attr;

var ready = false;

function main() {

    document.onkeydown = keyhandler;

    const vertex_request = new XMLHttpRequest();
    vertex_request.addEventListener("load", vertexListener);
    vertex_request.open("GET", "vertex.glsl");
    vertex_request.send();

}

function vertexListener() {

    VERTEX_SHADER = this.responseText;

    const fragment_request = new XMLHttpRequest();
    fragment_request.addEventListener("load", fragmentListener);
    fragment_request.open("GET", "fragment.glsl");
    fragment_request.send();

}

function fragmentListener() {
    FRAGMENT_SHADER = this.responseText;
    initWebGL();
}

function initWebGL() {
    
    const canvas = document.getElementById('compute-surface');
    gl = getWebGLContext(canvas);

    initShaders(gl, VERTEX_SHADER, FRAGMENT_SHADER);

    const vertices = new Float32Array([
        -1.0,  1.0,
        -1.0, -1.0,
         1.0,  1.0,
         1.0, -1.0
    ]);

    const vertexBuffer = gl.createBuffer();

    gl.bindBuffer(gl.ARRAY_BUFFER, vertexBuffer);
    gl.bufferData(gl.ARRAY_BUFFER, vertices, gl.STATIC_DRAW);

    const position_attr = gl.getAttribLocation(gl.program, "position");

    gl.vertexAttribPointer(position_attr, 2, gl.FLOAT, false, 0, 0);
    gl.enableVertexAttribArray(position_attr);

    magnitude_attr = gl.getUniformLocation(gl.program, 'magnitude');
    origin_real_attr = gl.getUniformLocation(gl.program, 'origin_real');
    origin_imag_attr = gl.getUniformLocation(gl.program, 'origin_imag');
    max_iterations_attr = gl.getUniformLocation(gl.program, 'max_iterations');

    ready = true;

    redraw();

}

function redraw() {

    if (!ready) {
        return;
    }

    gl.uniform1f(magnitude_attr, magnitude);
    gl.uniform1f(origin_real_attr, origin_real);
    gl.uniform1f(origin_imag_attr, origin_imag);
    gl.uniform1i(max_iterations_attr, max_iterations);

    gl.clear(gl.COLOR_BUFFER_BIT);
    gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);

}

function keyhandler(event) {
    
    switch (event.keyCode) {

        case 87: // W
            origin_imag += 0.5 * magnitude;
            redraw();
            break;

        case 83: // S
            origin_imag -= 0.5 * magnitude;
            redraw();
            break;

        case 65: // A
            origin_real -= 0.5 * magnitude;
            redraw();
            break;

        case 68: // D
            origin_real += 0.5 * magnitude;
            redraw();
            break;

        case 74: // J
            max_iterations += 5;
            redraw();
            break;

        case 75:
            max_iterations -= 5;
            redraw();
            break;

        case 187: // +
            magnitude /= 1.5;
            redraw();
            break;

        case 189: // -
            magnitude *= 1.5;
            redraw();
            break;

    }
}