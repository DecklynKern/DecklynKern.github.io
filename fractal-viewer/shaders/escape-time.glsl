precision highp float;

uniform float magnitude;
uniform float centre_x;
uniform float centre_y;

uniform int fractal_type;

uniform float fractal_param1;
uniform float fractal_param2;
uniform float fractal_param3;

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
    Complex z_prev;
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

float sinh(float x) {
    return (exp(x) - exp(-x)) * 0.5;
}

float cosh(float x) {
    return (exp(x) + exp(-x)) * 0.5;
}

vec3 interpolate(vec3 c1, vec3 c2, float amount) {
    return c1 * amount + c2 * (1.0 - amount);
}

void iterMandelbrot(inout Iterator iter) {
    
    iter.z.imag = iter.z.real * iter.z.imag;
    iter.z.imag = 2.0 * iter.z.imag + iter.c.imag;

    iter.z.real = iter.z_real_sq - iter.z_imag_sq + iter.c.real;

}

void iterBurningShip(inout Iterator iter) {

    iter.z.imag = abs(iter.z.imag);
    iter.z.real = abs(iter.z.real);

    iter.z.imag = iter.z.real * iter.z.imag;
    iter.z.imag = 2.0 * iter.z.imag + iter.c.imag;

    iter.z.real = iter.z_real_sq - iter.z_imag_sq + iter.c.real;

}

void iterTricorn(inout Iterator iter) {

    iter.z.imag = -iter.z.real * iter.z.imag;
    iter.z.imag = 2.0 * iter.z.imag + iter.c.imag;

    iter.z.real = iter.z_real_sq - iter.z_imag_sq + iter.c.real;

}

void iterHeart(inout Iterator iter) {

    float temp;

    temp = iter.z.real * iter.z.imag + iter.c.real;
    iter.z.imag = abs(iter.z.imag) - abs(iter.z.real) + iter.c.imag;
    iter.z.real = temp;

}

void iterMandelbox(inout Iterator iter) {

    float mag = iter.z_real_sq + iter.z_imag_sq;

    if (mag < 0.25) {
        iter.z.real *= 4.0;
        iter.z.imag *= 4.0;
    
    } else if (mag < 1.0) {
        iter.z.real /= mag;
        iter.z.imag /= mag;
    }

    iter.z.real = -fractal_param1 * iter.z.real + iter.c.real;
    iter.z.imag = -fractal_param1 * iter.z.imag + iter.c.imag;
    
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

    Complex z_exp = exponent(iter.z, fractal_param1);

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

void iterPowerTower(inout Iterator iter) {
    iter.z = exponent(iter.c, iter.z);
}

void iterDuffing(inout Iterator iter) {
    
    float z_real = iter.z.real;

    iter.z.real = iter.z.imag;
    iter.z.imag = iter.c.imag * z_real + iter.c.real * iter.z.imag - iter.z.imag * iter.z_imag_sq;

}

void iterGingerbread(inout Iterator iter) {
    
    float z_real = iter.z.real;

    iter.z.real = 1.0 - iter.z.imag + abs(z_real) + iter.c.real;
    iter.z.imag = z_real + iter.c.imag;

}

void iterHenon(inout Iterator iter) {
    
    float z_real = iter.z.real;

    iter.z.real = 1.0 - iter.c.real * iter.z_real_sq + iter.z.imag;
    iter.z.imag = iter.c.imag * z_real;

}

void iterSin(inout Iterator iter) {

    float sin_real = sin(iter.z.real) * cosh(iter.z.imag);
    float sin_imag = cos(iter.z.real) * sinh(iter.z.imag);

    iter.z.real = sin_real * iter.c.real - sin_imag * iter.c.imag;
    iter.z.imag = iter.c.real * sin_imag + sin_real * iter.c.imag;

}

void iterRational(inout Iterator iter) {

    Complex exp1 = exponent(iter.z, fractal_param1);
    Complex exp2 = exponent(iter.z, fractal_param2);

    iter.z.real = exp1.real - fractal_param3 * exp2.real + iter.c.real;
    iter.z.imag = exp1.imag - fractal_param3 * exp2.imag + iter.c.imag;

}

void iterPhoenix(inout Iterator iter) {

    float z_real = iter.z.real;

    iter.z.real = iter.z_real_sq - iter.z_imag_sq + fractal_param1 * iter.z_prev.real - fractal_param2 * iter.z_prev.imag + iter.c.real;
    iter.z.imag = 2.0 * z_real * iter.z.imag + fractal_param1 * iter.z_prev.imag + fractal_param2 * iter.z_prev.real + iter.c.imag;

}

// macro idea "borrowed" from https://github.com/HackerPoet/FractalSoundExplorer/blob/main/frag.glsl
#define ITERATE(iterFunc) \
for (int iteration = 0; iteration < TRUE_ITER_CAP; iteration++) {\
    \
    if (iteration >= max_iterations) {\
        iterations = TRUE_ITER_CAP;\
        break;\
    }\
    \
    z_prev = iterator.z;\
    \
    iterFunc(iterator);\
    \
    iterator.z_real_sq = iterator.z.real * iterator.z.real;\
    iterator.z_imag_sq = iterator.z.imag * iterator.z.imag;\
    iterator.z_prev = z_prev;\
    \
    float dist = iterator.z_real_sq + iterator.z_imag_sq;\
    \
    if (dist >= escape_radius_sq || dist <= min_radius_sq) {\
        iterations = iteration;\
        break;\
    }\
}

#define ITERATE_ORBIT(iterFunc)\
for (int iteration = 0; iteration < TRUE_ITER_CAP; iteration++) {\
    \
    if (iteration >= max_iterations) {\
        iterations = TRUE_ITER_CAP;\
        break;\
    }\
    \
    z_prev = iterator.z;\
    \
    iterFunc(iterator);\
    \
    iterator.z_real_sq = iterator.z.real * iterator.z.real;\
    iterator.z_imag_sq = iterator.z.imag * iterator.z.imag;\
    iterator.z_prev = z_prev;\
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
            z_imag,
            z_real
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
    Complex z_prev;

    if (interior_colouring_type == 0) {

        if (fractal_type == 0) {
            ITERATE(iterMandelbrot);

        } else if (fractal_type == 1) {
            ITERATE(iterBurningShip);
        
        } else if (fractal_type == 2) {
            ITERATE(iterTricorn);    
        
        } else if (fractal_type == 3) {
            ITERATE(iterHeart);
        
        } else if (fractal_type == 4) {
            ITERATE(iterMandelbox);
        
        } else if (fractal_type == 5) {
            ITERATE(iterMultibrot);
        
        } else if (fractal_type == 6) {
            ITERATE(iterFeather);
        
        } else if (fractal_type == 7) {
            ITERATE(iterChirikov);
        
        } else if (fractal_type == 8) {
            ITERATE(iterShoe);
        
        } else if (fractal_type == 9) {
            ITERATE(iterCustom);
        
        } else if (fractal_type == 10) {
            iterator.z = Complex(
                1.0,
                0.0
            );
            ITERATE(iterPowerTower);
        
        } else if (fractal_type == 11) {
            ITERATE(iterDuffing);
        
        } else if (fractal_type == 12) {
            ITERATE(iterGingerbread);
        
        } else if (fractal_type == 13) {
            ITERATE(iterHenon);
        
        } else if (fractal_type == 14) {
            ITERATE(iterSin);
        
        } else if (fractal_type == 15) {
            ITERATE(iterRational);
        
        } else if (fractal_type == 16) {
            ITERATE(iterPhoenix);
        }
    
    } else {

        if (fractal_type == 0) {
            ITERATE_ORBIT(iterMandelbrot);

        } else if (fractal_type == 1) {
            ITERATE_ORBIT(iterBurningShip);
        
        } else if (fractal_type == 2) {
            ITERATE_ORBIT(iterTricorn);    
        
        } else if (fractal_type == 3) {
            ITERATE_ORBIT(iterHeart);
        
        } else if (fractal_type == 4) {
            ITERATE_ORBIT(iterMandelbox);
        
        } else if (fractal_type == 5) {
            ITERATE_ORBIT(iterMultibrot);
        
        } else if (fractal_type == 6) {
            ITERATE_ORBIT(iterFeather);
        
        } else if (fractal_type == 7) {
            ITERATE_ORBIT(iterChirikov);
        
        } else if (fractal_type == 8) {
            ITERATE_ORBIT(iterShoe);
        
        } else if (fractal_type == 9) {
            ITERATE_ORBIT(iterCustom);
        
        } else if (fractal_type == 10) {
            iterator.z = Complex(
                1.0,
                0.0
            );
            ITERATE_ORBIT(iterPowerTower);
        
        } else if (fractal_type == 11) {
            ITERATE_ORBIT(iterDuffing);
        
        } else if (fractal_type == 12) {
            ITERATE_ORBIT(iterGingerbread);
        
        } else if (fractal_type == 13) {
            ITERATE_ORBIT(iterHenon);
        
        } else if (fractal_type == 14) {
            ITERATE_ORBIT(iterSin);
        
        } else if (fractal_type == 15) {
            ITERATE_ORBIT(iterRational);
        
        } else if (fractal_type == 16) {
            ITERATE_ORBIT(iterPhoenix);
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