shader_type canvas_item;

uniform float intensity : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec4 c = texture(TEXTURE, UV);

    if (intensity <= 0.0) {
        COLOR = c;
    }

    // Calculate distance from center
    float dist = distance(UV, vec2(0.5));

    // Create vignette effect
    // Adjust these values to control the vignette size and falloff
    float inner_radius = 0.3 - intensity * 0.2;  // Inner bright area shrinks as intensity increases
    float outer_radius = 0.8 + intensity * 0.4;  // Outer dark area expands as intensity increases

    float vignette = smoothstep(inner_radius, outer_radius, dist);

    //darkening
	float darkening = 1.0 - vignette * intensity;
    c.rgb *= vec3(darkening);

    COLOR = c;
}