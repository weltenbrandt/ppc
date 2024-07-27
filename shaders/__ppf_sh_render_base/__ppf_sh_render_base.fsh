
/*------------------------------------------------------------------
You cannot redistribute this pixel shader source code anywhere.
Only compiled binary executables. Don't remove this notice, please.
Copyright (C) 2023 Mozart Junior (FoxyOfJungle). Kazan Games Ltd.
Website: https://foxyofjungle.itch.io/ | Discord: @foxyofjungle
-------------------------------------------------------------------*/

precision highp float;

varying vec2 v_vPosition;
varying vec2 v_vTexcoord;
varying vec2 v_vTexelSize;
varying vec2 v_vResolution;

uniform highp vec2 u_time_n_intensity;

// >> uniforms
uniform float u_rotation_enable;
uniform float u_rotation_angle;

uniform float u_zoom_enable;
uniform float u_zoom_amount;
uniform float u_zoom_range;
uniform vec2 u_zoom_center;

uniform float u_shake_enable;
uniform float u_shake_speed;
uniform float u_shake_magnitude;
uniform float u_shake_hspeed;
uniform float u_shake_vspeed;

uniform float u_panorama_enable;
uniform float u_panorama_depth_x;
uniform float u_panorama_depth_y;

uniform float u_lens_distortion_enable;
uniform float u_lens_distortion_amount;

uniform float u_pixelize_enable;
uniform float u_pixelize_amount;
uniform float u_pixelize_squares_max;
uniform float u_pixelize_steps;

uniform float u_swirl_enable;
uniform float u_swirl_angle;
uniform float u_swirl_radius;
uniform vec2 u_swirl_center;

uniform float u_shockwaves_enable;
uniform float u_shockwaves_amount;
uniform float u_shockwaves_aberration;
uniform sampler2D u_shockwaves_tex;
uniform sampler2D u_shockwaves_prisma_lut_tex;

uniform float u_displacemap_enable;
uniform float u_displacemap_amount;
uniform float u_displacemap_scale;
uniform float u_displacemap_angle;
uniform float u_displacemap_speed;
uniform sampler2D u_displacemap_tex;
uniform vec2 u_displacemap_offset;

uniform float u_sinewave_enable;
uniform vec2 u_sinewave_frequency;
uniform vec2 u_sinewave_amplitude;
uniform float u_sinewave_speed;
uniform vec2 u_sinewave_offset;

uniform float u_glitch_enable;
uniform float u_glitch_speed;
uniform float u_glitch_block_size;
uniform float u_glitch_interval;
uniform float u_glitch_intensity;
uniform float u_glitch_peak_amplitude1;
uniform float u_glitch_peak_amplitude2;

uniform float u_white_balance_enable;
uniform vec2 u_white_balance_chromaticity;

// >> dependencies
#region Common
//float rand(vec2 co) {
//	return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
//}

float saturate(float x) {
	return clamp(x, 0.0, 1.0);
}

vec3 saturate(vec3 x) {
	return clamp(x, 0.0, 1.0);
}

float random(vec2 uv, float t) {
	highp float d = 437.0 + mod(t, 10.0);
	highp vec2 p = uv;
	return fract(sin(cos(1.0-sin(p.x) * 1.0-cos(p.y)) * d) * d);
}

float noise(in vec2 p) {
	highp vec2 i = floor(p);
	highp vec2 f = fract(p);
	vec2 u = f * f * (3.0-2.0*f);
	return mix(mix(random(i + vec2(0.0, 0.0), 0.0),
	random(i + vec2(1.0, 0.0), 0.0), u.x),
	mix(random(i + vec2(0.0, 1.0), 0.0),
	random(i + vec2(1.0, 1.0), 0.0), u.x), u.y);
}

float peak(float x, float xpos, float scale) {
	// Thanks to: "BitOfGold"
	return clamp((1.0 - x) * scale * log(1.0 / abs(x - xpos)), 0.0, 1.0);
}

vec2 tiling_mirror(vec2 uv, vec2 tiling) {
	uv = (uv - 0.5) * tiling + 0.5;
	uv = abs(mod(uv - 1.0, 2.0) - 1.0);
	return uv;
}

vec2 get_aspect_ratio(vec2 res, vec2 size) {
	float aspect_ratio = res.x / res.y;
	return (res.x > res.y)
	? vec2(size.x * aspect_ratio, size.y)
	: vec2(size.x, size.y / aspect_ratio);
}
#endregion

#region Color Spaces

vec3 LRGBtoLMS(vec3 col) {
	// Linear RGB to LMS
	const mat3 LIN_2_LMS_MAT = mat3 (
		3.90405e-1, 5.49941e-1, 8.92632e-3,
		7.08416e-2, 9.63172e-1, 1.35775e-3,
		2.31082e-2, 1.28021e-1, 9.36245e-1
	);
	return col * LIN_2_LMS_MAT;
}

vec3 LMStoLRGB(vec3 col) {
	// LMS to Linear RGB
	const mat3 LMS_2_LIN_MAT = mat3 (
		2.85847e+0, -1.62879e+0, -2.48910e-2,
		-2.10182e-1,  1.15820e+0,  3.24281e-4,
		-4.18120e-2, -1.18169e-1,  1.06867e+0
	);
	return col * LMS_2_LIN_MAT;
}

vec3 CIEtoLMS(float x, float y) {
	float Y = 1.0;
	float X = Y * x / y;
	float Z = Y * (1.0 - x - y) / y;
	
	float L = 0.7328 * X + 0.4296 * Y - 0.1624 * Z;
	float M = -0.7036 * X + 1.6975 * Y + 0.0061 * Z;
	float S = 0.0030 * X + 0.0136 * Y + 0.9834 * Z;
	
	return vec3(L, M, S);
}

#endregion

// >> effects
vec2 rotation_uv(vec2 uv) {
	float angle = radians(u_rotation_angle);
	mat2 rot = mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
	vec2 rs = v_vResolution.xy / vec2(2.0);
	vec2 uv2 = v_vPosition - rs;
	uv = (rot * uv2 + rs) / v_vResolution.xy;
	return uv;
}

vec2 zoom_uv(vec2 uv) {
	float zoom = 1.0 + (u_zoom_amount - 2.0);
	uv += (u_zoom_center - uv) * (zoom / max(1.0, u_zoom_range));
	return uv;
}

vec2 shake_uv(vec2 uv) {
	highp float t = 100.0 + u_time_n_intensity.x * u_shake_speed;
	float mag = u_shake_magnitude * u_time_n_intensity.y;
	vec2 offset;
	offset.x = u_shake_hspeed * cos(t*135.0 + sin(t)) * mag;
	offset.y = u_shake_vspeed * sin(t*90.0 + cos(t)) * mag;
	return uv + offset;
}

vec2 panorama_uv(vec2 uv) {
	vec2 dist = vec2(length(uv.x - 0.5), length(uv.y - 0.5));
	float offset = dist.x * dist.y;
	vec2 dir = vec2(1.0) - 2.0 * step(0.5, uv);
	uv = vec2(
		uv.x + dist.y * (offset * dir.x * u_panorama_depth_x),
		uv.y + dist.x * (offset * dir.y * u_panorama_depth_y)
	);
	return uv;
}

vec2 lens_distortion_uv(vec2 uv, float intensity) {
	vec2 uv2 = uv - 0.5;
	float polar = atan(uv2.y, uv2.x);
	float len = length(uv2);
	float amount = u_lens_distortion_amount * intensity;
	len *= (pow(len, 2.0) * amount + 1.0);
	uv = vec2(0.5) + vec2(cos(polar), sin(polar)) * len;
	return uv;
}

vec2 pixelize_uv(vec2 uv) {
	float amount = u_pixelize_amount * u_time_n_intensity.y;
	float steps = (u_pixelize_steps > 0.0) ? ceil(amount*u_pixelize_steps)/u_pixelize_steps : amount;
	vec2 square_size = vec2(2.0*u_pixelize_squares_max*steps) * v_vTexelSize;
	uv = (steps > 0.0) ? (floor(uv/square_size)+0.5)*square_size : uv;
	return uv;
}

vec2 swirl_uv(vec2 uv) {
	float dist = length(uv - u_swirl_center);
	uv -= u_swirl_center;
	float d = smoothstep(0.0, u_swirl_radius, u_swirl_radius-dist) * radians(u_swirl_angle);
	mat2 rot = mat2(cos(d), -sin(d), sin(d), cos(d));
	uv *= rot;
	uv += u_swirl_center;
	return uv;
}

vec2 shockwaves_uv(vec2 uv, out vec2 offset_out) {
	float size = 500.0 * u_shockwaves_amount * u_time_n_intensity.y;
	vec2 offset = v_vTexelSize * (texture2D(u_shockwaves_tex, uv).rg * 2.0 - 1.0) * size;
	offset_out = offset;
	return uv + offset;
}

vec4 shockwaves_fx(vec4 color, vec2 uv, in vec2 offset_in) {
	vec4 col_prisma_a = texture2D(u_shockwaves_prisma_lut_tex, vec2(0.5/3.0, 0.0));
	vec4 col_prisma_b = texture2D(u_shockwaves_prisma_lut_tex, vec2(1.5/3.0, 0.0));
	vec4 col_prisma_c = texture2D(u_shockwaves_prisma_lut_tex, vec2(2.5/3.0, 0.0));
	//float dir = radians(u_shockwaves_aberration_angle);
	//vec2 direction = vec2(cos(dir), -sin(dir));
	vec2 dist = vec2(v_vTexelSize * offset_in * 500.0 * u_shockwaves_aberration);
	vec4 col_chroma_a = texture2D(gm_BaseTexture, uv + dist);
	vec4 col_chroma_b = texture2D(gm_BaseTexture, uv);
	vec4 col_chroma_c = texture2D(gm_BaseTexture, uv - dist);
	vec4 col = col_chroma_a*col_prisma_a + col_chroma_b*col_prisma_b + col_chroma_c*col_prisma_c;
	vec4 col_sum = (col_prisma_a + col_prisma_b + col_prisma_c);
	color = col / col_sum;
	return color;
}

vec2 displacement_maps_uv(vec2 uv) {
	highp vec2 uv2 = uv + (u_displacemap_offset / v_vResolution.xy);
	float angle = radians(u_displacemap_angle);
	//vec2 direction = vec2(cos(angle), -sin(angle));
	mat2 rot = mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
	//vec2 rs = v_vResolution.xy / vec2(2.0);
	//vec2 uv3 = v_vPosition - rs;
	//uv2 = (rot * uv3 + rs) / v_vResolution.xy;
	uv2 = rot * (uv2 - 0.5) + 0.5;
	uv2.x -= u_time_n_intensity.x * u_displacemap_speed;
	uv2 = tiling_mirror(uv2, vec2(u_displacemap_scale));
	vec3 col_noise = texture2D(u_displacemap_tex, uv2).rgb;
	float size = u_displacemap_amount * u_time_n_intensity.y;
	highp vec2 offset = vec2(col_noise.rg * size - (size*0.5));
	return uv + offset;
}

vec2 sinewave_uv(vec2 uv) {
	vec2 uv2 = uv + (u_sinewave_offset / v_vResolution.xy);
	float spd = u_time_n_intensity.x * u_sinewave_speed;
	vec2 amp = u_sinewave_amplitude * u_time_n_intensity.y;
	vec2 offset;
	offset.x = cos(uv2.y*u_sinewave_frequency.x - spd) * amp.x;
	offset.y = sin(uv2.x*u_sinewave_frequency.y - spd) * amp.y;
	return uv + offset;
}

vec2 glitch_uv(vec2 uv) {
	highp float time = u_time_n_intensity.x * u_glitch_speed;
	highp float glitch = random(vec2(0.0, ceil(uv.y * (v_vResolution.y * (1.0-u_glitch_block_size)))), time);
	highp float vscan = glitch;
	glitch *= (glitch > u_glitch_interval) ? u_glitch_peak_amplitude1 : u_glitch_peak_amplitude2;
	float ds = 0.05 * u_glitch_intensity * glitch * peak(uv.y, vscan, vscan);
	ds *= u_time_n_intensity.y;
	uv.x -= ds;
	//uv.y += ds;
	return uv;
}

vec3 white_balance_fx(vec3 color) {
	// tristimulus values of the D65 white point in the CIE XYZ color space
	vec3 white1 = vec3(0.949237, 1.03542, 1.08728); // D65 illuminant  //vec3(0.95047, 1.00000, 1.08883)
	
	// CIE To LMS color space
	vec3 white2 = CIEtoLMS(u_white_balance_chromaticity.x, u_white_balance_chromaticity.y);
	
	// get balance
	vec3 balance = vec3(white1 / white2);
	
	vec3 lms = LRGBtoLMS(color);
	lms *= balance;
	color = LMStoLRGB(lms);
	return saturate(color);
}

void main() {
	// # base
	vec2 uv = v_vTexcoord;
	
	// rotation
	if (u_rotation_enable > 0.5) uv = rotation_uv(uv);
	
    // zoom
	if (u_zoom_enable > 0.5) uv = zoom_uv(uv);
	
	// shake
	if (u_shake_enable > 0.5) uv = shake_uv(uv);
	
	// lens distortion
	if (u_lens_distortion_enable > 0.5) uv = lens_distortion_uv(uv, u_time_n_intensity.y);
	
	// pixelize
	if (u_pixelize_enable > 0.5) uv = pixelize_uv(uv);
	
	// swirl
	if (u_swirl_enable > 0.5) uv = swirl_uv(uv);
	
	// panorama
	if (u_panorama_enable > 0.5) uv = panorama_uv(uv);
	
	// sine wave
	if (u_sinewave_enable > 0.5) uv = sinewave_uv(uv);
	
	// glitch
	if (u_glitch_enable > 0.5) uv = glitch_uv(uv);
	
	// shockwaves
	vec2 _sw_offset;
	if (u_shockwaves_enable > 0.5) uv = shockwaves_uv(uv, _sw_offset);
	
	// displacement map
	if (u_displacemap_enable > 0.5) uv = displacement_maps_uv(uv);
	
	// image
	vec4 col_tex = texture2D(gm_BaseTexture, uv);
	vec4 col_final = col_tex;
	
	// white balance
	if (u_white_balance_enable > 0.5) col_final.rgb = white_balance_fx(col_final.rgb);
	
	// shockwaves
	if (u_shockwaves_enable > 0.5) col_final = shockwaves_fx(col_final, uv, _sw_offset);
	
	gl_FragColor = mix(col_tex, col_final, u_time_n_intensity.y);
}
