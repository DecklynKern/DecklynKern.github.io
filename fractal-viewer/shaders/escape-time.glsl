#define MANDELBROT          0
#define BURNING_SHIP        1
#define TRICORN             2
#define HEART               3
#define MANDELBOX           4
#define MULTIBROT           5
#define FEATHER             6
#define CHIRIKOV            7
#define SMELLY_SHOE         8
#define DOG_SKULL           9
#define EXPONENT2           10
#define DUFFING             11
#define GINGERBREAD         12
#define HENON               13
#define SINE                14
#define RATIONAL_MAP        15
#define PHOENIX             16
#define SIMONBROT           17
#define TIPPETTS            18
#define MAREK_DRAGON        19
#define GANGOPADHYAY        20
#define EXPONENT            21
#define SFX                 22
#define COMPLEX_MULTIBROT   23
#define THORN               24
#define META_MANDELBROT     25
#define BUFFALO             26
#define MAGNET              27
#define TRIPLE_DRAGON       28
#define SPIRAL              29
#define MANDELBRUH          30
#define HYPERBOLIC_SINE     31
#define ZUBIETA             32
#define CUBIC               33
#define LOGISTIC            34

uniform float fractal_param1;
uniform float fractal_param2;
uniform float fractal_param3;

uniform int is_inverted;

uniform int max_iterations;

uniform int is_julia;
uniform float julia_c_real;
uniform float julia_c_imag;

uniform float escape_radius_sq;

uniform vec3 exterior_colour1;
uniform vec3 exterior_colour2;

uniform float exterior_colouring_param1;
uniform float exterior_colouring_param2;

uniform vec3 interior_colour1;
uniform vec3 interior_colour2;

uniform float interior_colouring_param1;

const int TRUE_ITER_CAP = 10000;

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

Complex abs_each(Complex z) {
	return Complex(
		abs(z.real),
		abs(z.imag)
	);
}

#define div(x, y) prod(x, reciprocal(y))
#define ADD3(a, b, c) add(add(a, b), c)

vec3 interpolate(vec3 c1, vec3 c2, float amount) {
    return c1 * amount + c2 * (1.0 - amount);
}

float getSmoothIter(float mag_sq, Complex z) {

    float exp;

    #if FRACTAL == MULTIBROT
        exp = fractal_param1;

    #elif FRACTAL == RATIONAL_MAP
        exp = max(fractal_param1, fractal_param2);

    #elif FRACTAL == SIMONBROT || FRACTAL == META_MANDELBROT
        exp = 4.0;

    #else
        exp = 2.0;
    #endif
    
    return 1.0 + log(log(escape_radius_sq) / log(mag_sq)) / log(exp);
    
}

vec3 getColour(float real, float imag) {

    Complex z = Complex(real, imag);

    if (bool(is_inverted)) {
        z = reciprocal(z);
    }

    Complex c;
    
    #if FRACTAL == LOGISTIC
        c = z;
        z = Complex(0.5, 0.0);
    #else
        if (bool(is_julia)) {
            c = Complex(julia_c_real, julia_c_imag);
        }
        else {
            c = z;
        }
    #endif

    Complex z_prev;
    float z_real_sq = z.real * z.real;
    float z_imag_sq = z.imag * z.imag;
    float mag_sq = z_real_sq + z_imag_sq;

    int iterations;

    #if FRACTAL == EXPONENT2
        z = Complex(1.0, 0.0);

    #elif FRACTAL == MAREK_DRAGON
        float r = PI * 2.0 * fractal_param1;
        Complex zc = Complex(
            cos(r),
            sin(r)
        );

    #elif FRACTAL == SFX
        Complex c_mul = Complex(
            c.real * c.real,
            c.imag * c.imag
        );
    #endif

    #if MONITOR_ORBIT_TRAPS != 0
        float orbit_min_dist = monitorOrbitTraps(z, 99999999.9, mag_sq);
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
		
	#elif EXTERIOR_COLOURING_STYLE == 2
		#if RADIAL_ANGLE == 1
			float init_angle = argument(z);
			
		#elif RADIAL_ANGLE == 2
			Complex total_orbit = z;
		#endif
    #endif

    #if EXTERIOR_COLOURING_STYLE == 0 && MONOTONIC_FUNCTION == 3
        float exterior_stripe_total_prev = 0.0;
        float exterior_stripe_total = 0.0;
    #endif

    #if INTERIOR_COLOURING == 1
        float mag_sum = 0.0;

    #elif INTERIOR_COLOURING == 2
        float bail_dist_sq;
        float min_dist_sq = 1.0;

    #elif INTERIOR_COLOURING == 3
        Complex diff;
        float total_dist_sq = 0.0;
		
	#elif INTERIOR_COLOURING == 4
        float interior_stripe_total = 0.0;
    #endif

    for (int iteration = 0; iteration < TRUE_ITER_CAP; iteration++) {
    
        if (iteration >= max_iterations) {
            iterations = TRUE_ITER_CAP;
            break;
        }
        
        z_prev = z;

        #if FRACTAL == MANDELBROT
            z.imag = 2.0 * z.real * z.imag + c.imag;
            z.real = z_real_sq - z_imag_sq + c.real;

        #elif FRACTAL == BURNING_SHIP
		
			z = abs_each(z);

            z.imag = 2.0 * z.real * z.imag + c.imag;
            z.real = z_real_sq - z_imag_sq + c.real;

        #elif FRACTAL == TRICORN

            z.imag = -z.real * z.imag;
            z.imag = 2.0 * z.imag + c.imag;

            z.real = z_real_sq - z_imag_sq + c.real;

        #elif FRACTAL == HEART

            float temp;

            temp = z.real * z.imag + c.real;
            z.imag = abs(z.imag) - abs(z.real) + c.imag;
            z.real = temp;

        #elif FRACTAL == MANDELBOX

            if (mag_sq < 0.25) {
                z.real *= 4.0;
                z.imag *= 4.0;
            }
            else if (mag_sq < 1.0) {

                float temp = 1.0 / mag_sq;

                z.real /= temp;
                z.imag /= temp;
            }

            z.real = -fractal_param1 * z.real + c.real;
            z.imag = -fractal_param1 * z.imag + c.imag;
            
            if (z.real > 1.0) {
                z.real = 2.0 - z.real;
            }
            else if (z.real < -1.0) {
                z.real = -2.0 - z.real;
            }
            
            if (z.imag > 1.0) {
                z.imag = 2.0 - z.imag;
            }
            else if (z.imag < -1.0) {
                z.imag = -2.0 - z.imag;
            }

        #elif FRACTAL == MULTIBROT
            z = add(
                exponent(z, fractal_param1),
                c);

        #elif FRACTAL == FEATHER
            z = add(
                div(
                    Complex(
                    z.real * (z_real_sq - 3.0 * z_imag_sq),
                    z.imag * (3.0 * z_real_sq - z_imag_sq)),
                    Complex(
                        1.0 + z_real_sq,
                        1.0 + z_imag_sq)),
                c);

        #elif FRACTAL == CHIRIKOV
            z.imag += c.imag * sin(z.real);
            z.real += c.real * z.imag;

        #elif FRACTAL == SMELLY_SHOE

            z.real = sin(z.imag * z.real);
    
            z.imag = 2.0 * z.real * z.imag + c.imag;
            z.real = z_real_sq - z_imag_sq + c.real;

        #elif FRACTAL == DOG_SKULL
			float z_real = z.real;
			z.real = z_real_sq + tan(z.imag) + c.real;
			z.imag = z.imag * z_imag_sq - z_real + c.imag;

        #elif FRACTAL == EXPONENT2
            z = exponent(c, z);

        #elif FRACTAL == DUFFING
            z.real = z.imag;
            z.imag = c.imag * z.real + c.real * z.imag - z.imag * z_imag_sq;

        #elif FRACTAL == GINGERBREAD
            z.real = 1.0 - z.imag + abs(z.real) + c.real;
            z.imag = z.real + c.imag;

        #elif FRACTAL == HENON
            z.real = 1.0 - c.real * z_real_sq + z.imag;
            z.imag = c.imag * z.real;

        #elif FRACTAL == SINE

            float sin_real = sin(z.real) * cosh(z.imag);
            float sin_imag = cos(z.real) * sinh(z.imag);

            z.real = sin_real * c.real - sin_imag * c.imag;
            z.imag = c.real * sin_imag + sin_real * c.imag;

        #elif FRACTAL == RATIONAL_MAP
            z = add(
                sub(
                    exponent(z, fractal_param1),
                    scale(
                        exponent(z, fractal_param2),
                        fractal_param3)),
                c);

        #elif FRACTAL == PHOENIX

            float z_real = z.real;

            z.real = z_real_sq - z_imag_sq + fractal_param1 * z.real - fractal_param2 * z.imag + c.real;
            z.imag = 2.0 * z_real * z.imag + fractal_param1 * z.imag + fractal_param2 * z_real + c.imag;

        #elif FRACTAL == SIMONBROT
            z.imag = 2.0 * (z.real * z.imag) * mag_sq + c.imag;
            z.real = (z_real_sq - z_imag_sq) * mag_sq + c.real;

        #elif FRACTAL == TIPPETTS
            z.real = z_real_sq - z_imag_sq + c.real;
            z.imag = 2.0 * z.real * z.imag + c.imag;

        #elif FRACTAL == MAREK_DRAGON
            z = prod(
                z, 
                Complex(
                    zc.real + z.real,
                    zc.imag + z.imag));

        #elif FRACTAL == GANGOPADHYAY

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

        #elif FRACTAL == EXPONENT
            z = prod(c, exponent(z));

        #elif FRACTAL == SFX

            Complex zc = prod(z, c_mul);

            z = Complex(
                z.real * mag_sq - zc.real,
                z.imag * mag_sq - zc.imag);

        #elif FRACTAL == COMPLEX_MULTIBROT
            z = add(
                exponent(
                    z,
                    Complex(fractal_param1, fractal_param2)),
                c);

        #elif FRACTAL == THORN
            z.real = z.real / cos(z.imag) + c.real;
            z.imag = z.imag / sin(z.real) + c.imag;

        #elif FRACTAL == META_MANDELBROT

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

        #elif FRACTAL == BUFFALO
            z = Complex(
                z_real_sq - z_imag_sq - abs(z.real) + c.real,
                2.0 * abs(z.real * z.imag) - abs(z.imag) + c.imag
            );

        #elif FRACTAL == MAGNET

            float dzr = 2.0 * z.real;

            z = square(
                div(
                    Complex(
                        z_real_sq - z_imag_sq + c.real - 1.0,
                        dzr * z.imag + c.imag),
                    Complex(
                        dzr + c.real - 2.0,
                        2.0 * z.imag + c.imag)));

        #elif FRACTAL == TRIPLE_DRAGON

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

        #elif FRACTAL == SPIRAL

            Complex dz2c = Complex(
                2.0 * (z_real_sq - z_imag_sq + c.real),
                4.0 * z.real * z.imag + c.imag
            );

            float denom = cos(dz2c.real) + cosh(dz2c.imag);

            z = Complex(
                sin(dz2c.real) / denom,
                sinh(dz2c.imag) / denom
            );
		
		#elif FRACTAL == MANDELBRUH
            z.imag = fractal_param1 * z.real * z.imag + c.imag;
            z.real = z_real_sq - z_imag_sq + c.real;
			
		#elif FRACTAL == HYPERBOLIC_SINE
		
			z = add(
				abs_each(exponent(
					Complex(
						sinh(z.real) * cos(z.imag),
						cosh(z.real) * sin(z.imag)),
					fractal_param1)),
				c);
				
		#elif FRACTAL == ZUBIETA
		
			Complex recip = div(prod(c, Complex(fractal_param1, fractal_param2)), z);
		
            z.imag = 2.0 * z.real * z.imag + recip.imag;
            z.real = z_real_sq - z_imag_sq + recip.real;
			
		#elif FRACTAL == CUBIC
            
			z = add(
				sub(
					exponent(z, 3.0),
					exponent(
						Complex(
							-z.real,
							-z.imag),
						2.00001)),
					c);

        #elif FRACTAL == LOGISTIC

            z = prod(
                c,
                prod(
                    z,
                    Complex(
                        1.0 - z.real,
                        -z.imag)));
			
        #endif
        
        z_real_sq = z.real * z.real;
        z_imag_sq = z.imag * z.imag;
        
        mag_sq = z_real_sq + z_imag_sq;

        #if MONITOR_ORBIT_TRAPS != 0
            orbit_min_dist = monitorOrbitTraps(z, orbit_min_dist, mag_sq);
        #endif

        #if EXTERIOR_COLOURING_STYLE == 0
            #if MONOTONIC_FUNCTION == 2
                #if FRACTAL == MANDELBROT

                    der = add(
                        scale(
                            prod(
                                z_prev,
                                der),
                            2.0),
                        Complex(
                            1.0,
                            0.0));

                #elif FRACTAL == MULTIBROT

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
        
        #if EXTERIOR_COLOURING_STYLE == 0 && MONOTONIC_FUNCTION == 3
            exterior_stripe_total_prev = exterior_stripe_total;
            exterior_stripe_total += 0.5 + 0.5 * sin(exterior_colouring_param1 * argument(z));
        #endif

        #if EXTERIOR_COLOURING_STYLE == 1
            #if CYCLE_FUNCTION == 1
                exp_diff = sub(z, z_prev);
                exponential += exp(-(sqrt(mag_sq) + 0.5 / sqrt(exp_diff.real * exp_diff.real + exp_diff.imag * exp_diff.imag)));
            #endif
			
		#elif EXTERIOR_COLOURING_STYLE == 2
			#if RADIAL_ANGLE == 2
				total_orbit = add(total_orbit, z);
			#endif
        #endif

        #if INTERIOR_COLOURING == 1
            mag_sum += mag_sq;

        #elif INTERIOR_COLOURING == 2
            min_dist_sq = min(min_dist_sq, 1.0 - mag_sq / escape_radius_sq);

        #elif INTERIOR_COLOURING == 3
            diff = sub(z, z_prev);
            total_dist_sq += diff.real * diff.real + diff.imag * diff.imag;
		
        #elif INTERIOR_COLOURING == 4
            interior_stripe_total += 0.5 + 0.5 * sin(interior_colouring_param1 * argument(z));
        #endif
        
        if (mag_sq >= escape_radius_sq) {
            iterations = iteration + 1;
            break;
        }
    }

    if (iterations == TRUE_ITER_CAP) {

        #if INTERIOR_COLOURING == 0
            return interior_colour1;

        #elif INTERIOR_COLOURING == 1
            return interpolate(interior_colour2, interior_colour1, mag_sum / sqrt(float(iterations)));

        #elif INTERIOR_COLOURING == 2
            return interpolate(interior_colour1, interior_colour2, min_dist_sq);

        #elif INTERIOR_COLOURING == 3
            return hsv2rgb(vec3(fract(sqrt(total_dist_sq)), 1.0, 1.0));

        #elif INTERIOR_COLOURING == 4
            return interpolate(interior_colour1, interior_colour2, interior_stripe_total / float(max_iterations));

        #elif INTERIOR_COLOURING == 5
            #if MONITOR_ORBIT_TRAPS == 0
                return interior_colour1;
            #else
                return interpolate(interior_colour1, interior_colour2, 1.0 - orbit_min_dist / 2.0);
            #endif
        #endif

    }
else {

        float colour_val = 0.0;

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
                colour_val = (exterior_stripe_total * interp + exterior_stripe_total_prev * (1.0 - interp)) / (float(iterations) + interp);

            #elif MONOTONIC_FUNCTION == 4
                #if MONITOR_ORBIT_TRAPS == 0
                    colour_val = 0.0;

                #else
                    colour_val = 1.0 - orbit_min_dist / 2.0;
                #endif
            #endif

        #elif EXTERIOR_COLOURING_STYLE == 1

            float val;

            #if CYCLE_FUNCTION == 0
                val = float(iterations) + getSmoothIter(mag_sq, z);

            #elif CYCLE_FUNCTION == 1
                val = log(exponential);

            #elif CYCLE_FUNCTION == 2
                #if MONITOR_ORBIT_TRAPS == 0
                    val = 0.0;
                #else
                    val = log(orbit_min_dist);
                #endif
            #endif

            val /= exterior_colouring_param1;

            #if CYCLIC_WAVEFORM == 0
                colour_val = 0.5 * sin(val * 2.0 * PI) + 0.5;

            #elif CYCLIC_WAVEFORM == 1
                colour_val = round(fract(val + 0.5));

            #elif CYCLIC_WAVEFORM == 2
                val = fract(val);
                colour_val = val > 0.5 ? 1.0 - 2.0 * (val - 0.5) : 2.0 * val;

            #elif CYCLIC_WAVEFORM == 3
                colour_val = fract(val + 0.5);
            #endif

        #elif EXTERIOR_COLOURING_STYLE == 2
            
            float angle;

			#if RADIAL_ANGLE == 0
				angle = argument(z);
				
			#elif RADIAL_ANGLE == 1
				angle = init_angle;
				
			#elif RADIAL_ANGLE == 2
				angle = argument(total_orbit);
			#endif

            #if RADIAL_DECOMPOSITION == 0
                colour_val = abs(angle) / PI;

            #elif RADIAL_DECOMPOSITION == 1
                colour_val = angle > 0.0 ? 0.0 : 1.0;
            #endif
        #endif

        #if EXTERIOR_COLOURING == 0
            return interpolate(exterior_colour1, exterior_colour2, colour_val);

        #elif EXTERIOR_COLOURING == 1
            return hsv2rgb(vec3(colour_val, 1.0, 1.0));
        #endif

    }
}