#version 300 es
precision highp float;

//%

uniform float magnitude;
uniform float centre_x;
uniform float centre_y;

uniform float fractal_param1;
uniform float fractal_param2;
uniform float fractal_param3;

uniform int is_inverted;

uniform int max_iterations;

uniform float orbit_trap_param1;
uniform float orbit_trap_param2;

uniform int is_julia;
uniform float julia_c_real;
uniform float julia_c_imag;

uniform vec3 exterior_colour1;
uniform vec3 exterior_colour2;

uniform float exterior_colouring_param1;
uniform float exterior_colouring_param2;

uniform vec3 interior_colour1;
uniform vec3 interior_colour2;

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

Complex add(Complex x, Complex y) {
    return Complex(
        x.real + y.real,
        x.imag + y.imag
    );
}

Complex sub(Complex x, Complex y) {
    return Complex(
        x.real - y.real,
        x.imag - y.imag
    );
}

Complex scale(Complex z, float d) {
    return Complex(
        z.real * d,
        z.imag * d
    );
}

Complex square(Complex z) {
    return Complex(z.real * z.real - z.imag * z.imag, (z.real + z.real) * z.imag);
}

Complex prod(Complex x, Complex y) {
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
    return atan(z.imag, z.real);
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
    float r = pow(z_norm_sq, 0.5 * d.real) * exp(-d.imag * arg);
    float angle = d.real * arg + 0.5 * d.imag * log(z_norm_sq);

    return Complex(
        r * cos(angle),
        r * sin(angle)
    );
}

Complex exponent(Complex z) {
    float mag = exp(z.real);
    return Complex(
        mag * cos(z.imag),
        mag * sin(z.imag)
    );
}

#define div(x, y) prod(x, reciprocal(y))
#define ADD3(a, b, c) add(add(a, b), c)

vec3 interpolate(vec3 c1, vec3 c2, float amount) {
    return c1 * amount + c2 * (1.0 - amount);
}

vec3 hsvToRgb(float h, float s, float v) {

    float c = v * s;
    float x = c * 1.0 - abs(2.0 * fract(h * 3.0) - 1.0);
    float m = v - c;

    if (h < 0.16666666666667) {
        return vec3(c, x, 0) + m;

    } else if (h < 0.3333333333333334) {
        return vec3(x, c, 0) + m;
    
    } else if (h < 0.5) {
        return vec3(0, c, x) + m;
    
    } else if (h < 0.666666666666667) {
        return vec3(0, x, c) + m;
    
    } else if (h < 0.8333333333333334) {
        return vec3(x, 0, c) + m;
    
    } else {
        return vec3(c, 0, x) + m;
    }
}

float getSmoothIter(float mag_sq, Complex z) {

    float exp;

    #if FRACTAL == 5
        exp = fractal_param1;

    #elif FRACTAL == 15
        exp = max(fractal_param1, fractal_param2);

    #elif FRACTAL == 17
        exp = 4.0;

    #else
        exp = 2.0;

    #endif

    #if ORBIT_TRAP == 0
        return 1.0 + log(log(orbit_trap_param1 * orbit_trap_param1) / log(mag_sq)) / log(exp);

    #elif ORBIT_TRAP == 1
        return 1.0 + log(log(mag_sq) / log(orbit_trap_param1 * orbit_trap_param1)) / log(exp);

    #elif ORBIT_TRAP == 2
        return 1.0 + log(log(min(abs(z.real), abs(z.imag))) / log(orbit_trap_param1 * 0.5)) / log(exp);

    #elif ORBIT_TRAP == 3
        float ring_min_sq = orbit_trap_param1 * orbit_trap_param1;
        float ring_max_sq = orbit_trap_param2 * orbit_trap_param2;
        // TODO

    #elif ORBIT_TRAP == 4
        return 1.0 + log(log(min(abs(z.real), abs(z.imag))) / log(orbit_trap_param1 * 0.5)) / log(exp);
    #endif
    
}

vec3 getColour(float z_real, float z_imag) {

    if (bool(is_inverted)) {

        Complex inv = reciprocal(Complex(z_real, z_imag));

        z_real = inv.real;
        z_imag = inv.imag;

    }

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

    float colour_val = 0.0;

    #if FRACTAL == 10
        z = Complex(1.0, 0.0);

    #elif FRACTAL == 19
        float r = PI * 2.0 * fractal_param1;
        Complex zc = Complex(
            cos(r),
            sin(r)
        );

    #elif FRACTAL == 22
        Complex c_mul = Complex(
            c.real * c.real,
            c.imag * c.imag
        );

    #endif

    #if ORBIT_TRAP == 0
        float escape_radius_sq = orbit_trap_param1 * orbit_trap_param1;

    #elif ORBIT_TRAP == 1
        float min_radius_sq = orbit_trap_param1 * orbit_trap_param1;

    #elif ORBIT_TRAP == 2
        float half_side = orbit_trap_param1 * 0.5;

    #elif ORBIT_TRAP == 3
        float ring_min_sq = orbit_trap_param1 * orbit_trap_param1;
        float ring_max_sq = orbit_trap_param2 * orbit_trap_param2;

    #elif ORBIT_TRAP == 4
        float cross_width = orbit_trap_param1 * 0.5;
    #endif

    #if EXTERIOR_COLOURING_STYLE == 0
        #if MONOTONIC_FUNCTION == 2
            Complex der = Complex(1.0, 0.0);
        #endif

    #elif EXTERIOR_COLOURING_STYLE == 1
        #if CYCLE_FUNCTION == 1
            Complex exp_diff;
            float exponential = 0.0;
        #endif
    #endif

    #if (EXTERIOR_COLOURING_STYLE == 0 && MONOTONIC_FUNCTION == 3) || INTERIOR_COLOURING == 4
        float total = 0.0;
        float total_prev = 0.0;
    #endif

    #if INTERIOR_COLOURING == 1
        float mag_sum = 0.0;

    #elif INTERIOR_COLOURING == 2
        float bail_dist_sq;
        float min_dist_sq = 1.0;

    #elif INTERIOR_COLOURING == 3
        Complex diff;
        float total_dist_sq = 0.0;

    #endif

    for (int iteration = 0; iteration < TRUE_ITER_CAP; iteration++) {
    
        if (iteration >= max_iterations) {
            iterations = TRUE_ITER_CAP;
            break;
        }
        
        z_prev = z;

        #if FRACTAL == 0 // mandelbrot
            z.imag = 2.0 * z.real * z.imag + c.imag;
            z.real = z_real_sq - z_imag_sq + c.real;

        #elif FRACTAL == 1 // burning ship

            z.imag = abs(z.imag);
            z.real = abs(z.real);

            z.imag = 2.0 * z.real * z.imag + c.imag;
            z.real = z_real_sq - z_imag_sq + c.real;

        #elif FRACTAL == 2 // tricorn

            z.imag = -z.real * z.imag;
            z.imag = 2.0 * z.imag + c.imag;

            z.real = z_real_sq - z_imag_sq + c.real;

        #elif FRACTAL == 3 // heart

            float temp;

            temp = z.real * z.imag + c.real;
            z.imag = abs(z.imag) - abs(z.real) + c.imag;
            z.real = temp;

        #elif FRACTAL == 4 // mandelbox

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

        #elif FRACTAL == 5 // multibrot
            z = add(
                exponent(z, fractal_param1),
                c);

        #elif FRACTAL == 6 // feather
            z = add(
                div(
                    Complex(
                    z.real * (z_real_sq - 3.0 * z_imag_sq),
                    z.imag * (3.0 * z_real_sq - z_imag_sq)),
                    Complex(
                        1.0 + z_real_sq,
                        1.0 + z_imag_sq)),
                c);

        #elif FRACTAL == 7 // chrikov
            z.imag += c.imag * sin(z.real);
            z.real += c.real * z.imag;

        #elif FRACTAL == 8 // shoe

            z.real = sin(z.imag * z.real);
    
            z.imag = 2.0 * z.real * z.imag + c.imag;
            z.real = z_real_sq - z_imag_sq + c.real;

        #elif FRACTAL == 9 // custom

            float z_real = z.real;

            z.real += sin(z.imag);
            z.real += sin(z_real);
    
            z.imag = 2.0 * z.real * z.imag + c.imag;

            z.real = z_real_sq - z_imag_sq + c.real;

        #elif FRACTAL == 10 // power tower
            z = exponent(c, z);

        #elif FRACTAL == 11 // duffing
            z.real = z.imag;
            z.imag = c.imag * z_real + c.real * z.imag - z.imag * z_imag_sq;

        #elif FRACTAL == 12 // gingerbread/ 2.0
            z.real = 1.0 - z.imag + abs(z_real) + c.real;
            z.imag = z_real + c.imag;

        #elif FRACTAL == 13 // henon
            z.real = 1.0 - c.real * z_real_sq + z.imag;
            z.imag = c.imag * z_real;

        #elif FRACTAL == 14 // sin

            float sin_real = sin(z.real) * cosh(z.imag);
            float sin_imag = cos(z.real) * sinh(z.imag);

            z.real = sin_real * c.real - sin_imag * c.imag;
            z.imag = c.real * sin_imag + sin_real * c.imag;

        #elif FRACTAL == 15 // rational map
            z = add(
                sub(
                    exponent(z, fractal_param1),
                    scale(
                        exponent(z, fractal_param2),
                        fractal_param3)),
                c);

        #elif FRACTAL == 16 // phoenix

            float z_real = z.real;

            z.real = z_real_sq - z_imag_sq + fractal_param1 * z.real - fractal_param2 * z.imag + c.real;
            z.imag = 2.0 * z_real * z.imag + fractal_param1 * z.imag + fractal_param2 * z_real + c.imag;

        #elif FRACTAL == 17 // simonbrot
            z.imag = 2.0 * (z.real * z.imag) * mag_sq + c.imag;
            z.real = (z_real_sq - z_imag_sq) * mag_sq + c.real;

        #elif FRACTAL == 18 //tippetts
            z.real = z_real_sq - z_imag_sq + c.real;
            z.imag = 2.0 * z.real * z.imag + c.imag;

        #elif FRACTAL == 19 // marek dragon
            z = prod(
                z, 
                Complex(
                    zc.real + z.real,
                    zc.imag + z.imag));

        #elif FRACTAL == 20 // gangopadhyay

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

        #elif FRACTAL == 21 // exponent
            z = prod(c, exponent(z));

        #elif FRACTAL == 22 // sfx

            Complex zc = prod(z, c_mul);

            z = Complex(
                z.real * mag_sq - zc.real,
                z.imag * mag_sq - zc.imag);

        #elif FRACTAL == 23 // complex multibrot
            z = add(
                exponent(
                    z,
                    Complex(fractal_param1, fractal_param2)),
                c);

        #elif FRACTAL == 24 // thorn
            z.real = z.real / cos(z.imag) + c.real;
            z.imag = z.imag / sin(z_real) + c.imag;

        #elif FRACTAL == 25 // meta

            Complex meta_z = Complex(
                z_real_sq - z_imag_sq + c.real,
                2.0 * z.real * z.imag + c.imag
            );

            Complex meta_c = add(
                square(c),
                z);

            z = add(
                square(meta_z),
                meta_c);

        #elif FRACTAL == 26 // buffalo
            z = Complex(
                z_real_sq - z_imag_sq - abs(z.real) + c.real,
                2.0 * abs(z.real * z.imag) - abs(z.imag) + c.imag
            );

        #elif FRACTAL == 27 // magnet

            float dzr = 2.0 * z.real;

            z = square(
                div(
                    Complex(
                        z_real_sq - z_imag_sq + c.real - 1.0,
                        dzr * z.imag + c.imag),
                    Complex(
                        dzr + c.real - 2.0,
                        2.0 * z.imag + c.imag)));

        #elif FRACTAL == 28 // triple dragon

            Complex z3 = prod(
                z,
                Complex(
                    z_real_sq - z_imag_sq,
                    2.0 * z.real * z.imag));

            z = add(
                div(
                    z3,
                    Complex(
                        z3.real + 1.0,
                        z3.imag)),
                c);

        #elif FRACTAL == 29 // spiral

            Complex dz2c = Complex(
                2.0 * (z_real_sq - z_imag_sq + c.real),
                4.0 * z.real * z.imag + c.imag
            );

            float denom = cos(dz2c.real) + cosh(dz2c.imag);

            z = Complex(
                sin(dz2c.real) / denom,
                sinh(dz2c.imag) / denom
            );
            
        #endif
        
        z_real_sq = z.real * z.real;
        z_imag_sq = z.imag * z.imag;
        
        mag_sq = z_real_sq + z_imag_sq;

        #if EXTERIOR_COLOURING_STYLE == 0
            #if MONOTONIC_FUNCTION == 2
                #if FRACTAL == 0

                    der = add(
                        scale(
                            prod(
                                z_prev,
                                der),
                            2.0),
                        Complex(
                            1.0,
                            0.0));

                #elif FRACTAL == 5

                    der = add(
                        scale(
                            prod(
                                exponent(
                                    z_prev,
                                    fractal_param1 - 1.0),
                                der),
                            2.0 * fractal_param1),
                        Complex(
                            1.0,
                            0.0));
                #endif
            #endif
        #endif
        
        #if (EXTERIOR_COLOURING_STYLE == 0 && MONOTONIC_FUNCTION == 3) || INTERIOR_COLOURING == 4
            total_prev = total;
            total += 0.5 + 0.5 * sin(exterior_colouring_param1 * argument(z));
        #endif

        #if EXTERIOR_COLOURING_STYLE == 1
            #if CYCLE_FUNCTION == 1
                exp_diff = sub(z, z_prev);
                exponential += exp(-(sqrt(mag_sq) + 0.5 / sqrt(exp_diff.real * exp_diff.real + exp_diff.imag * exp_diff.imag)));
            #endif
        #endif

        #if INTERIOR_COLOURING == 1
            mag_sum += mag_sq;

        #elif INTERIOR_COLOURING == 2
            
            #if ORBIT_TRAP == 0
                bail_dist_sq = 1.0 - mag_sq / escape_radius_sq;

            #elif ORBIT_TRAP == 1
                bail_dist_sq = 1.0 - min_radius_sq / mag_sq;

            #elif ORBIT_TRAP == 2

                float square_dist;

                if (abs(z.real) <= half_side) {
                    square_dist = z_imag_sq;
                
                } else if (abs(z.imag) <= half_side1) {
                    square_dist = z_real_sq;
                
                } else {
                    square_dist = mag_sq;
                }

                bail_dist_sq = 1.0 - half_side / square_dist;

            #elif ORBIT_TRAP == 3

                if (ring_min_sq > mag_sq) {
                    bail_dist_sq = 1.0 - mag_sq / ring_min_sq;
                
                } else {
                    bail_dist_sq = 1.0 - ring_max_sq / mag_sq;
                }

            #elif ORBIT_TRAP == 4
                float cross_dist = min(z_real_sq, z_imag_sq);
                bail_dist_sq = 1.0 - cross_width / cross_dist;
            #endif

            if (bail_dist_sq < min_dist_sq) {
                min_dist_sq = bail_dist_sq;
            }

        #elif INTERIOR_COLOURING == 3
            diff = sub(z, z_prev);
            total_dist_sq += diff.real * diff.real + diff.imag * diff.imag;

        #endif

        #if ORBIT_TRAP == 0

            if (mag_sq >= escape_radius_sq) {
                iterations = iteration + 1;
                break;
            }

        #elif ORBIT_TRAP == 1
        
            if (mag_sq <= min_radius_sq) {
                iterations = iteration + 1;
                break;
            }

        #elif ORBIT_TRAP == 2
        
            if (abs(z.real) < half_side && abs(z.imag) < half_side) {
                iterations = iteration + 1;
                break;
            }

        #elif ORBIT_TRAP == 3
        
            if ((mag_sq >= ring_min_sq && mag_sq <= ring_max_sq)
            ) {
                iterations = iteration + 1;
                break;
            }

        #elif ORBIT_TRAP == 4

            if (abs(z.real) < cross_width || abs(z.imag) < cross_width) {
                iterations = iteration + 1;
                break;
            }

        #endif
    }

    if (iterations == TRUE_ITER_CAP) {

        #if INTERIOR_COLOURING == 0
            return interior_colour1;

        #elif INTERIOR_COLOURING == 1
            return interpolate(interior_colour2, interior_colour1, mag_sum / sqrt(float(iterations)));

        #elif INTERIOR_COLOURING == 2
            return interpolate(interior_colour1, interior_colour2, min_dist_sq);

        #elif INTERIOR_COLOURING == 3
            return hsvToRgb(fract(sqrt(total_dist_sq)), 1.0, 1.0);

        #elif INTERIOR_COLOURING == 4
            return interpolate(interior_colour1, interior_colour2, total / float(max_iterations));
        #endif

    } else {

        #if EXTERIOR_COLOURING_STYLE == 0

            #if MONOTONIC_FUNCTION == 0 || MONOTONIC_FUNCTION == 1
            
                float f_iterations = float(iterations);

                #if MONOTONIC_FUNCTION == 1
                    f_iterations += getSmoothIter(mag_sq, z);
                #endif

                colour_val = f_iterations / float(max_iterations);

            #elif MONOTONIC_FUNCTION == 2

                z = div(z, der);

                float mag = sqrt(z.real * z.real + z.imag * z.imag);

                z = Complex(
                    z.real / mag,
                    z.imag / mag
                );

                colour_val = max(0.0, 
                    exterior_colouring_param1 * z.real +
                    exterior_colouring_param2 * z.imag +
                    sqrt(1.0 - exterior_colouring_param1 * exterior_colouring_param1 - exterior_colouring_param2 * exterior_colouring_param2)
                );

            #elif MONOTONIC_FUNCTION == 3
                float interp = getSmoothIter(mag_sq, z);
                colour_val = (total * interp + total_prev * (1.0 - interp)) / (float(iterations) + interp);
            #endif

        #elif EXTERIOR_COLOURING_STYLE == 1

            float val;

            #if CYCLE_FUNCTION == 0
                val = float(iterations) + getSmoothIter(mag_sq, z);

            #elif CYCLE_FUNCTION == 1
                val = log(exponential);

            #endif

            val /= exterior_colouring_param1;

            #if CYCLIC_WAVEFORM == 0
                colour_val = 0.5 * sin(val * 2.0 * PI) + 0.5;

            #elif CYCLIC_WAVEFORM == 1
                colour_val = round(fract(val));

            #elif CYCLIC_WAVEFORM == 2

                val = fract(val);

                if (val > 0.5) {
                    colour_val = 1.0 - 2.0 * (val - 0.5);
                
                } else {
                    colour_val = 2.0 * val;
                }

            #elif CYCLIC_WAVEFORM == 3
                colour_val = fract(val);
            #endif

        #elif EXTERIOR_COLOURING_STYLE == 2
            
            float angle = argument(z);

            #if RADIAL_DECOMPOSITION == 0
                if (angle > 0.0) {
                    colour_val = angle / PI;

                } else {
                    colour_val = -angle / PI;
                }

            #elif RADIAL_DECOMPOSITION == 1
                if (angle > 0.0) {
                    colour_val = 0.0;
                
                } else {
                    colour_val = 1.0;
                }

            #endif
        #endif

        #if EXTERIOR_COLOURING == 0
            return interpolate(exterior_colour1, exterior_colour2, colour_val);

        #elif EXTERIOR_COLOURING == 1
            return hsvToRgb(colour_val, 1.0, 1.0);
        #endif

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