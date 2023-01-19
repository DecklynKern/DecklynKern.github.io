precision mediump float;

uniform int fractal_type;
uniform float fractal_param;
uniform int max_iterations;
uniform float escape_radius_sq;

uniform float magnitude;
uniform float origin_real;
uniform float origin_imag;

uniform int is_julia;
uniform float julia_c_real;
uniform float julia_c_imag;

uniform int colouring_type;
uniform vec3 trapped_colour;
uniform vec3 far_colour;
uniform vec3 close_colour;
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

// macro idea shamelessly "borrowed" from https://github.com/HackerPoet/FractalSoundExplorer/blob/main/frag.glsl
#define ITERATE(iterFunc, iterator) \
for (int iteration = 0; iteration < TRUE_ITER_CAP; iteration++) { \
    \
    if (iteration >= max_iterations) { \
        iterations = TRUE_ITER_CAP;\
        break;\
    }\
    \
    iterFunc(iterator);\
    \
    iterator.z_real_sq = iterator.z.real * iterator.z.real;\
    iterator.z_imag_sq = iterator.z.imag * iterator.z.imag;\
    \
    if (iterator.z_real_sq + iterator.z_imag_sq >= escape_radius_sq) {\
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
    }

    float f_iterations = float(iterations) + 0.00001;

    if (iterations == TRUE_ITER_CAP) {
        return trapped_colour;

    } else {

        float normalized_closeness;

        if (colouring_type == 0) {
            normalized_closeness = f_iterations / float(max_iterations);

        } else if (colouring_type == 1) {

            float smoothed = max(f_iterations - log(log(iterator.z_real_sq + iterator.z_imag_sq) / log(f_iterations) * 0.5) / log(escape_radius_sq) * 2.0, 0.0);
            normalized_closeness = smoothed / float(max_iterations);
        
        } else if (colouring_type == 2) {
            
            float dist = max(f_iterations - log(log(iterator.z_real_sq + iterator.z_imag_sq) / log(f_iterations) * 0.5) / log(escape_radius_sq) * 2.0, 0.0);

            normalized_closeness = sin(dist) * 0.5 + 0.5;

        } else if (colouring_type == 3) {

            float smoothed = (f_iterations - log(log(iterator.z_real_sq + iterator.z_imag_sq) / log(f_iterations) * 0.5) / log(escape_radius_sq) * 2.0) / 2.0;

            float h = 6.0 * fract(smoothed / 6.0);
            float x = 1.0 - abs(2.0 * fract(smoothed / 2.0) - 1.0);

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

        return close_colour * normalized_closeness + far_colour * (1.0 - normalized_closeness);

    }
}

void main() {

    float pixel_size = 2.0 * magnitude / 1000.0;

    float real = origin_real + frag_position.x * magnitude;
    float imag = origin_imag + frag_position.y * magnitude;

    vec3 colour_sum;

    for (int sample = 0; sample < TRUE_SAMPLE_CAP; sample++) {

        if (sample == samples) {
            break;
        }

        float real_offset = fract(0.1234 * float(sample)) - 0.5;
        float imag_offset = fract(0.7654 * float(sample)) - 0.5;

        colour_sum += getColour(real + real_offset * pixel_size, imag + imag_offset * pixel_size);

    }

    gl_FragColor = vec4(colour_sum / float(samples), 1.0);

}