
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
uniform vec2 u_time_n_intensity;

// >> uniforms
uniform float u_lut_enable;
uniform int u_lut_type;
uniform vec2 u_lut_size;
uniform vec2 u_lut_squares;
uniform float u_lut_intensity;
uniform sampler2D u_lut_tex;

uniform float u_color_balance_enable;
uniform vec3 u_shadow_color;
uniform vec3 u_midtone_color;
uniform vec3 u_highlight_color;
uniform float u_shadow_range;
uniform float u_highlight_range;

uniform float u_exposure_enable;
uniform float u_exposure_val;

uniform float u_brightness_enable;
uniform float u_brightness_val;

uniform float u_contrast_enable;
uniform float u_contrast_val;

uniform float u_channel_mixer_enable;
uniform vec3 u_channel_mixer_red;
uniform vec3 u_channel_mixer_green;
uniform vec3 u_channel_mixer_blue;

uniform float u_lift_gamma_gain_enable;
uniform vec3 u_lift_rgb;
uniform vec3 u_gamma_rgb;
uniform vec3 u_gain_rgb;

uniform float u_hueshift_enable;
uniform vec3 u_hueshift_hsv;
uniform float u_hueshift_preserve_lum;

uniform float u_saturation_enable;
uniform float u_saturation_val;

uniform float u_colortint_enable;
uniform vec3 u_colortint_color;

uniform float u_colorize_enable;
uniform vec3 u_colorize_hsv;
uniform float u_colorize_intensity;

uniform float u_posterization_enable;
uniform float u_posterization_col_factor;

uniform float u_invert_colors_enable;
uniform float u_invert_colors_intensity;

uniform float u_curves_enable;
uniform float u_curves_preserve_lum;
uniform float u_curves_yrgb_is_ready;
uniform float u_curves_hhsl_is_ready;
uniform sampler2D u_curves_yrgb_tex;
uniform sampler2D u_curves_hhsl_tex;

uniform float u_tone_mapping_enable;
uniform int u_tone_mapping_mode;

// >> dependencies
#region Common
const vec3 lum_weights = vec3(0.2126729, 0.7151522, 0.0721750);
const vec3 lum_weight_avg = vec3(0.333);

float get_luminance(vec3 color) {
	return dot(color, lum_weights);
}

float get_luminance_avg(vec3 color) {
	return dot(color, lum_weight_avg);
}

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

vec3 blend(vec3 source, vec3 dest) {
	return source + dest - source * dest;
}

vec3 blend(vec3 source, vec4 dest) {
	return dest.rgb * dest.a + source * (1.0-dest.a);
}

vec4 blend(vec4 source, vec4 dest) {
	return dest * dest.a + source * (1.0-dest.a);
}

const float M_LOG10E = 0.434294481903251827651128918916605082;

#endregion

#region Color Spaces

//#define GAMMA 2.2

///// @desc Converts gamma space color to linear space.
//vec3 GammaToLinear(vec3 rgb) {
//	return pow(rgb, vec3(GAMMA));
//}

///// @desc Converts linear space color to gamma space.
//vec3 LinearToGamma(vec3 rgb) {
//	return pow(rgb, vec3(1.0 / GAMMA));
//}

const float YRGB_EPSILON = 1e-4;

vec3 HUEtoRGB(in float hue) {
	// Hue [0..1] to RGB [0..1]
	// See http://www.chilliant.com/rgb2hsv.html
	vec3 rgb = abs(hue * 6. - vec3(3, 2, 4)) * vec3(1, -1, -1) + vec3(-1, 2, 2);
	return clamp(rgb, 0., 1.);
}

vec3 RGBtoHCV(in vec3 rgb) {
	// RGB [0..1] to Hue-Chroma-Value [0..1]
	// Based on work by Sam Hocevar and Emil Persson
	vec4 p = (rgb.g < rgb.b) ? vec4(rgb.bg, -1., 2. / 3.) : vec4(rgb.gb, 0., -1. / 3.);
	vec4 q = (rgb.r < p.x) ? vec4(p.xyw, rgb.r) : vec4(rgb.r, p.yzx);
	float c = q.x - min(q.w, q.y);
	float h = abs((q.w - q.y) / (6. * c + YRGB_EPSILON) + q.z);
	return vec3(h, c, q.x);
}

vec3 HSVtoRGB(in vec3 hsv) {
	// Hue-Saturation-Value [0..1] to RGB [0..1]
	vec3 rgb = HUEtoRGB(hsv.x);
	return ((rgb - 1.) * hsv.y + 1.) * hsv.z;
}

vec3 HSLtoRGB(in vec3 hsl) {
	// Hue-Saturation-Lightness [0..1] to RGB [0..1]
	vec3 rgb = HUEtoRGB(hsl.x);
	float c = (1. - abs(2. * hsl.z - 1.)) * hsl.y;
	return (rgb - 0.5) * c + hsl.z;
}

vec3 RGBtoHSV(in vec3 rgb) {
	// RGB [0..1] to Hue-Saturation-Value [0..1]
	vec3 hcv = RGBtoHCV(rgb);
	float s = hcv.y / (hcv.z + YRGB_EPSILON);
	return vec3(hcv.x, s, hcv.z);
}

vec3 RGBtoHSL(in vec3 rgb) {
	// RGB [0..1] to Hue-Saturation-Lightness [0..1]
	vec3 hcv = RGBtoHCV(rgb);
	float z = hcv.z - hcv.y * 0.5;
	float s = hcv.y / (1. - abs(z * 2. - 1.) + YRGB_EPSILON);
	return vec3(hcv.x, s, z);
}

#endregion

#region ACES
#region License
/*-------------------------------[ License Terms for Academy Color Encoding System Components ]-------------------------------
Academy Color Encoding System (ACES) software and tools are provided by the Academy under the following terms and conditions:
A worldwide, royalty-free, non-exclusive right to copy, modify, create derivatives, and use, in source and binary forms, is
hereby granted, subject to acceptance of this license.

Copyright © 2015 Academy of Motion Picture Arts and Sciences (A.M.P.A.S.). Portions contributed by others as indicated.
All rights reserved.

Performance of any of the aforementioned acts indicates acceptance to be bound by the following terms and conditions:

* Copies of source code, in whole or in part, must retain the above copyright notice, this list of conditions and the Disclaimer
of Warranty.

* Use in binary form must retain the above copyright notice, this list of conditions and the Disclaimer of Warranty in the
documentation and/or other materials provided with the distribution.

* Nothing in this license shall be deemed to grant any rights to trademarks, copyrights, patents, trade secrets or any other
intellectual property of A.M.P.A.S. or any contributors, except as expressly stated herein.

* Neither the name "A.M.P.A.S." nor the name of any other contributors to this software may be used to endorse or promote products
derivative of or based on this software without express prior written permission of A.M.P.A.S. or the contributors, as appropriate.

This license shall be construed pursuant to the laws of the State of California, and any disputes related thereto shall be subject
to the jurisdiction of the courts therein.

Disclaimer of Warranty: THIS SOFTWARE IS PROVIDED BY A.M.P.A.S. AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT
ARE DISCLAIMED. IN NO EVENT SHALL A.M.P.A.S., OR ANY CONTRIBUTORS OR DISTRIBUTORS, BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, RESITUTIONARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

WITHOUT LIMITING THE GENERALITY OF THE FOREGOING, THE ACADEMY SPECIFICALLY DISCLAIMS ANY REPRESENTATIONS OR WARRANTIES WHATSOEVER
RELATED TO PATENT OR OTHER INTELLECTUAL PROPERTY RIGHTS IN THE ACADEMY COLOR ENCODING SYSTEM, OR APPLICATIONS THEREOF, HELD BY
PARTIES OTHER THAN A.M.P.A.S., WHETHER DISCLOSED OR UNDISCLOSED.
-------------------------------------------------------------------------------------------*/
#endregion

#define ACEScc_MAX 1.4679964
#define ACEScc_MIDGRAY 0.4135884

const mat3 AP1_2_XYZ_MAT = mat3 (
	0.6624541811, 0.1340042065, 0.1561876870,
	0.2722287168, 0.6740817658, 0.0536895174,
	-0.0055746495, 0.0040607335, 1.0103391003
);

const vec3 AP1_RGB2Y = vec3(AP1_2_XYZ_MAT[0][1], AP1_2_XYZ_MAT[1][1], AP1_2_XYZ_MAT[2][1]);

float get_luminance_ACES(vec3 color) {
	return dot(color, AP1_RGB2Y);
}

// Narkowicz 2015, "ACES Filmic Tone Mapping Curve"
vec3 tonemap_ACESFilm(vec3 x) {
	return clamp((x * (2.51 * x + 0.03)) / (x * (2.43 * x + 0.59) + 0.14), 0.0, 1.0);
}
#endregion

#region Tonemap
vec3 tonemap_lottes(vec3 x) {
	// Lottes 2016, "Advanced Techniques and Optimization of HDR Color Pipelines" (modified)
	vec3 a = vec3(1.6);
	vec3 d = vec3(0.977);
	vec3 hdrMax = vec3(1.0);
	vec3 midIn = vec3(0.2);
	vec3 midOut = vec3(0.267);
	vec3 b = (-pow(midIn, a) + pow(hdrMax, a) * midOut) / ((pow(hdrMax, a * d) - pow(midIn, a * d)) * midOut);
	vec3 c = (pow(hdrMax, a * d) * pow(midIn, a) - pow(hdrMax, a) * pow(midIn, a * d) * midOut) / ((pow(hdrMax, a * d) - pow(midIn, a * d)) * midOut);
	return pow(x, a) / (pow(x, a * d) * b + c);
}

vec3 tonemap_unreal3(vec3 x) {
	// Unreal 3, Documentation: "Color Grading"
	return x / (x + 0.155) * 1.019;
}

vec3 uncharted2Tonemap(vec3 x) {
	// http://filmicgames.com/archives/75
	float A = 0.15;
	float B = 0.50;
	float C = 0.10;
	float D = 0.20;
	float E = 0.02;
	float F = 0.30;
	float W = 11.2;
	return ((x * (A * x + C * B) + D * E) / (x * (A * x + B) + D * F)) - E / F;
}
vec3 tonemap_uncharted2(vec3 color) {
	float W = 11.2;
	float exposureBias = 8.0;
	vec3 curr = uncharted2Tonemap(exposureBias * color);
	vec3 whiteScale = 1.0 / uncharted2Tonemap(vec3(W));
	return curr * whiteScale;
}
#endregion

// >> effects
vec3 lut_fx(vec3 color) {
	float red_squares = u_lut_squares.x;
	float green_squares = u_lut_squares.y;
	
	float red_area = red_squares * red_squares;
	float green_area = green_squares * green_squares;
	
	float blue = (color.b * (red_area - 1.0)) * (green_squares / red_squares);
	
	vec2 quad1 = vec2(0.0);
	quad1.y = floor(floor(blue) / red_squares);
	quad1.x = floor(blue) - (quad1.y * red_squares);
	
	vec2 quad2 = vec2(0.0);
	quad2.y = floor(floor(blue) / red_squares);
	quad2.x = floor(blue) - (quad2.y * red_squares);
	
	float pd_red = red_squares / red_area;
	float pd_green = green_squares / green_area;
	
	vec4 error_fix = vec4(0.5/u_lut_size.x, 0.5/u_lut_size.y, 1.0/u_lut_size.x, 1.0/u_lut_size.y); // almost 0
	
	vec2 uv1 = vec2(0.0);
	uv1.x = (quad1.x * pd_red) + error_fix.x + ((pd_red - error_fix.z) * color.r);
	uv1.y = (quad1.y * pd_green) + error_fix.y + ((pd_green - error_fix.w) * color.g);
	
	vec2 uv2 = vec2(0.0);
	uv2.x = (quad2.x * pd_red) + error_fix.x + ((pd_red - error_fix.z) * color.r);
	uv2.y = (quad2.y * pd_green) + error_fix.y + ((pd_green - error_fix.w) * color.g);
	
	vec3 col = mix(texture2D(u_lut_tex, uv1).rgb, saturate(texture2D(u_lut_tex, uv2).rgb), fract(blue));
	return mix(color, col, u_lut_intensity);
}

vec3 shadow_midtone_highlight_fx(vec3 color) {
	float lum = get_luminance_ACES(color);
	float shadow_factor = 1.0 - smoothstep(0.0, u_shadow_range, lum);
	float highlight_factor = smoothstep(u_highlight_range, 1.0, lum);
	float midtone_factor = 1.0 - shadow_factor - highlight_factor;
	color *= (shadow_factor * u_shadow_color) + (midtone_factor * u_midtone_color + (highlight_factor * u_highlight_color));
	return color;
}

vec3 lift_gamma_gain_fx(vec3 color) {
	color = saturate(color * (1.5-0.5 * u_lift_rgb) + 0.5 * u_lift_rgb - 0.5);
	color *= u_gain_rgb;
	color = saturate(pow(abs(color), 1.0/u_gamma_rgb));
	return color;
}

vec3 exposure_fx(vec3 color) {
	return color * u_exposure_val;
}

vec3 brightness_fx(vec3 color) {
	return color + (u_brightness_val - 1.0);
}

vec3 contrast_fx(vec3 color) {
	//color = LinearToLogC(color); // currently not supported
	color = (color - ACEScc_MIDGRAY) * max(u_contrast_val, 0.0) + ACEScc_MIDGRAY;
	return color; //LogCToLinear(color);
}

vec3 channel_mixer_fx(vec3 color) {
	return vec3(dot(color, u_channel_mixer_red.rgb), dot(color, u_channel_mixer_green.rgb), dot(color, u_channel_mixer_blue.rgb));
}

vec3 hue_shift_fx(vec3 color) {
	vec3 lum = RGBtoHSL(color);
	
	color = RGBtoHSV(color);
	color.x = fract(color.x + u_hueshift_hsv.x);
	color.y *= u_hueshift_hsv.y;
	//color.z *= u_hueshift_hsv.z;
	color = HSVtoRGB(color);
	
	if (u_hueshift_preserve_lum > 0.5) {
		color.rgb = RGBtoHSL(color.rgb);
		color.z = lum.z;
		color.rgb = HSLtoRGB(color.rgb);
	}
	return color;
}

vec3 colortint_fx(in vec3 color) {
	return color * u_colortint_color;
}

vec3 colorize_fx(vec3 color) {
	float lum = get_luminance(color);
	float aa = clamp(2.0 * lum, 0.0, 1.0);
	float cc = clamp(2.0 * (1.0 - lum), 0.0, 1.0);
	float bb = 1.0 - aa - cc;
	vec3 _merged = 1.0 - (bb * HSVtoRGB(u_colorize_hsv) + cc);
	return mix(color, _merged, u_colorize_intensity);
}

vec3 saturation_fx(vec3 color) {
	float lum = get_luminance(color);
	return mix(vec3(lum), color, u_saturation_val);
}

vec3 posterization_fx(vec3 color) {
	color = floor(color * u_posterization_col_factor) / u_posterization_col_factor;
	return color;
}

vec3 invert_colors_fx(vec3 color) {
	return mix(color, 1.0-color, u_invert_colors_intensity);
}

vec3 color_curves_fx(vec3 color) {
	vec3 linear_col = color;
	// HHSL
	float saturation;
	if (u_curves_hhsl_is_ready > 0.5) {
		// convert to hsv space
		vec3 hsv = RGBtoHSV(linear_col);
		saturation = saturate(texture2D(u_curves_hhsl_tex, vec2(hsv.x, 0.0)).y) * 2.0; // hue x sat
		saturation *= saturate(texture2D(u_curves_hhsl_tex, vec2(hsv.y, 0.0)).z) * 2.0; // sat x sat
		saturation *= saturate(texture2D(u_curves_hhsl_tex, vec2(get_luminance(linear_col), 0.0)).w) * 2.0; // lum x sat
		
		// hue shift
		float hue = hsv.x + u_hueshift_hsv.x;
		hue += saturate(texture2D(u_curves_hhsl_tex, vec2(hue, 0.0)).x) - 0.5; // hue x hue
		hsv.x = fract(hue);
		
		// back to linear RGB space
		linear_col = HSVtoRGB(hsv);
		
		// saturation
		float lum = get_luminance(linear_col);
		linear_col = mix(vec3(lum), linear_col, saturation * u_hueshift_hsv.y);
	}
	
	vec3 original_lum = RGBtoHSL(linear_col);
	
	// YRGB
	if (u_curves_yrgb_is_ready > 0.5) {
		// Y (main)
		float yred = saturate(texture2D(u_curves_yrgb_tex, vec2(linear_col.r, 0.0)).w);
		float ygreen = saturate(texture2D(u_curves_yrgb_tex, vec2(linear_col.g, 0.0)).w);
		float yblue = saturate(texture2D(u_curves_yrgb_tex, vec2(linear_col.b, 0.0)).w);
		linear_col = vec3(yred, ygreen, yblue);
		
		// RGB
		float red = saturate(texture2D(u_curves_yrgb_tex, vec2(linear_col.r, 0.0)).x);
		float green = saturate(texture2D(u_curves_yrgb_tex, vec2(linear_col.g, 0.0)).y);
		float blue = saturate(texture2D(u_curves_yrgb_tex, vec2(linear_col.b, 0.0)).z);
		linear_col = vec3(red, green, blue);
	}
	
	// preserve luminance
	linear_col.rgb = RGBtoHSL(linear_col.rgb);
	linear_col.z = mix(linear_col.z, original_lum.z, step(0.5, u_curves_preserve_lum));
	linear_col.rgb = HSLtoRGB(linear_col.rgb);
	return linear_col;
}

vec3 tone_mapping_fx(vec3 color) {
	if (u_tone_mapping_mode == 0) {
		color = tonemap_ACESFilm(color);
	} else
	if (u_tone_mapping_mode == 1) {
		color = tonemap_lottes(color);
	} else
	if (u_tone_mapping_mode == 2) {
		color = tonemap_uncharted2(color);
	} else
	if (u_tone_mapping_mode == 3) {
		color = tonemap_unreal3(color);
	}
	return color;
}

void main() {
	// image
	vec4 col_tex = texture2D(gm_BaseTexture, v_vTexcoord);
	vec4 col_final = col_tex;
	
	// lut
	if (u_lut_enable > 0.5) col_final.rgb = lut_fx(col_final.rgb);
	
	// exposure_fx
	if (u_exposure_enable > 0.5) col_final.rgb = exposure_fx(col_final.rgb);
	
	// brightness_fx
	if (u_brightness_enable > 0.5) col_final.rgb = brightness_fx(col_final.rgb);
	
	// contrast_fx
	if (u_contrast_enable > 0.5) col_final.rgb = contrast_fx(col_final.rgb);
	
	// channel_mixer_fx
	if (u_channel_mixer_enable > 0.5) col_final.rgb = channel_mixer_fx(col_final.rgb);
	
	// shadow_midtone_highlight_fx
	if (u_color_balance_enable > 0.5) col_final.rgb = shadow_midtone_highlight_fx(col_final.rgb);
	
	// lift_gamma_gain_fx
	if (u_lift_gamma_gain_enable > 0.5) col_final.rgb = lift_gamma_gain_fx(col_final.rgb);
	
	// saturation_fx
	if (u_saturation_enable > 0.5) col_final.rgb = saturation_fx(col_final.rgb);
	
	// hue_shift_fx
	if (u_hueshift_enable > 0.5) col_final.rgb = hue_shift_fx(col_final.rgb);
	
	// color_tint
	if (u_colortint_enable > 0.5) col_final.rgb = colortint_fx(col_final.rgb);
	
	// prevent negative values
	col_final.rgb = max(vec3(0.0), col_final.rgb);
	
	// colorize_fx
	if (u_colorize_enable > 0.5) col_final.rgb = colorize_fx(col_final.rgb);
	
	// posterization_fx
	if (u_posterization_enable > 0.5) col_final.rgb = posterization_fx(col_final.rgb);
	
	// invert_colors_fx
	if (u_invert_colors_enable > 0.5) col_final.rgb = invert_colors_fx(col_final.rgb);
	
	// color_curves_fx
	if (u_curves_enable > 0.5) col_final.rgb = color_curves_fx(col_final.rgb);
	
	// tone_mapping_fx
	if (u_tone_mapping_enable > 0.5) col_final.rgb = tone_mapping_fx(col_final.rgb);
	
	gl_FragColor = mix(col_tex, col_final, u_time_n_intensity.y);
}
