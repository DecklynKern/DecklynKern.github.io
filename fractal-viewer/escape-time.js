class EscapeTime extends Program {

    shader = "shaders/escape-time.glsl";
    options_panel = "escape_time_options";

    fractal_type = 0;
    orbit_trap = 0;

    fractal_param1 = new Param(2.0);
    fractal_param2 = new Param(-2.0);
    fractal_param3 = new Param(0.0625);
    
    max_iterations = new Param(30);
    escape_radius = new Param(2.0);

    orbit_trap_param1 = new Param(0.0);
    orbit_trap_param2 = new Param(0.0);
    
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

    getShader = function() {

        var shader = (' ' + this.baseShader).slice(1);
        var def = `#define FRACTAL_TYPE ${this.fractal_type}
                   #define ORBIT_TRAP ${this.orbit_trap}`;

        var total = 0;

        if (this.fractal_type == 20) {

            for (var i = 1; i < 6; i++) {

                def += "\n#define G_" + i;

                if (document.getElementById("gangopadhyay" + i).checked) {
                    def += " 1";
                    total++;

                } else {
                    def += " 0";
                }
            }

            def += `\n#define G_TOTAL ${total}.0`;

        }

        return shader.replace("//%", def);

    }

    setupGUI = function() {

        document.getElementById("esc_fractal_type").onchange = this.updateFractalType;
        
        document.getElementById("scaling").onchange = paramSet(this.fractal_param1);
        document.getElementById("exponent").onchange = paramSet(this.fractal_param1);

        document.getElementById("rational_p").onchange = paramSet(this.fractal_param1);
        document.getElementById("rational_q").onchange = paramSet(this.fractal_param2);
        document.getElementById("rational_lambda").onchange = paramSet(this.fractal_param3);

        document.getElementById("phoenix_p_real").onchange = paramSet(this.fractal_param1);
        document.getElementById("phoenix_p_imag").onchange = paramSet(this.fractal_param2);

        document.getElementById("dragon_r").onchange = paramSet(this.fractal_param1);

        document.getElementById("gangopadhyay1").onchange = this.updateGangopadhyay;
        document.getElementById("gangopadhyay2").onchange = this.updateGangopadhyay;
        document.getElementById("gangopadhyay3").onchange = this.updateGangopadhyay;
        document.getElementById("gangopadhyay4").onchange = this.updateGangopadhyay;
        document.getElementById("gangopadhyay5").onchange = this.updateGangopadhyay;
        
        document.getElementById("esc_max_iterations").onchange = paramSet(this.max_iterations);
        document.getElementById("escape_radius").onchange = paramSet(this.escape_radius);

        document.getElementById("orbit_trap").onchange = this.updateOrbitTrap;
        document.getElementById("orbit_circle").onchange = paramSet(this.orbit_trap_param1);
        document.getElementById("orbit_square").onchange = paramSet(this.orbit_trap_param1);
        document.getElementById("orbit_cross").onchange = paramSet(this.orbit_trap_param1);
        document.getElementById("orbit_ring_min").onchange = paramSet(this.orbit_trap_param1);
        document.getElementById("orbit_ring_max").onchange = paramSet(this.orbit_trap_param2);
    
        document.getElementById("is_julia").onchange = this.updateIsJulia;
    
        document.getElementById("smoothing_type").onchange = paramSet(this.smoothing_type);
        document.getElementById("colouring_type").onchange = this.updateColouringType;
        document.getElementById("interior_colouring_type").onchange = paramSet(this.interior_colouring_type);
    
        document.getElementById("trapped_colour").onchange = paramSetColour(this.trapped_colour);
        document.getElementById("close_colour").onchange = paramSetColour(this.close_colour);
        document.getElementById("far_colour").onchange = paramSetColour(this.far_colour);

        this.julia_c_handler = new ComplexPickerHandler("julia_selector", this.julia_c_real, this.julia_c_imag, 2.5, 0, 0, "esc_julia_text", "c = $");

    }

    setupAttrs = function() {

        this.fractal_param1.getAttr("fractal_param1");
        this.fractal_param2.getAttr("fractal_param2");
        this.fractal_param3.getAttr("fractal_param3");
        
        this.max_iterations.getAttr("max_iterations");
        this.escape_radius.getAttr("escape_radius_sq");

        this.orbit_trap_param1.getAttr("orbit_trap_param1");
        this.orbit_trap_param2.getAttr("orbit_trap_param2");
            
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

        this.fractal_param1.loadFloat();
        this.fractal_param2.loadFloat();
        this.fractal_param3.loadFloat();

        this.max_iterations.loadInt();
        this.escape_radius.loadFloatSq();

        this.orbit_trap_param1.loadFloat();
        this.orbit_trap_param2.loadFloat();

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

        ESCAPE_TIME.fractal_type = event.target.value;
    
        var julia_style = document.getElementById("julia_div").style;
        var scaling_style = document.getElementById("scaling_div").style;
        var exponent_style = document.getElementById("exponent_div").style;
        var rational_style = document.getElementById("rational_div").style;
        var phoenix_style = document.getElementById("phoenix_div").style;
        var dragon_style = document.getElementById("dragon_div").style;
        var gangopadhyay_style = document.getElementById("gangopadhyay_div").style;
    
        julia_style.display = "block";
        scaling_style.display = "none";
        exponent_style.display = "none";
        rational_style.display = "none";
        phoenix_style.display = "none";
        dragon_style.display = "none";
        gangopadhyay_style.display = "none";
        
        if (ESCAPE_TIME.fractal_type == 4) {
            scaling_style.display = "block";
            ESCAPE_TIME.fractal_param1.value = document.getElementById("scaling").value;
    
        } else if (ESCAPE_TIME.fractal_type == 5) {
            exponent_style.display = "block";
            ESCAPE_TIME.fractal_param1.value = document.getElementById("exponent").value;
        
        } else if (ESCAPE_TIME.fractal_type == 15) {
            rational_style.display = "block";
            ESCAPE_TIME.fractal_param1.value = document.getElementById("rational_p").value;
            ESCAPE_TIME.fractal_param2.value = document.getElementById("rational_q").value;
            ESCAPE_TIME.fractal_param3.value = document.getElementById("rational_lambda").value;
        
        } else if (ESCAPE_TIME.fractal_type == 16) {
            phoenix_style.display = "block";
            ESCAPE_TIME.fractal_param1.value = document.getElementById("phoenix_p_real").value;
            ESCAPE_TIME.fractal_param2.value = document.getElementById("phoenix_p_imag").value;

        } else if (ESCAPE_TIME.fractal_type == 19) {
            julia_style.display = "none";
            dragon_style.display = "block";
        
        } else if (ESCAPE_TIME.fractal_type == 20) {
            gangopadhyay_style.display = "block";
        }
        
        setupShader();
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

    updateOrbitTrap = function(event) {

        ESCAPE_TIME.orbit_trap = event.target.value;

        var circle_style = document.getElementById("orbit_circle_div").style;
        var square_style = document.getElementById("orbit_square_div").style;
        var cross_style = document.getElementById("orbit_cross_div").style;
        var ring_style = document.getElementById("orbit_ring_div").style;

        circle_style.display = "none";
        square_style.display = "none";
        cross_style.display = "none";
        ring_style.display = "none";

        if (ESCAPE_TIME.orbit_trap == 1) {
            ESCAPE_TIME.orbit_trap_param1.value = document.getElementById("orbit_circle").value;
            circle_style.display = "block";
        
        } else if (ESCAPE_TIME.orbit_trap == 2) {
            ESCAPE_TIME.orbit_trap_param1.value = document.getElementById("orbit_square").value;
            square_style.display = "block";

        } else if (ESCAPE_TIME.orbit_trap == 3) {
            ESCAPE_TIME.orbit_trap_param1.value = document.getElementById("orbit_cross").value;
            cross_style.display = "block";

        } else if (ESCAPE_TIME.orbit_trap == 4) {
            ESCAPE_TIME.orbit_trap_param1.value = document.getElementById("orbit_ring_min").value;
            ESCAPE_TIME.orbit_trap_param2.value = document.getElementById("orbit_ring_max").value;
            ring_style.display = "block";
        }

        setupShader();
        redraw();

    }

    updateGangopadhyay = function(event) {
        setupShader();
        redraw();
    }
}