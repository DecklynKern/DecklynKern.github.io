precision highp float;

//%

uniform float magnitude;
uniform float centre_x;
uniform float centre_y;

uniform int max_iterations;
uniform float threshold;

uniform float root1_real;
uniform float root1_imag;
uniform float root2_real;
uniform float root2_imag;
uniform float root3_real;
uniform float root3_imag;

uniform float a_real;
uniform float a_imag;

uniform float c_real;
uniform float c_imag;

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

const Complex ZERO = Complex(0.0, 0.0);

Complex reciprocal(Complex z) {
    float denom = z.real * z.real + z.imag * z.imag;
    return Complex(z.real / denom, -z.imag / denom);
}

Complex square(Complex z) {
    return Complex(z.real * z.real - z.imag * z.imag, (z.real + z.real) * z.imag);
}

Complex scale(Complex z, float d) {
    return Complex(
        z.real * d,
        z.imag * d
    );
}

Complex add(Complex x, Complex y) {
    return Complex(
        x.real + y.real,
        x.imag + y.imag
    );
}

void iadd(inout Complex x, Complex y) {
    x.real += y.real;
    x.imag += y.imag;
}

Complex sub(Complex x, Complex y) {
    return Complex(
        x.real - y.real,
        x.imag - y.imag
    );
}

Complex prod(Complex x, Complex y) {
    return Complex(
        x.real * y.real - x.imag * y.imag,
        x.real * y.imag + y.real * x.imag
    );
}

Complex neg(Complex z) {
    return Complex(
        -z.real,
        -z.imag
    );
}

Complex conj(Complex z) {
    return Complex(
        z.real,
        -z.imag
    );
}

float root_dist_sq(Complex z, Complex root) {
    Complex diff = sub(z, root);
    return diff.real * diff.real + diff.imag * diff.imag;
}

#define div(x, y) prod(x, reciprocal(y))
#define ADD3(a, b, c) add(add(a, b), c)

vec3 getColour(Complex z) {

    Complex z_prev;

    Complex root1 = Complex(root1_real, root1_imag);
    Complex root2 = Complex(root2_real, root2_imag);
    Complex root3 = Complex(root3_real, root3_imag);

    Complex r1r2 = prod(root1, root2);
    
    Complex d = neg(ADD3(root1, root2, root3));
    Complex e = ADD3(r1r2, prod(root1, root3), prod(root2, root3));
    Complex f = neg(prod(r1r2, root3));

    int iters = max_iterations;

    #if FRACTAL_TYPE == 1

        Complex c = z;
        z = ZERO;

        z_prev = Complex(10000.0, 0.0);
        Complex dz;

    #elif FRACTAL_TYPE == 2

        Complex c = Complex(c_real, c_imag);

        z_prev = Complex(1000000.0, 0.0);
        Complex dz;

    #endif

    Complex func;
    Complex diff;

    Complex a = Complex(a_real, a_imag);

    #if ALGORITHM == 0
        Complex der = ZERO;

    #elif ALGORITHM == 1 || ALGORITHM == 2
        Complex der = ZERO;
        Complex der2 = ZERO;

    #elif ALGORITHM == 3
        Complex func_step = ZERO;

    #elif ALGORITHM == 4

        Complex func_prev;

        #if START_POINT == 0
            z_prev = ZERO;

        #elif START_POINT == 1
            z_prev = Complex(
                z.imag,
                z.real
            );

        #elif START_POINT == 2
            z_prev = scale(z, 2.0);

        #elif START_POINT == 3
            z_prev = conj(z);

        #elif START_POINT == 4
            z_prev = square(z);
        #endif

        func_prev = ADD3(
            prod(
                add(d, z_prev),
                square(z_prev)),
            prod(e, z_prev),
            f);

    #elif ALGORITHM == 5
        Complex der = ZERO;
        Complex der2 = ZERO;
        Complex der3 = ZERO;

    #endif

    for (int iteration = 0; iteration < TRUE_ITER_CAP; iteration++) {

        Complex z2 = square(z);

        func = ADD3(
            prod(
                add(d, z),
                z2),
            prod(e, z),
            f);

        #if ALGORITHM == 0 || ALGORITHM == 1 || ALGORITHM == 2 || ALGORITHM == 5

            Complex dd = scale(d, 2.0);

            der = ADD3(
                scale(z2, 3.0),
                prod(dd, z),
                e);

        #endif

        #if ALGORITHM == 1 || ALGORITHM == 2 || ALGORITHM == 5

            der2 = add(
                scale(z, 6.0),
                dd);

        #endif

        #if ALGORITHM == 3 // steffensen

            Complex func_z = add(func, z);

            func_step = ADD3(
                prod(
                    add(func_z, d),
                    square(func_z)),
                prod(e, func_z),
                f);

        #elif ALGORITHM == 5
            der3 = Complex(6.0, 0.0);

        #endif

        #if FRACTAL_TYPE == 0 // normal
        
            if (func.real * func.real + func.imag * func.imag <= threshold || iteration == max_iterations) {
                iters = iteration;
                break;
            }

        #elif FRACTAL_TYPE == 1 || FRACTAL_TYPE == 2 // nova

            dz = sub(z, z_prev);
            
            if (dz.real * dz.real + dz.imag * dz.imag <= threshold || iteration == max_iterations) {
                iters = iteration;
                break;
            }
            
            z_prev = z;

        #endif

        #if ALGORITHM == 0 // newton
            diff = div(
                func,
                der);

        #elif ALGORITHM == 1 // halley
            diff = div(
                scale(
                    prod(
                        func,
                        der),
                    2.0),
                sub(
                    scale(
                        square(der),
                        2.0),
                    prod(func, der2)));

        #elif ALGORITHM == 2 // schroeder
            diff = div(
                prod(func, der),
                sub(
                    square(der),
                    prod(func, der2)));

        #elif ALGORITHM == 3 // steffensen
            diff = div(
                square(func),
                sub(
                    func_step,
                    func));

        #elif ALGORITHM == 4 // secant

            Complex z_temp = z;

            diff = prod(
                    func,
                    div(
                        sub(
                            z,
                            z_prev),
                        sub(
                            func,
                            func_prev)));

            func_prev = func;
            z_prev = z_temp;

        #elif ALGORITHM == 5

            Complex funcder = prod(func, der);
            Complex func_sq = square(func);

            diff = div(
                sub(
                    scale(
                        prod(
                            funcder,
                            der),
                        6.0),
                    scale(
                        prod(
                            func_sq,
                            der2),
                        3.0)),
                add(
                    sub(
                        scale(
                            prod(
                                der,
                                square(der)),
                            6.0),
                        scale(
                            prod(
                                funcder,
                                der2),
                            6.0)),
                    prod(
                        func_sq,
                        der3)));

        #endif

        z = sub(z, prod(a, diff));

        #if FRACTAL_TYPE == 1 || FRACTAL_TYPE == 2
            iadd(z, c);
        #endif
        
    }

    if (colouring_type == 0 || colouring_type == 1) {

        float root_dist_1 = root_dist_sq(z, root1);
        float root_dist_2 = root_dist_sq(z, root2);
        float root_dist_3 = root_dist_sq(z, root3);

        float amount;

        if (colouring_type == 0) {
            amount = 0.0;
        
        } else {
            amount = float(iters) / float(max_iterations);
        }

        if (iters == max_iterations) {
            return base_colour;
        }

        if (root_dist_1 < root_dist_2 && root_dist_1 < root_dist_3) {
            return root1_colour * (1.0 - amount) + base_colour * amount;
        
        } else if (root_dist_2 < root_dist_3) {
            return root2_colour * (1.0 - amount) + base_colour * amount;
        
        } else {
            return root3_colour * (1.0 - amount) + base_colour * amount;
        }

    } else if (colouring_type == 2) {
        float amount = float(iters) / float(max_iterations);
        return root1_colour * (1.0 - amount) + base_colour * amount;
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