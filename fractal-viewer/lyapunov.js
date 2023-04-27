LYAPUNOV_FUNCTIONS = [
    "x ← rx(1 - x)",
    "x ← e<sup>-αx²</sup> + r",
    "x ← x + Ω + r/2π*sin(2πx)",
    "x ← r - x<sup>2</sup>",
    "x ← rx(1 - x<sup>2</sup>)",
    "x ← rx(1 - x) + μsin<sup>2</sup>(2πx)"
]

class Lyapunov extends Program {

    shader = "shaders/lyapunov.glsl";
    options_panel = "lyapunov_options";

    fractal_type = 0;

    fractal_param = new Param(0);

    sequence0 = new Param(0);
    sequence1 = new Param(1);
    sequence2 = new Param(0);
    sequence3 = new Param(0);
    sequence4 = new Param(0);
    sequence5 = new Param(0);
    sequence6 = new Param(0);
    sequence7 = new Param(0);

    length = new Param(2);
    c_value = new Param(2);

    initial_value = new Param(0.5);

    iterations = new Param(250);

    stable_colour = new Param([1.0, 1.0, 0.0]);
    chaotic_colour = new Param([0.0, 0.0, 1.0]);
    infinity_colour = new Param([0.0, 0.0, 0.0]);

    getShader = function() {
        
        var shader = (' ' + this.baseShader).slice(1);
        var def = `#define FRACTAL_TYPE ${this.fractal_type}`;

        return shader.replace("//%", def);

    }

    setupGUI = function() {

        document.getElementById("lya_fractal_type").onchange = this.updateFractalType;
        document.getElementById("lya_gauss_alpha").onchange = paramSet(this.fractal_param);
        document.getElementById("lya_circle_omega").onchange = paramSet(this.fractal_param);
        document.getElementById("lya_sine_mu").onchange = paramSet(this.fractal_param);

        document.getElementById("lya_sequence").onkeydown = this.processSequenceEvent;
        document.getElementById("lya_sequence").onchange = this.updateSequence;
        document.getElementById("lya_initial").onchange = paramSet(this.initial_value);
        document.getElementById("c_value").oninput = this.updateCValue;
        
        document.getElementById("lya_iterations").onchange = paramSet(this.iterations);

        document.getElementById("stable_colour").onchange = paramSetColour(this.stable_colour);
        document.getElementById("chaotic_colour").onchange = paramSetColour(this.chaotic_colour);
        document.getElementById("infinity_colour").onchange = paramSetColour(this.infinity_colour);
    
    }

    setupAttrs = function() {

        this.fractal_param.getAttr("fractal_param");

        this.iterations.getAttr("iterations");

        this.sequence0.getAttr("sequence0");
        this.sequence1.getAttr("sequence1");
        this.sequence2.getAttr("sequence2");
        this.sequence3.getAttr("sequence3");
        this.sequence4.getAttr("sequence4");
        this.sequence5.getAttr("sequence5");
        this.sequence6.getAttr("sequence6");
        this.sequence7.getAttr("sequence7");

        this.length.getAttr("length");
        this.initial_value.getAttr("initial_value");
        this.c_value.getAttr("c_value");

        this.stable_colour.getAttr("stable_colour");
        this.chaotic_colour.getAttr("chaotic_colour");
        this.infinity_colour.getAttr("infinity_colour");

    }

    loadAttrs = function() {

        this.fractal_param.loadFloat();

        this.iterations.loadInt();

        this.sequence0.loadInt();
        this.sequence1.loadInt();
        this.sequence2.loadInt();
        this.sequence3.loadInt();
        this.sequence4.loadInt();
        this.sequence5.loadInt();
        this.sequence6.loadInt();
        this.sequence7.loadInt();

        this.length.loadInt();
        this.initial_value.loadFloat();
        this.c_value.loadFloat();
        
        this.stable_colour.loadFloat3();
        this.chaotic_colour.loadFloat3();
        this.infinity_colour.loadFloat3();

    }

    updateFractalType = function(event) {

        LYAPUNOV.fractal_type = event.target.value;

        var gauss_style = document.getElementById("lya_gauss_div").style;
        var circle_style = document.getElementById("lya_circle_div").style;
        var sine_style = document.getElementById("lya_sine_div").style;
        var function_text = document.getElementById("lya_function_text");

        gauss_style.display = "none";
        circle_style.display = "none";
        sine_style.display = "none";

        function_text.innerHTML = LYAPUNOV_FUNCTIONS[LYAPUNOV.fractal_type];

        if (LYAPUNOV.fractal_type == 1) {
            LYAPUNOV.fractal_param.value = document.getElementById("lya_gauss_alpha").value;
            gauss_style.display = "block";
            
        } else if (LYAPUNOV.fractal_type == 2) {
            LYAPUNOV.fractal_param.value = document.getElementById("lya_circle_omega").value;
            circle_style.display = "block";
                
        } else if (LYAPUNOV.fractal_type == 5) {
            LYAPUNOV.fractal_param.value = document.getElementById("lya_sine_mu").value;
            sine_style.display = "block";
        }

        setupShader();
        redraw();

    }

    processSequenceEvent = function(event) {

        if (event.key != "1" && event.key != "2" && event.key != "3" && event.key != "Backspace" && event.key != "ArrowLeft" && event.key != "ArrowRight") {
            event.preventDefault();
        }
    }

    updateSequence = function(event) {

        const sequence = event.target.value;

        var s = 0;
        var l = 0;

        for (var idx=0; idx<sequence.length; idx++) {

            l = -1;

            switch (sequence[idx]) {
                case "1":
                    l = 0;
                    break;

                case "2":
                    l = 1;
                    break;

                case "3":
                    l = 2;
                    break;
                    
            }

            if (l == -1) {
                continue;
            }

            switch (s) {

                case 0:
                    LYAPUNOV.sequence0.value = l;
                    break;

                case 1:
                    LYAPUNOV.sequence1.value = l;
                    break;

                case 2:
                    LYAPUNOV.sequence2.value = l;
                    break;

                case 3:
                    LYAPUNOV.sequence3.value = l;
                    break;

                case 4:
                    LYAPUNOV.sequence4.value = l;
                    break;

                case 5:
                    LYAPUNOV.sequence5.value = l;
                    break;

                case 6:
                    LYAPUNOV.sequence6.value = l;
                    break;

                case 7:
                    LYAPUNOV.sequence7.value = l;
                    break;
            }

            s++;

        }

        LYAPUNOV.length.value = s;

        redraw();

    }

    updateCValue = function(event) {

        LYAPUNOV.c_value.value = event.target.value;;

        if (document.getElementById("lya_sequence").value.includes("3")) {
            redraw();
        }
    }
}