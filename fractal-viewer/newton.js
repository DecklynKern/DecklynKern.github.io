class Newton {

    shader = "shaders/newton.glsl";
    options_panel = "newton_options";

    fractal_type = new Param(0);
    max_iterations = new Param(40);
    colouring_type = new Param(0);

    root1_colour = new Param([1.0, 0.0, 0.0]);
    root2_colour = new Param([0.0, 1.0, 0.0]);
    root3_colour = new Param([0.0, 0.0, 1.0]);
    base_colour = new Param([0.0, 0.0, 0.0]);

    setupGUI = function() {
        
        document.getElementById("nwt_fractal_type").onchange = this.updateFractalType;
        document.getElementById("nwt_iterations").onchange = this.updateMaxIterations;
        document.getElementById("nwt_colouring_type").onchange = this.updateColouringType;
        
        document.getElementById("root1_colour").onchange = this.updateRoot1Colour;
        document.getElementById("root2_colour").onchange = this.updateRoot2Colour;
        document.getElementById("root3_colour").onchange = this.updateRoot3Colour;
        document.getElementById("base_colour").onchange = this.updateBaseColour;

    }

    setupAttrs = function() {
        
        this.fractal_type.attr = gl.getUniformLocation(gl.program, "fractal_type");
        this.max_iterations.attr = gl.getUniformLocation(gl.program, "max_iterations");
        this.colouring_type.attr = gl.getUniformLocation(gl.program, "colouring_type");
        
        this.root1_colour.attr = gl.getUniformLocation(gl.program, "root1_colour");
        this.root2_colour.attr = gl.getUniformLocation(gl.program, "root2_colour");
        this.root3_colour.attr = gl.getUniformLocation(gl.program, "root3_colour");
        this.base_colour.attr = gl.getUniformLocation(gl.program, "base_colour");

    }

    loadAttrs = function() {
        
        this.fractal_type.loadInt();
        this.max_iterations.loadInt();
        this.colouring_type.loadInt();

        this.root1_colour.loadFloat3();
        this.root2_colour.loadFloat3();
        this.root3_colour.loadFloat3();
        this.base_colour.loadFloat3();

    }

    updateFractalType = function(_ev) {
        NEWTON.fractal_type.value = document.getElementById("nwt_fractal_type").value;
        redraw();
    }

    updateMaxIterations = function(_ev) {
        NEWTON.max_iterations.value = document.getElementById("nwt_iterations").value;
        redraw();
    }

    updateColouringType = function(_ev) {

        const colouring_type = document.getElementById("nwt_colouring_type").value;
        
        NEWTON.colouring_type.value = colouring_type;
   
        const root_colour_div = document.getElementById("root_colour_div");
        
        if (colouring_type == 2) {
            root_colour_div.style.display = "none";
        
        } else {
            root_colour_div.style.display = "block";
        }

        const base_colour_div = document.getElementById("base_colour_div");

        if (colouring_type == 1) {
            base_colour_div.style.display = "flex";
        
        } else {
            base_colour_div.style.display = "none";
        }
    
        redraw();
    
    }

    updateRoot1Colour = function(_ev) {
        NEWTON.root1_colour.value = hexToRGB(document.getElementById("root1_colour").value);
        redraw();
    }

    updateRoot2Colour = function(_ev) {
        NEWTON.root2_colour.value = hexToRGB(document.getElementById("root2_colour").value);
        redraw();
    }

    updateRoot3Colour = function(_ev) {
        NEWTON.root3_colour.value = hexToRGB(document.getElementById("root3_colour").value);
        redraw();
    }

    updateBaseColour = function(_ev) {
        NEWTON.base_colour.value = hexToRGB(document.getElementById("base_colour").value);
        redraw();
    }
}