precision highp float;

uniform float magnitude;
uniform float centre_x;
uniform float centre_y;

uniform int fractal_type;
uniform int max_iterations;
uniform int colouring_type;

uniform vec3 root1_colour;
uniform vec3 root2_colour;
uniform vec3 root3_colour;
uniform vec3 base_colour;

const int TRUE_ITER_CAP = 10000;
const int TRUE_SAMPLE_CAP = 10;

uniform int samples;
varying vec2 frag_position;

struct Complex {
    float real;
    float imag;
};

Complex reciprocal(Complex z) {
    float denom = z.real * z.real + z.imag * z.imag;
    return Complex(z.real / denom, -z.imag / denom);
}

Complex square(Complex z) {
    return Complex(z.real * z.real - z.imag * z.imag, (z.real + z.real) * z.imag);
}

float root_dist_sq(Complex z, Complex root) {

    float d_real = z.real - root.real;
    float d_imag = z.imag - root.imag;

    return d_real * d_real + d_imag * d_imag;

}

vec3 getColour(Complex z) {

    int iters;

    if (fractal_type == 0) {

        for (int iter = 0; iter < TRUE_ITER_CAP; iter++) {

            if (iter == max_iterations) {
                iters = iter;
                break;
            }

            Complex reciprocal_sq = square(reciprocal(z));

            Complex z_new =  Complex(
                (z.real + z.real + reciprocal_sq.real) / 3.0,
                (z.imag + z.imag + reciprocal_sq.imag) / 3.0
            );

            if (z_new.real == z.real && z_new.imag == z.imag) {
                iters = iter;
                break;
            }

            z = z_new;

        }
    
    } else {

        Complex c = z;
        z = Complex(1.0, 0.0);

        for (int iter = 0; iter < TRUE_ITER_CAP; iter++) {

            if (iter == max_iterations) {
                break;
            }

            Complex reciprocal_sq = square(reciprocal(z));

            Complex z_new =  Complex(
                (z.real + z.real + reciprocal_sq.real) / 3.0 + c.real,
                (z.imag + z.imag + reciprocal_sq.imag) / 3.0 + c.imag
            );

            if (z_new.real == z.real && z_new.imag == z.imag) {
                iters = iter;
                break;
            }

            z = z_new;
        }
    }

    if (colouring_type == 0 || colouring_type == 1) {

        float root_dist_1 = root_dist_sq(z, Complex(1.0, 0.0));
        float root_dist_2 = root_dist_sq(z, Complex(-0.5, -0.866025404));
        float root_dist_3 = root_dist_sq(z, Complex(-0.5, 0.866025404));

        float amount;

        if (colouring_type == 0) {
            amount = 1.0;
        
        } else {
            amount = 1.0 - float(iters) / float(max_iterations);
        }

        if (root_dist_1 < root_dist_2 && root_dist_1 < root_dist_3) {
            return root1_colour * amount + base_colour * (1.0 - amount);
        
        } else if (root_dist_2 < root_dist_3) {
            return root2_colour * amount + base_colour * (1.0 - amount);
        
        } else {
            return root3_colour * amount + base_colour * (1.0 - amount);
        }

    } else if (colouring_type == 2) {
        float amount = float(iters) / float(max_iterations);
        return vec3(amount, amount, amount);
    }
}

void main() {

    float pixel_size = 2.0 * magnitude / 1000.0;

    float real = centre_x + frag_position.x * magnitude;
    float imag = centre_y + frag_position.y * magnitude;

    vec3 colour_sum;

    for (int sample = 0; sample < TRUE_SAMPLE_CAP; sample++) {

        if (sample == samples) {
            break;
        }

        float real_offset = fract(0.1234 * float(sample));
        float imag_offset = fract(0.7654 * float(sample));

        colour_sum += getColour(Complex(real + real_offset * pixel_size, imag + imag_offset * pixel_size));

    }

    gl_FragColor = vec4(colour_sum / float(samples), 1.0);

}