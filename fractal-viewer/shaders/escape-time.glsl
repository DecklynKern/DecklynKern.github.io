#version 300 es
precision highp float;

//%

uniform float magnitude;
uniform float centre_x;
uniform float centre_y;

uniform float fractal_param1;
uniform float fractal_param2;
uniform float fractal_param3;

uniform int max_iterations;
uniform float escape_radius_sq;

uniform float orbit_trap_param1;
uniform float orbit_trap_param2;

uniform int is_julia;
uniform float julia_c_real;
uniform float julia_c_imag;

uniform int smoothing_type;
uniform int colouring_type;
uniform vec3 trapped_colour;

uniform vec3 close_colour;
uniform vec3 far_colour;
uniform int interior_colouring_type;

uniform int samples;

const int TRUE_ITER_CAP = 10000;
const int TRUE_SAMPLE_CAP = 10;

in vec2 frag_position;
out vec4 colour;

const float PI = 3.1415926535;

struct Complex {
    float real;
    float imag;
};

Complex multiply(Complex x, Complex y) {
    return Complex(
        x.real * y.real - x.imag * y.imag,
        x.real * y.imag + y.real * x.imag
    );
}

Complex reciprocal(Complex z) {

    float sum = z.real * z.real + z.imag * z.imag;

    return Complex(
        z.real / sum,
        -z.imag / sum
    );
}

float argument(Complex z) {
    return atan(z.imag / z.real);
}

Complex exponent(Complex z, float d) {

    float r = pow(z.real * z.real + z.imag * z.imag, 0.5 * d);
    float theta = atan(z.imag, z.real) * d;

    return Complex(
        r * cos(theta),
        r * sin(theta)
    );
}

Complex exponent(Complex z, Complex d) {

    float z_norm_sq = z.real * z.real + z.imag * z.imag;
    float arg = argument(z);
    float r = pow(z_norm_sq, 0.5 * d.real);
    float angle = d.real * arg + 0.5 * z.imag * log(z_norm_sq);

    return Complex(r * cos(angle), r * sin(angle));

}

Complex exponent(Complex z) {
    float mag = exp(z.real);
    return Complex(
        mag * cos(z.imag),
        mag * sin(z.imag)
    );
}

vec3 interpolate(vec3 c1, vec3 c2, float amount) {
    return c1 * amount + c2 * (1.0 - amount);
}

vec3 getColour(float z_real, float z_imag) {

    float c_real, c_imag;

    if (bool(is_julia)) {
        c_real = julia_c_real;
        c_imag = julia_c_imag;
        
    } else {
        c_real = z_real;
        c_imag = z_imag;
    }

    Complex z = Complex(z_real, z_imag);
    Complex z_prev = Complex(z_imag, z_real);
    Complex c = Complex(c_real, c_imag);
    float z_real_sq = z_real * z_real;
    float z_imag_sq = z_imag * z_imag;
    float mag_sq = z_real_sq + z_imag_sq;

    int iterations;
    float interior_colour_param;
    Complex derivative;

    #if FRACTAL_TYPE == 10
        z = Complex(1.0, 0.0);

    #elif FRACTAL_TYPE == 19
        float r = PI * 2.0 * fractal_param1;
        Complex zc = Complex(
            cos(r),
            sin(r)
        );

    #elif FRACTAL_TYPE == 22
        Complex c_mul = Complex(
            c.real * c.real,
            c.imag * c.imag
        );

    #endif

    #if ORBIT_TRAP == 1
        float min_radius_sq = orbit_trap_param1 * orbit_trap_param1;

    #elif ORBIT_TRAP == 2
        float half_side = orbit_trap_param1 / 2.0;

    #elif ORBIT_TRAP == 3
        float cross_width = orbit_trap_param1 / 2.0;

    #elif ORBIT_TRAP == 4
        float ring_min_sq = orbit_trap_param1 * orbit_trap_param1;
        float ring_max_sq = orbit_trap_param2 * orbit_trap_param2;
    #endif

    for (int iteration = 0; iteration < TRUE_ITER_CAP; iteration++) {
    
        if (iteration >= max_iterations) {
            iterations = TRUE_ITER_CAP;
            break;
        }
        
        z_prev = z;

        #if FRACTAL_TYPE == 0 // mandelbrot
            z.imag = 2.0 * z.real * z.imag + c.imag;
            z.real = z_real_sq - z_imag_sq + c.real;

        #elif FRACTAL_TYPE == 1 // burning ship

            z.imag = abs(z.imag);
            z.real = abs(z.real);

            z.imag = 2.0 * z.real * z.imag + c.imag;
            z.real = z_real_sq - z_imag_sq + c.real;

        #elif FRACTAL_TYPE == 2 // tricorn

            z.imag = -z.real * z.imag;
            z.imag = 2.0 * z.imag + c.imag;

            z.real = z_real_sq - z_imag_sq + c.real;

        #elif FRACTAL_TYPE == 3 // heart

            float temp;

            temp = z.real * z.imag + c.real;
            z.imag = abs(z.imag) - abs(z.real) + c.imag;
            z.real = temp;

        #elif FRACTAL_TYPE == 4 // mandelbox

            if (mag_sq < 0.25) {
                z.real *= 4.0;
                z.imag *= 4.0;
            
            } else if (mag_sq < 1.0) {
                z.real /= mag_sq;
                z.imag /= mag_sq;
            }

            z.real = -fractal_param1 * z.real + c.real;
            z.imag = -fractal_param1 * z.imag + c.imag;
            
            if (z.real > 1.0) {
                z.real = 2.0 - z.real;
            
            } else if (z.real < -1.0) {
                z.real = -2.0 - z.real;
            }
            
            if (z.imag > 1.0) {
                z.imag = 2.0 - z.imag;
            
            } else if (z.imag < -1.0) {
                z.imag = -2.0 - z.imag;
            }

        #elif FRACTAL_TYPE == 5 // multibrot

            Complex z_exp = exponent(z, fractal_param1);

            z.real = z_exp.real + c.real;
            z.imag = z_exp.imag + c.imag;

        #elif FRACTAL_TYPE == 6 // feather

            Complex numerator = Complex(
                z.real * (z_real_sq - 3.0 * z_imag_sq),
                z.imag * (3.0 * z_real_sq - z_imag_sq)
            );

            Complex div = multiply(numerator, reciprocal(
                Complex(
                    1.0 + z_real_sq,
                    1.0 + z_imag_sq
                )
            ));

            z.real = div.real + c.real;
            z.imag = div.imag + c.imag;

        #elif FRACTAL_TYPE == 7 // chrikov
            z.imag += c.imag * sin(z.real);
            z.real += c.real * z.imag;

        #elif FRACTAL_TYPE == 8 // shoe

            z.real = sin(z.imag * z.real);
    
            z.imag = 2.0 * z.real * z.imag + c.imag;
            z.real = z_real_sq - z_imag_sq + c.real;

        #elif FRACTAL_TYPE == 9 // custom

            float z_real = z.real;

            z.real += sin(z.imag);
            z.real += sin(z_real);
    
            z.imag = 2.0 * z.real * z.imag + c.imag;

            z.real = z_real_sq - z_imag_sq + c.real;

        #elif FRACTAL_TYPE == 10 // power tower
            z = exponent(c, z);

        #elif FRACTAL_TYPE == 11 // duffing
    
            float z_real = z.real;

            z.real = z.imag;
            z.imag = c.imag * z_real + c.real * z.imag - z.imag * z_imag_sq;

        #elif FRACTAL_TYPE == 12 // gingerbread

            float z_real = z.real;

            z.real = 1.0 - z.imag + abs(z_real) + c.real;
            z.imag = z_real + c.imag;

        #elif FRACTAL_TYPE == 13 // henon

            float z_real = z.real;

            z.real = 1.0 - c.real * z_real_sq + z.imag;
            z.imag = c.imag * z_real;

        #elif FRACTAL_TYPE == 14 // sin

            float sin_real = sin(z.real) * cosh(z.imag);
            float sin_imag = cos(z.real) * sinh(z.imag);

            z.real = sin_real * c.real - sin_imag * c.imag;
            z.imag = c.real * sin_imag + sin_real * c.imag;

        #elif FRACTAL_TYPE == 15 // rational map

            Complex exp1 = exponent(z, fractal_param1);
            Complex exp2 = exponent(z, fractal_param2);

            z.real = exp1.real - fractal_param3 * exp2.real + c.real;
            z.imag = exp1.imag - fractal_param3 * exp2.imag + c.imag;

        #elif FRACTAL_TYPE == 16 // phoenix

            float z_real = z.real;

            z.real = z_real_sq - z_imag_sq + fractal_param1 * z_prev.real - fractal_param2 * z_prev.imag + c.real;
            z.imag = 2.0 * z_real * z.imag + fractal_param1 * z_prev.imag + fractal_param2 * z_prev.real + c.imag;

        #elif FRACTAL_TYPE == 17 // simonbrot
            z.imag = 2.0 * (z.real * z.imag) * mag_sq + c.imag;
            z.real = (z_real_sq - z_imag_sq) * mag_sq + c.real;

        #elif FRACTAL_TYPE == 18 //tippetts
            z.real = z_real_sq - z_imag_sq + c.real;
            z.imag = 2.0 * z.real * z.imag + c.imag;

        #elif FRACTAL_TYPE == 19 // marek dragon
            z = multiply(
                z, 
                Complex(
                    zc.real + z.real,
                    zc.imag + z.imag));

        #elif FRACTAL_TYPE == 20 // gangopadhyay

            Complex z_run = Complex(0.0, 0.0);

            float mag = sqrt(mag_sq);
            float t = atan(z.imag / z.real);

            #if G_1 == 1
                z_run.real += sin(z.real);
                z_run.imag += sin(z.imag);

            #elif G_2 == 1
                z_run.real += z.real / mag_sq;
                z_run.imag += z.imag / mag_sq;

            #elif G_3 == 1
                float theta = t + mag;
                z_run.real += mag * cos(theta);
                z_run.imag += mag * sin(theta);

            #elif G_4 == 1
                z_run.real += mag * cos(2.0 * t);
                z_run.imag += mag * sin(2.0 * t);

            #elif G_5 == 1
                z_run.real += t / PI,
                z_run.imag += mag - 1.0;

            #endif

            z = Complex(
                z_run.real / G_TOTAL,
                z_run.imag / G_TOTAL
            );

            z.imag = 2.0 * z.real * z.imag + c.imag;
            z.real = z_real_sq - z_imag_sq + c.real;

        #elif FRACTAL_TYPE == 21 // exponent
            z = multiply(c, exponent(z));

        #elif FRACTAL_TYPE == 22

            float dot = z_real_sq + z_imag_sq;
            Complex zc = multiply(z, c_mul);

            z = Complex(
                z.real * dot - zc.real,
                z.imag * dot - zc.imag);
            
        #endif
        
        z_real_sq = z.real * z.real;
        z_imag_sq = z.imag * z.imag;
        z_prev = z_prev;
        
        mag_sq = z_real_sq + z_imag_sq;

        #if ORBIT_TRAP == 0

            if (mag_sq >= escape_radius_sq) {
                iterations = iteration;
                break;
            }

        #elif ORBIT_TRAP == 1
        
            if (mag_sq >= escape_radius_sq || mag_sq <= min_radius_sq) {
                iterations = iteration;
                break;
            }

        #elif ORBIT_TRAP == 2
        
            if (mag_sq >= escape_radius_sq || 
                (z.real < orbit_trap_param1 &&
                -z.real < orbit_trap_param1 &&
                z.imag < orbit_trap_param1 &&
                -z.imag < orbit_trap_param1)
            ) {
                iterations = iteration;
                break;
            }

        #elif ORBIT_TRAP == 3

            if (mag_sq >= escape_radius_sq || 
                (-z.real < cross_width && z.real < cross_width) ||
                (-z.imag < cross_width && z.imag < cross_width)
            ) {
                iterations = iteration;
                break;
            }

        #elif ORBIT_TRAP == 4
        
            if (mag_sq >= escape_radius_sq || 
                (mag_sq >= ring_min_sq && mag_sq <= ring_max_sq)
            ) {
                iterations = iteration;
                break;
            }

        #endif
    }

    float f_iterations = float(iterations);

    if (iterations == TRUE_ITER_CAP) {

        if (interior_colouring_type == 0) {
            return trapped_colour;
        
        } else {
            return trapped_colour * (sin(interior_colour_param) + 1.0) / 2.0;
        }

    } else {

        if (smoothing_type == 1) {
            f_iterations += 1.0 + log(log(escape_radius_sq) / log(mag_sq)) / log(2.0);

        } else if (smoothing_type == 2) {
            f_iterations -= log(log(mag_sq) / log(f_iterations + 0.000001) * 0.5) / log(escape_radius_sq) * 2.0;
            f_iterations = max(f_iterations, 0.0);

        } else if (smoothing_type == 3) {
            f_iterations += (mag_sq - escape_radius_sq) / (escape_radius_sq - sqrt(escape_radius_sq));
        }

        if (colouring_type == 0) {
            return interpolate(close_colour, far_colour, f_iterations / float(max_iterations));

        } else if (colouring_type == 1) {
            return interpolate(close_colour, far_colour, sin(f_iterations) * 0.5 + 0.5);

        } else if (colouring_type == 2) {

            float h = 6.0 * fract(f_iterations / 12.0);
            float x = 1.0 - abs(2.0 * fract(f_iterations / 4.0) - 1.0);

            if (h < 1.0) {
                return vec3(1.0, x, 0);

            } else if (h < 2.0) {
                return vec3(x, 1.0, 0);
            
            } else if (h < 3.0) {
                return vec3(0, 1.0, x);
            
            } else if (h < 4.0) {
                return vec3(0, x, 1.0);
            
            } else if (h < 5.0) {
                return vec3(x, 0, 1.0);
            
            } else {
                return vec3(1.0, 0, x);
            }
        }   
    }
}

void main() {

    float pixel_size = 2.0 * magnitude / 1000.0;

    float real = centre_x + frag_position.x * magnitude;
    float imag = centre_y + frag_position.y * magnitude;

    vec3 colour_sum;

    for (int s = 0; s < TRUE_SAMPLE_CAP; s++) {

        if (s == samples) {
            break;
        }

        float real_offset = fract(0.1234 * float(s));
        float imag_offset = fract(0.7654 * float(s));

        colour_sum += getColour(real + real_offset * pixel_size, imag + imag_offset * pixel_size);

    }

    colour = vec4(colour_sum / float(samples), 1.0);
    
}