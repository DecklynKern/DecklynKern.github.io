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

    return `${real} ` + (imag > 0 ? "-" : "+") + ` ${Math.abs(imag)}i`;
    
}

function show(do_show) {
    return do_show ? "block" : "none";
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
    
    drawPath = function() {}
}

class ComplexPickerHandler {

    constructor(canvas, real_param, imag_param, scale, offset_real, offset_imag, info_div, template) {

        this.real_param = real_param;
        this.imag_param = imag_param;

        this.real = real_param.value;
        this.imag = imag_param.value;
        
        this.scale = scale;
        this.unit_px = 100 / scale;
        
        this.offset_real = offset_real;
        this.offset_imag = offset_imag;
        
        this.info_div = info_div;
        this.template = template;

        var canvas_ref = document.getElementById(canvas);
        
        this.canvas_context = canvas_ref.getContext("2d");
        var t = this;
        canvas_ref.onmousemove = function(event) {
            t.updateComplex(event);
        };
        
        var x = (offset_real - offset_real + scale) * this.unit_px;
        var y = (offset_imag - offset_imag + scale) * this.unit_px;
        
        this.redraw(x, y);

    }
    
    redraw(x, y) {
    
        this.canvas_context.clearRect(0, 0, 200, 200);
    
        this.canvas_context.beginPath();
        this.canvas_context.moveTo(0, 100);
        this.canvas_context.lineTo(200, 100);
        this.canvas_context.moveTo(100, 0);
        this.canvas_context.lineTo(100, 200);
        this.canvas_context.stroke();
        
        this.canvas_context.beginPath();
        this.canvas_context.arc(x, y, 4, 0, 2 * Math.PI);
        this.canvas_context.stroke();
        
    }
    
    loadValues = function() {
        this.real_param.value = this.real;
        this.imag_param.value = this.imag;
    }

    updateComplex = function(event) {
    
        if (!mouse_down) {
            return;
        }
    
        this.real_param.value = event.offsetX / this.unit_px - this.scale + this.offset_real;
        this.imag_param.value = event.offsetY / this.unit_px - this.scale + this.offset_imag;

        this.real = this.real_param.value;
        this.imag = this.imag_param.value;

        if (this.info_div) {
            document.getElementById(this.info_div).innerHTML = this.template.replace("$", formatComplex(this.real_param.value, this.imag_param.value));
        }
    
        this.redraw(event.offsetX, event.offsetY);
        redraw();
        
    }
}