class Recursive extends Program {

    shader = "shaders/recursive.glsl";
    options_panel = "recursive_options";

    fractal_type = new Param(0);
    iterations = new Param(8);

    setupGUI = function() {
        document.getElementById("rc_fractal_type").onchange = paramSet(this.fractal_type);
        document.getElementById("rc_iterations").onchange = paramSet(this.iterations);
    }

    setupAttrs = function() {
        this.fractal_type.getAttr("fractal_type");
        this.iterations.getAttr("iterations");
    }

    loadAttrs = function() {
        this.fractal_type.loadInt();
        this.iterations.loadInt();
    }
}