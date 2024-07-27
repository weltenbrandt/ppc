
/*------------------------------------------------------------------
You cannot redistribute this pixel shader source code anywhere.
Only compiled binary executables. Don't remove this notice, please.
Copyright (C) 2023 Mozart Junior (FoxyOfJungle). Kazan Games Ltd.
Website: https://foxyofjungle.itch.io/ | Discord: @foxyofjungle
-------------------------------------------------------------------*/

varying vec2 v_vPosition;
varying vec2 v_vTexcoord;
varying vec2 v_TexelSize;

uniform float u_fxaa_strength;

// >> effect
// Original shader by Timothy Lottes, NVIDIA
// https://developer.download.nvidia.com/assets/gamedev/files/sdk/11/FXAA_WhitePaper.pdf

#define FXAA_REDUCE_MIN (1.0 / 128.0)
#define FXAA_REDUCE_MUL (1.0 / 8.0)

vec4 FXAA() {
	vec3 col_tex = texture2D(gm_BaseTexture, v_vTexcoord).rgb;
	vec3 base_nw = texture2D(gm_BaseTexture, v_vTexcoord - v_TexelSize).rgb;
	vec3 base_ne = texture2D(gm_BaseTexture, v_vTexcoord + vec2(v_TexelSize.x, -v_TexelSize.y)).rgb;
	vec3 base_sw = texture2D(gm_BaseTexture, v_vTexcoord + vec2(-v_TexelSize.x, v_TexelSize.y)).rgb;
	vec3 base_se = texture2D(gm_BaseTexture, v_vTexcoord + v_TexelSize).rgb;
	
	vec3 lum = vec3(0.299, 0.587, 0.114);
	float mono_col = dot(col_tex, lum);
	float mono_nw = dot(base_nw, lum);
	float mono_ne = dot(base_ne, lum);
	float mono_sw = dot(base_sw, lum);
	float mono_se = dot(base_se, lum);
	
	float mono_min = min(mono_col, min(min(mono_nw, mono_ne), min(mono_sw, mono_se)));
	float mono_max = max(mono_col, max(max(mono_nw, mono_ne), max(mono_sw, mono_se)));
	
	vec2 dir = vec2(-((mono_nw + mono_ne) - (mono_sw + mono_se)), ((mono_nw + mono_sw) - (mono_ne + mono_se)));
	float dir_reduce = max((mono_nw + mono_ne + mono_sw + mono_se) * FXAA_REDUCE_MUL * 0.25, FXAA_REDUCE_MIN);
	float dir_min = 1.0 / (min(abs(dir.x), abs(dir.y)) + dir_reduce);
	dir = min(vec2(u_fxaa_strength), max(vec2(-u_fxaa_strength), dir * dir_min)) * v_TexelSize;
	
	vec4 result_a = 0.5 * (texture2D(gm_BaseTexture, v_vTexcoord + dir * -0.166667) +
							texture2D(gm_BaseTexture, v_vTexcoord + dir * 0.166667));
	vec4 result_b = result_a * 0.5 + 0.25 * (texture2D(gm_BaseTexture, v_vTexcoord + dir * -0.5) +
											texture2D(gm_BaseTexture, v_vTexcoord + dir * 0.5));
	float mono_b = dot(result_b.rgb, lum);
	return (mono_b < mono_min || mono_b > mono_max) ? result_a : result_b;
}

void main() {
	gl_FragColor = FXAA();
}
