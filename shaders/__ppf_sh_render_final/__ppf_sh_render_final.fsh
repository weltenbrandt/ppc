
/*------------------------------------------------------------------
You cannot redistribute this pixel shader source code anywhere.
Only compiled binary executables. Don't remove this notice, please.
Copyright (C) 2023 Mozart Junior (FoxyOfJungle). Kazan Games Ltd.
Website: https://foxyofjungle.itch.io/ | Discord: @foxyofjungle
-------------------------------------------------------------------*/

precision highp float;

varying vec2 v_vPosition;
varying vec2 v_vTexcoord;

uniform vec2 u_resolution;
uniform highp vec2 u_time_n_intensity;

// >> uniforms
uniform float u_dither_enable;
uniform float u_dither_mode;
uniform float u_dither_intensity;
uniform float u_dither_bit_levels;
uniform float u_dither_contrast;
uniform float u_dither_threshold;
uniform float u_dither_scale;
uniform float u_dither_bayer_size;
uniform sampler2D u_dither_bayer_tex;

uniform float u_noise_grain_enable;
uniform float u_noise_grain_intensity;
uniform float u_noise_grain_luminosity;
uniform float u_noise_grain_scale;
uniform float u_noise_grain_speed;
uniform float u_noise_grain_mix;
uniform vec2 u_noise_grain_res;
uniform sampler2D u_noise_grain_tex;

uniform float u_mist_enable;
uniform float u_mist_intensity;
uniform float u_mist_scale;
uniform float u_mist_tiling;
uniform float u_mist_speed;
uniform float u_mist_angle;
uniform float u_mist_contrast;
uniform float u_mist_power;
uniform float u_mist_remap;
uniform vec3 u_mist_color;
uniform float u_mist_mix;
uniform float u_mist_mix_threshold;
uniform sampler2D u_mist_noise_tex;
uniform vec2 u_mist_offset;
uniform float u_mist_fade_amount;
uniform float u_mist_fade_angle;

uniform float u_speedlines_enable;
uniform float u_speedlines_scale;
uniform float u_speedlines_tiling;
uniform float u_speedlines_speed;
uniform float u_speedlines_rot_speed;
uniform float u_speedlines_contrast;
uniform float u_speedlines_power;
uniform float u_speedlines_remap;
uniform vec3 u_speedlines_color;
uniform float u_speedlines_mask_power;
uniform float u_speedlines_mask_scale;
uniform float u_speedlines_mask_smoothness;
uniform sampler2D u_speedlines_noise_tex;

uniform float u_vignette_enable;
uniform float u_vignette_intensity;
uniform float u_vignette_curvature;
uniform float u_vignette_inner;
uniform float u_vignette_outer;
uniform vec3 u_vignette_color;
uniform vec2 u_vignette_center;
uniform float u_vignette_rounded;
uniform float u_vignette_linear;

uniform float u_scanlines_enable;
uniform float u_scanlines_intensity;
uniform float u_scanlines_sharpness;
uniform float u_scanlines_speed;
uniform float u_scanlines_amount;
uniform vec3 u_scanlines_color;
uniform float u_scanlines_mask_power;
uniform float u_scanlines_mask_scale;
uniform float u_scanlines_mask_smoothness;

uniform float u_nes_fade_enable;
uniform float u_nes_fade_amount;
uniform float u_nes_fade_levels;

uniform float u_fade_enable;
uniform float u_fade_amount;
uniform vec3 u_fade_color;

uniform float u_cinama_bars_enable;
uniform float u_cinema_bars_amount;
uniform float u_cinema_bars_intensity;
uniform vec3 u_cinema_bars_color;
uniform float u_cinema_bars_vertical_enable;
uniform float u_cinema_bars_horizontal_enable;
uniform float u_cinema_bars_can_distort;

uniform float u_color_blindness_enable;
uniform float u_color_blindness_mode;

uniform float u_channels_enable;
uniform vec3 u_channel_rgb;

uniform float u_border_enable;
uniform float u_border_curvature;
uniform float u_border_smooth;
uniform vec3 u_border_color;

// >> dependencies
const float Tau = 6.28318;

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

const vec3 lum_weights = vec3(0.2126729, 0.7151522, 0.0721750);
float get_luminance(vec3 color) {
	return dot(color, lum_weights);
}

float dithering_matrix(vec2 pos) {  
	return texture2D(u_dither_bayer_tex, mod(pos, u_dither_bayer_size)/u_dither_bayer_size).r;
}

float rand(vec2 p, sampler2D tex) {
	return texture2D(tex, p).r;
}

// (C) 2016, Ashima Arts
/*vec3 mod2D289(vec3 x) {return x - floor( x * (1.0 / 289.0)) * 289.0;}
vec2 mod2D289(vec2 x) {return x - floor( x * (1.0 / 289.0)) * 289.0;}
vec3 permute(vec3 x) {return mod2D289(((x * 34.0) + 1.0) * x);}
float snoise(vec2 v) {
	const highp vec4 C = vec4(0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439);
	vec2 i = floor(v + dot(v, C.yy));
	vec2 x0 = v - i + dot(i, C.xx);
	vec2 i1;
	i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
	vec4 x12 = x0.xyxy + C.xxzz;
	x12.xy -= i1;
	i = mod2D289(i);
	vec3 p = permute(permute(i.y + vec3( 0.0, i1.y, 1.0 )) + i.x + vec3(0.0, i1.x, 1.0));
	vec3 m = max(0.5 - vec3(dot(x0, x0), dot(x12.xy, x12.xy), dot(x12.zw, x12.zw)), 0.0);
	m = m * m;
	m = m * m;
	vec3 x = 2.0 * fract(p * C.www) - 1.0;
	vec3 h = abs(x) - 0.5;
	vec3 ox = floor(x + 0.5);
	vec3 a0 = x - ox;
	m *= 1.79284291400159 - 0.85373472095314 * (a0 * a0 + h * h);
	vec3 g;
	g.x = a0.x * x0.x + h.x * x0.y;
	g.yz = a0.yz * x12.xz + h.yz * x12.yw;
	return 130.0 * dot(m, g);
}*/

vec2 get_aspect_ratio(vec2 res, vec2 size) {
	float aspect_ratio = res.x / res.y;
	return (res.x > res.y)
	? vec2(size.x * aspect_ratio, size.y)
	: vec2(size.x, size.y / aspect_ratio);
}

vec2 tiling(vec2 uv, vec2 tiling) {
	uv = (uv - 0.5) * tiling + 0.5;
	return mod(uv, 1.0);
}

vec2 tiling_mirror(vec2 uv, vec2 tiling) {
	uv = (uv - 0.5) * tiling + 0.5;
	uv = abs(mod(uv - 1.0, 2.0) - 1.0);
	return uv;
}

float linearstep(float a, float b, float c) {
	return (c - a) / (b - a);
}

float saturate(float x) {
	return clamp(x, 0.0, 1.0);
}

vec3 blend(vec3 source, vec3 dest) {
	return source + dest - source * dest;
}

vec3 blend(vec3 source, vec4 dest) {
	return dest.rgb * dest.a + source * (1.0-dest.a);
}

vec4 blend(vec4 source, vec4 dest) {
	return dest * dest.a + source * (1.0-dest.a);
}

float mask_radial(vec2 uv, vec2 center, float power, float scale, float smoothness) {
	float smoothh = mix(scale, 0.0, smoothness);
	float sc = scale / 2.0;
	float mask = pow(1.0-saturate((length(uv-center)-sc) / ((smoothh-0.001)-sc)), power);
	return mask;
}
#endregion

// >> effects
vec3 dithering_fx(vec3 color) {
	float matrix = dithering_matrix(v_vPosition / u_dither_scale);
	float lum = get_luminance(color);
	lum = (lum - 0.5 - abs(u_dither_threshold)) * max(u_dither_contrast, 0.0) + 0.5;
	
	vec3 dithering;
	if (u_dither_mode == 0.0) {
		dithering = floor(color * u_dither_bit_levels + matrix) / u_dither_bit_levels;
	} else
	if (u_dither_mode == 1.0) {
		vec3 col_step = floor(color * u_dither_bit_levels) / u_dither_bit_levels;
		dithering = mix(color, vec3(step(matrix, col_step)), (color - 0.5) * u_dither_contrast + 0.5);
	} else
	if (u_dither_mode == 2.0) {
		vec3 col_step = floor(color * u_dither_bit_levels + matrix) / u_dither_bit_levels;
		dithering = mix(color, col_step, step(matrix, lum));
	} else
	if (u_dither_mode == 3.0) {
		float lum_step = floor(lum * u_dither_bit_levels) / u_dither_bit_levels;
		dithering = mix(color, color * step(matrix, lum_step) + color, mix(0.0, 0.5, u_dither_intensity));
	}
	return mix(color, dithering, u_dither_intensity);
}

vec3 noise_grain_fx(vec3 color) {
	vec2 uv = v_vPosition / u_noise_grain_res;
	uv = tiling(uv, vec2(u_noise_grain_scale));
	
	float spd = 50.0 * u_noise_grain_speed;
	float t = 1.0;
	if (u_noise_grain_speed > 0.0) t = floor(1.0+fract(u_time_n_intensity.x) * spd) / spd;
	
	vec2 offset1 = vec2(cos(t*135.0 + sin(t)), sin(t*90.0 + cos(t)));
    vec2 offset2 = vec2(cos(t*90.0 + sin(t)), sin(t*135.0 + cos(t)));
	
	float g1 = texture2D(u_noise_grain_tex, uv+offset1).r;
	float g2 = texture2D(u_noise_grain_tex, uv+offset2).r;
	float grain = sqrt(g1 * g2) / 0.75;
	
	float lum = 1.0 - sqrt(get_luminance(color));
	lum = mix(lum, 1.0, u_noise_grain_luminosity);
	
	if (u_noise_grain_mix > 0.5) {
		color += color * (grain*2.0-1.0) * lum * u_noise_grain_intensity;
	} else {
		color = vec3(grain);
	}
	return color;
}

vec4 mist_fx(vec4 color, vec2 uv) {
	const float mist_fade_smoothness = 0.8;
	
	//vec2 uv_o = (v_vPosition-u_mist_offset) / u_resolution.xy;
	vec2 uv_o = uv + (u_mist_offset / u_resolution.xy);
	
	vec2 uv_noise = uv_o;
	float noise_angle = radians(u_mist_angle);
	uv_noise = mat2(cos(noise_angle), -sin(noise_angle), sin(noise_angle), cos(noise_angle)) * (uv_noise - 0.5) + 0.5;
	uv_noise = tiling(uv_noise, vec2(u_mist_tiling*u_mist_scale, u_mist_tiling));
	uv_noise.x -= u_time_n_intensity.x * u_mist_speed;
	
	float perlin_noise = texture2D(u_mist_noise_tex, uv_noise).r * u_mist_contrast + 0.5;
	float fog = saturate(pow(perlin_noise, u_mist_power) - u_mist_remap) / (1.0-u_mist_remap);
	
	vec2 uv_fade = uv_o;
	float fade_angle = radians(u_mist_fade_angle);
	uv_fade = mat2(cos(fade_angle), -sin(fade_angle), sin(fade_angle), cos(fade_angle)) * (uv_fade - 0.5) + 0.5;
	if (u_mist_fade_amount > 0.0) fog *= smoothstep(u_mist_fade_amount, u_mist_fade_amount-mist_fade_smoothness, uv_fade.x);
	
	float intensity = u_mist_intensity * u_time_n_intensity.y;
	fog *= intensity;
	fog = saturate(fog);
	
	vec3 luminance_level = max((color.rgb + u_mist_mix_threshold) * intensity, 0.0);
	vec3 luma = mix(vec3(1.0), luminance_level, u_mist_mix);
	
	vec3 col_mist = mix(color.rgb, u_mist_color, fog*luma);
	color.rgb = mix(color.rgb, col_mist, fog);
	return color;
}

vec3 speedlines_fx(vec3 color, vec2 uv) {
	vec2 center = uv - 0.5;
	
	float angle = radians(u_time_n_intensity.x * u_speedlines_rot_speed);
	center *= mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
	
	highp float time = u_time_n_intensity.x * u_speedlines_speed*0.1;
	vec2 uv2 = vec2((length(center) * u_speedlines_scale * 0.5) - time, atan(center.x, center.y) * (1.0/Tau) * u_speedlines_tiling);
	
	float perlin_noise = texture2D(u_speedlines_noise_tex, uv2).r * u_speedlines_contrast + 0.5;
	float fast_lines = saturate(pow(perlin_noise, u_speedlines_power) - u_speedlines_remap) / (1.0-u_speedlines_remap);
	float mask = mask_radial(uv, vec2(0.5), u_speedlines_mask_power, u_speedlines_mask_scale, u_speedlines_mask_smoothness);
	
	return mix(color, u_speedlines_color, fast_lines * mask * u_time_n_intensity.y);
}

vec3 vignette_fx(vec3 color, vec2 uv) {
	float curvature = clamp(u_vignette_curvature, 0.02, 1.0);
	vec2 dist = abs(uv - u_vignette_center) * 2.0;
	if (u_vignette_rounded > 0.5) dist = get_aspect_ratio(u_resolution.xy, dist);
	vec2 curve = pow(dist, vec2(1.0/curvature));
	float edge = pow(length(curve), curvature);
	float vig = (u_vignette_linear > 0.5) ? 
		smoothstep(1.0-u_vignette_inner, 1.0, edge/u_vignette_outer) :
		pow(edge/u_vignette_outer, 1.0/u_vignette_inner);
	return mix(color, u_vignette_color, saturate(vig) * u_vignette_intensity);
}

vec3 nes_fade_fx(vec3 color) {
	// with help of Jan Vorisek
	color = max(vec3(0.0), color - u_nes_fade_amount);
	vec3 bias = vec3(1.0) / u_nes_fade_levels;
	color = (floor((color + bias) * u_nes_fade_levels) / u_nes_fade_levels) - bias;
	return color;
}

vec3 scanlines_fx(vec3 color, vec2 uv) {
	highp float time = u_time_n_intensity.x * u_scanlines_speed;
	float mask = mask_radial(uv, vec2(0.5), u_scanlines_mask_power, u_scanlines_mask_scale, u_scanlines_mask_smoothness);
	float lines = sin(time - (uv.y * 2.0*u_resolution.y * u_scanlines_amount)) * 0.5+0.5;
	float sharp = mix(0.0, 0.5, u_scanlines_sharpness);
	lines = saturate(linearstep(sharp, 1.0-sharp, lines));
	return mix(color, u_scanlines_color, lines * mask * u_scanlines_intensity);
}

vec3 fade_color_fx(vec3 color) {
	return mix(color, u_fade_color, u_fade_amount);
}

vec3 cinema_bars_fx(vec3 color, vec2 uv, vec2 uvl) {
	vec2 uv2 = mix(uv, uvl, step(0.5, u_cinema_bars_can_distort));
	vec2 uv_b = abs(uv2 * 2.0 - 1.0);
	vec2 bars = 1.0-step(u_cinema_bars_amount, 1.0-uv_b);
	vec3 col = color;
	if (u_cinema_bars_vertical_enable > 0.5) col = mix(col, u_cinema_bars_color, bars.y);
	if (u_cinema_bars_horizontal_enable > 0.5) col = mix(col, u_cinema_bars_color, bars.x);
	return mix(color, col, u_cinema_bars_intensity);
}

vec3 color_blindness_fx(vec3 color) {
	//http://blog.noblemaster.com/2013/10/26/opengl-shader-to-correct-and-simulate-color-blindness-experimental/
	if (u_color_blindness_mode == 0.0) { // protanopia
		color *= mat3(0.20, 0.99, -0.19,
					0.16, 0.79, 0.04,
					0.01, -0.01, 1.00);
	} else
	if (u_color_blindness_mode == 1.0) { // deuteranopia
		color *= mat3(0.43, 0.72, -0.15,
					0.34, 0.57, 0.09,
					-0.02, 0.03, 1.00);
	} else
	if (u_color_blindness_mode == 2.0) { // tritanopia
		color *= mat3(0.97, 0.11, -0.08,
					0.02, 0.82, 0.16,
					-0.06, 0.88, 0.18);
	}
	return color;
}

vec3 channels_fx(vec3 color) {
	return color * u_channel_rgb.xyz;
}

vec3 border_fx(vec3 color, vec2 uv) {
	float curvature = clamp(u_border_curvature, 0.005, 1.0);
	vec2 corner = pow(abs(uv*2.0-1.0), vec2(1.0/curvature));
	float edge = pow(length(corner), curvature);
	float border = smoothstep(1.0-u_border_smooth, 1.0, edge);
	return mix(color, u_border_color, border);
}

void main() {
	vec2 uv = v_vTexcoord;
	
	// [d] lens distortion
	vec2 uvl = uv;
	if (u_lens_distortion_enable > 0.5) uvl = lens_distortion_uv(uv, u_time_n_intensity.y);
	
	// image
	vec4 col_tex = texture2D(gm_BaseTexture, uv);
	vec4 col_final = col_tex;
	
	// mist_fx
	if (u_mist_enable > 0.5) col_final = mist_fx(col_final, uvl);
	
	// speedlines_fx
	if (u_speedlines_enable > 0.5) col_final.rgb = speedlines_fx(col_final.rgb, uvl);
	
	// dithering_fx
	if (u_dither_enable > 0.5) col_final.rgb = dithering_fx(col_final.rgb);
	
	// noise_grain_fx
	if (u_noise_grain_enable > 0.5) col_final.rgb = noise_grain_fx(col_final.rgb);
	
	// vignette_fx
	if (u_vignette_enable > 0.5) col_final.rgb = vignette_fx(col_final.rgb, uvl);
	
	// nes_fade_fx
	if (u_nes_fade_enable > 0.5) col_final.rgb = nes_fade_fx(col_final.rgb);
	
	// scanlines_fx
	if (u_scanlines_enable > 0.5) col_final.rgb = scanlines_fx(col_final.rgb, uvl);
	
	// fade_color_fx
	if (u_fade_enable > 0.5) col_final.rgb = fade_color_fx(col_final.rgb);
	
	// cinema bars
	if (u_cinama_bars_enable > 0.5) col_final.rgb = cinema_bars_fx(col_final.rgb, uv, uvl);
	
	// color_blindness_fx
	if (u_color_blindness_enable > 0.5) col_final.rgb = color_blindness_fx(col_final.rgb);
	
	// channels_fx
	if (u_channels_enable > 0.5) col_final.rgb = channels_fx(col_final.rgb);
	
	// border_fx
	if (u_border_enable > 0.5) col_final.rgb = border_fx(col_final.rgb, uvl);
	gl_FragColor = mix(col_tex, col_final, u_time_n_intensity.y);
}
