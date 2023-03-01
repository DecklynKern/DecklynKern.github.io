class RootFinding {

    shader = "shaders/root-finding.glsl";
    options_panel = "root_finding_options";

    root_clicked = 0;

    algorithm = new Param(0);
    fractal_type = new Param(0);

    max_iterations = new Param(40);
    threshold = new Param(0.000001);
    
    root1_real = new Param(1.0);
    root1_imag = new Param(0.0);
    root2_real = new Param(-0.5);
    root2_imag = new Param(-0.866025404);
    root3_real = new Param(-0.5);
    root3_imag = new Param(0.866025404);
    
    colouring_type = new Param(0);
    root1_colour = new Param([1.0, 0.0, 0.0]);
    root2_colour = new Param([0.0, 1.0, 0.0]);
    root3_colour = new Param([0.0, 0.0, 1.0]);
    base_colour = new Param([0.0, 0.0, 0.0]);

    setupGUI = function() {
        
        document.getElementById("rtf_fractal_type").onchange = paramSet(this.fractal_type);
        document.getElementById("rtf_algorithm").onchange = paramSet(this.algorithm);
        
        document.getElementById("rtf_iterations").onchange = paramSet(this.max_iterations);
        document.getElementById("rtf_threshold").onchange = paramSet(this.threshold);
        
        document.getElementById("root_selector").onmousedown = this.clickRoot;
        document.getElementById("root_selector").onmousemove = this.updateRoots;
        
        document.getElementById("rtf_colouring_type").onchange = this.updateColouringType; 
        document.getElementById("root1_colour").onchange = paramSetColour(this.root1_colour);
        document.getElementById("root2_colour").onchange = paramSetColour(this.root2_colour);
        document.getElementById("root3_colour").onchange = paramSetColour(this.root3_colour);
        document.getElementById("base_colour").onchange = paramSetColour(this.base_colour);

        this.root_canvas_context = document.getElementById("root_selector").getContext("2d");
        this.drawRoots();

    }

    setupAttrs = function() {
        
        this.fractal_type.getAttr("fractal_type");
        this.algorithm.getAttr("algorithm");

        this.max_iterations.getAttr("max_iterations");
        this.threshold.getAttr("threshold");
        
        this.root1_real.getAttr("root1_real");
        this.root1_imag.getAttr("root1_imag");
        this.root2_real.getAttr("root2_real");
        this.root2_imag.getAttr("root2_imag");
        this.root3_real.getAttr("root3_real");
        this.root3_imag.getAttr("root3_imag");
        
        this.colouring_type.getAttr("colouring_type");
        this.root1_colour.getAttr("root1_colour");
        this.root2_colour.getAttr("root2_colour");
        this.root3_colour.getAttr("root3_colour");
        this.base_colour.getAttr("base_colour");

    }

    loadAttrs = function() {
        
        this.fractal_type.loadInt();
        this.algorithm.loadInt();

        this.max_iterations.loadInt();
        this.threshold.loadFloat();
        
        this.root1_colour.loadFloat3();
        this.root2_colour.loadFloat3();
        this.root3_colour.loadFloat3();
        this.base_colour.loadFloat3();
        
        this.colouring_type.loadInt();
        this.root1_real.loadFloat();
        this.root1_imag.loadFloat();
        this.root2_real.loadFloat();
        this.root2_imag.loadFloat();
        this.root3_real.loadFloat();
        this.root3_imag.loadFloat();

    }

    drawRoots = function() {

        this.root_canvas_context.clearRect(0, 0, 200, 200);

        this.root_canvas_context.strokeStyle = "black";
        this.root_canvas_context.beginPath();
        this.root_canvas_context.moveTo(0, 100);
        this.root_canvas_context.lineTo(200, 100);
        this.root_canvas_context.moveTo(100, 0);
        this.root_canvas_context.lineTo(100, 200);
        this.root_canvas_context.stroke();

        this.root_canvas_context.strokeStyle = document.getElementById("root1_colour").value;
        this.root_canvas_context.beginPath();
        this.root_canvas_context.arc(100 + 50 * ROOT_FINDING.root1_real.value, 100 + 50 * ROOT_FINDING.root1_imag.value, 4, 0, 2 * Math.PI);
        this.root_canvas_context.stroke();
        
        this.root_canvas_context.strokeStyle = document.getElementById("root2_colour").value;
        this.root_canvas_context.beginPath();
        this.root_canvas_context.arc(100 + 50 * ROOT_FINDING.root2_real.value, 100 + 50 * ROOT_FINDING.root2_imag.value, 4, 0, 2 * Math.PI);
        this.root_canvas_context.stroke();
        
        this.root_canvas_context.strokeStyle = document.getElementById("root3_colour").value;
        this.root_canvas_context.beginPath();
        this.root_canvas_context.arc(100 + 50 * ROOT_FINDING.root3_real.value, 100 + 50 * ROOT_FINDING.root3_imag.value, 4, 0, 2 * Math.PI);
        this.root_canvas_context.stroke();

    }

    clickRoot = function(event) {

        const dx1 = 100 + 50 * ROOT_FINDING.root1_real.value - event.offsetX;
        const dy1 = 100 + 50 * ROOT_FINDING.root1_imag.value - event.offsetY;
        const root1_dist = dx1 * dx1 + dy1 * dy1;

        const dx2 = 100 + 50 * ROOT_FINDING.root2_real.value - event.offsetX;
        const dy2 = 100 + 50 * ROOT_FINDING.root2_imag.value - event.offsetY;
        const root2_dist = dx2 * dx2 + dy2 * dy2;
        
        const dx3 = 100 + 50 * ROOT_FINDING.root3_real.value - event.offsetX;
        const dy3 = 100 + 50 * ROOT_FINDING.root3_imag.value - event.offsetY;
        const root3_dist = dx3 * dx3 + dy3 * dy3;

        const min_dist = Math.min(root1_dist, root2_dist, root3_dist);

        if (min_dist > 20) {
            return;
        }

        if (min_dist == root1_dist) {
            ROOT_FINDING.root_clicked = 1;
            
        } else if (min_dist == root2_dist) {
            ROOT_FINDING.root_clicked = 2;
            
        } else {
            ROOT_FINDING.root_clicked = 3;
        }
    }

    updateRoots = function(event) {
        
        if (!mouse_down) {
            ROOT_FINDING.root_clicked = 0;
            return;
        }

        const new_real = (event.offsetX - 100) / 50;
        const new_imag = (event.offsetY - 100) / 50;

        switch (ROOT_FINDING.root_clicked) {

            case 0:
                return;

            case 1:
                ROOT_FINDING.root1_real.value = new_real;
                ROOT_FINDING.root1_imag.value = new_imag;
                break;

            case 2:
                ROOT_FINDING.root2_real.value = new_real;
                ROOT_FINDING.root2_imag.value = new_imag;
                break;

            case 3:
                ROOT_FINDING.root3_real.value = new_real;
                ROOT_FINDING.root3_imag.value = new_imag;

        }

        ROOT_FINDING.drawRoots();
        redraw();

    }

    updateColouringType = function(event) {

        const colouring_type = event.target.value;
        ROOT_FINDING.colouring_type.value = colouring_type;
   
        const root_colour_div = document.getElementById("root_colour_div");
        
        if (colouring_type == 2) {
            root_colour_div.style.display = "none";
        
        } else {
            root_colour_div.style.display = "block";
        }
    
        redraw();
    
    }
}