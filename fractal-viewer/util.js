function hexToRGB(hex) {
    return [
        parseInt(hex.slice(1, 3), 16) / 256,
        parseInt(hex.slice(3, 5), 16) / 256,
        parseInt(hex.slice(5, 7), 16) / 256
    ];
}

function formatComplex(real, imag) {

    real = real.toPrecision(6);
    imag = imag.toPrecision(6);

    if (imag < 0) {
        return `${real} - ${-imag}i`;
    }
    else {
        return `${real} + ${imag}i`;
    }
}

function paramSet(param) {
    return function(event) {
        param.value = event.target.value;
        redraw();
    }
}

function paramSetColour(param) {
    return function(event) {
        param.value = hexToRGB(event.target.value);
        redraw();
    }
}

class Param {
    
    constructor(value) {
        this.value = value;
        this.attr = null;
    }

    getAttr = function(name) {
        this.attr = gl.getUniformLocation(gl.program, name);
    }

    loadInt = function() {
        gl.uniform1i(this.attr, this.value);
    }

    loadFloat = function() {
        gl.uniform1f(this.attr, this.value);
    }

    loadFloatSq = function() {
        gl.uniform1f(this.attr, this.value * this.value);
    }

    loadFloat3 = function() {
        gl.uniform3f(this.attr, ...this.value);
    }
}

class Program {
    
    baseShader = null;

    getShader = function() {
        return this.baseShader;
    }
}

class ComplexPickerHandler {

    constructor(canvas, real_param, imag_param, scale, offset_real, offset_imag, info_div, template) {

        this.real = real_param.value;
        this.imag = imag_param.value;

        var canvas_ref = document.getElementById(canvas);
        
        var canvas_context = canvas_ref.getContext("2d");
        canvas_ref.onmousemove = this.updateComplex(real_param, imag_param, canvas_context, scale, offset_real, offset_imag, info_div, template);
        
        canvas_context.strokeStyle = "black";
        canvas_context.beginPath();
        canvas_context.moveTo(0, 100);
        canvas_context.lineTo(200, 100);
        canvas_context.moveTo(100, 0);
        canvas_context.lineTo(100, 200);
        canvas_context.stroke();
        canvas_context.beginPath();
        
        var unit_px = 100 / scale;

        var x = (this.real - offset_real + scale) * unit_px;
        var y = (this.imag - offset_imag + scale) * unit_px;

        canvas_context.arc(x, y, 4, 0, 2 * Math.PI);
        canvas_context.stroke();

    }

    updateComplex = function(real_param, imag_param, canvas_context, scale, offset_real, offset_imag, info_div, template) {

        var unit_px = 100 / scale;

        function onMove(event) {
    
            if (!mouse_down) {
                return;
            }
        
            real_param.value = event.offsetX / unit_px - scale + offset_real;
            imag_param.value = event.offsetY / unit_px - scale + offset_imag;

            this.real = real_param.value;
            this.imag = imag_param.value;

            if (info_div) {
                document.getElementById(info_div).innerHTML = template.replace("$", formatComplex(real_param.value, imag_param.value));
            }

        
            canvas_context.clearRect(0, 0, 200, 200);
        
            canvas_context.beginPath();
            canvas_context.moveTo(0, 100);
            canvas_context.lineTo(200, 100);
            canvas_context.moveTo(100, 0);
            canvas_context.lineTo(100, 200);
            canvas_context.stroke();
            canvas_context.beginPath();
            canvas_context.arc(event.offsetX, event.offsetY, 4, 0, 2 * Math.PI);
            canvas_context.stroke();
            
            redraw();

        }

        return onMove

    }
}