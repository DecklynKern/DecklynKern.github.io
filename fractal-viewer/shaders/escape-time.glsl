precision highp float;

uniform float magnitude;
uniform float centre_x;
uniform float centre_y;

uniform int fractal_type;
uniform float fractal_param;
uniform int max_iterations;
uniform float escape_radius_sq;
uniform float min_radius_sq;

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

varying vec2 frag_position;

struct Complex {
    float real;
    float imag;
};

struct Iterator {
    Complex c;
    Complex z;
    float z_real_sq;
    float z_imag_sq;
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

Complex exponent(Complex z, float d) {

    float r = pow(z.real * z.real + z.imag * z.imag, d * 0.5);
    float theta = atan(z.imag, z.real) * d;

    return Complex(
        r * cos(theta),
        r * sin(theta)
    );
}

vec3 interpolate(vec3 c1, vec3 c2, float amount) {
    return c1 * amount + c2 * (1.0 - amount);
}

void iterMandelbrot(inout Iterator iter) {
    
    iter.z.imag = iter.z.real * iter.z.imag;
    iter.z.imag = iter.z.imag + iter.z.imag + iter.c.imag;

    iter.z.real = iter.z_real_sq - iter.z_imag_sq + iter.c.real;

}

void iterBurningShip(inout Iterator iter) {

    iter.z.imag = abs(iter.z.imag);
    iter.z.real = abs(iter.z.real);

    iter.z.imag = iter.z.real * iter.z.imag;
    iter.z.imag = iter.z.imag + iter.z.imag + iter.c.imag;

    iter.z.real = iter.z_real_sq - iter.z_imag_sq + iter.c.real;

}

void iterTricorn(inout Iterator iter) {

    iter.z.imag = -iter.z.real * iter.z.imag;
    iter.z.imag = iter.z.imag + iter.z.imag + iter.c.imag;

    iter.z.real = iter.z_real_sq - iter.z_imag_sq + iter.c.real;

}

void iterHeart(inout Iterator iter) {

    float temp;

    temp = iter.z.real * iter.z.imag + iter.c.real;
    iter.z.imag = abs(iter.z.imag) - abs(iter.z.real) + iter.c.imag;
    iter.z.real = temp;

}

void iterMandelbox(inout Iterator iter) {

    float mag = iter.z.real * iter.z.real + iter.z.imag * iter.z.imag;

    if (mag < 0.25) {
        iter.z.real *= 4.0;
        iter.z.imag *= 4.0;
    
    } else if (mag < 1.0) {
        iter.z.real /= mag;
        iter.z.imag /= mag;
    }

    iter.z.real = -fractal_param * iter.z.real + iter.c.real;
    iter.z.imag = -fractal_param * iter.z.imag + iter.c.imag;
    
    if (iter.z.real > 1.0) {
        iter.z.real = 2.0 - iter.z.real;
    
    } else if (iter.z.real < -1.0) {
        iter.z.real = -2.0 - iter.z.real;
    }
    
    if (iter.z.imag > 1.0) {
        iter.z.imag = 2.0 - iter.z.imag;
    
    } else if (iter.z.imag < -1.0) {
        iter.z.imag = -2.0 - iter.z.imag;
    }

}

void iterMultibrot(inout Iterator iter) {

    Complex z_exp = exponent(iter.z, fractal_param);

    iter.z.real = z_exp.real + iter.c.real;
    iter.z.imag = z_exp.imag + iter.c.imag;

}

void iterFeather(inout Iterator iter) {

    Complex numerator = Complex(
        iter.z.real * (iter.z_real_sq - 3.0 * iter.z_imag_sq),
        iter.z.imag * (3.0 * iter.z_real_sq - iter.z_imag_sq)
    );

    Complex div = multiply(numerator, reciprocal(
        Complex(
            1.0 + iter.z_real_sq,
            1.0 + iter.z_imag_sq
        )
    ));

    iter.z.real = div.real + iter.c.real;
    iter.z.imag = div.imag + iter.c.imag;

}

void iterChirikov(inout Iterator iter) {
    iter.z.imag += iter.c.imag * sin(iter.z.real);
    iter.z.real += iter.c.real * iter.z.imag;
}

void iterShoe(inout Iterator iter) {
    iter.z.real = sin(iter.z.imag * iter.z.real);
    iterMandelbrot(iter);
}

void iterCustom(inout Iterator iter) {

    float z_real = iter.z.real;

    iter.z.real += sin(iter.z.imag);
    iter.z.real += sin(z_real);
    iterMandelbrot(iter);

}

// macro idea "borrowed" from https://github.com/HackerPoet/FractalSoundExplorer/blob/main/frag.glsl
#define ITERATE(iterFunc, iterator) \
for (int iteration = 0; iteration < TRUE_ITER_CAP; iteration++) {\
    \
    if (iteration >= max_iterations) {\
        iterations = TRUE_ITER_CAP;\
        break;\
    }\
    \
    iterFunc(iterator);\
    \
    iterator.z_real_sq = iterator.z.real * iterator.z.real;\
    iterator.z_imag_sq = iterator.z.imag * iterator.z.imag;\
    \
    float dist = iterator.z_real_sq + iterator.z_imag_sq;\
    \
    if (dist >= escape_radius_sq || dist <= min_radius_sq) {\
        iterations = iteration;\
        break;\
    }\
}

#define ITERATE_ORBIT(iterFunc, iterator)\
for (int iteration = 0; iteration < TRUE_ITER_CAP; iteration++) {\
    \
    if (iteration >= max_iterations) {\
        iterations = TRUE_ITER_CAP;\
        break;\
    }\
    \
    iterFunc(iterator);\
    \
    iterator.z_real_sq = iterator.z.real * iterator.z.real;\
    iterator.z_imag_sq = iterator.z.imag * iterator.z.imag;\
    \
    float dist = iterator.z_real_sq + iterator.z_imag_sq;\
    interior_colour_param += iterator.z.real / iterator.z.imag;\
    \
    if (dist >= escape_radius_sq || dist <= min_radius_sq) {\
        iterations = iteration;\
        break;\
    }\
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

    Iterator iterator = Iterator(
        Complex(
            c_real,
            c_imag
        ),
        Complex(
            z_real,
            z_imag
        ),
        z_real * z_real,
        z_imag * z_imag
    );

    int iterations;
    float interior_colour_param;
    Complex derivative;

    if (interior_colouring_type == 0) {

        if (fractal_type == 0) {
            ITERATE(iterMandelbrot, iterator);

        } else if (fractal_type == 1) {
            ITERATE(iterBurningShip, iterator);
        
        } else if (fractal_type == 2) {
            ITERATE(iterTricorn, iterator);    
        
        } else if (fractal_type == 3) {
            ITERATE(iterHeart, iterator);
        
        } else if (fractal_type == 4) {
            ITERATE(iterMandelbox, iterator);
        
        } else if (fractal_type == 5) {
            ITERATE(iterMultibrot, iterator);
        
        } else if (fractal_type == 6) {
            ITERATE(iterFeather, iterator);
        
        } else if (fractal_type == 7) {
            ITERATE(iterChirikov, iterator);
        
        } else if (fractal_type == 8) {
            ITERATE(iterShoe, iterator);
        
        } else if (fractal_type == 9) {
            ITERATE(iterCustom, iterator);
        }
    
    } else {

        if (fractal_type == 0) {
            ITERATE_ORBIT(iterMandelbrot, iterator);

        } else if (fractal_type == 1) {
            ITERATE_ORBIT(iterBurningShip, iterator);
        
        } else if (fractal_type == 2) {
            ITERATE_ORBIT(iterTricorn, iterator);    
        
        } else if (fractal_type == 3) {
            ITERATE_ORBIT(iterHeart, iterator);
        
        } else if (fractal_type == 4) {
            ITERATE_ORBIT(iterMandelbox, iterator);
        
        } else if (fractal_type == 5) {
            ITERATE_ORBIT(iterMultibrot, iterator);
        
        } else if (fractal_type == 6) {
            ITERATE_ORBIT(iterFeather, iterator);
        
        } else if (fractal_type == 7) {
            ITERATE_ORBIT(iterChirikov, iterator);
        
        } else if (fractal_type == 8) {
            ITERATE_ORBIT(iterShoe, iterator);
        
        } else if (fractal_type == 9) {
            ITERATE_ORBIT(iterCustom, iterator);
        }
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
            f_iterations -= log(log(iterator.z_real_sq + iterator.z_imag_sq) / log(f_iterations + 0.000001) * 0.5) / log(escape_radius_sq) * 2.0;

        } else if (smoothing_type == 2) {
            f_iterations += (iterator.z_real_sq + iterator.z_imag_sq - escape_radius_sq) / (escape_radius_sq - sqrt(escape_radius_sq));
        }

        if (colouring_type == 0) {
            return interpolate(close_colour, far_colour, max(f_iterations, 0.0) / float(max_iterations));

        } else if (colouring_type == 1) {;
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
        } else if (colouring_type == 3) {

            

        }
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

        colour_sum += getColour(real + real_offset * pixel_size, imag + imag_offset * pixel_size);

    }

    gl_FragColor = vec4(colour_sum / float(samples), 1.0);

}