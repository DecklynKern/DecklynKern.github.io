const axiom = "-YF";
const ruleHeads = ['X', 'Y'];
const ruleReplaces = ["XFX-YF-YF+FX+FX-YF-YFFX+YF+FXFXYF-FX+YF+FXFX+YF-FXYF-YF-FX+FX+YFYF-", "+FXFX-YF-YF+FX+FXYF+FX-YFYF-FX-YF+FXYFYF-FX-YFFX+FX+YF-YF-FX+FX+YFY"];
const lineSize = 100;

var canvas;
var context;

var pos_x;
var pos_y;
var angle;
var stack;

var turning_angle = Math.PI / 2;
var full_depth;

function setup() {	
	canvas = document.getElementById("main_canvas");
	context = canvas.getContext("2d");
}

function draw() {
	
	pos_x = canvas.width / 2;
	pos_y = canvas.height / 2;
	angle = 0;
	stack = [];
	
	full_depth = document.getElementById("depth").value;
	
	context.clearRect(0, 0, canvas.width, canvas.height);
	context.beginPath();
	context.moveTo(pos_x, pos_y);
	drawPattern(axiom, full_depth);
	context.stroke();
	
}

function drawPattern(pattern, depth) {
	
	for (var i = 0; i < pattern.length; i++) {
		
		if (depth > 1) {
		
			var usedRule = false;
			
			for (var r = 0; r < ruleHeads.length; r++) {
				if (pattern[i] == ruleHeads[r]) {
					drawPattern(ruleReplaces[r], depth - 1);
					usedRule = true;
					break;
				}
			}
			
			if (usedRule) {
				continue;
			}
		}
	
		switch (pattern[i]) {
		
			case 'F':
			
				pos_x += lineSize * Math.cos(angle) / full_depth;
				pos_y += lineSize * Math.sin(angle) / full_depth;
				
				context.lineTo(pos_x, pos_y);
				
				break;
				
			case 'f':
			
				pos_x += lineSize * Math.cos(angle) / full_depth;
				pos_y += lineSize * Math.sin(angle) / full_depth;
				
				context.moveTo(pos_x, pos_y);
				
				break;
				
			case '+':
				angle += turning_angle;
				break;
				
			case '-':
				angle -= turning_angle;
				break;
				
			case '|':
				angle = -angle;
				break;
				
			case '[':
				stack.push([pos_x, pos_y, angle]);
				break;
				
			case ']':
				[pos_x, pos_y, angle] = stack.pop();
				context.moveTo(pos_x, pos_y);
				break;
				
		}
	}
}