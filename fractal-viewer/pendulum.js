class Pendulum extends Program {

    shader = "shaders/pendulum.glsl";
    options_panel = "pendulum_options";

    iterations = 400;

    friction = new ParamFloat(0.01, "friction");
    tension = new ParamFloat(0.75, "tension");
    mass = new ParamFloat(1.0, "mass");
    dt = new ParamFloat(0.02, "dt");

    params = [
        this.friction,
        this.tension,
        this.mass,
        this.dt,
    ];

    magnet_strengths = [];
    magnet_strengths_attr = null;
    
    magnet_positions = [];
    magnet_positions_attr = null;

    magnet_colours = [];
    magnet_colours_attr = null;

    getShader() {

        var def = `//%
        #define ITERATIONS ${this.iterations}
        #define MAGNET_COUNT ${this.magnet_strengths.length}`;

        return this.baseShader.replace("//%", def);

    }

    setupGUI() {

        document.getElementById("pend_iterations").onchange = paramSetWithRecompile(this, "iterations");
        
        document.getElementById("pend_friction").onchange = paramSet(this.friction);
        document.getElementById("pend_tension").onchange = paramSet(this.tension);
        document.getElementById("pend_mass").onchange = paramSet(this.mass);
        document.getElementById("pend_dt").onchange = paramSet(this.dt);

        this.addMagnet();
        this.addMagnet();
        this.addMagnet();

        this.magnet_positions = [
             1.0,  0,
            -0.5, -0.866025404,
            -0.5,  0.866025404
        ];
    }

    setupAttrs() {

        super.setupAttrs();

        this.magnet_strengths_attr = gl.getUniformLocation(gl.program, "magnet_strengths");
        this.magnet_positions_attr = gl.getUniformLocation(gl.program, "magnet_positions");
        this.magnet_colours_attr = gl.getUniformLocation(gl.program, "magnet_colours");

    }

    loadAttrs() {

        super.loadAttrs();

        gl.uniform1fv(this.magnet_strengths_attr, this.magnet_strengths);
        gl.uniform2fv(this.magnet_positions_attr, this.magnet_positions);
        gl.uniform3fv(this.magnet_colours_attr, this.magnet_colours);

    }

    addMagnet() {

        var magnetNum = PENDULUM.magnet_strengths.length;
        var colour = BASIC_COLOURS[magnetNum % BASIC_COLOURS.length];

        var new_magnet_div1 = document.createElement("div");
        var new_magnet_div2 = document.createElement("div");
        new_magnet_div1.className = new_magnet_div2.className = "grid-entry";

        if (magnetNum != 0) {
            document.getElementById("magnets").appendChild(document.createElement("hr"));
        }

        new_magnet_div1.innerHTML = `Colour:
        <input type=color value=${colour} onchange="PENDULUM.setMagnetColour(event, ${magnetNum})">`

        new_magnet_div2.innerHTML = `Strength:
        <input type=number value=9.0 min=0 step=0.1 onchange="PENDULUM.setMagnetStrength(event, ${magnetNum})">`;

        document.getElementById("magnets").appendChild(new_magnet_div1);
        document.getElementById("magnets").appendChild(new_magnet_div2);

        PENDULUM.magnet_strengths.push(9);
        PENDULUM.magnet_positions.push(Math.random() * 2 - 1, Math.random() * 2 - 1);
        PENDULUM.magnet_colours.push(...hexToRGB(colour));

    }

    setMagnetColour(event, idx) {
        [PENDULUM.magnet_colours[3 * idx], PENDULUM.magnet_colours[3 * idx + 1], PENDULUM.magnet_colours[3 * idx + 2]] = hexToRGB(event.target.value);
        redraw();
    }

    setMagnetStrength(event, idx) {
        PENDULUM.magnet_strengths[idx] = hexToRGB(event.target.value);
        redraw();
    }


    drawPath(event) {

        if (program != PENDULUM) {
            return;
        }
        
        clearPath();

        var pos = [
            (event.layerX / canvas_size.value * 2 - 1) * magnitude.value + centre_x.value,
            (event.layerY / canvas_size.value * 2 - 1) * magnitude.value + centre_y.value
        ];

        var velocity = [0, 0];
        var accel_prev = [0, 0];

        path_context.beginPath();

        for (var iteration = 0; iteration < PENDULUM.iterations; iteration++) {
        
            path_context.lineTo(
                ((pos[0] - centre_x.value) / magnitude.value + 1) * canvas_size.value / 2,
                ((pos[1] - centre_y.value) / magnitude.value + 1) * canvas_size.value / 2
            );

            var accel = [0, 0];

            for (var i = 0; i < PENDULUM.magnet_strengths.length; i++) {

                const offset = [PENDULUM.magnet_positions[2 * i] - pos[0], PENDULUM.magnet_positions[2 * i + 1] - pos[1]];
                const dist_sq = offset[0] * offset[0] + offset[1] * offset[1] + 0.1;
                const str = PENDULUM.magnet_strengths[i] * Math.pow(dist_sq, -1.5);

                accel[0] += str * offset[0];
                accel[1] += str * offset[1];

            }

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