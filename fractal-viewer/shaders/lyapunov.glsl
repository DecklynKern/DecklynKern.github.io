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

uniform int iterations;

uniform vec3 stable_colour;
uniform vec3 chaotic_colour;
uniform vec3 infinity_colour;

const int TRUE_ITER_CAP = 10000;

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
        
        }
        else if (letter_idx == 1) {
            letter = sequence1;
        }
        else if (letter_idx == 2) {
            letter = sequence2;
        }
        else if (letter_idx == 3) {
            letter = sequence3;
        }
        else if (letter_idx == 4) {
            letter = sequence4;
        }
        else if (letter_idx == 5) {
            letter = sequence5;
        }
        else if (letter_idx == 6) {
            letter = sequence6;
        }
        else {
            letter = sequence7;
        }
        
        if (letter == 0) {
            r = a;
        }
        else if (letter == 1) {
            r = b;
        }
        else {
            r = c_value;
        }

        #if FRACTAL_TYPE == 0 // logistic map
            x = r * x * (1.0 - x);
            lambda += log(abs(r * (1.0 - 2.0 * x)));

        #elif FRACTAL_TYPE == 1 // gauss map
            x = exp(-fractal_param * x * x) + r;
            float xa = x * fractal_param;
            lambda += log(abs(2.0 * xa * exp(-x * xa)));

        #elif FRACTAL_TYPE == 2 // circle map
            x += fractal_param + 0.000001 - r / TAU * sin(TAU * x);
            lambda += log(abs(1.0 - r * cos(TAU * x)));

        #elif FRACTAL_TYPE == 3 // quadratic
            x = r - fractal_param * x * x;
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
        return mix(stable_colour, infinity_colour, min(sqrt(-lambda), 1.0));
    }
    else {
        float amount = sqrt(lambda);
        return chaotic_colour * (1.0 - amount) + infinity_colour * amount;

        // return mix(chaotic_colour, infinity_colour, sqrt(lambda));
        // fsr this doesn't work right
    }
}