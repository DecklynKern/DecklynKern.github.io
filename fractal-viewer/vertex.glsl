attribute vec2 position;
varying vec2 frag_position;

void main() {
    gl_Position = vec4(position, 0, 1);
    frag_position = position;
}