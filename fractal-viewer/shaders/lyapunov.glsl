precision highp float;

uniform float magnitude;
uniform float centre_x;
uniform float centre_y;

uniform int sequence0;
uniform int sequence1;
uniform int sequence2;
uniform int sequence3;
uniform int sequence4;
uniform int sequence5;
uniform int sequence6;
uniform int sequence7;

uniform int length;
uniform float c_value;

uniform int samples;
uniform int iterations;

uniform vec3 stable_colour;
uniform vec3 chaotic_colour;
uniform vec3 infinity_colour;

varying vec2 frag_position;

const int TRUE_SAMPLE_CAP = 10;
const int TRUE_ITER_CAP = 10000;

vec3 getColour(float a, float b) {

    float x = 0.5;
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

        x = r * x * (1.0 - x);
        lambda += log(abs(r * (1.0 - x - x)));
    
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

    gl_FragColor = vec4(colour_sum / float(samples), 1.0);

}