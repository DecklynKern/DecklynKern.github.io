#define MANDELBROT             0
#define BURNING_SHIP           1
#define TRICORN                2
#define HEART                  3
#define MANDELBOX              4
#define MULTIBROT              5
#define FEATHER                6
#define CHIRIKOV               7
#define SMELLY_SHOE            8
#define DOG_SKULL              9
#define EXPONENT2              10
#define DUFFING                11
#define GINGERBREAD            12
#define HENON                  13
#define SINE                   14
#define RATIONAL_MAP           15
#define PHOENIX                16
#define SIMONBROT              17
#define TIPPETTS               18
#define MAREK_DRAGON           19
#define GANGOPADHYAY           20
#define EXPONENT               21
#define SFX                    22
#define COMPLEX_MULTIBROT      23
#define THORN                  24
#define META_MANDELBROT        25
#define BUFFALO                26
#define MAGNET                 27
#define TRIPLE_DRAGON          28
#define SPIRAL                 29
#define MANDELBRUH             30
#define HYPERBOLIC_SINE        31
#define ZUBIETA                32
#define CUBIC                  33
#define LOGISTIC               34
#define TRICORN_SINE           35
#define TWIN_MANDELBROT        36
#define FRACKTAIL              37
#define SAURON                 38
#define PARTIAL_BURNING_SHIP   39
#define MULTI_BURNING_SHIP     40

uniform float fractal_param1;
uniform float fractal_param2;
uniform float fractal_param3;

uniform int is_inverted;
uniform float invert_real;
uniform float invert_imag;

uniform float escape_param;
uniform int max_iterations;

uniform int is_julia;
uniform float julia_c_real;
uniform float julia_c_imag;

uniform vec3 exterior_colour1;
uniform vec3 exterior_colour2;

uniform float exterior_colouring_param1;
uniform float exterior_colouring_param2;

uniform vec3 interior_colour1;
uniform vec3 interior_colour2;

uniform float interior_colouring_param1;
uniform float interior_colouring_param2;

const int TRUE_ITER_CAP = 10000;

float getSmoothIter(float mag_sq) {

    float exp;

    #if FRACTAL == MULTIBROT || FRACTAL == MULTI_BURNING_SHIP
        exp = max(1.0, fractal_param1);

    #elif FRACTAL == RATIONAL_MAP
        exp = max(fractal_param1, fractal_param2);

    #elif FRACTAL == SIMONBROT || FRACTAL == META_MANDELBROT
        exp = 4.0;

    #else
        exp = 2.0;
    #endif
    
    return 1.0 + log(log(escape_param) / log(mag_sq)) / log(exp);
    
}

float getSmoothDerIter(Complex der) {

    float exp;

    #if FRACTAL == MULTIBROT || FRACTAL == MULTI_BURNING_SHIP
        exp = max(1.0, fractal_param1);

    #elif FRACTAL == RATIONAL_MAP
        exp = max(fractal_param1, fractal_param2);

    #elif FRACTAL == SIMONBROT || FRACTAL == META_MANDELBROT
        exp = 4.0;

    #else
        exp = 2.0;
    #endif
    
    return 1.0 + log(log(escape_param) / log(dot(der, der))) / log(exp);
    
}

float centrePointOrbitDist(float mag_sq) {
    return sqrt(mag_sq);
}

float centrePointOrbitTaxicabDist(Complex z) {
    return abs(z.real) + abs(z.imag);
}

float circleOrbitDist(float mag_sq, float radius) {
    return abs(sqrt(mag_sq) - radius);
}

float crossOrbitDist(Complex z, float size) {
    vec2 dists = abs(abs(z) - size);
    return min(dists.real, dists.imag);
}

float gaussianIntegerOrbitDist(Complex z, float scale) {
    Complex scaled = fract(z / scale);
    return length(min(scaled, 1.0 - scaled)) * 3.0;
}

float gaussianIntegerOrbitTaxicabDist(Complex z, float scale) {
    Complex scaled = fract(z / scale);
    Complex axis_dists = min(scaled, 1.0 - scaled);
    return (axis_dists.real + axis_dists.imag * 3.0);
}

float lineOrbitDist(vec2 z, float angle) {
    return abs(-cos(angle) * z.y - sin(angle) * z.x);
}

vec3 getColour(float real, float imag) {

    Complex z = Complex(real, imag);
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

    Complex z_prev = ZERO;
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

    #ifdef MONITOR_ORBIT_TRAPS
        float orbit_min_dist = monitorOrbitTraps(z, 99999999.9, mag_sq);
    #endif

    #if (EXTERIOR_COLOURING_STYLE == 0 && MONOTONIC_FUNCTION == 2) || ESCAPE_ALGORITHM == 1
        Complex der = Complex(1.0, 0.0);
    #endif

    #if EXTERIOR_COLOURING_STYLE == 1
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

    #elif INTERIOR_COLOURING == 6

        Complex period_check = Complex(99999.9, 999999.9);

        int max_period_length = int(interior_colouring_param1);
        int period_count = max_period_length - 1;
        int known_period = 0;

    #elif INTERIOR_COLOURING == 7
        Complex z_prev_prev;
        vec3 sum = vec3(0.0, 0.0, 0.0);
    #endif

    for (int iteration = 0; iteration < TRUE_ITER_CAP; iteration++) {
    
        if (iteration >= max_iterations) {
            iterations = TRUE_ITER_CAP;
            break;
        }
        
        #if INTERIOR_COLOURING == 7
            z_prev_prev = z_prev;
        #endif
        
        z_prev = z;

        #if FRACTAL == MANDELBROT
            z.imag = 2.0 * z.real * z.imag;
            z.real = z_real_sq - z_imag_sq;
            z += c;

        #elif FRACTAL == BURNING_SHIP
            z.imag = 2.0 * abs(z.real * z.imag);
            z.real = z_real_sq - z_imag_sq;
            z += c;

        #elif FRACTAL == TRICORN

            z.imag = -z.real * z.imag;
            z.imag = 2.0 * z.imag;
            z.real = z_real_sq - z_imag_sq;
            z += c;

        #elif FRACTAL == HEART

            float temp = z.real * z.imag;
            
            z.imag = abs(z.imag) - abs(z.real);
            z.real = temp;
            z += c;

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
            z = exponent(z, fractal_param1) + c;

        #elif FRACTAL == FEATHER
            z = div(
                    Complex(
                    z.real * (z_real_sq - 3.0 * z_imag_sq),
                    z.imag * (3.0 * z_real_sq - z_imag_sq)),
                    Complex(
                        1.0 + z_real_sq,
                        1.0 + z_imag_sq));
            z += c;

        #elif FRACTAL == CHIRIKOV
            z.imag += c.imag * sin(z.real);
            z.real += c.real * z.imag;

        #elif FRACTAL == SMELLY_SHOE

            z.real = sin(z.imag * z.real);
    
            z.imag = 2.0 * z.real * z.imag;
            z.real = z_real_sq - z_imag_sq;
            z += c;

        #elif FRACTAL == DOG_SKULL
			float z_real = z.real;
			z.real = z_real_sq + tan(z.imag);
			z.imag = z.imag * z_imag_sq - z_real;
            z += c;

        #elif FRACTAL == EXPONENT2
            z = exponent(c, z);

        #elif FRACTAL == DUFFING
            z.real = z.imag;
            z.imag = c.imag * z.real + c.real * z.imag - z.imag * z_imag_sq;

        #elif FRACTAL == GINGERBREAD
            z.real = 1.0 - z.imag + abs(z.real);
            z.imag = z.real;
            z += c;

        #elif FRACTAL == HENON
            z.real = 1.0 - c.real * z_real_sq + z.imag;
            z.imag = c.imag * z.real;

        #elif FRACTAL == SINE

            float sin_real = sin(z.real) * cosh(z.imag);
            float sin_imag = cos(z.real) * sinh(z.imag);

            z = c * mat2(
                sin_real, -sin_imag,
                sin_imag, sin_real    
            );

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

            Complex z_run = ZERO;

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
				abs(exponent(
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

        #elif FRACTAL == TRICORN_SINE

            float sin_real = sin(z.real) * cosh(z.imag);
            float sin_imag = cos(z.real) * sinh(z.imag);

            z = mat2(
                sin_real, -sin_imag,
                sin_imag, sin_real    
            ) * c;

        #elif FRACTAL == TWIN_MANDELBROT

            z = square(
                add(
                    z,
                    div(
                        square(c),
                        z)));
                        
        #elif FRACTAL == FRACKTAIL
            
            z = prod(z, z) * argument(z);
            z += c;
                        
        #elif FRACTAL == SAURON
            z = div(c, prod(z, z)) + c + Complex(fractal_param1, fractal_param2);
        
        #elif FRACTAL == PARTIAL_BURNING_SHIP
            z.imag = 2.0 * z.real * abs(z.imag);
            z.real = z_real_sq - z_imag_sq;
            z += c;
            
        #elif FRACTAL == MULTI_BURNING_SHIP
            z = exponent(Complex(abs(z.real), abs(z.imag)), fractal_param1) + c;
        #endif
        
        z_real_sq = z.real * z.real;
        z_imag_sq = z.imag * z.imag;
        
        mag_sq = z_real_sq + z_imag_sq;

        #ifdef MONITOR_ORBIT_TRAPS
            orbit_min_dist = monitorOrbitTraps(z, orbit_min_dist, mag_sq);
        #endif

        #if (EXTERIOR_COLOURING_STYLE == 0 && MONOTONIC_FUNCTION == 2) || ESCAPE_ALGORITHM == 1
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
                        
            #elif FRACTAL == BURNING_SHIP
                der = add(
                    scale(
                        div(
                            prod(
                                z_prev,
                                der),
                            sign(z_prev)),
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
        
        #if EXTERIOR_COLOURING_STYLE == 0 && MONOTONIC_FUNCTION == 3
            exterior_stripe_total_prev = exterior_stripe_total;
            exterior_stripe_total += 0.5 + 0.5 * sin(exterior_colouring_param1 * argument(z));
        #endif

        #if EXTERIOR_COLOURING_STYLE == 1
            #if CYCLE_FUNCTION == 1
                exp_diff = sub(z, z_prev);
                exponential += exp(-(sqrt(mag_sq) + 0.5 * inversesqrt(exp_diff.real * exp_diff.real + exp_diff.imag * exp_diff.imag)));
            #endif
			
		#elif EXTERIOR_COLOURING_STYLE == 2
			#if RADIAL_ANGLE == 2
				total_orbit = add(total_orbit, z);
			#endif
        #endif

        #if INTERIOR_COLOURING == 1
            mag_sum += mag_sq;

        #elif INTERIOR_COLOURING == 2
            min_dist_sq = min(min_dist_sq, 1.0 - mag_sq / escape_param);

        #elif INTERIOR_COLOURING == 3
            diff = sub(z, z_prev);
            total_dist_sq += diff.real * diff.real + diff.imag * diff.imag;
		
        #elif INTERIOR_COLOURING == 4
            interior_stripe_total += 0.5 + 0.5 * sin(interior_colouring_param1 * argument(z));
        
        #elif INTERIOR_COLOURING == 6

            Complex offset = z - period_check;

            period_count++;

            if (dot(offset, offset) < interior_colouring_param2 && (known_period == 0 || period_count < known_period)) {
                known_period = period_count;
                iterations = TRUE_ITER_CAP;
            }

            if (period_count == max_period_length) {
                period_count = 0;
                period_check = z;
            }
        
        #elif INTERIOR_COLOURING == 7
        
            Complex dz = z - z_prev;
            Complex dzz = z_prev - z_prev_prev;
            Complex ddz = z - z_prev_prev;
            
            sum.x += dot(dz, ddz);
            sum.y += dot(dz, dz);
            sum.z += dot(ddz, ddz);

        #endif
        
        #if ESCAPE_ALGORITHM == 0
            if (mag_sq >= escape_param) {
                iterations = iteration + 1;
                break;
            }
        
        #elif ESCAPE_ALGORITHM == 1
            if (dot(der, der) >= escape_param) {
                iterations = iteration + 1;
                break;
            }
        #endif
    }

    if (iterations == TRUE_ITER_CAP) {

        #if INTERIOR_COLOURING == 0
            return interior_colour1;

        #elif INTERIOR_COLOURING == 1
            return mix(interior_colour1, interior_colour2, mag_sum * inversesqrt(float(iterations)));

        #elif INTERIOR_COLOURING == 2
            return mix(interior_colour2, interior_colour1, min_dist_sq);

        #elif INTERIOR_COLOURING == 3
            return hsv2rgb(vec3(fract(sqrt(total_dist_sq)), 1.0, 1.0));

        #elif INTERIOR_COLOURING == 4
            return mix(interior_colour2, interior_colour1, interior_stripe_total / float(max_iterations));

        #elif INTERIOR_COLOURING == 5
            #ifdef MONITOR_ORBIT_TRAPS
                return mix(interior_colour2, interior_colour1, orbit_min_dist * 0.5);
            #else
                return interior_colour1;
            #endif

        #elif INTERIOR_COLOURING == 6

            if (known_period == 0) {
                return vec3(0.0, 0.0, 0.0);
            }
            else {
                return hsv2rgb(vec3(sin(float(known_period)) * 0.5 + 0.5, 1.0, 1.0));
            }

        #elif INTERIOR_COLOURING == 7
            return sin(abs(sum) / float(max_iterations) * 5.0) * 0.45 + 0.5;
        #endif

    }
    else {

        float colour_val = 0.0;

        #if EXTERIOR_COLOURING_STYLE == 0

            #if MONOTONIC_FUNCTION == 0 || MONOTONIC_FUNCTION == 1 || MONOTONIC_FUNCTION == 5
            
                float f_iterations = float(iterations);

                #if MONOTONIC_FUNCTION == 1
                    f_iterations += getSmoothIter(mag_sq);
                    
                #elif MONOTONIC_FUNCTION == 5
                    f_iterations += getSmoothDerIter(der);
                #endif

                colour_val = f_iterations / float(max_iterations);

            #elif MONOTONIC_FUNCTION == 2

                z = normalize(div(z, der));

                colour_val = max(0.0, 
                    dot(z, Complex(exterior_colouring_param1, exterior_colouring_param2)) +
                    sqrt(1.0 - exterior_colouring_param1 * exterior_colouring_param1 - exterior_colouring_param2 * exterior_colouring_param2)
                );

            #elif MONOTONIC_FUNCTION == 3
                float interp = getSmoothIter(mag_sq);
                colour_val = mix(exterior_stripe_total_prev, exterior_stripe_total, interp) / (float(iterations) + interp);
                colour_val = max(colour_val, 0.0);

            #elif MONOTONIC_FUNCTION == 4
                #ifdef MONITOR_ORBIT_TRAPS
                    colour_val = clamp(1.0 - orbit_min_dist * 0.5, 0.0, 1.0);
                #else
                    colour_val = 0.0;
                #endif
            #endif

            #ifdef MONOTONIC_EASE_OUT
                colour_val = 1.0 - colour_val;
            #endif

            #if MONOTONIC_EASING_FUNCTION == 1
                colour_val = colour_val * colour_val;

            #elif MONOTONIC_EASING_FUNCTION == 2
                colour_val = sqrt(colour_val);

            #elif MONOTONIC_EASING_FUNCTION == 3
                colour_val = colour_val * colour_val * colour_val;

            #elif MONOTONIC_EASING_FUNCTION == 4
                colour_val = pow(colour_val, 1.0 / 3.0);

            #elif MONOTONIC_EASING_FUNCTION == 5
                colour_val = colour_val * colour_val * colour_val * colour_val;

            #elif MONOTONIC_EASING_FUNCTION == 6
                colour_val = pow(colour_val, 0.25);

            #elif MONOTONIC_EASING_FUNCTION == 7
                colour_val = colour_val * colour_val * colour_val * colour_val * colour_val;

            #elif MONOTONIC_EASING_FUNCTION == 8
                colour_val = pow(colour_val, 0.2);

            #elif MONOTONIC_EASING_FUNCTION == 9
                colour_val = (exp(colour_val) - 1.0) / (E - 1.0);

            #elif MONOTONIC_EASING_FUNCTION == 10
                colour_val = sin(colour_val * PI / 2.0);
            #endif

            #ifdef MONOTONIC_EASE_OUT
                colour_val = 1.0 - colour_val;
            #endif

        #elif EXTERIOR_COLOURING_STYLE == 1

            float val;

            #if CYCLE_FUNCTION == 0
                val = float(iterations) + getSmoothIter(mag_sq);

            #elif CYCLE_FUNCTION == 1
                val = log(exponential);

            #elif CYCLE_FUNCTION == 2
                #ifdef MONITOR_ORBIT_TRAPS
                    val = log(orbit_min_dist);
                #else
                    val = 0.0;
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
            return mix(exterior_colour2, exterior_colour1, colour_val);

        #elif EXTERIOR_COLOURING == 1
            return hsv2rgb(vec3(colour_val, 1.0, 1.0));
        #endif

    }
}