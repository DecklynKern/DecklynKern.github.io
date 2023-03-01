precision highp float;

uniform float magnitude;
uniform float centre_x;
uniform float centre_y;

uniform int samples;

uniform int iterations;

varying vec2 frag_position;

const int TRUE_ITER_CAP = 20;
const int TRUE_SAMPLE_CAP = 10;

const vec3 WHITE = vec3(1.0, 1.0, 1.0);
const vec3 BLACK = vec3(0.0, 0.0, 0.0);

float mmod(float x, float d) {
    return fract(x * d);
}

vec3 getColour(float x, float y) {

    if (x < 0.0 || x > 1.0 || y < 0.0 || y > 1.0) {
        return WHITE;
    }

    for (int iter = 0; iter < TRUE_ITER_CAP; iter++) {

        if (iter == iterations) {
            break;
        }

        if (0.33333333 < x && x < 0.66666667 && 0.33333333 < y && y < 0.66666667) {
            return WHITE;
        }

        x = mmod(x, 3.0);
        y = mmod(y, 3.0);

    }

    return BLACK;

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