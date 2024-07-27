
/*------------------------------------------------------------------
You cannot redistribute this pixel shader source code anywhere.
Only compiled binary executables. Don't remove this notice, please.
Copyright (C) 2023 Mozart Junior (FoxyOfJungle). Kazan Games Ltd.
Website: https://foxyofjungle.itch.io/ | Discord: @foxyofjungle
-------------------------------------------------------------------*/

precision highp float;

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

varying vec2 v_vTexelSize;
varying vec2 v_vResolution;
uniform vec2 u_time_n_intensity;

// >> uniforms
uniform float u_vhs_chromatic_aberration;
uniform float u_vhs_scan_aberration;
uniform float u_vhs_grain_intensity;
uniform float u_vhs_grain_height;
uniform float u_vhs_grain_fade;
uniform float u_vhs_grain_amount;
uniform float u_vhs_grain_speed;
uniform float u_vhs_grain_interval;
uniform float u_vhs_scan_speed;
uniform float u_vhs_scan_size;
uniform float u_vhs_scan_offset;
uniform float u_vhs_hscan_offset;
uniform float u_vhs_flickering_intensity;
uniform float u_vhs_flickering_speed;
uniform float u_vhs_wiggle_amplitude;

const vec4 col_spectral_a = vec4(vec3(1.0, 0.0, 0.0), 1.0);
const vec4 col_spectral_b = vec4(vec3(0.0, 1.0, 0.0), 1.0);
const vec4 col_spectral_c = vec4(vec3(0.0, 0.0, 1.0), 1.0);

// >> dependencies
uniform float u_lens_distortion_enable;
uniform float u_lens_distortion_amount;
vec2 lens_distortion_uv(vec2 uv, float intensity) {
	vec2 uv2 = uv - 0.5;
	float polar = atan(uv2.y, uv2.x);
	float len = length(uv2);
	float amount = u_lens_distortion_amount * intensity;
	len *= (pow(len, 2.0) * amount + 1.0);
	uv = vec2(0.5) + vec2(cos(polar), sin(polar)) * len;
	return uv;
}

#region Common
const float Phi = 1.61803398875;

float saturate(float x) {
	return clamp(x, 0.0, 1.0);
}

vec2 saturate(vec2 x) {
	return clamp(x, 0.0, 1.0);
}

vec3 saturate(vec3 x) {
	return clamp(x, 0.0, 1.0);
}

vec4 saturate(vec4 x) {
	return clamp(x, 0.0, 1.0);
}

float gold_noise(in vec2 fpos, in float seed) {
	// (C) 2015, Dominic Cerisano
	highp vec2 p = fpos;
	return fract(tan(distance(p*Phi, p)*seed)*p.x);
}

float bar_vertical(float uv, float pos, float offset, float size) {
    return (smoothstep(pos-size, pos, uv) * offset) - smoothstep(pos, pos+size, uv) * offset;
}

float scan_vertical(float uv, float pos, float offset, float size) {
    return (smoothstep(pos-size, pos, 1.0-uv) * offset) - step(pos, 1.0-uv) * offset;
}
#endregion

vec4 vhs_fx(vec2 uv, vec2 uvl, vec2 fpos) {
	float geral_intensity = u_time_n_intensity.y;
	uv.y = 1.0-uv.y;
	uvl.y = 1.0-uvl.y;
	
	// sets
	float scan_aberration_sum = 0.0;
	float time = u_time_n_intensity.x;
	
	// wiggle
	uv.y += sin(time*15.0 + sin(time*15.0)) * u_vhs_wiggle_amplitude * geral_intensity;
	
	// bottom glitch
	float scan_time = time * u_vhs_scan_speed;
	
	float hscan = sin(scan_time*60.0 + sin(scan_time))*0.1+0.5;
	float vscan = floor(bar_vertical(uvl.y, 0.008, hscan, 0.03)*5.0) * 0.01;
	uv.x -= vscan * geral_intensity;
	scan_aberration_sum += vscan * u_vhs_scan_aberration;
	
	// scan
	float wave = sin(uvl.y*4.0 + scan_time);
	float scan = step(sin(wave), wave) * u_vhs_hscan_offset;
	uv.x += scan * geral_intensity;
	
	float scan_noise = gold_noise(vec2(time, fpos.y), 1.0) * geral_intensity;
	
	for(float i = 1.0; i < 2.0; i+=1.0/2.0) {
		float scan_yoffset = -u_vhs_scan_size + fract(scan_time*0.1 * i) * 2.0;
		float scan_hscan = sin(uvl.y + scan_time * i);
		float scan = scan_vertical(uvl.y, scan_yoffset, u_vhs_scan_offset*uvl.y*scan_hscan, u_vhs_scan_size);
		uv.x -= scan * scan_noise;
		scan_aberration_sum += scan * u_vhs_scan_aberration;
	}
	
	// chromatic aberration
	float chroma_dist = v_vTexelSize.x * geral_intensity * u_vhs_chromatic_aberration + scan_aberration_sum;
	vec4 col_chroma_a = texture2D(gm_BaseTexture, vec2(uv.x+chroma_dist, 1.0-uv.y));
	vec4 col_chroma_b = texture2D(gm_BaseTexture, vec2(uv.x, 1.0-uv.y));
	vec4 col_chroma_c = texture2D(gm_BaseTexture, vec2(uv.x-chroma_dist, 1.0-uv.y));
	vec4 col = col_chroma_a*col_spectral_a + col_chroma_b*col_spectral_b + col_chroma_c*col_spectral_c;
	vec4 col_sum = (col_spectral_a + col_spectral_b + col_spectral_c);
	vec4 col_final = col / col_sum;
	
	// grain
	float grain_time = 100.0 + time;
	float grain_lines = v_vResolution.y / max(2.0, u_vhs_grain_amount);
	float sprinkles = gold_noise(vec2(1.0+grain_time, fpos.y), 1.0);
	sprinkles = 1.0 + pow(sprinkles, 7.0) * step(u_vhs_grain_interval, sprinkles);
	
	float grain_yoffset = (grain_time * grain_lines * u_vhs_grain_speed) * sprinkles;
	float mask = floor(mod(fpos.y-grain_yoffset, grain_lines+u_vhs_grain_height) / grain_lines) * smoothstep(mix(2.0, 0.0, u_vhs_grain_fade), 0.0, uv.y);
	
	float grain = pow(gold_noise(fpos, 1.0+fract(grain_time)), 1.0/u_vhs_grain_intensity) * mask * geral_intensity;
	col_final.rgb += grain;
	
	// flickering
	float flickering_time = time * u_vhs_flickering_speed;
	float scanlines = ((sin(uvl.y*0.8 + flickering_time*15.0 + sin(flickering_time))*0.5+0.2) * u_vhs_flickering_intensity) * geral_intensity;
	scanlines = saturate(scanlines);
	col_final.rgb = mix(col_final.rgb, vec3(scanlines), scanlines);
	
	return saturate(col_final);
}

void main() {
	vec2 uv = v_vTexcoord;
	vec2 uvl = uv;
	// [d] lens distortion
	//if (u_lens_distortion_enable > 0.5) uvl = lens_distortion_uv(uv, u_time_n_intensity.y); // it has limitations from gm-side
	gl_FragColor = vhs_fx(uv, uvl, gl_FragCoord.xy);
}
