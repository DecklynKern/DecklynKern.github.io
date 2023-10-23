#version 300 es
precision highp float;

#define Complex vec2
#define real x
#define imag y
#define add(a, b) ((a) + (b))
#define add3(a, b, c) ((a) + (b) + (c))
#define sub(a, b) ((a) - (b))
#define div(a, b) prod(a, reciprocal(b))
#define scale(a, b) ((a) * (b))
#define neg(a) (-(a))
#define magnitude_sq(a) dot(a, a)

//%

uniform float magnitude;
uniform float centre_x;
uniform float centre_y;

in vec2 frag_position;
out vec4 colour;

const float E = 2.7182818285;
const float PI = 3.1415926535;
const float TAU = 2.0 * PI;

const Complex ZERO = Complex(0.0, 0.0);

Complex reciprocal(Complex z) {
    float denom = 1.0 / dot(z, z);
    return Complex(z.real * denom, -z.imag * denom);
}

Complex square(Complex z) {
    return Complex(z.real * z.real - z.imag * z.imag, 2.0 * z.real * z.imag);
}

Complex prod(Complex x, Complex y) {
    return Complex(
        x.real * y.real - x.imag * y.imag,
        x.real * y.imag + y.real * x.imag
    );
}

Complex conj(Complex z) {
    return Complex(
        z.real,
        -z.imag
    );
}

float argument(Complex z) {
    return atan(z.imag, z.real);
}

Complex exponent(Complex z) {
    float mag = exp(z.real);
    return Complex(
        mag * cos(z.imag),
        mag * sin(z.imag)
    );
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

    float z_norm_sq = dot(z, z);
    float arg = argument(z);
    float r = pow(z_norm_sq, 0.5 * d.real) * exp(-d.imag * arg);
    float angle = d.real * arg + 0.5 * d.imag * log(z_norm_sq);

    return Complex(
        r * cos(angle),
        r * sin(angle)
    );
}

float root_dist_sq(Complex z, Complex root) {
    Complex diff = sub(z, root);
    return diff.real * diff.real + diff.imag * diff.imag;
}

vec3 getColour(float x, float y);

/*
Conversions from: https://www.shadertoy.com/view/4syfRc
*/
vec3 rgb2xyz( vec3 c ) {
    vec3 tmp;
    tmp.x = ( c.r > 0.04045 ) ? pow( ( c.r + 0.055 ) / 1.055, 2.4 ) : c.r / 12.92;
    tmp.y = ( c.g > 0.04045 ) ? pow( ( c.g + 0.055 ) / 1.055, 2.4 ) : c.g / 12.92,
    tmp.z = ( c.b > 0.04045 ) ? pow( ( c.b + 0.055 ) / 1.055, 2.4 ) : c.b / 12.92;
    return 100.0 * tmp *
        mat3( 0.4124, 0.3576, 0.1805,
              0.2126, 0.7152, 0.0722,
              0.0193, 0.1192, 0.9505 );
}

vec3 xyz2lab( vec3 c ) {
    vec3 n = c / vec3( 95.047, 100, 108.883 );
    vec3 v;
    v.x = ( n.x > 0.008856 ) ? pow( n.x, 1.0 / 3.0 ) : ( 7.787 * n.x ) + ( 16.0 / 116.0 );
    v.y = ( n.y > 0.008856 ) ? pow( n.y, 1.0 / 3.0 ) : ( 7.787 * n.y ) + ( 16.0 / 116.0 );
    v.z = ( n.z > 0.008856 ) ? pow( n.z, 1.0 / 3.0 ) : ( 7.787 * n.z ) + ( 16.0 / 116.0 );
    return vec3(( 116.0 * v.y ) - 16.0, 500.0 * ( v.x - v.y ), 200.0 * ( v.y - v.z ));
}

vec3 rgb2lab(vec3 c) {
    vec3 lab = xyz2lab( rgb2xyz( c ) );
    return vec3( lab.x / 100.0, 0.5 + 0.5 * ( lab.y / 127.0 ), 0.5 + 0.5 * ( lab.z / 127.0 ));
}

vec3 lab2xyz( vec3 c ) {
    float fy = ( c.x + 16.0 ) / 116.0;
    float fx = c.y / 500.0 + fy;
    float fz = fy - c.z / 200.0;
    return vec3(
         95.047 * (( fx > 0.206897 ) ? fx * fx * fx : ( fx - 16.0 / 116.0 ) / 7.787),
        100.000 * (( fy > 0.206897 ) ? fy * fy * fy : ( fy - 16.0 / 116.0 ) / 7.787),
        108.883 * (( fz > 0.206897 ) ? fz * fz * fz : ( fz - 16.0 / 116.0 ) / 7.787)
    );
}

vec3 xyz2rgb( vec3 c ) {
    vec3 v =  c / 100.0 * mat3( 
        3.2406, -1.5372, -0.4986,
        -0.9689, 1.8758, 0.0415,
        0.0557, -0.2040, 1.0570
    );
    vec3 r;
    r.x = ( v.r > 0.0031308 ) ? (( 1.055 * pow( v.r, ( 1.0 / 2.4 ))) - 0.055 ) : 12.92 * v.r;
    r.y = ( v.g > 0.0031308 ) ? (( 1.055 * pow( v.g, ( 1.0 / 2.4 ))) - 0.055 ) : 12.92 * v.g;
    r.z = ( v.b > 0.0031308 ) ? (( 1.055 * pow( v.b, ( 1.0 / 2.4 ))) - 0.055 ) : 12.92 * v.b;
    return r;
}

vec3 lab2rgb(vec3 c) {
    return xyz2rgb( lab2xyz( vec3(100.0 * c.x, 2.0 * 127.0 * (c.y - 0.5), 2.0 * 127.0 * (c.z - 0.5)) ) );
}

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {

    float pixel_size = 2.0 * magnitude / 1000.0;

    float x = centre_x + frag_position.x * magnitude;
    
    #ifdef FLIP_Y
        float y = -(centre_y + frag_position.y * magnitude);
    #else
        float y = centre_y + frag_position.y * magnitude;
    #endif

    vec3 colour_sum;

    for (int s = 0; s < SAMPLES; s++) {

        float x_offset = fract(0.1234 * float(s));
        float y_offset = fract(0.7654 * float(s));

        vec3 pixel_sample = getColour(x + x_offset * pixel_size, y + y_offset * pixel_size);

        #if MULTISAMPLING_ALGORITHM == 1
            pixel_sample *= pixel_sample;

        #elif MULTISAMPLING_ALGORITHM == 2
            pixel_sample = rgb2xyz(pixel_sample);

        #elif MULTISAMPLING_ALGORITHM == 3
            pixel_sample = rgb2lab(pixel_sample);
        #endif

        colour_sum += pixel_sample;

    }

    colour_sum *= 1.0 / float(SAMPLES);
    vec3 final_colour;

    #if MULTISAMPLING_ALGORITHM == 0
        final_colour = colour_sum;

    #elif MULTISAMPLING_ALGORITHM == 1
        final_colour = sqrt(colour_sum);

    #elif MULTISAMPLING_ALGORITHM == 2
        final_colour = xyz2rgb(colour_sum);

    #elif MULTISAMPLING_ALGORITHM == 3
        final_colour = lab2rgb(colour_sum);
    #endif

    colour = vec4(final_colour, 1.0);
    
}
