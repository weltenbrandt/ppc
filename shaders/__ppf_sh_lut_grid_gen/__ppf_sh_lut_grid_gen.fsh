
/*------------------------------------------------------------------
You cannot redistribute this pixel shader source code anywhere.
Only compiled binary executables. Don't remove this notice, please.
Copyright (C) 2023 Mozart Junior (FoxyOfJungle). Kazan Games Ltd.
Website: https://foxyofjungle.itch.io/ | Discord: @foxyofjungle
-------------------------------------------------------------------*/

varying vec2 v_vPosition;
varying vec4 v_vColour;

const vec2 pos = vec2(0.0);
uniform vec2 u_size;
uniform vec2 u_squares;

void main() {
	vec2 uv = (v_vPosition-pos.xy) / u_size.xy;
	
	vec2 cell = vec2(floor(vec2(uv.x, uv.y) * u_squares));
	float idx = cell.y * u_squares.x + cell.x;
	
	vec3 col;
	col.rg = fract(uv.xy * u_squares.xy);
	col.b = idx / (u_squares.x*u_squares.y-1.0);
	
	gl_FragColor = vec4(col, 1.0);
}
