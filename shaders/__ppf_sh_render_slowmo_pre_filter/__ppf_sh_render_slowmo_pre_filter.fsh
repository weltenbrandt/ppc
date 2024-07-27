
/*------------------------------------------------------------------
You cannot redistribute this pixel shader source code anywhere.
Only compiled binary executables. Don't remove this notice, please.
Copyright (C) 2023 Mozart Junior (FoxyOfJungle). Kazan Games Ltd.
Website: https://foxyofjungle.itch.io/ | Discord: @foxyofjungle
-------------------------------------------------------------------*/

varying vec2 v_vTexcoord;

uniform float u_slowmo_threshold;
uniform float u_slowmo_force;

vec3 threshold(vec3 color) {
	return clamp((color - u_slowmo_threshold) * (1.0 + u_slowmo_threshold * u_slowmo_force), 0.0, 1.0);
}
		
void main() {
	gl_FragColor = vec4(threshold(texture2D(gm_BaseTexture, v_vTexcoord).rgb), 1.0);
}
