
/*------------------------------------------------------------------
You cannot redistribute this pixel shader source code anywhere.
Only compiled binary executables. Don't remove this notice, please.
Copyright (C) 2023 Mozart Junior (FoxyOfJungle). Kazan Games Ltd.
With help of Tobias Fleischer
Website: https://foxyofjungle.itch.io/ | Discord: @foxyofjungle
-------------------------------------------------------------------*/

precision highp float;

varying vec2 v_vTexcoord;
varying vec2 v_TexelSize;

uniform float u_gaussian_amount;
uniform float u_gaussian_angle;

const float radius = 20.0;
const float dev = 7.0;
const float mean = 0.398942280401 / dev;

float coeff(float x) {
	return mean * exp(-x * x * 0.5 / (dev * dev));
}

void main() {
	vec2 uv = v_vTexcoord;
	vec4 sum = vec4(0.0);
	
	float dir = radians(u_gaussian_angle);
	vec2 direction = vec2(cos(dir), sin(dir));
	vec2 move = v_TexelSize * direction;
	
	for (float i = -radius; i <= radius; i++) {
		sum += coeff(i) * texture2D(gm_BaseTexture, uv + move * i * u_gaussian_amount);
	}
	gl_FragColor = sum;
}
