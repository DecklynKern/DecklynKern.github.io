#version 300 es
precision highp float;

//%

uniform float magnitude;
uniform float centre_x;
uniform float centre_y;

uniform float fractal_param;

uniform int sequence0;
uniform int sequence1;
uniform int sequence2;
uniform int sequence3;
uniform int sequence4;
uniform int sequence5;
uniform int sequence6;
uniform int sequence7;

uniform int length;
uniform float initial_value;
uniform float c_value;

uniform int samples;
uniform int iterations;

uniform vec3 stable_colour;
uniform vec3 chaotic_colour;
uniform vec3 infinity_colour;

in vec2 frag_position;
out vec4 colour;

const int TRUE_SAMPLE_CAP = 10;
const int TRUE_ITER_CAP = 10000;

const float PI = 3.141592653589;
const float TAU = 2.0 * PI;

vec3 getColour(float a, float b) {

    float x = initial_value;
    float lambda = 0.0;
    float r;
    int letter_idx = 0;
    int letter;

    for (int iter = 0; iter < TRUE_ITER_CAP; iter++) {
        
        if (iter == iterations) {
            break;
        }
        
        letter_idx++;
        
        if (letter_idx == length) {
            letter_idx = 0;
        }
        
        if (letter_idx == 0) {
            letter = sequence0;
        
        } else if (letter_idx == 1) {
            letter = sequence1;
        
        } else if (letter_idx == 2) {
            letter = sequence2;
        
        } else if (letter_idx == 3) {
            letter = sequence3;
        
        } else if (letter_idx == 4) {
            letter = sequence4;
        
        } else if (letter_idx == 5) {
            letter = sequence5;
        
        } else if (letter_idx == 6) {
            letter = sequence6;
        
        } else {
            letter = sequence7;
        }
        
        if (letter == 0) {
            r = a;
        
        } else if (letter == 1) {
            r = b;
        
        } else {
            r = c_value;
        }

        #if FRACTAL_TYPE == 0 // logistic map
            x = r * x * (1.0 - x);
            lambda += log(abs(r * (1.0 - 2.0 * x)));

        #elif FRACTAL_TYPE == 1 // gauss map
            x = exp(-fractal_param * x * x) + r;
            float xa = x * fractal_param;
            lambda += log(abs(2.0 * xa * exp(-x * xa)));

  
                            <option value="9">Collatz</option>          x = r - fractal_param * x * x;
            lambda += log(abs(2.0 * fractal_param * x));

        #elif FRACTAL_TYPE == 4 // square logistic
            x = r * x * (1.0 - x * x);
            lambda += log(abs(1.0 - 3.0 * x * x));

        #elif FRACTAL_TYPE == 5 // squared sine logistic
            float s = sin(TAU * x);
            x = r * x * (1.0 - x) + fractal_param * s * s;
            float angle = TAU * x;
            lambda += log(abs(r * (1.0 - 2.0 * x) + fractal_param * TAU * sin(angle) * cos(angle)));

        #elif FRACTAL_TYPE == 6
            x = r * sin(x + fractal_param);
            lambda += log(abs(r * cos(x)));

        #elif FRACTAL_TYPE == 7
            x = r * cos(x + fractal_param);
            lambda += log(abs(r * sin(x)));

        #elif FRACTAL_TYPE == 8
            x = r * (fractal_param - cosh(x));
            lambda += log(abs(r * sinh(x)));

        #endif
        
    }

    lambda /= float(iterations) * 3.0;

    if (lambda < 0.0) {
        float amount = min(sqrt(-lambda), 1.0);
        return stable_colour * (1.0 - amount) + infinity_colour * amount;

    } else {
        float amount = sqrt(lambda);
        return chaotic_colour * (1.0 - amount) + infinity_colour * amount;
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

        colour_sum += getColour(x + x_offset * pixel_size, y + y_offset * pixel_size);

    }

    colour = vec4(colour_sum / float(samples), 1.0);

}