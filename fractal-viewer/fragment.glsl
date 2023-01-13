precision highp float;

uniform float magnitude;
uniform float origin_real;
uniform float origin_imag;
uniform int max_iterations;

const int TRUE_ITER_CAP = 10000;

varying vec2 frag_position;

void main() {

    float c_real = origin_real + frag_position.x * magnitude;
    float c_imag = origin_imag + frag_position.y * magnitude;

    float z_real = 0.0;
    float z_imag = 0.0;

    float z_real_sq = 0.0;
    float z_imag_sq = 0.0;

    for (int iteration = 0; iteration < TRUE_ITER_CAP; iteration++) {

        if (iteration >= max_iterations) {
            break;
        }

        z_imag = z_real * z_imag;
        z_imag = z_imag + z_imag + c_imag;

        z_real = z_real_sq - z_imag_sq + c_real;

        z_real_sq = z_real * z_real;
        z_imag_sq = z_imag * z_imag;

        if (z_real_sq + z_imag_sq >= 4.0) {
            gl_FragColor = vec4(255, 255, 255, 255);
            return;
        }
    }

    gl_FragColor = vec4(0, 0, 0, 255);

}