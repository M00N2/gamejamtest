shader_type canvas_item;

uniform float intensity : hint_range(0.0, 1.0) = 1.0; // strength of blue scaling
uniform float brightness : hint_range(0.0, 2.0) = 0.7; // overall brightness

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV); // gets texture at that pixel

    // Convert to grayscale
    float gray = dot(tex_color.rgb, vec3(0.299, 0.587, 0.114));

    // Create a "blue scale" version: red & green low, blue high
    vec3 blue_scale = vec3(0.0, 0.0, gray);

    // Blend between original and blue scale based on intensity
    vec3 final_color = mix(tex_color.rgb, blue_scale, intensity);

    // Adjust brightness
    final_color *= brightness;

    COLOR = vec4(final_color, tex_color.a);
}
