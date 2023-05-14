#version 300 es
precision highp float;

uniform float magnitude;
uniform float centre_x;
uniform float centre_y;

uniform int samples;
uniform int canvas_size;

uniform int fractal_type;
uniform int iterations;

in vec2 frag_position;
out vec4 colour;

const int TRUE_ITER_CAP = 20;
const int TRUE_SAMPLE_CAP = 10;

const vec3 WHITE = vec3(1.0, 1.0, 1.0);
const vec3 BLACK = vec3(0.0, 0.0, 0.0);

const float ONE_THIRD = 0.33333333333;
const float TWO_THIRDS = 0.66666666667;

bool rectBound(vec2 pos, float min_x, float max_x, float min_y, float max_y) {
    return min_x < pos.x && pos.x < max_x && min_y < pos.y && pos.y < max_y;
}

mat2 rotMat(float angle) {
    return mat2(
        cos(angle), sin(angle),
        -sin(angle), cos(angle)
    );
}

struct Iterator {
    vec2 pos;
    float pixel_size;
};

#define ITERATE(escape_check, update_func, escape_colour, remain_colour)\
for (int iteration = 0; iteration < TRUE_ITER_CAP; iteration++) {\
    \
    if (iteration == iterations) {\
        break;\
    }\
    \
    if (escape_check(iter)) {\
        return escape_colour;\
    }\
    \
    update_func(iter);\
    \
}\
return remain_colour;

#define ITERATE_CHECK_FINAL(escape_check, update_func, escape_colour, remain_colour)\
for (int iteration = 0; iteration < TRUE_ITER_CAP; iteration ++) {\
    \
    if (iteration == iterations) {\
        break;\
    }\
    \
    update_func(iter);\
    \
}\
if (escape_check(iter)) {\
    return escape_colour;\
}\
return remain_colour;

bool carpetEscape(Iterator iter) {
    return rectBound(iter.pos, ONE_THIRD, TWO_THIRDS, ONE_THIRD, TWO_THIRDS);
}

void carpetUpdate(inout Iterator iter) {
    iter.pos = fract(iter.pos * 3.0);
}

bool triangleEscape(Iterator iter) {
    return abs(iter.pos.x - 0.5) > 0.5 - iter.pos.y / 2.0;
}

void triangleUpdate(inout Iterator iter) {

    if (iter.pos.y > 0.5) {
        iter.pos.x -= 0.25;
    }

    iter.pos = fract(iter.pos * 2.0);

}

bool tSquareEscape(Iterator iter) {
    return rectBound(iter.pos, 0.25, 0.75, 0.25, 0.75);
}

void tSquareUpdate(inout Iterator iter) {
    iter.pos = fract(iter.pos * 2.0);
}

bool pTreeEscape(Iterator iter) {
    return rectBound(iter.pos, 0.4375, 0.5625, 0.0, 0.125);
}

const float TREE_SCALING = 2.0 / sqrt(2.0);

void pTreeUpdate(inout Iterator iter) {

    if (iter.pos.x < 0.5) {
        mat2 rot = rotMat(radians(-45.0));
        iter.pos = rot * (iter.pos - vec2(0.4375, 0.125)) * TREE_SCALING + vec2(0.4375, 0.0);

    } else {
        mat2 rot = rotMat(radians(45.0));
        iter.pos = rot * (iter.pos - vec2(0.5625, 0.125)) * TREE_SCALING + vec2(0.5625, 0.0);
    }
}

bool hTreeEscape(Iterator iter) {
    return 0.25 < iter.pos.x && iter.pos.x < 0.75 && abs(iter.pos.y - 0.5) < iter.pixel_size ||
        0.25 < iter.pos.y && iter.pos.y < 0.75 && (abs(iter.pos.x - 0.25) < iter.pixel_size || abs(iter.pos.x - 0.75) < iter.pixel_size);
}

void hTreeUpdate(inout Iterator iter) {
    iter.pos = fract(iter.pos * 2.0);
    iter.pixel_size *= 2.0;
}

bool vicsekEscape(Iterator iter) {
    return abs(iter.pos.x - 0.5) < iter.pixel_size || abs(iter.pos.y - 0.5) < iter.pixel_size;
}

void vicsekUpdate(inout Iterator iter) {

    if (!(ONE_THIRD < iter.pos.x && iter.pos.x < TWO_THIRDS ||
         ONE_THIRD < iter.pos.y && iter.pos.y < TWO_THIRDS)) {
        iter.pos = vec2(0.0, 0.0);
        return;
    }

    iter.pos = fract(iter.pos * 3.0);
    iter.pixel_size *= 3.0;

}

vec3 getColour(Iterator iter) {

    if (iter.pos.x < 0.0 || iter.pos.x > 1.0 || iter.pos.y < 0.0 || iter.pos.y > 1.0) {
        return WHITE;
    }

    if (fractal_type == 0) {
        ITERATE(carpetEscape, carpetUpdate, WHITE, BLACK);
    
    } else if (fractal_type == 1) {
        
        if (triangleEscape(iter)) {
            return WHITE;
        }

        triangleUpdate(iter);

        ITERATE(triangleEscape, triangleUpdate, WHITE, BLACK);

    } else if (fractal_type == 2) {
        ITERATE(tSquareEscape, tSquareUpdate, BLACK, WHITE);

    } else if (fractal_type == 3) {

        if (pTreeEscape(iter)) {
            return BLACK;
        }

        pTreeUpdate(iter);

        ITERATE(pTreeEscape, pTreeUpdate, BLACK, WHITE);

    } else if (fractal_type == 4) {
        ITERATE(hTreeEscape, hTreeUpdate, BLACK, WHITE);
    
    } else if (fractal_type == 5) {
        ITERATE(vicsekEscape, vicsekUpdate, BLACK, WHITE);

    }

    return WHITE;

}

void main() {

    float pixel_size = 2.0 * magnitude / float(canvas_size);

    float x = centre_x + frag_position.x * magnitude;
    float y = -(centre_y + frag_position.y * magnitude);

    vec3 colour_sum;

    for (int s = 0; s < TRUE_SAMPLE_CAP; s++) {

        if (s == samples) {
            break;
        }

        float x_offset = fract(0.1234 * float(s));
        float y_offset = fract(0.7654 * float(s));

        colour_sum += getColour(Iterator(
            vec2(
                x + x_offset * pixel_size,
                y + y_offset * pixel_size
            ),
            pixel_size
        ));

    }

    colour = vec4(colour_sum / float(samples), 1.0);

}