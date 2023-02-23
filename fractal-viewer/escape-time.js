class EscapeTime {

    shader = "shaders/escape-time.glsl";
    options_panel = "escape_time_options";

    fractal_type = new Param(0);
    fractal_param = new Param(2.0);
    max_iterations = new Param(30);
    escape_radius = new Param(2.0);
    min_radius = new Param(0.0);
    
    is_julia = new Param(0);
    julia_c_real = new Param(0.0);
    julia_c_imag = new Param(0.0);
    
    magnitude = new Param(2.0);
    origin_real = new Param(0.0);
    origin_imag = new Param(0.0);
    
    smoothing_type = new Param(0);
    colouring_type = new Param(0);
    interior_colouring_type = new Param(0);
    trapped_colour = new Param([0.0, 0.0, 0.0]);
    close_colour = new Param([0.0, 0.0, 1.0]);
    far_colour = new Param([0.0, 0.0, 0.0]);

    setupGUI = function() {

        document.getElementById("fractal_type").onchange = this.updateFractalType;
        document.getElementById("scaling").onchange = this.updateScaling;
        document.getElementById("exponent").onchange = this.updateExponent;
        
        document.getElementById("et_max_iterations").onchange = this.updateMaxIterations;
        document.getElementById("escape_radius").onchange = this.updateEscapeRadius;
        document.getElementById("min_radius").onchange = this.updateMinRadius;
    
        document.getElementById("is_julia").onchange = this.updateIsJulia;  
        document.getElementById("julia_selector").onmousemove = this.updateJuliaCoord;
    
        document.getElementById("smoothing_type").onchange = this.updateSmoothingType;
        document.getElementById("colouring_type").onchange = this.updateColouringType;
        document.getElementById("interior_colouring_type").onchange = this.updateInteriorColouringType;
    
        document.getElementById("trapped_colour").onchange = this.updateTrappedColour;
        document.getElementById("close_colour").onchange = this.updateCloseColour;
        document.getElementById("far_colour").onchange = this.updateFarColour;

        this.julia_canvas_context = document.getElementById("julia_selector").getContext("2d");
        this.julia_canvas_context.fillStyle = "black";
        this.julia_canvas_context.beginPath();
        this.julia_canvas_context.arc(50, 50, 4, 0, 2 * Math.PI);
        this.julia_canvas_context.stroke();

    }

    setupAttrs = function() {
        
        this.fractal_type.attr = gl.getUniformLocation(gl.program, "fractal_type");
        this.fractal_param.attr = gl.getUniformLocation(gl.program, "fractal_param");
        this.max_iterations.attr = gl.getUniformLocation(gl.program, "max_iterations");
        this.escape_radius.attr = gl.getUniformLocation(gl.program, "escape_radius_sq");
        this.min_radius.attr = gl.getUniformLocation(gl.program, "min_radius_sq");
            
        this.is_julia.attr = gl.getUniformLocation(gl.program, "is_julia");
        this.julia_c_real.attr = gl.getUniformLocation(gl.program, "julia_c_real");
        this.julia_c_imag.attr = gl.getUniformLocation(gl.program, "julia_c_imag");
        
        this.smoothing_type.attr = gl.getUniformLocation(gl.program, "smoothing_type");
        this.colouring_type.attr = gl.getUniformLocation(gl.program, "colouring_type");
        this.interior_colouring_type.attr = gl.getUniformLocation(gl.program, "interior_colouring_type");

        this.trapped_colour.attr = gl.getUniformLocation(gl.program, "trapped_colour");
        this.close_colour.attr = gl.getUniformLocation(gl.program, "close_colour");
        this.far_colour.attr = gl.getUniformLocation(gl.program, "far_colour");
    
    }

    loadAttrs = function() {

        this.fractal_type.loadInt();
        this.fractal_param.loadFloat();
        this.max_iterations.loadInt();

        this.escape_radius.loadFloatSq();
        this.min_radius.loadFloatSq();

        this.is_julia.loadInt();
        this.julia_c_real.loadFloat();
        this.julia_c_imag.loadFloat();

        this.smoothing_type.loadInt();
        this.colouring_type.loadInt();
        this.interior_colouring_type.loadInt();

        this.trapped_colour.loadFloat3();
        this.close_colour.loadFloat3();
        this.far_colour.loadFloat3();

    }

    updateFractalType = function(_ev) {

        ESCAPE_TIME.fractal_type.value = document.getElementById("fractal_type").value;
    
        const scaling_style = document.getElementById("scaling_div").style;
        const exponent_style = document.getElementById("exponent_div").style;
    
        scaling_style.display = "none";
        exponent_style.display = "none";
    
        if (fractal_type.value == 4) {
            scaling_style.display = "block";
    
        } else if (fractal_type.value == 5) {
            exponent_style.display = "block";
        }
        
        redraw();
    
    }
    
    updateScaling = function(_ev) {
        ESCAPE_TIME.fractal_param.value = document.getElementById("scaling").value;
        redraw();
    }
    
    updateExponent = function(_ev) {
        ESCAPE_TIME.fractal_param.value = document.getElementById("exponent").value;
        redraw();
    }
    
    updateIsJulia = function(_ev) {
    
        ESCAPE_TIME.is_julia.value = +document.getElementById("is_julia").checked;
        
        if (is_julia.value) {
            document.getElementById("julia_options").style.display = "block";
        
        } else {
            document.getElementById("julia_options").style.display = "none";
        }
        
        redraw();
    
    }
    
    updateSmoothingType = function(_ev) {
        ESCAPE_TIME.smoothing_type.value = document.getElementById("smoothing_type").value;
        redraw();
    }
    
    updateColouringType = function(_ev) {
    
        ESCAPE_TIME.colouring_type.value = document.getElementById("colouring_type").value;
    
        const colour_select_style = document.getElementById("colour_select").style;
    
        if (colouring_type.value == 2) {
            colour_select_style.display = "none";
    
        } else {
            colour_select_style.display = "block";
        }
    
        redraw();
    
    }

    updateInteriorColouringType = function(_ev) {
        ESCAPE_TIME.interior_colouring_type.value = document.getElementById("interior_colouring_type").value;
        redraw();
    }
    
    updateMaxIterations = function(_ev) {
        ESCAPE_TIME.max_iterations.value = document.getElementById("et_max_iterations").value;
        redraw();
    }
    
    updateEscapeRadius = function(_ev) {
        ESCAPE_TIME.escape_radius.value = document.getElementById("escape_radius").value;
        redraw();
    }
    
    updateMinRadius = function(_ev) {
        ESCAPE_TIME.min_radius.value = document.getElementById("min_radius").value;
        redraw();
    }
    
    updateTrappedColour = function(_ev) {
        ESCAPE_TIME.trapped_colour.value = hexToRGB(document.getElementById("trapped_colour").value);
        redraw();
    }
    
    updateCloseColour = function(_ev) {
        ESCAPE_TIME.close_colour.value = hexToRGB(document.getElementById("close_colour").value);
        redraw();
    }
    
    updateFarColour = function(_ev) {
        ESCAPE_TIME.far_colour.value = hexToRGB(document.getElementById("far_colour").value);
        redraw();
    }
    
    updateJuliaCoord = function(event) {
    
        if (!mouse_down) {
            return;
        }
    
        ESCAPE_TIME.julia_c_real.value = event.offsetX / 40 - 2.5;
        ESCAPE_TIME.julia_c_imag.value = event.offsetY / 40 - 2.5;
    
        redraw();
    
        ESCAPE_TIME.julia_canvas_context.clearRect(0, 0, 200, 200);
    
        ESCAPE_TIME.julia_canvas_context.beginPath();
        ESCAPE_TIME.julia_canvas_context.arc(event.offsetX, event.offsetY, 4, 0, 2 * Math.PI);
        ESCAPE_TIME.julia_canvas_context.stroke();
    
    }
}