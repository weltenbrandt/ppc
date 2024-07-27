
/*------------------------------------------------------------------
You cannot redistribute this pixel shader source code anywhere.
Only compiled binary executables. Don't remove this notice, please.
Copyright (C) 2023 Mozart Junior (FoxyOfJungle). Kazan Games Ltd.
Website: https://foxyofjungle.itch.io/ | Discord: @foxyofjungle
-------------------------------------------------------------------*/

varying vec2 v_vTexcoord;

// >> uniforms
uniform vec2 u_time_n_intensity;
uniform float u_palette_swap_texel;
uniform float u_palette_swap_row;
uniform float u_palette_swap_height;
uniform float u_palette_swap_threshold;
uniform float u_palette_swap_smoothness;
uniform float u_palette_swap_flip;
uniform sampler2D u_palette_swap_tex;

// >> dependencies
const vec3 lum_weights = vec3(0.2126729, 0.7151522, 0.0721750);

float get_luminance(vec3 color) {
	return dot(color, lum_weights);
}

// >> effect
vec3 palette_swap_fx(vec3 color) {
	float lum = get_luminance(color);
	lum = mix(lum, 1.0-lum, step(0.5, u_palette_swap_flip));
	
	vec2 uv2 = vec2(lum, u_palette_swap_row * u_palette_swap_texel);
	vec3 col_pal = texture2D(u_palette_swap_tex, uv2).rgb;
	
	float rate = smoothstep(u_palette_swap_threshold-u_palette_swap_smoothness, u_palette_swap_threshold, length(color - col_pal.rgb));
	return mix(color, col_pal.rgb, rate);
}

void main() {
	vec4 col_tex = texture2D(gm_BaseTexture, v_vTexcoord);
	vec3 col_final = col_tex.rgb;
	col_final = palette_swap_fx(col_final);
	gl_FragColor = mix(col_tex, vec4(mix(col_tex.rgb, col_final, u_time_n_intensity.y), 1.0), col_tex.a);
}
