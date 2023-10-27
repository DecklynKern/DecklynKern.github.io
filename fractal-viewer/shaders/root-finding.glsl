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

uniform float colouring_param;

uniform vec3 root1_colour;
uniform vec3 root2_colour;
uniform vec3 root3_colour;
uniform vec3 base_colour;

const int TRUE_ITER_CAP = 10000;

float root_dist_sq(Complex z, Complex root) {
    Complex diff = z - root;
    return dot(diff, diff);
}

vec3 getColour(float real, float imag) {

    Complex z = Complex(real, imag);
    Complex z_prev;

    #if FUNCTION == 0

        Complex root1 = Complex(root1_real, root1_imag);
        Complex root2 = Complex(root2_real, root2_imag);

        #if FRACTAL_TYPE == 3
            Complex root3 = z;
            z = (root1 + root2 + root3) * 0.33333333333;
        
        #else
            Complex root3 = Complex(root3_real, root3_imag);
        #endif

        Complex r1r2 = prod(root1, root2);
        
        Complex d = -(root1 + root2 + root3);
        Complex e = r1r2 + prod(root1, root3) + prod(root2, root3);
        Complex f = -prod(r1r2, root3);

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

        z_prev = Complex(MAX, 0.0);
        Complex dz;

    #elif FRACTAL_TYPE == 2

        Complex c = Complex(c_real, c_imag);

        z_prev = Complex(MAX, 0.0);
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
            z_prev = 2.0 * z;

        #elif START_POINT == 3
            z_prev = conj(z);

        #elif START_POINT == 4
            z_prev = square(z);
        #endif

        #if FUNCTION == 0
        
            func_prev = 
                prod(z_prev + d, square(z_prev)) +
                prod(e, z_prev) +
                f;

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
        vec3 min_root_dists_sq = vec3(MAX, MAX, MAX);
    #endif

    for (int iteration = 0; iteration < TRUE_ITER_CAP; iteration++) {

        #if FUNCTION == 0
        
            Complex z2 = square(z);
            func = 
                prod(z + d, z2) +
                prod(e, z) +
                f;

            #if ALGORITHM == 0 || ALGORITHM == 1 || ALGORITHM == 2 || ALGORITHM == 5
                Complex dd = 2.0 * d;
                der = 3.0 * z2 + prod(dd, z) + e;
            #endif

            #if ALGORITHM == 1 || ALGORITHM == 2 || ALGORITHM == 5
                der2 = 6.0 * z + dd;
            #endif

            #if ALGORITHM == 3
                Complex func_z = func + z;
                func_step =
                    prod(func_z + d, square(func_z)) +
                    prod(e, func_z) +
                    f;

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
                der2 = -func;
            #endif

            #if ALGORITHM == 3

                Complex func_z = func + z;

                func_step = Complex(
                    sin(func_z.real) * cosh(func_z.imag),
                    cos(func_z.real) * sinh(func_z.imag)
                );

            #elif ALGORITHM == 5
                der3 = -der;
            #endif

        #elif FUNCTION == 2

            Complex exp = exponent(z, p);
            func = Complex(
                exp.real - 1.0,
                exp.imag
            );

            #if ALGORITHM == 0 || ALGORITHM == 1 || ALGORITHM == 2 || ALGORITHM == 5
                der = prod(p, exponent(z, p2));

            #endif

            #if ALGORITHM == 1 || ALGORITHM == 2 || ALGORITHM == 5
                der2 = prod(pp2, exponent(z, p3));

            #endif

            #if ALGORITHM == 3
            
                Complex exp2 = exponent(func + z, p);

                func_step = Complex(
                    exp2.real - 1.0,
                    exp2.imag
                );

            #elif ALGORITHM == 5
                der3 = prod(pp2p3, exponent(z, p4));
            #endif
        #endif

        #if COLOURING_TYPE == 3
            max_norm_sq = max(max_norm_sq, dot(z, z));

        #elif COLOURING_TYPE == 4
        
            Complex offset1 = z - root1;
            Complex offset2 = z - root2;
            Complex offset3 = z - root3;
            
            min_root_dists_sq = min(
                min_root_dists_sq,
                vec3(
                    dot(offset1, offset1),
                    dot(offset2, offset2),
                    dot(offset3, offset3)
                )
            );

        #endif

        #if FRACTAL_TYPE == 0 || FRACTAL_TYPE == 3 // normal
        
            if (dot(func, func) <= threshold || iteration == max_iterations) {
                iters = iteration;
                break;
            }

        #elif FRACTAL_TYPE == 1 || FRACTAL_TYPE == 2 // nova

            dz = z - z_prev;
            
            if (dot(dz, dz) <= threshold || iteration == max_iterations) {
                iters = iteration;
                break;
            }

        #endif

        #if ALGORITHM != 4
            z_prev = z;
        #endif

        #if ALGORITHM == 0 // newton
            diff = div(func, der);

        #elif ALGORITHM == 1 // halley
            diff = div(
                prod(func, der),
                square(der) - 0.5 * prod(func, der2));

        #elif ALGORITHM == 2 // schroeder
            diff = div(
                prod(func, der),
                square(der) - prod(func, der2));

        #elif ALGORITHM == 3 // steffensen
            diff = div(square(func), func_step - func);

        #elif ALGORITHM == 4 // secant

            Complex z_temp = z;

            diff = prod(
                func,
                div(
                    z - z_prev,
                    func - func_prev));

            func_prev = func;
            z_prev = z_temp;

        #elif ALGORITHM == 5

            Complex funcder = prod(func, der);
            Complex func_sq = square(func);
            
            Complex num =
                6.0 * prod(funcder, der) -
                3.0 * prod(func_sq, der2);
                
            Complex denom =
                6.0 * prod(der, square(der)) -
                6.0 * prod(funcder, der2) +
                prod(func_sq, der3);
            
            diff = div(num, denom);

        #endif

        z -= prod(a, diff);

        #if FRACTAL_TYPE == 1 || FRACTAL_TYPE == 2
            z += c;
        #endif
        
    }

    #if COLOURING_TYPE == 2
        return mix(root1_colour, base_colour, float(iters) / float(max_iterations));

    #elif COLOURING_TYPE == 4
        return
            mat3(root1_colour, root2_colour, root3_colour) *
            (1.0 - min(vec3(1.0, 1.0, 1.0), log(min_root_dists_sq / colouring_param + 1.0)));
			
	#elif COLOURING_TYPE == 5

        if (iters == max_iterations) {
            return base_colour;
        }
	
        // fix 
		float thresh = 2.0 * (threshold + 0.000000000000001);
		return vec3((thresh * round(z.xy / thresh)), 1.0);

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