class Pendulum extends Program {

    shader = "shaders/pendulum.glsl";
    options_panel = "pendulum_options";

    iterations = new Param(400);

    friction = new Param(0.01);
    tension = new Param(0.75);
    mass = new Param(1.0);
    dt = new Param(0.02);

    magnet1_strength = new Param(9.0);
    magnet2_strength = new Param(9.0);
    magnet3_strength = new Param(9.0);

    magnet1_colour = new Param([1.0, 0.0, 0.0]);
    magnet2_colour = new Param([0.0, 1.0, 0.0]);
    magnet3_colour = new Param([0.0, 0.0, 1.0]);

    setupGUI = function() {

        document.getElementById("pend_iterations").onchange = paramSet(this.iterations);
        
        document.getElementById("pend_friction").onchange = paramSet(this.friction);
        document.getElementById("pend_tension").onchange = paramSet(this.tension);
        document.getElementById("pend_mass").onchange = paramSet(this.mass);
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
        this.mass.getAttr("mass");
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
        this.mass.loadFloat();
        this.dt.loadFloat();

        this.magnet1_strength.loadFloat();
        this.magnet2_strength.loadFloat();
        this.magnet3_strength.loadFloat();

        this.magnet1_colour.loadFloat3();
        this.magnet2_colour.loadFloat3();
        this.magnet3_colour.loadFloat3();

    }

    drawPath = function(event) {

        if (program != PENDULUM) {
            return;
        }
        
        clearPath();

        var pos = [
            (event.layerX / canvas_size.value * 2 - 1) * magnitude.value + centre_x.value,
            (event.layerY / canvas_size.value * 2 - 1) * magnitude.value + centre_y.value
        ];
        
        const magnet1_pos = [ 0.75,   0.0     ];
        const magnet2_pos = [-0.375, -0.649519];
        const magnet3_pos = [-0.375,  0.649519];

        var velocity = [0, 0];
        var accel_prev = [0, 0];

        path_context.beginPath();

        for (var iteration = 0; iteration < PENDULUM.iterations.value; iteration++) {
        
            path_context.lineTo(
                ((pos[0] - centre_x.value) / magnitude.value + 1) * canvas_size.value / 2,
                ((pos[1] - centre_y.value) / magnitude.value + 1) * canvas_size.value / 2
            );

            const magnet1_offset = [magnet1_pos[0] - pos[0], magnet1_pos[1] - pos[1]];
            const magnet1_dist_sq = magnet1_offset[0] * magnet1_offset[0] + magnet1_offset[1] * magnet1_offset[1] + 0.1;

            const magnet2_offset = [magnet2_pos[0] - pos[0], magnet2_pos[1] - pos[1]];
            const magnet2_dist_sq = magnet2_offset[0] * magnet2_offset[0] + magnet2_offset[1] * magnet2_offset[1] + 0.1;

            const magnet3_offset = [magnet3_pos[0] - pos[0], magnet3_pos[1] - pos[1]];
            const magnet3_dist_sq = magnet3_offset[0] * magnet3_offset[0] + magnet3_offset[1] * magnet3_offset[1] + 0.1;

            const magnet1_str = PENDULUM.magnet1_strength.value * Math.pow(magnet1_dist_sq, -1.5);
            const magnet2_str = PENDULUM.magnet2_strength.value * Math.pow(magnet2_dist_sq, -1.5);
            const magnet3_str = PENDULUM.magnet3_strength.value * Math.pow(magnet3_dist_sq, -1.5);

            var accel = [
                magnet1_str * magnet1_offset[0] + magnet2_str * magnet2_offset[0] + magnet3_str * magnet3_offset[0],
                magnet1_str * magnet1_offset[1] + magnet2_str * magnet2_offset[1] + magnet3_str * magnet3_offset[1]
            ];

            accel[0] -= PENDULUM.tension.value * pos[0];
            accel[1] -= PENDULUM.tension.value * pos[1];

            accel[0] -= PENDULUM.friction.value * velocity[0];
            accel[1] -= PENDULUM.friction.value * velocity[1];
            
            accel[0] = accel[0] / PENDULUM.mass.value;
            accel[1] = accel[1] / PENDULUM.mass.value;

            velocity[0] += accel[0] * PENDULUM.dt.value;
            velocity[1] += accel[1] * PENDULUM.dt.value;

            pos[0] += velocity[0] * PENDULUM.dt.value + 0.166666666 * (4 * accel[0] - accel_prev[0]) * PENDULUM.dt.value * PENDULUM.dt.value;
            pos[1] += velocity[1] * PENDULUM.dt.value + 0.166666666 * (4 * accel[1] - accel_prev[1]) * PENDULUM.dt.value * PENDULUM.dt.value;

            accel_prev = accel;

        }

        path_context.stroke();

    }
}