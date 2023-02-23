class Lyapunov {

    shader = "shaders/lyapunov.glsl";
    options_panel = "lyapunov_options";

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

    iterations = new Param(500);

    stable_colour = new Param([1.0, 1.0, 0.0]);
    chaotic_colour = new Param([0.0, 0.0, 1.0]);
    infinity_colour = new Param([0.0, 0.0, 0.0]);

    setupGUI = function() {

        document.getElementById("lya_sequence").onkeydown = this.processSequenceEvent;
        document.getElementById("lya_sequence").onchange = this.updateSequence;
        document.getElementById("c_value").oninput = this.updateCValue;
        
        document.getElementById("lya_iterations").onchange = this.updateIterations;

        document.getElementById("stable_colour").onchange = this.updateStableColour;
        document.getElementById("chaotic_colour").onchange = this.updateChaoticColour;
        document.getElementById("infinity_colour").onchange = this.updateInfinityColour;
    
    }

    setupAttrs = function() {

        this.iterations.attr = gl.getUniformLocation(gl.program, "iterations");

        this.sequence0.attr = gl.getUniformLocation(gl.program, "sequence0");
        this.sequence1.attr = gl.getUniformLocation(gl.program, "sequence1");
        this.sequence2.attr = gl.getUniformLocation(gl.program, "sequence2");
        this.sequence3.attr = gl.getUniformLocation(gl.program, "sequence3");
        this.sequence4.attr = gl.getUniformLocation(gl.program, "sequence4");
        this.sequence5.attr = gl.getUniformLocation(gl.program, "sequence5");
        this.sequence6.attr = gl.getUniformLocation(gl.program, "sequence6");
        this.sequence7.attr = gl.getUniformLocation(gl.program, "sequence7");

        this.length.attr = gl.getUniformLocation(gl.program, "length");
        this.c_value.attr = gl.getUniformLocation(gl.program, "c_value");

        this.stable_colour.attr = gl.getUniformLocation(gl.program, "stable_colour");
        this.chaotic_colour.attr = gl.getUniformLocation(gl.program, "chaotic_colour");
        this.infinity_colour.attr = gl.getUniformLocation(gl.program, "infinity_colour");

    }

    loadAttrs = function() {

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
        this.c_value.loadFloat();

        this.stable_colour.loadFloat3();
        this.chaotic_colour.loadFloat3();
        this.infinity_colour.loadFloat3();

    }

    updateIterations = function(_ev) {
        LYAPUNOV.iterations.value = document.getElementById("lya_iterations").value;
        redraw();
    }

    processSequenceEvent = function(event) {

        if (event.key != "1" && event.key != "2" && event.key != "3" && event.key != "Backspace" && event.key != "ArrowLeft" && event.key != "ArrowRight") {
            event.preventDefault();
        }
    }

    updateSequence = function(_ev) {

        const sequence_input = document.getElementById("lya_sequence");

        var s = 0;
        var l = 0;

        for (var idx=0; idx<sequence_input.value.length; idx++) {

            l = -1;

            switch (sequence_input.value[idx]) {
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

    updateCValue = function(_ev) {

        LYAPUNOV.c_value.value = document.getElementById("c_value").value;

        if (document.getElementById("lya_sequence").value.includes("3")) {
            redraw();
        }
    }

    updateStableColour = function(_ev) {
        LYAPUNOV.stable_colour.value = hexToRGB(document.getElementById("stable_colour").value);
        redraw();
    }

    updateChaoticColour = function(_ev) {
        LYAPUNOV.chaotic_colour.value = hexToRGB(document.getElementById("chaotic_colour").value);
        redraw();
    }

    updateInfinityColour = function(_ev) {
        LYAPUNOV.infinity_colour.value = hexToRGB(document.getElementById("infinity_colour").value);
        redraw();
    }
}