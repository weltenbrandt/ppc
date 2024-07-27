
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

uniform vec2 u_time_n_intensity;
uniform float u_radial_blur_radius;
uniform vec2 u_radial_blur_center;
uniform float u_radial_blur_inner;
uniform sampler2D u_radial_blur_noise_tex;
uniform vec2 u_radial_blur_noise_size;

vec4 blur_radial_fx(vec2 uv) {
	float dist = pow(length(uv - u_radial_blur_center), u_radial_blur_inner) * u_radial_blur_radius * u_time_n_intensity.y;
	vec2 center = u_radial_blur_center - uv;
	float offset = texture2D(u_radial_blur_noise_tex, gl_FragCoord.xy/u_radial_blur_noise_size).r;
	
	vec4 blur = vec4(0.0);
	for(float i = 0.0; i < ITERATIONS; i+=1.0) {
		float percent = (i + offset) / ITERATIONS;
		blur += texture2D(gm_BaseTexture, uv + center * percent * dist);
	}
	return blur / ITERATIONS;
}

void main() {
	gl_FragColor = blur_radial_fx(v_vTexcoord);
}
