uniform float friction;
uniform float tension;
uniform float mass;
uniform float dt;

uniform float magnet_strengths[MAGNET_COUNT];
uniform vec2 magnet_positions[MAGNET_COUNT];
uniform vec3 magnet_colours[MAGNET_COUNT];

vec3 getColour(float x, float y) {

    vec2 pos = vec2(x, y);
    vec2 pos_prev = vec2(MAX, MAX);
    vec2 velocity = ZERO;
    
    vec2 accel;
    vec2 accel_prev = ZERO;
    
    float inv_mass = 1.0 / mass;
    
    int iters_taken = ITERATIONS;

    for (int iteration = 0; iteration < ITERATIONS; iteration++) {

        vec2 accel = ZERO;

        for (int i = 0; i < MAGNET_COUNT; i++) {

            vec2 offset = magnet_positions[i] - pos;
            float dist_sq = dot(offset, offset) + 0.1;

            accel += magnet_strengths[i] * offset * pow(dist_sq, -1.5);

        }

        accel -= tension * pos + friction * velocity;
        accel *= inv_mass;

        velocity += accel * dt;
        pos += velocity * dt + 0.166666666 * (4.0 * accel - accel_prev) * dt * dt;
        
        vec2 diff = pos - pos_prev;

        if (dot(diff, diff) < 0.0000001) {
            iters_taken = iteration;
            break;
        }

        accel_prev = accel;
        pos_prev = pos;

    }

    int closest_idx = 0;
    float closest_dist = MAX;
        
    for (int i = 0; i < MAGNET_COUNT; i++) {
        
        vec2 offset = magnet_positions[i] - pos; 
        float dist_sq = dot(offset, offset);

        if (closest_dist > dist_sq) {
            closest_dist = dist_sq;
            closest_idx = i;
        }
    }
        
    for (int i = 0; i < MAGNET_COUNT; i++) {
        if (i == closest_idx) {
            return magnet_colours[i] * (1.0 - float(iters_taken) / float(ITERATIONS));
        }
    }

    return vec3(0.0, 0.0, 0.0);
    
}