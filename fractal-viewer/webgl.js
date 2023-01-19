var VERTEX_SHADER = "";
var FRAGMENT_SHADER = "";
var gl;

var mouse_down = false;
var ready = false;

class Param {
    constructor(value) {
        this.value = value;
        this.attr = null;
    }
}

var fractal_type = new Param(0);
var fractal_param = new Param(2.0);
var max_iterations = new Param(30);
var escape_radius = new Param(2.0);

var is_julia = new Param(0);
var julia_c_real = new Param(0.0);
var julia_c_imag = new Param(0.0);

var magnitude = new Param(2.0);
var origin_real = new Param(0.0);
var origin_imag = new Param(0.0);

var colouring_type = new Param(0);
var trapped_colour = new Param([0.0, 0.0, 0.0]);
var close_colour = new Param([0.0, 0.0, 1.0]);
var far_colour = new Param([0.0, 0.0, 0.0]);

var julia_canvas_context;

function main() {

    document.onkeydown = keyhandler;

    document.onmousedown = function(_ev) {mouse_down = true};
    document.onmouseup = function(_ev) {mouse_down = false};

    document.getElementById("fractal_type").onchange = updateFractalType;
    document.getElementById("scaling").onchange = updateScaling;
    document.getElementById("exponent").onchange = updateExponent;

    document.getElementById("is_julia").onchange = updateIsJulia;  
    document.getElementById("julia_selector").onmousemove = updateJuliaCoord;

    document.getElementById("colouring_type").onchange = updateColouringType;
    document.getElementById("max_iterations").onchange = updateMaxIterations;
    document.getElementById("escape_radius").onchange = updateEscapeRadius;

    document.getElementById("trapped_colour").onchange = updateTrappedColour;
    document.getElementById("close_colour").onchange = updateCloseColour;
    document.getElementById("far_colour").onchange = updateFarColour;

    julia_canvas_context = document.getElementById("julia_selector").getContext("2d");
    julia_canvas_context.fillStyle = "black";
    julia_canvas_context.beginPath();
    julia_canvas_context.arc(50, 50, 4, 0, 2 * Math.PI);
    julia_canvas_context.stroke();

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
    
    const canvas = document.getElementById("compute-surface");
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

    fractal_type.attr = gl.getUniformLocation(gl.program, "fractal_type");
    fractal_param.attr = gl.getUniformLocation(gl.program, "fractal_param");
    max_iterations.attr = gl.getUniformLocation(gl.program, "max_iterations");
    escape_radius.attr = gl.getUniformLocation(gl.program, "escape_radius_sq");
    
    magnitude.attr = gl.getUniformLocation(gl.program, "magnitude");
    origin_real.attr = gl.getUniformLocation(gl.program, "origin_real");
    origin_imag.attr = gl.getUniformLocation(gl.program, "origin_imag");
    
    is_julia.attr = gl.getUniformLocation(gl.program, "is_julia");
    julia_c_real.attr = gl.getUniformLocation(gl.program, "julia_c_real");
    julia_c_imag.attr = gl.getUniformLocation(gl.program, "julia_c_imag");
    
    colouring_type.attr = gl.getUniformLocation(gl.program, "colouring_type");
    trapped_colour.attr = gl.getUniformLocation(gl.program, "trapped_colour");
    close_colour.attr = gl.getUniformLocation(gl.program, "close_colour");
    far_colour.attr = gl.getUniformLocation(gl.program, "far_colour");

    ready = true;

    redraw();

}

function redraw() {

    if (!ready) {
        return;
    }

    gl.uniform1i(fractal_type.attr, fractal_type.value);
    gl.uniform1f(fractal_param.attr, fractal_param.value);
    gl.uniform1i(max_iterations.attr, max_iterations.value);
    gl.uniform1f(escape_radius.attr, escape_radius.value * escape_radius.value);
    
    gl.uniform1f(magnitude.attr, magnitude.value);
    gl.uniform1f(origin_real.attr, origin_real.value);
    gl.uniform1f(origin_imag.attr, origin_imag.value);
    
    gl.uniform1i(is_julia.attr, is_julia.value);
    gl.uniform1f(julia_c_real.attr, julia_c_real.value);
    gl.uniform1f(julia_c_imag.attr, julia_c_imag.value);
    
    gl.uniform1i(colouring_type.attr, colouring_type.value);
    gl.uniform3f(trapped_colour.attr, ...trapped_colour.value);
    gl.uniform3f(close_colour.attr, ...close_colour.value);
    gl.uniform3f(far_colour.attr, ...far_colour.value);

    gl.clear(gl.COLOR_BUFFER_BIT);
    gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);

}

function updateFractalType(_ev) {

    fractal_type.value = document.getElementById("fractal_type").value;

    scaling_style = document.getElementById("scaling_div").style;
    exponent_style = document.getElementById("exponent_div").style;

    scaling_style.display = "none";
    exponent_style.display = "none";

    if (fractal_type.value == 4) {
        scaling_style.display = "block";

    } else if (fractal_type.value == 5) {
        exponent_style.display = "block";
    }
    
    redraw();

}

function updateScaling(_ev) {
    fractal_param.value = document.getElementById("scaling").value;
    redraw();
}

function updateExponent(_ev) {
    fractal_param.value = document.getElementById("exponent").value;
    redraw();
}

function updateIsJulia(_ev) {

    is_julia.value = +document.getElementById("is_julia").checked;
    
    if (is_julia.value) {
        document.getElementById("julia_options").style.display = "block";
    
    } else {
        document.getElementById("julia_options").style.display = "none";
    }
    
    redraw();

}

function updateColouringType(_ev) {
    colouring_type.value = document.getElementById("colouring_type").value;
    redraw();
}

function updateMaxIterations(_ev) {
    max_iterations.value = document.getElementById("max_iterations").value;
    redraw();
}

function updateEscapeRadius(_ev) {
    escape_radius.value = document.getElementById("escape_radius").value;
    redraw();
}

function hexToRGB(hex) {
    return [
        parseInt(hex.slice(1, 3), 16) / 256,
        parseInt(hex.slice(3, 5), 16) / 256,
        parseInt(hex.slice(5, 7), 16) / 256
    ];
}

function updateTrappedColour(_ev) {
    trapped_colour.value = hexToRGB(document.getElementById("trapped_colour").value);
    redraw();
}

function updateCloseColour(_ev) {
    close_colour.value = hexToRGB(document.getElementById("close_colour").value);
    redraw();
}

function updateFarColour(_ev) {
    far_colour.value = hexToRGB(document.getElementById("far_colour").value);
    redraw();
}

function updateJuliaCoord(event) {

    if (!mouse_down) {
        return;
    }

    julia_c_real.value = event.offsetX / 25 - 2;
    julia_c_imag.value = event.offsetY / 25 - 2;

    redraw();

    julia_canvas_context.clearRect(0, 0, 100, 100);

    julia_canvas_context.beginPath();
    julia_canvas_context.arc(event.offsetX, event.offsetY, 4, 0, 2 * Math.PI);
    julia_canvas_context.stroke();

}

function keyhandler(event) {
    
    switch (event.keyCode) {

        case 82: // R
            origin_imag.value = 0.0;
            origin_real.value = 0.0;
            magnitude.value = 2.0;
            redraw();
            break;

        case 87: // W
            origin_imag.value -= 0.5 * magnitude.value;
            redraw();
            break;

        case 83: // S
            origin_imag.value += 0.5 * magnitude.value;
            redraw();
            break;

        case 65: // A
            origin_real.value -= 0.5 * magnitude.value;
            redraw();
            break;

        case 68: // D
            origin_real.value += 0.5 * magnitude.value;
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