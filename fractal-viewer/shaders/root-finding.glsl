uniform int max_iterations;
uniform float threshold;

uniform int is_inverted;

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

uniform float colouring_param;

uniform vec3 root1_colour;
uniform vec3 root2_colour;
uniform vec3 root3_colour;
uniform vec3 base_colour;

const int TRUE_ITER_CAP = 10000;
const float MAX = 9999999999999.9;

vec3 getColour(float real, float imag) {

    Complex z = Complex(real, imag);

	if (bool(is_inverted)) {
		z = reciprocal(z);
	}

    Complex z_prev;

    #if FUNCTION == 0

        Complex root1 = Complex(root1_real, root1_imag);
        Complex root2 = Complex(root2_real, root2_imag);

        #if FRACTAL_TYPE != 3
            Complex root3 = Complex(root3_real, root3_imag);
        
        #else
            Complex root3 = z;
            z = scale(
                add3(root1, root2, root3),
                0.3333333333);

        #endif


        Complex r1r2 = prod(root1, root2);
        
        Complex d = neg(add3(root1, root2, root3));
        Complex e = add3(r1r2, prod(root1, root3), prod(root2, root3));
        Complex f = neg(prod(r1r2, root3));

    #elif FUNCTION == 2

        Complex p = Complex(root1_real, root1_imag);

        #if ALGORITHM == 0 || ALGORITHM == 1 || ALGORITHM == 2 || ALGORITHM == 5

            Complex p2 = Complex(
                root1_real - 1.0,
                root1_imag
            );

        #endif

        #if ALGORITHM == 1 || ALGORITHM == 2 || ALGORITHM == 5

            Complex pp2 = prod(p, p2);
            Complex p3 = Complex(
                root1_real - 2.0,
                root1_imag
            );

        #endif

        #if ALGORITHM == 5

            Complex pp2p3 = prod(pp2, p3);
            Complex p4 = Complex(
                root1_real - 3.0,
                root1_imag
            );

        #endif

    #endif

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
            z_prev = Complex(z.imag, z.real);

        #elif START_POINT == 2
            z_prev = scale(z, 2.0);

        #elif START_POINT == 3
            z_prev = conj(z);

        #elif START_POINT == 4
            z_prev = square(z);
        #endif

        #if FUNCTION == 0

            func_prev = add3(
                prod(
                    add(d, z_prev),
                    square(z_prev)),
                prod(e, z_prev),
                f);

        #elif FUNCTION == 1

            z_prev = Complex(
                sin(z_prev.real) * cosh(z_prev.imag),
                cos(z_prev.real) * sinh(z_prev.imag)
            );

        #endif

    #elif ALGORITHM == 5
        Complex der = ZERO;
        Complex der2 = ZERO;
        Complex der3 = ZERO;

    #endif

    #if COLOURING_TYPE == 3
        float max_norm_sq = 0.0;

    #elif COLOURING_TYPE == 4
        float min_root1_dist_sq = MAX;
        float min_root2_dist_sq = MAX;
        float min_root3_dist_sq = MAX;

    #endif

    for (int iteration = 0; iteration < TRUE_ITER_CAP; iteration++) {

        #if FUNCTION == 0

            Complex z2 = square(z);

            func = add3(
                prod(
                    add(d, z),
                    z2),
                prod(e, z),
                f);

            #if ALGORITHM == 0 || ALGORITHM == 1 || ALGORITHM == 2 || ALGORITHM == 5

                Complex dd = scale(d, 2.0);

                der = add3(
                    scale(z2, 3.0),
                    prod(dd, z),
                    e);

            #endif

            #if ALGORITHM == 1 || ALGORITHM == 2 || ALGORITHM == 5

                der2 = add(
                    scale(z, 6.0),
                    dd);

            #endif

            #if ALGORITHM == 3

                Complex func_z = add(func, z);

                func_step = add3(
                    prod(
                        add(func_z, d),
                        square(func_z)),
                    prod(e, func_z),
                    f);

            #elif ALGORITHM == 5
                der3 = Complex(6.0, 0.0);

            #endif

        #elif FUNCTION == 1

            float cos_a = cos(z.real);
            float sin_a = sin(z.real);
            float cosh_b = cosh(z.imag);
            float sinh_b = sinh(z.imag);

            func = Complex(
                sin_a * cosh_b,
                cos_a * sinh_b
            );

            #if ALGORITHM == 0 || ALGORITHM == 1 || ALGORITHM == 2 || ALGORITHM == 5

                der = Complex(
                    cos_a * cosh_b,
                    sin_a * sinh_b
                );

            #endif

            #if ALGORITHM == 1 || ALGORITHM == 2 || ALGORITHM == 5
                der2 = neg(func);

            #endif

            #if ALGORITHM == 3

                Complex func_z = add(func, z);

                func_step = Complex(
                    sin(func_z.real) * cosh(func_z.imag),
                    cos(func_z.real) * sinh(func_z.imag)
                );

            #elif ALGORITHM == 5
                der3 = neg(der);

            #endif

        #elif FUNCTION == 2

            Complex exp = exponent(z, p);
            func = Complex(
                exp.real - 1.0,
                exp.imag
            );

            #if ALGORITHM == 0 || ALGORITHM == 1 || ALGORITHM == 2 || ALGORITHM == 5
                der = prod(
                    p,
                    exponent(
                        z,
                        p2));

            #endif

            #if ALGORITHM == 1 || ALGORITHM == 2 || ALGORITHM == 5
                der2 = prod(
                    pp2,
                    exponent(
                        z,
                        p3));

            #endif

            #if ALGORITHM == 3

                Complex func_z = add(func, z);
                Complex exp2 = exponent(func_z, p);

                func_step = Complex(
                    exp2.real - 1.0,
                    exp2.imag
                );

            #elif ALGORITHM == 5
                der3 = prod(
                    pp2p3,
                    exponent(
                        z,
                        p4));

            #endif

        #endif

        #if COLOURING_TYPE == 3

            float norm_sq = z.real * z.real + z.imag * z.imag;

            if (norm_sq > max_norm_sq) {
                max_norm_sq = norm_sq;
            }

        #elif COLOURING_TYPE == 4

            Complex root1_offset = sub(z, root1);
            float root1_dist_sq = root1_offset.real * root1_offset.real + root1_offset.imag* root1_offset.imag;

            if (root1_dist_sq < min_root1_dist_sq) {
                min_root1_dist_sq = root1_dist_sq;
            }

            Complex root2_offset = sub(z, root2);
            float root2_dist_sq = root2_offset.real * root2_offset.real + root2_offset.imag* root2_offset.imag;

            if (root2_dist_sq < min_root2_dist_sq) {
                min_root2_dist_sq = root2_dist_sq;
            }

            Complex root3_offset = sub(z, root3);
            float root3_dist_sq = root3_offset.real * root3_offset.real + root3_offset.imag* root3_offset.imag;

            if (root3_dist_sq < min_root3_dist_sq) {
                min_root3_dist_sq = root3_dist_sq;
            }

        #endif

        #if FRACTAL_TYPE == 0 || FRACTAL_TYPE == 3 // normal
        
            if (magnitude_sq(func) <= threshold || iteration == max_iterations) {
                iters = iteration;
                break;
            }

        #elif FRACTAL_TYPE == 1 || FRACTAL_TYPE == 2 // nova

            dz = sub(z, z_prev);
            
            if (magnitude_sq(dz) <= threshold || iteration == max_iterations) {
                iters = iteration;
                break;
            }

        #endif

        #if ALGORITHM != 4
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
            z += c;
        #endif
        
    }

    #if COLOURING_TYPE == 2
        float amount = float(iters) / float(max_iterations);
        return root1_colour * (1.0 - amount) + base_colour * amount;

    #elif COLOURING_TYPE == 4

        return root1_colour * (1.0 - min(1.0, log(min_root1_dist_sq / colouring_param + 1.0))) +
            root2_colour * (1.0 - min(1.0, log(min_root2_dist_sq / colouring_param + 1.0))) +
            root3_colour * (1.0 - min(1.0, log(min_root3_dist_sq / colouring_param + 1.0)));
			
	#elif COLOURING_TYPE == 5

        if (iters == max_iterations) {
            return base_colour;
        }
	
        // fix 
		float thresh = (threshold + 0.000000000000001) * 2.0;
		return vec3((thresh * round(z * (1.0 / thresh)).xy), 1.0);

    #else

        float root_dist_1 = root_dist_sq(z, root1);
        float root_dist_2 = root_dist_sq(z, root2);
        float root_dist_3 = root_dist_sq(z, root3);

        float amount;

        #if COLOURING_TYPE == 0
            amount = 0.0;

        #elif COLOURING_TYPE == 1
            amount = float(iters) / float(max_iterations);

        #else
            amount = fract(max_norm_sq / colouring_param);
        #endif

        if (iters == max_iterations) {
            return base_colour;
        }

        if (root_dist_1 < root_dist_2 && root_dist_1 < root_dist_3) {
            return mix(root1_colour, base_colour, amount);
        }
        else if (root_dist_2 < root_dist_3) {
            return mix(root2_colour, base_colour, amount);
        }
        else {
            return mix(root3_colour, base_colour, amount);
        }

    #endif
}