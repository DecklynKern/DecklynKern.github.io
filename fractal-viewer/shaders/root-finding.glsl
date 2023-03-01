precision highp float;

uniform float magnitude;
uniform float centre_x;
uniform float centre_y;

uniform int algorithm;
uniform int fractal_type;

uniform int max_iterations;
uniform float threshold;

uniform float root1_real;
uniform float root1_imag;
uniform float root2_real;
uniform float root2_imag;
uniform float root3_real;
uniform float root3_imag;

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

struct Iterator {
    Complex z;
    Complex c;
    Complex d;
    Complex e;
    Complex f;
};

struct Val0 {
    Complex func;
};

struct Val1 {
    Complex func;
    Complex der;
};

struct Val2 {
    Complex func;
    Complex der;
    Complex der2;
};

struct ValPrev {
    Complex func;
    Complex func_prev;
    Complex z;
    Complex z_prev;
};

struct ValStef {
    Complex func;
    Complex func_step;
};

#define div(x, y) prod(x, reciprocal(y))

#define ADD3(a, b, c) add(add(a, b), c)
#define ADD4(a, b, c, d) add(ADD3(a, b, c), d)
#define ADD5(a, b, c, d, e) add(ADD4(a, b, c, d), e)

void cubic0(Iterator iter, inout Val0 val) {
    val.func = ADD3(
        prod(
            add(iter.d, iter.z),
            square(iter.z)),
        prod(iter.e, iter.z),
        iter.f);
}

void cubic1(Iterator iter, inout Val1 val) {

    Complex z2 = square(iter.z);

    val.func = ADD3(
        prod(
            add(iter.d, iter.z),
            z2),
        prod(iter.e, iter.z),
        iter.f);

    val.der = ADD3(
        scale(z2, 3.0),
        prod(scale(iter.d, 2.0), iter.z),
        iter.e);

}

void cubic2(Iterator iter, inout Val2 val) {

    Complex z2 = square(iter.z);
    Complex dd = scale(iter.d, 2.0);

    val.func = ADD3(
        prod(
            add(iter.d, iter.z),
            z2),
        prod(iter.e, iter.z),
        iter.f);

    val.der = ADD3(
        scale(z2, 3.0),
        prod(dd, iter.z),
        iter.e);

    val.der2 = add(
        scale(iter.z, 6.0),
        dd);

}

void cubicPrev(Iterator iter, inout ValPrev val) {

    val.func_prev = val.func;
    val.func = ADD3(
        prod(
            add(iter.d, iter.z),
            square(iter.z)),
        prod(iter.e, iter.z),
        iter.f);

    val.z_prev = val.z;
    val.z = iter.z;
    
}

void cubicStef(Iterator iter, inout ValStef val) {

    val.func = ADD3(
        prod(
            add(iter.d, iter.z),
            square(iter.z)),
        prod(iter.e, iter.z),
        iter.f);

    Complex func_z = add(val.func, iter.z);

    val.func_step = ADD3(
        prod(
            add(func_z, iter.d),
            square(func_z)),
        prod(iter.e, func_z),
        iter.f);

}

void newton(inout Iterator iter, Val1 val) {
    iter.z = sub(
        iter.z,
        div(
            val.func,
            val.der));
}

void halley(inout Iterator iter, Val2 val) {
    iter.z = sub(
        iter.z,
        div(
            scale(
                prod(
                    val.func,
                    val.der),
                2.0),
            sub(
                scale(
                    square(val.der),
                    2.0),
                prod(val.func, val.der2))));
}

void schroeder(inout Iterator iter, Val2 val) {
    iter.z = sub(
        iter.z,
        div(
            prod(val.func, val.der),
            sub(
                square(val.der),
                prod(val.func, val.der2))));
}

void steffensen(inout Iterator iter, ValStef val) {
    iter.z = sub(
        iter.z,
        div(
            square(val.func),
            sub(
                val.func_step,
                val.func)));
}

void secant(inout Iterator iter, ValPrev val) {
    iter.z = sub(
        iter.z,
        prod(
            val.func,
            div(
                sub(
                    val.z,
                    val.z_prev),
                sub(
                    val.func,
                    val.func_prev))));
}

#define SOLVE(algorithm, calc_vals)\
for (int iteration = 0; iteration < TRUE_ITER_CAP; iteration++) {\
    \
    calc_vals(iter, val);\
    \
    if (val.func.real * val.func.real + val.func.imag * val.func.imag <= threshold || iteration == max_iterations) {\
        iters = iteration;\
        break;\
    }\
    \
    algorithm(iter, val);\
    iadd(iter.z, iter.c);\
    \
}

#define SOLVE_NOVA(algorithm, calc_vals)\
Complex z_prev = Complex(\
    iter.z.real + 1.0,\
    iter.z.imag\
);\
Complex dz;\
for (int iteration = 0; iteration < TRUE_ITER_CAP; iteration++) {\
    \
    calc_vals(iter, val);\
    dz = sub(iter.z, z_prev);\
    \
    if (dz.real * dz.real + dz.imag * dz.imag <= threshold || iteration == max_iterations) {\
        iters = iteration;\
        break;\
    }\
    \
    z_prev = iter.z;\
    algorithm(iter, val);\
    iadd(iter.z, iter.c);\
    \
}

#define SOLVE_ALL(algorithm, calc_vals)\
if (fractal_type == 0) {\
    SOLVE(algorithm, calc_vals);\
} else if (fractal_type == 1) {\
    SOLVE_NOVA(algorithm, calc_vals);\
}

vec3 getColour(Complex z) {

    Complex c;

    Complex root1 = Complex(root1_real, root1_imag);
    Complex root2 = Complex(root2_real, root2_imag);
    Complex root3 = Complex(root3_real, root3_imag);

    if (fractal_type == 0) {
        c = ZERO;
    
    } else if (fractal_type == 1) {
        c = z;
        z = Complex(1.0, 0.0);
    }

    Complex r1r2 = prod(root1, root2);

    Iterator iter = Iterator(
        z,
        c,
        neg(ADD3(root1, root2, root3)),
        ADD3(r1r2, prod(root1, root3), prod(root2, root3)),
        neg(prod(r1r2, root3))
    );

    int iters = max_iterations;

    if (algorithm == 0) {
        Val1 val = Val1(ZERO, ZERO);
        SOLVE_ALL(newton, cubic1);

    } else if (algorithm == 1) {
        Val2 val = Val2(ZERO, ZERO, ZERO);
        SOLVE_ALL(halley, cubic2);

    } else if (algorithm == 2) {
        Val2 val = Val2(ZERO, ZERO, ZERO);
        SOLVE_ALL(schroeder, cubic2);

    } else if (algorithm == 3) {
        ValStef val = ValStef(ZERO, ZERO);
        SOLVE_ALL(steffensen, cubicStef);
    
    } else if (algorithm >= 4 && algorithm <= 8) {

        Complex z_prev;

        if (algorithm == 4) {
            z_prev = ZERO;
        
        } else if (algorithm == 5) {
            z_prev = Complex(
                iter.z.imag,
                iter.z.real
            );

        } else if (algorithm == 6) {
            z_prev = scale(iter.z, 2.0);
        
        } else if (algorithm == 7) {
            z_prev = conj(iter.z);

        } else if (algorithm == 8) {
            z_prev = square(iter.z);
        }

        Val0 temp = Val0(ZERO);
        Complex z_temp = iter.z;

        iter.z = z_prev;
        cubic0(iter, temp);
        iter.z = z_temp;

        ValPrev val = ValPrev(
            temp.func,
            ZERO,
            z_prev,
            ZERO
        );
        SOLVE(secant, cubicPrev);
    }

    if (colouring_type == 0 || colouring_type == 1 ) {

        float root_dist_1 = root_dist_sq(iter.z, root1);
        float root_dist_2 = root_dist_sq(iter.z, root2);
        float root_dist_3 = root_dist_sq(iter.z, root3);

        float amount;

        if (colouring_type == 0) {
            amount = 1.0;
        
        } else {
            amount = 1.0 - float(iters) / float(max_iterations);
        }

        if (iters == max_iterations) {
            return base_colour;
        }

        if (root_dist_1 < root_dist_2 && root_dist_1 < root_dist_3) {
            return root1_colour * amount + base_colour * (1.0 - amount);
        
        } else if (root_dist_2 < root_dist_3) {
            return root2_colour * amount + base_colour * (1.0 - amount);
        
        } else {
            return root3_colour * amount + base_colour * (1.0 - amount);
        }

    } else if (colouring_type == 2) {
        float amount = 1.0 - float(iters) / float(max_iterations);
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