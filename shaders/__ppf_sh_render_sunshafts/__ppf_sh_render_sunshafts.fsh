
/*------------------------------------------------------------------
You cannot redistribute this pixel shader source code anywhere.
Only compiled binary executables. Don't remove this notice, please.
Copyright (C) 2023 Mozart Junior (FoxyOfJungle). Kazan Games Ltd.
Website: https://foxyofjungle.itch.io/ | Discord: @foxyofjungle
-------------------------------------------------------------------*/

// quality (low number = more performance)
#ifdef _YY_HLSL11_
#define ITERATIONS 24.0 // windows
#else
#define ITERATIONS 16.0 // others (android, operagx...)
#endif

precision highp float;

varying vec2 v_vPosition;
varying vec2 v_vTexcoord;

uniform vec2 u_resolution;
uniform vec2 u_time_n_intensity;
uniform vec2 u_sunshaft_position;
uniform float u_sunshaft_center_smoothness;
uniform float u_sunshaft_threshold;
uniform float u_sunshaft_intensity;
uniform float u_sunshaft_dimmer;
uniform float u_sunshaft_scattering;
uniform float u_sunshaft_noise_enable;
uniform float u_sunshaft_rays_intensity;
uniform float u_sunshaft_rays_tiling;
uniform float u_sunshaft_rays_speed;
uniform sampler2D u_sunshaft_rays_noise_tex;
uniform float u_sunshaft_debug;
uniform sampler2D u_sunshaft_tex;

uniform sampler2D u_sunshaft_noise_tex;
uniform vec2 u_sunshaft_noise_size;


const float ITERATIONS_RECIPROCAL = 1.0/ITERATIONS;
const float debug_alpha = 1.0;

const float Tau = 6.28318;

vec3 threshold(vec3 color) {
	return max((color - u_sunshaft_threshold), 0.0);
}

float saturate(float x) {
	return clamp(x, 0.0, 1.0);
}

vec3 saturate(vec3 x) {
    return clamp(x, 0.0, 1.0);
}

const vec3 lum_weights = vec3(0.2126, 0.7152, 0.0722);
float get_luminance(vec3 color) {
	return dot(color, lum_weights);
}

vec3 tonemap_jodie_reinhard(vec3 c, float lum) {
	vec3 tc = c / (c + 1.0);
	return mix(c / (lum + 1.0), tc, tc);
}

float mask_radial(vec2 uv, vec2 center, float power, float scale, float smoothness) {
	float smoothh = mix(scale, 0.0, smoothness);
	float sc = scale / 2.0;
	float mask = pow(1.0-saturate((length(uv-center)-sc) / ((smoothh-0.001)-sc)), power);
	return mask;
}

vec2 get_aspect_ratio(vec2 size, vec2 res) {
	float aspect_ratio = res.x / res.y;
	return (res.x > res.y)
	? vec2(size.x * aspect_ratio, size.y)
	: vec2(size.x, size.y / aspect_ratio);
}

vec3 blend(vec3 source, vec3 dest) {
    return source + dest - source * dest;
}

void main() {
	vec2 uv = v_vTexcoord;
	float time = u_time_n_intensity.x * u_sunshaft_rays_speed;
	
	vec2 polar_center = uv - u_sunshaft_position;
	vec2 uv_noise_rays = vec2((length(polar_center) * 0.01) - time, atan(polar_center.y, polar_center.x) * (1.0/Tau) * u_sunshaft_rays_tiling);
	float noise = 1.0;
	if (u_sunshaft_noise_enable > 0.5) noise = mix(noise, texture2D(u_sunshaft_rays_noise_tex, uv_noise_rays).r * 0.9 + 0.5, u_sunshaft_rays_intensity);
	
	vec2 mask_size = get_aspect_ratio(vec2(1.0), u_resolution);
	noise *= mask_radial(uv*mask_size, u_sunshaft_position*mask_size, u_sunshaft_center_smoothness, u_sunshaft_center_smoothness, 1.0);
	
	// godrays
	float offset = texture2D(u_sunshaft_noise_tex, gl_FragCoord.xy/u_sunshaft_noise_size).r;
	vec2 center = u_sunshaft_position - uv;
	float lum_decay = u_sunshaft_dimmer;
	float scattering = clamp(u_sunshaft_scattering, 0.0, 1.0);
	
	vec3 shaft;
	for(float i = 0.0; i < ITERATIONS; i++) {
		float reciprocal = (i + offset) / ITERATIONS;
		shaft += threshold(texture2D(u_sunshaft_tex, uv + (center * reciprocal * scattering)).rgb * noise) * lum_decay;
		lum_decay *= (1.0-ITERATIONS_RECIPROCAL);
	}
	vec3 godray = (shaft / ITERATIONS) * u_sunshaft_intensity * u_time_n_intensity.y;
	godray = tonemap_jodie_reinhard(godray, get_luminance(godray));
	
	// blend
	vec4 col_tex = texture2D(gm_BaseTexture, uv);
	col_tex.rgb = mix(blend(col_tex.rgb, godray), col_tex.rgb, step(u_sunshaft_position.x + u_sunshaft_position.y, 0.0));
	col_tex.rgb = mix(col_tex.rgb, godray, step(0.5, u_sunshaft_debug)*debug_alpha);
	gl_FragColor = col_tex;
}
