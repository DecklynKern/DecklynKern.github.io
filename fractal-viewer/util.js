function hexToRGB(hex) {
    return [
        parseInt(hex.slice(1, 3), 16) / 256,
        parseInt(hex.slice(3, 5), 16) / 256,
        parseInt(hex.slice(5, 7), 16) / 256
    ];
}

class Param {
    
    constructor(value) {
        this.value = value;
        this.attr = null;
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