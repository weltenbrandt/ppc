
/*------------------------------------------------------------------
You cannot redistribute this pixel shader source code anywhere.
Only compiled binary executables. Don't remove this notice, please.
Copyright (C) 2023 Mozart Junior (FoxyOfJungle). Kazan Games Ltd.
Website: https://foxyofjungle.itch.io/ | Discord: @foxyofjungle
-------------------------------------------------------------------*/

varying vec2 v_vTexcoord;
varying vec2 v_TexelSize;

// quality (low number = more performance)
#ifdef _YY_HLSL11_
#define ITERATIONS 360.0 // windows
#else
#define ITERATIONS 180.0 // others (android, operagx...)
#endif

const float Pi = 3.14159265;
const float Tau = 6.28318;
const float Golden_Angle = 2.39996323;

// >> uniforms
uniform vec2 u_time_n_intensity;

uniform float u_focus_distance;
uniform float u_focus_range;

uniform float u_bokeh_radius;
uniform float u_bokeh_intensity;
uniform float u_bokeh_shaped;
uniform float u_bokeh_blades_aperture;
uniform float u_bokeh_blades_angle;

uniform sampler2D u_zdepth_tex;
uniform sampler2D u_coc_tex;

uniform float u_dof_debug;

// smaller: more quality | larger: faster
const float rad_scale = 1.0;

// Based on DOF by Dennis Gustafsson.
// Improved and implemented for GameMaker by Mozart Junior

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

float saturate(float x) {
	return clamp(x, 0.0, 1.0);
}

vec3 blend(vec3 source, vec3 dest) {
	return source + dest - source * dest;
}

float get_luminance(vec3 color) {
	return dot(color, vec3(0.299, 0.587, 0.114));
}

vec3 uncharted2Tonemap(vec3 x) {
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

float get_CoC(float depth, float f_distance, float f_range) {
	float coc = clamp((1.0 / f_distance - 1.0 / depth) * f_range, -1.0, 1.0);
	return abs(coc) * u_bokeh_radius;
} 

vec2 bokeh_shape(float reciprocal, mat2 angle, float aperture) {
	float s = mix(1.0, cos(aperture) / cos(mod(reciprocal, 2.0*aperture) - aperture), step(0.5, u_bokeh_shaped));
	return vec2(cos(reciprocal), sin(reciprocal)) * s * angle;
}

// >> effect
vec4 dof_fx(vec2 uv, vec2 fpos) {
	// lens distortion (if needed)
	vec2 uv_l = mix(uv, lens_distortion_uv(uv, 1.0), step(0.5, u_lens_distortion_enable));
	
	// dof
	float center_depth = texture2D(u_zdepth_tex, uv_l).r;
	float center_size = get_CoC(center_depth, u_focus_distance, u_focus_range);
	
	float total = 1.0;
	float radius = rad_scale;
	float bokeh_intensity = u_bokeh_intensity * 64.0;
	float shape_a = radians(u_bokeh_blades_angle); 
	mat2 shape_ang = mat2(cos(shape_a), -sin(shape_a), sin(shape_a), cos(shape_a));
	float shape_rt = Pi/u_bokeh_blades_aperture;
	
	vec4 blur = texture2D(gm_BaseTexture, uv);
	vec4 light;
	vec2 offset;
	for(float ang = 0.0; ang < ITERATIONS; ang += Golden_Angle) {
		offset = bokeh_shape(ang, shape_ang, shape_rt);
		vec2 move = offset * v_TexelSize * radius;
		vec4 tex = texture2D(gm_BaseTexture, uv + move);
		float depth = texture2D(u_zdepth_tex, uv_l + move).r;
		
		float coc = get_CoC(depth, u_focus_distance, u_focus_range);
		if (depth > center_depth) coc = clamp(coc, 0.0, center_size*2.0);
        
		float mid = smoothstep(radius-0.5, radius+0.5, coc);
		
		light += pow(tex, vec4(vec3(8.0), 1.0)) * mid;
		
		blur += mix(blur/total, tex, mid);
		total += 1.0;
		radius += rad_scale/radius;
	}
	vec4 col_bokeh = blur / total;
	
	vec4 col_lights = (light*bokeh_intensity) / total;
	col_lights.rgb = uncharted2Tonemap(col_lights.rgb);
	col_bokeh.rgb = blend(col_bokeh.rgb, col_lights.rgb);
	
	if (u_dof_debug > 0.5) {
		vec3 col_debug = mix(vec3(1.0, 0.0, 0.0), vec3(1.0), saturate(center_size/u_bokeh_radius));
		col_debug *= get_luminance(col_bokeh.rgb) + 0.5;
		col_bokeh.rgb = col_debug;
	}
	
	return col_bokeh;
}

void main() {
	gl_FragColor = dof_fx(v_vTexcoord, gl_FragCoord.xy);
}
