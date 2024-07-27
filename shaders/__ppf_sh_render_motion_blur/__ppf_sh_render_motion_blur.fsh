
/*------------------------------------------------------------------
You cannot redistribute this pixel shader source code anywhere.
Only compiled binary executables. Don't remove this notice, please.
Copyright (C) 2023 Mozart Junior (FoxyOfJungle). Kazan Games Ltd.
Website: https://foxyofjungle.itch.io/ | Discord: @foxyofjungle
-------------------------------------------------------------------*/

varying vec2 v_vTexcoord;

// quality (low number = more performance)
#ifdef _YY_HLSL11_
#define ITERATIONS 32.0 // windows
#else
#define ITERATIONS 16.0 // others (android, operagx...)
#endif

// >> uniforms
uniform vec2 u_time_n_intensity;
uniform float u_motion_blur_direction;
uniform float u_motion_blur_radius;
uniform vec2 u_motion_blur_center;
uniform float u_motion_blur_mask_power;
uniform float u_motion_blur_mask_scale;
uniform float u_motion_blur_mask_smoothness;
uniform float u_motion_blur_using_overlay_texture;
uniform sampler2D u_motion_blur_overlay_tex;
uniform sampler2D u_motion_blur_noise_tex;
uniform vec2 u_motion_blur_noise_size;

#region Common
float saturate(float x) {
	return clamp(x, 0.0, 1.0);
}

vec4 blend_b(vec4 source, vec4 dest) {
	return dest * dest.a + source * (1.0-dest.a);
}

float mask_radial(vec2 uv, vec2 center, float power, float scale, float smoothness) {
	float smoothh = mix(scale, 0.0, smoothness);
	float sc = scale / 2.0;
	float mask = pow(1.0-saturate((length(uv-center)-sc) / ((smoothh-0.001)-sc)), power);
	return mask;
}
#endregion

// >> effect
vec4 motion_blur_fx(vec2 uv) {
	float dir = radians(u_motion_blur_direction);
	vec2 direction = vec2(cos(dir), -sin(dir));
	float mask = mask_radial(uv, u_motion_blur_center, u_motion_blur_mask_power, u_motion_blur_mask_scale, u_motion_blur_mask_smoothness);
	vec2 dist = direction * mask * u_motion_blur_radius * 0.05 * u_time_n_intensity.y;
	float offset = texture2D(u_motion_blur_noise_tex, gl_FragCoord.xy/u_motion_blur_noise_size).r;
	
	vec4 blur = vec4(0.0);
	for(float i = 0.0; i < ITERATIONS; i+=1.0) {
		float percent = (i + offset) / ITERATIONS;
		blur += texture2D(gm_BaseTexture, uv + (percent * 2.0 - 1.0) * dist);
	}
	vec4 mblur = blur / ITERATIONS;
	if (u_motion_blur_using_overlay_texture > 0.5) mblur = blend_b(mblur, texture2D(u_motion_blur_overlay_tex, uv));
	return mblur;
}

void main() {
	gl_FragColor = motion_blur_fx(v_vTexcoord);
}
