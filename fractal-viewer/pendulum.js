class Pendulum extends Program {

    shader = "shaders/pendulum.glsl";
    options_panel = "pendulum_options";

    iterations = new Param(40);

    friction = new Param(1.0);
    tension = new Param(1.0);
    dt = new Param(0.25);

    magnet1_strength = new Param(1.0);
    magnet2_strength = new Param(1.0);
    magnet3_strength = new Param(1.0);

    magnet1_colour = new Param([1.0, 0.0, 0.0]);
    magnet2_colour = new Param([0.0, 1.0, 0.0]);
    magnet3_colour = new Param([0.0, 0.0, 1.0]);

    setupGUI = function() {

        document.getElementById("pend_iterations").onchange = paramSet(this.iterations);
        
        document.getElementById("pend_friction").onchange = paramSet(this.friction);
        document.getElementById("pend_tension").onchange = paramSet(this.tension);
        document.getElementById("pend_dt").onchange = paramSet(this.dt);

        document.getElementById("magnet1_strength").onchange = paramSet(this.magnet1_strength);
        document.getElementById("magnet2_strength").onchange = paramSet(this.magnet2_strength);
        document.getElementById("magnet3_strength").onchange = paramSet(this.magnet3_strength);

        document.getElementById("magnet1_colour").onchange = paramSetColour(this.magnet1_colour);
        document.getElementById("magnet2_colour").onchange = paramSetColour(this.magnet2_colour);
        document.getElementById("magnet3_colour").onchange = paramSetColour(this.magnet3_colour);


    }

    setupAttrs = function() {

        this.iterations.getAttr("iterations");

        this.friction.getAttr("friction");
        this.tension.getAttr("tension");
        this.dt.getAttr("dt");

        this.magnet1_strength.getAttr("magnet1_strength");
        this.magnet2_strength.getAttr("magnet2_strength");
        this.magnet3_strength.getAttr("magnet3_strength");

        this.magnet1_colour.getAttr("magnet1_colour");
        this.magnet2_colour.getAttr("magnet2_colour");
        this.magnet3_colour.getAttr("magnet3_colour");

    }

    loadAttrs = function() {

        this.iterations.loadInt();

        this.friction.loadFloat();
        this.tension.loadFloat();
        this.dt.loadFloat();

        this.magnet1_strength.loadFloat();
        this.magnet2_strength.loadFloat();
        this.magnet3_strength.loadFloat();

        this.magnet1_colour.loadFloat3();
        this.magnet2_colour.loadFloat3();
        this.magnet3_colour.loadFloat3();

    }
}