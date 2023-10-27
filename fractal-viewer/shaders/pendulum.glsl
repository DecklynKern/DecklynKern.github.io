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

const vec2 magnet1_pos = vec2(0.5, 0.0);
const vec2 magnet2_pos = vec2(-0.5, -0.5);
const vec2 magnet3_pos = vec2(-0.5, 0.5);

const int TRUE_ITER_CAP = 10000;
const int TRUE_SAMPLE_CAP = 10;

vec3 getColour(float x, float y) {

    vec2 pos = vec2(x, y);
    vec2 pos_prev = vec2(MAX, MAX);
    vec2 velocity = vec2(0.0, 0.0);

    vec2 accel;
    vec2 accel_prev = vec2(0.0, 0.0);

    int iters_taken = iterations;

    for (int iteration = 0; iteration < TRUE_ITER_CAP; iteration++) {
    
        if (iteration >= iterations) {
            break;
        }

        vec2 magnet1_offset = magnet1_pos - pos; 
        float magnet1_dist_sq = dot(magnet1_offset, magnet1_offset) + 0.1;

        vec2 magnet2_offset = magnet2_pos - pos; 
        float magnet2_dist_sq = dot(magnet2_offset, magnet2_offset) + 0.1;

        vec2 magnet3_offset = magnet3_pos - pos; 
        float magnet3_dist_sq = dot(magnet3_offset, magnet3_offset) + 0.1;

        vec2 accel = 
            magnet1_strength * magnet1_offset * pow(magnet1_dist_sq, -1.5) +
            magnet2_strength * magnet2_offset * pow(magnet2_dist_sq, -1.5) +
            magnet3_strength * magnet3_offset * pow(magnet3_dist_sq, -1.5)
            - tension * pos
            - friction * velocity;

        velocity += accel * dt;
        pos += velocity * dt + 0.1666666 * (4.0 * accel - accel_prev) * dt * dt;

        vec2 diff = pos - pos_prev;

        if (dot(diff, diff) < 0.00001) {
            iters_taken = iteration;
            break;
        }

        accel_prev = accel;
        pos_prev = pos;

    }

    vec2 magnet1_offset = magnet1_pos - pos; 
    float magnet1_dist = dot(magnet1_offset, magnet1_offset);

    vec2 magnet2_offset = magnet2_pos - pos; 
    float magnet2_dist = dot(magnet2_offset, magnet2_offset);

    vec2 magnet3_offset = magnet3_pos - pos; 
    float magnet3_dist = dot(magnet3_offset, magnet3_offset);

    vec3 magnet_colour;

    if (magnet1_dist < magnet2_dist && magnet1_dist < magnet3_dist) {
        magnet_colour = magnet1_colour;
    }
    else if (magnet2_dist < magnet3_dist) {
        magnet_colour = magnet2_colour;
    }
    else {
        magnet_colour = magnet3_colour;
    }

    return magnet_colour * (1.0 - float(iters_taken) / float(iterations));

}