var canvas;
var context;

var scroll_x = 0;
var scroll_y = 0;
var zoom = 5;

var inDrag = false;
var drag_start_x;
var drag_start_y;

function setup() {
    
    canvas = document.getElementById("main_canvas");
    context = canvas.getContext("2d"); 
    
    canvas.onmousedown = mouseClick;
    canvas.onmousemove = mouseMove;
    canvas.onmouseup = mouseRelease;
    
    canvas.onwheel = mouseWheel;
    
    redraw();
    
}

function mouseClick(event) {
    inDrag = true;
    drag_start_x = event.offsetX;
    drag_start_y = event.offsetY;
}

function mouseMove(event) {
    
    if (!inDrag) {
        return;
    }
    
    scroll_x += event.offsetX - drag_start_x;
    scroll_y += event.offsetY - drag_start_y;
    
    drag_start_x = event.offsetX;
    drag_start_y = event.offsetY;
    
    redraw();
    
}

function mouseRelease(event) {
    inDrag = false;
}

function mouseWheel(event) {
    // zoom could use to actually be centered on the mouse
    zoom /= 1 + (event.deltaY / 1000);
    redraw();
}

function patternChange(event) {
    
    if (event.key != "0" && event.key != "1") {
        event.preventDefault();
    }
}

function redraw() {
    
    canvas.width = document.body.clientWidth;
    canvas.height = document.body.clientHeight;
	
    var full_depth = document.getElementById("rows").value;
    
    var rule = document.getElementById("rule").value;    
    var rule_bits = [];
    for (var i = 0; i < 8; i++) {
        rule_bits[i] = (rule >> i) & 1;
    }
    
	context.clearRect(0, 0, canvas.width, canvas.height);
    
    var row_cells;
    
    for (var row = 0; row < full_depth; row++) {
        
        if (row == 0) {
            
            const pattern = document.getElementById("pattern").value;
            
            row_cells = new Int8Array(pattern.length + 4);
            
            for (var i = 0; i < pattern.length; i++) {
                row_cells[i + 2] = pattern[i];
            }
        }
        else {
            
            var new_row_cells = new Int8Array(row_cells.length + 2);
            
            for (var i = 2; i < row_cells.length; i++) {
                new_row_cells[i] = rule_bits[(row_cells[i - 2] << 2) | (row_cells[i - 1] << 1) | row_cells[i]];
            }
            
            row_cells = new_row_cells;
            
        }
        
        var y = row * zoom + scroll_y;
        var row_offset = Math.floor(row_cells.length / 2);	
        
        for (var i = 0; i < row_cells.length; i++) {
         
            if (row_cells[i]) {
                context.fillRect(400 + (i - row_offset) * zoom + scroll_x, y, zoom, zoom);
            }
        }
    }
}
