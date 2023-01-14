precision mediump float;

uniform int fractal_type;
uniform int colouring_type;
uniform float magnitude;
uniform float origin_real;
uniform float origin_imag;
uniform int max_iterations;

const int TRUE_ITER_CAP = 10000;

varying vec2 frag_position;

struct Iterator {
    float c_real;
    float c_imag;
    float z_real;
    float z_imag;
    float z_real_sq;
    float z_imag_sq;
};

Iterator iterMandelbrot(Iterator iter) {
    
    iter.z_imag = iter.z_real * iter.z_imag;
    iter.z_imag = iter.z_imag + iter.z_imag + iter.c_imag;

    iter.z_real = iter.z_real_sq - iter.z_imag_sq + iter.c_real;

    return iter;

}

Iterator iterBurningShip(Iterator iter) {

    iter.z_imag = abs(iter.z_imag);
    iter.z_real = abs(iter.z_real);

    iter.z_imag = iter.z_real * iter.z_imag;
    iter.z_imag = iter.z_imag + iter.z_imag + iter.c_imag;

    iter.z_real = iter.z_real_sq - iter.z_imag_sq + iter.c_real;

    return iter;

}

Iterator iterTricorn(Iterator iter) {

    iter.z_imag = -iter.z_real * iter.z_imag;
    iter.z_imag = iter.z_imag + iter.z_imag + iter.c_imag;

    iter.z_real = iter.z_real_sq - iter.z_imag_sq + iter.c_real;

    return iter;

}

Iterator iterHeart(Iterator iter) {

    float temp;

    temp = iter.z_real * iter.z_imag + iter.c_real;
    iter.z_imag = abs(iter.z_imag) - abs(iter.z_real) + iter.c_imag;
    iter.z_real = temp;

    return iter;

}

Iterator iterDeck(Iterator iter) {
    
    iter.z_real = iter.z_imag + iter.c_real;
    iter.z_imag = iter.z_real * iter.z_real + iter.c_imag;
    
    return iter;

}

void main() {

    Iterator iterator = Iterator(
        origin_real + frag_position.x * magnitude,
        origin_imag + frag_position.y * magnitude,
        0.0,
        0.0,
        0.0,
        0.0
    );

    int iterations;

    for (int iteration = 0; iteration < TRUE_ITER_CAP; iteration++) {

        if (iteration >= max_iterations) {
            iterations = TRUE_ITER_CAP;
            break;
        }

        if (fractal_type == 0) {
            iterator = iterMandelbrot(iterator);

        }  else if (fractal_type == 1) {
            iterator = iterBurningShip(iterator);
        
        } else if (fractal_type == 2) {
            iterator = iterTricorn(iterator);    
        
        } else if (fractal_type == 3) {
            iterator = iterHeart(iterator);
        
        } else if (fractal_type == 4) {
            iterator = iterDeck(iterator);
        }

        iterator.z_real_sq = iterator.z_real * iterator.z_real;
        iterator.z_imag_sq = iterator.z_imag * iterator.z_imag;

        if (iterator.z_real_sq + iterator.z_imag_sq >= 4.0) {
            iterations = iteration;
            break;
        }
    }

    if (iterations == TRUE_ITER_CAP) {
        gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);

    } else {

        if (colouring_type == 0) {
            gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
        
        } else if (colouring_type == 1) {
            gl_FragColor = vec4(0.0, 0.0, float(iterations) / float(max_iterations), 1.0);

        } else if (colouring_type == 2) {
            gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
        
        } else if (colouring_type == 3) {
            gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
        }
    }
}