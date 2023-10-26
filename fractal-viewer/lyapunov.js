LYAPUNOV_FUNCTIONS = [
    "x ← rx(1 - x)",
    "x ← e<sup>-αx²</sup> + r",
    "x ← x + Ω + r/2π*sin(2πx)",
    "x ← r - ax<sup>2</sup>",
    "x ← rx(1 - x<sup>2</sup>)",
    "x ← rx(1 - x) + μsin<sup>2</sup>(2πx)",
    "x ← r*sin(x)",
    "x ← r*cos(x)",
    "x ← r*(a - cosh(x))",
    "x ← r/2(xcos<sup>2</sup>(π/2x) + (3x + 1)sin<sup>2</sup>(π/2x))"
]

class Lyapunov extends Program {

    shader = "shaders/lyapunov.glsl";
    options_panel = "lyapunov_options";

    fractal_type = 0;

    fractal_param = new Param(0);

    sequence = [0, 1];

    z_value = new Param(2);

    initial_value = new Param(0.5);

    iterations = 250;

    stable_colour = new Param([1.0, 1.0, 0.0]);
    chaotic_colour = new Param([0.0, 0.0, 1.0]);
    infinity_colour = new Param([0.0, 0.0, 0.0]);

    getShader = function() {
        
        var shader = (' ' + this.baseShader).slice(1);
        var def = `
        //%
        #define FLIP_Y
        #define FRACTAL_TYPE ${this.fractal_type}
        #define SEQUENCE_LENGTH ${this.sequence.length}
        #define ITERATIONS ${this.iterations}`;

        var sequence_iter = "";

        for (var i = 0; i < this.sequence.length; i++) {

            if (this.sequence[i] == 0) {
                sequence_iter += "r = a;\n";
            }
            else if (this.sequence[i] == 1) {
                sequence_iter += "r = b;\n";
            }
            else if (this.sequence[i] == 2) {
                sequence_iter += "r = c;\n";
            }

            sequence_iter += "doIteration(r, x, lambda);\n\n";

        }

        return shader.replace("//%", def).replace("//+", sequence_iter);

    }

    setupGUI = function() {

        document.getElementById("lya_fractal_type").onchange = this.updateFractalType;
        document.getElementById("lya_gauss_alpha").onchange = this.updateGaussAlpha;
        document.getElementById("lya_circle_omega").onchange = paramSet(this.fractal_param);
        document.getElementById("lya_quadratic_a").onchange = paramSet(this.fractal_param);
        document.getElementById("lya_squared_sine_mu").onchange = paramSet(this.fractal_param);
        document.getElementById("lya_trig_theta").onchange = paramSet(this.fractal_param);
        document.getElementById("lya_cosh_a").onchange = paramSet(this.fractal_param);

        document.getElementById("lya_sequence").onkeydown = this.processSequenceEvent;
        document.getElementById("lya_sequence").onchange = this.updateSequence;
        document.getElementById("lya_initial").onchange = paramSet(this.initial_value);
        document.getElementById("z_value").oninput = this.updateZValue;
        
        document.getElementById("lya_iterations").onchange = this.updateIterations;

        document.getElementById("stable_colour").onchange = paramSetColour(this.stable_colour);
        document.getElementById("chaotic_colour").onchange = paramSetColour(this.chaotic_colour);
        document.getElementById("infinity_colour").onchange = paramSetColour(this.infinity_colour);
    
    }

    setupAttrs = function() {

        this.fractal_param.getAttr("fractal_param");

        this.initial_value.getAttr("initial_value");
        this.z_value.getAttr("c");

        this.stable_colour.getAttr("stable_colour");
        this.chaotic_colour.getAttr("chaotic_colour");
        this.infinity_colour.getAttr("infinity_colour");

    }

    loadAttrs = function() {

        this.fractal_param.loadFloat();

        this.initial_value.loadFloat();
        this.z_value.loadFloat();
        
        this.stable_colour.loadFloat3();
        this.chaotic_colour.loadFloat3();
        this.infinity_colour.loadFloat3();

    }

    updateFractalType = function(event) {

        LYAPUNOV.fractal_type = event.target.value;

        var gauss_style = document.getElementById("lya_gauss_div").style;
        var circle_style = document.getElementById("lya_circle_div").style;
        var quadratic_style = document.getElementById("lya_quadratic_div").style;
        var squared_sine_style = document.getElementById("lya_squared_sine_div").style;
        var trig_style = document.getElementById("lya_trig_div").style;
        var cosh_style = document.getElementById("lya_cosh_div").style;
        var function_text = document.getElementById("lya_function_text");

        gauss_style.display = "none";
        circle_style.display = "none";
        quadratic_style.display = "none";
        squared_sine_style.display = "none";
        trig_style.display = "none";
        cosh_style.display = "none";

        function_text.innerHTML = LYAPUNOV_FUNCTIONS[LYAPUNOV.fractal_type];

        if (LYAPUNOV.fractal_type == 1) {
            LYAPUNOV.fractal_param.value = -document.getElementById("lya_gauss_alpha").value;
            gauss_style.display = "block";
        }
        else if (LYAPUNOV.fractal_type == 2) {
            LYAPUNOV.fractal_param.value = document.getElementById("lya_circle_omega").value;
            circle_style.display = "block";    
        }
        else if (LYAPUNOV.fractal_type == 3) {
            LYAPUNOV.fractal_param.value = document.getElementById("lya_quadratic_a").value;
            quadratic_style.display = "block";
        }
        else if (LYAPUNOV.fractal_type == 5) {
            LYAPUNOV.fractal_param.value = document.getElementById("lya_squared_sine_mu").value;
            squared_sine_style.display = "block";
        }
        else if (LYAPUNOV.fractal_type == 6 || LYAPUNOV.fractal_type == 7) {
            LYAPUNOV.fractal_param.value = document.getElementById("lya_trig_theta").value;
            trig_style.display = "block";
        }
        else if (LYAPUNOV.fractal_type == 8) {
            LYAPUNOV.fractal_param.value = document.getElementById("lya_cosh_a").value;
            cosh_style.display = "block";
        }

        setupShader();
        redraw();

    }

    processSequenceEvent = function(event) {

        var key = event.key.toLowerCase();

        if (key != "x" && key != "y" && key != "z" && key != "backspace" && key != "arrowleft" && key != "arrowright") {
            event.preventDefault();
        }
    }

    updateSequence = function(event) {

        LYAPUNOV.sequence = [];
        
        for (var idx = 0; idx < event.target.value.length; idx++) {
            
            switch (event.target.value[idx]) {
                case "X":
                case "x":
                    LYAPUNOV.sequence.push(0);
                    break;

                case "Y":
                case "y":
                    LYAPUNOV.sequence.push(1);
                    break;

                case "Z":
                case "z":
                    LYAPUNOV.sequence.push(2);
                    break;
                    
            }
        }

        setupShader();
        redraw();

    }

    updateIterations = function(event) {
        LYAPUNOV.iterations = event.target.value;
        setupShader();
        redraw();
    }

    updateZValue = function(event) {

        LYAPUNOV.z_value.value = event.target.value;

        if (LYAPUNOV.sequence.includes(2)) {
            redraw();
        }
    }

    updateGaussAlpha = function(event) {
        // negate for performance reasons
        LYAPUNOV.fractal_param.value = -event.target.value;
        redraw();
    }
}