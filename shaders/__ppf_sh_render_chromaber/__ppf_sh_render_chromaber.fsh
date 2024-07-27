
/*------------------------------------------------------------------
You cannot redistribute this pixel shader source code anywhere.
Only compiled binary executables. Don't remove this notice, please.
Copyright (C) 2023 Mozart Junior (FoxyOfJungle). Kazan Games Ltd.
Website: https://foxyofjungle.itch.io/ | Discord: @foxyofjungle
-------------------------------------------------------------------*/

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

varying vec2 v_TexelSize;
uniform vec2 u_time_n_intensity;

// quality (low number = more performance)
#ifdef _YY_HLSL11_
#define ITERATIONS 16.0 // windows
#else
#define ITERATIONS 8.0 // others (android, operagx...)
#endif

vec4 saturate(vec4 x) {
	return clamp(x, 0.0, 1.0);
}

// >> uniforms
// chromatic aberration
uniform float u_chromaber_intensity;
uniform float u_chromaber_angle;
uniform float u_chromaber_center_radius;
uniform float u_chromaber_inner;
uniform float u_chromaber_blur_enable;
uniform sampler2D u_chromaber_prisma_lut;

const float ITERATIONS_RECIPROCAL = 1.0/ITERATIONS;

// >> effect
vec4 chromaberration_fx(vec2 uv) {
	float theta = radians(u_chromaber_angle);
	vec2 direction = vec2(cos(theta), -sin(theta));
	vec2 uv2 = uv * 2.0-1.0;
	float center_radius = pow(length(uv - 0.5), u_chromaber_center_radius) * 2.0;
	float edge = dot(uv2, uv2) * center_radius * u_chromaber_intensity;
	vec2 weight = (edge - uv) / 3.0;
	vec2 dist = vec2(v_TexelSize * direction * mix(vec2(u_chromaber_intensity), uv2*weight, u_chromaber_inner)) * u_time_n_intensity.y;
	vec4 col_final;
	if (u_chromaber_blur_enable < 0.5) {
		vec4 col_lut_a = texture2D(u_chromaber_prisma_lut, vec2(0.5/3.0, 0.0));
		vec4 col_lut_b = texture2D(u_chromaber_prisma_lut, vec2(1.5/3.0, 0.0));
		vec4 col_lut_c = texture2D(u_chromaber_prisma_lut, vec2(2.5/3.0, 0.0));
		vec4 col_tex_a = texture2D(gm_BaseTexture, uv + dist);
		vec4 col_tex_b = texture2D(gm_BaseTexture, uv);
		vec4 col_tex_c = texture2D(gm_BaseTexture, uv - dist);
		vec4 chroma = col_tex_a*col_lut_a + col_tex_b*col_lut_b + col_tex_c*col_lut_c;
		vec4 prisma = (col_lut_a + col_lut_b + col_lut_c);
		col_final = chroma / prisma;
	} else {
		float move;
		vec4 chroma;
		vec4 prisma;
		for(float i = 0.0; i < ITERATIONS; ++i) {
			move = i * ITERATIONS_RECIPROCAL;
			vec4 lut = texture2D(u_chromaber_prisma_lut, vec2(move, 0.0));
			chroma += texture2D(gm_BaseTexture, uv - (move*2.0-1.0) * dist) * lut;
			prisma += lut;
		}
		col_final = chroma / prisma;
	}
	return saturate(col_final);
}

void main() {
	gl_FragColor = chromaberration_fx(v_vTexcoord);
}
