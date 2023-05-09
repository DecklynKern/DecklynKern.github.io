#version 300 es
precision highp float;

uniform float magnitude;
uniform float centre_x;
uniform float centre_y;

uniform int samples;

uniform int iterations;

uniform float friction;
uniform float tension;
uniform float dt;

uniform float magnet1_strength;
uniform float magnet2_strength;
uniform float magnet3_strength;

uniform vec3 magnet1_colour;
uniform vec3 magnet2_colour;
uniform vec3 magnet3_colour;

in vec2 frag_position;
out vec4 colour;

const vec2 magnet1_pos = vec2(1, 0);
const vec2 magnet2_pos = vec2(-1, -1);
const vec2 magnet3_pos = vec2(-1, 1);

const int TRUE_ITER_CAP = 10000;
const int TRUE_SAMPLE_CAP = 10;

vec3 getColour(vec2 pos) {

    vec2 velocity = vec2(0.0, 0.0);

    for (int iteration = 0; iteration < TRUE_ITER_CAP; iteration++) {
    
        if (iteration >= iterations) {
            break;
        }

        vec2 magnet1_offset = magnet1_pos - pos; 
        float magnet1_dist = dot(magnet1_offset, magnet1_offset);

        vec2 magnet2_offset = magnet2_pos - pos; 
        float magnet2_dist = dot(magnet2_offset, magnet2_offset);

        vec2 magnet3_offset = magnet3_pos - pos; 
        float magnet3_dist = dot(magnet3_offset, magnet3_offset);

        vec2 accel = 
            magnet1_strength * magnet1_offset / (pow(magnet1_dist, 3.0)) +
            magnet2_strength * magnet2_offset / (pow(magnet2_dist, 3.0)) +
            magnet3_strength * magnet3_offset / (pow(magnet3_dist, 3.0))
            - tension * pos
            - friction * velocity;

        pos += velocity * dt + 0.5 * accel * dt * dt;
        velocity += accel * dt;

    }

    vec2 magnet1_offset = magnet1_pos - pos; 
    float magnet1_dist = dot(magnet1_offset, magnet1_offset);

    vec2 magnet2_offset = magnet2_pos - pos; 
    float magnet2_dist = dot(magnet2_offset, magnet2_offset);

    vec2 magnet3_offset = magnet3_pos - pos; 
    float magnet3_dist = dot(magnet3_offset, magnet3_offset);

    if (magnet1_dist < magnet2_dist && magnet1_dist < magnet3_dist) {
        return magnet1_colour;
    
    } else if (magnet2_dist < magnet3_dist) {
        return magnet2_colour;
    
    } else {
        return magnet3_colour;
    }
}

void main() {

    float pixel_size = 2.0 * magnitude / 1000.0;

    float x = centre_x + frag_position.x * magnitude;
    float y = -(centre_y + frag_position.y * magnitude);

    vec3 colour_sum;

    for (int s = 0; s < TRUE_SAMPLE_CAP; s++) {

        if (s == samples) {
            break;
        }

        float x_offset = fract(0.1234 * float(s));
        float y_offset = fract(0.7654 * float(s));

        colour_sum += getColour(vec2(
            x + x_offset * pixel_size,
            y + y_offset * pixel_size
        ));

    }

    colour = vec4(colour_sum / float(samples), 1.0);

}