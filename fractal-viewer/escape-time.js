class EscapeTime {

    shader = "shaders/escape-time.glsl";
    options_panel = "escape_time_options";

    fractal_type = new Param(0);

    fractal_param1 = new Param(2.0);
    fractal_param2 = new Param(-2.0);
    fractal_param3 = new Param(0.0625);
    
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

        document.getElementById("esc_fractal_type").onchange = this.updateFractalType;
        
        document.getElementById("scaling").onchange = paramSet(this.fractal_param1);
        document.getElementById("exponent").onchange = paramSet(this.fractal_param1);

        document.getElementById("rational_p").onchange = paramSet(this.fractal_param1);
        document.getElementById("rational_q").onchange = paramSet(this.fractal_param2);
        document.getElementById("rational_lambda").onchange = paramSet(this.fractal_param3);

        document.getElementById("phoenix_p_real").onchange = paramSet(this.fractal_param1);
        document.getElementById("phoenix_p_imag").onchange = paramSet(this.fractal_param2);
        
        document.getElementById("esc_max_iterations").onchange = paramSet(this.max_iterations);
        document.getElementById("escape_radius").onchange = paramSet(this.escape_radius);
        document.getElementById("min_radius").onchange = paramSet(this.min_radius);
    
        document.getElementById("is_julia").onchange = this.updateIsJulia;
        document.getElementById("julia_selector").onmousemove = this.updateJuliaCoord;
    
        document.getElementById("smoothing_type").onchange = paramSet(this.smoothing_type);
        document.getElementById("colouring_type").onchange = this.updateColouringType;
        document.getElementById("interior_colouring_type").onchange = paramSet(this.interior_colouring_type);
    
        document.getElementById("trapped_colour").onchange = paramSetColour(this.trapped_colour);;
        document.getElementById("close_colour").onchange = paramSetColour(this.close_colour);;
        document.getElementById("far_colour").onchange = paramSetColour(this.far_colour);;

        this.julia_canvas_context = document.getElementById("julia_selector").getContext("2d");
        this.julia_canvas_context.strokeStyle = "black";
        this.julia_canvas_context.beginPath();
        this.julia_canvas_context.moveTo(0, 100);
        this.julia_canvas_context.lineTo(200, 100);
        this.julia_canvas_context.moveTo(100, 0);
        this.julia_canvas_context.lineTo(100, 200);
        this.julia_canvas_context.stroke();
        this.julia_canvas_context.beginPath();
        this.julia_canvas_context.arc(100, 100, 4, 0, 2 * Math.PI);
        this.julia_canvas_context.stroke();

    }

    setupAttrs = function() {
        
        this.fractal_type.getAttr("fractal_type");

        this.fractal_param1.getAttr("fractal_param1");
        this.fractal_param2.getAttr("fractal_param2");
        this.fractal_param3.getAttr("fractal_param3");
        
        this.max_iterations.getAttr("max_iterations");
        this.escape_radius.getAttr("escape_radius_sq");
        this.min_radius.getAttr("min_radius_sq");
            
        this.is_julia.getAttr("is_julia");
        this.julia_c_real.getAttr("julia_c_real");
        this.julia_c_imag.getAttr("julia_c_imag");
        
        this.smoothing_type.getAttr("smoothing_type");
        this.colouring_type.getAttr("colouring_type");
        this.interior_colouring_type.getAttr("interior_colouring_type");

        this.trapped_colour.getAttr("trapped_colour");
        this.close_colour.getAttr("close_colour");
        this.far_colour.getAttr("far_colour");
    
    }

    loadAttrs = function() {

        this.fractal_type.loadInt();

        this.fractal_param1.loadFloat();
        this.fractal_param2.loadFloat();
        this.fractal_param3.loadFloat();

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

    updateFractalType = function(event) {

        ESCAPE_TIME.fractal_type.value = event.target.value;
    
        const scaling_style = document.getElementById("scaling_div").style;
        const exponent_style = document.getElementById("exponent_div").style;
        const rational_style = document.getElementById("rational_div").style;
        const phoenix_style = document.getElementById("phoenix_div").style;
    
        scaling_style.display = "none";
        exponent_style.display = "none";
        rational_style.display = "none";
        phoenix_style.display = "none";
        
        if (ESCAPE_TIME.fractal_type.value == 4) {
            scaling_style.display = "block";
            ESCAPE_TIME.fractal_param1.value = document.getElementById("scaling").value;
    
        } else if (ESCAPE_TIME.fractal_type.value == 5) {
            exponent_style.display = "block";
            ESCAPE_TIME.fractal_param1.value = document.getElementById("exponent").value;
        
        } else if (ESCAPE_TIME.fractal_type.value == 15) {
            rational_style.display = "block";
            ESCAPE_TIME.fractal_param1.value = document.getElementById("rational_p").value;
            ESCAPE_TIME.fractal_param2.value = document.getElementById("rational_q").value;
            ESCAPE_TIME.fractal_param3.value = document.getElementById("rational_lambda").value;
        
        } else if (ESCAPE_TIME.fractal_type.value == 16) {
            phoenix_style.display = "block";
            ESCAPE_TIME.fractal_param1.value = document.getElementById("phoenix_p_real").value;
            ESCAPE_TIME.fractal_param2.value = document.getElementById("phoenix_p_imag").value;
        }
        
        redraw();
    
    }
    
    updateIsJulia = function(event) {
    
        ESCAPE_TIME.is_julia.value = +event.target.checked;
        
        if (ESCAPE_TIME.is_julia.value) {
            document.getElementById("julia_options").style.display = "block";
        
        } else {
            document.getElementById("julia_options").style.display = "none";
        }
        
        redraw();
    
    }
    
    updateColouringType = function(event) {
    
        ESCAPE_TIME.colouring_type.value = event.target.value;
    
        const colour_select_style = document.getElementById("colour_select").style;
    
        if (ESCAPE_TIME.colouring_type.value == 2) {
            colour_select_style.display = "none";
    
        } else {
            colour_select_style.display = "block";
        }
    
        redraw();
    
    }
    
    updateJuliaCoord = function(event) {
    
        if (!mouse_down) {
            return;
        }
    
        ESCAPE_TIME.julia_c_real.value = event.offsetX / 40 - 2.5;
        ESCAPE_TIME.julia_c_imag.value = event.offsetY / 40 - 2.5;
    
        ESCAPE_TIME.julia_canvas_context.clearRect(0, 0, 200, 200);
    
        ESCAPE_TIME.julia_canvas_context.beginPath();
        ESCAPE_TIME.julia_canvas_context.moveTo(0, 100);
        ESCAPE_TIME.julia_canvas_context.lineTo(200, 100);
        ESCAPE_TIME.julia_canvas_context.moveTo(100, 0);
        ESCAPE_TIME.julia_canvas_context.lineTo(100, 200);
        ESCAPE_TIME.julia_canvas_context.stroke();
        ESCAPE_TIME.julia_canvas_context.beginPath();
        ESCAPE_TIME.julia_canvas_context.arc(event.offsetX, event.offsetY, 4, 0, 2 * Math.PI);
        ESCAPE_TIME.julia_canvas_context.stroke();
        
        redraw();
    
    }
}