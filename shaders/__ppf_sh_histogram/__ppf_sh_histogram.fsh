
/*------------------------------------------------------------------
You cannot redistribute this pixel shader source code anywhere.
Only compiled binary executables. Don't remove this notice, please.
Copyright (C) 2022 Mozart Junior (FoxyOfJungle). Kazan Games Ltd.
Website: https://foxyofjungle.itch.io/ | Discord: @foxyofjungle
-------------------------------------------------------------------*/

varying vec2 v_vPosition;
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec4 u_pos_res;
uniform sampler2D u_data_tex;

vec3 blend(vec3 source, vec3 dest) {
	return source + dest - source * dest;
}

const vec3 lum_weights = vec3(0.299, 0.587, 0.114);

// WIP

void main() {
	vec2 uv = (v_vPosition-u_pos_res.xy) / u_pos_res.zw; //v_vTexcoord;
	vec4 col_tex = texture2D(gm_BaseTexture, v_vTexcoord) * v_vColour;
	vec3 col_data = texture2D(u_data_tex, vec2(uv.x, 0.0)).rgb;
	
	vec3 red = vec3(1.0, 0.0, 0.0) * step(1.0-uv.y, col_data.r);
	vec3 green = vec3(0.0, 1.0, 0.0) * step(1.0-uv.y, col_data.g);
	vec3 blue = vec3(0.0, 0.0, 1.0) * step(1.0-uv.y, col_data.b);
	
	col_tex.rgb = blend(col_tex.rgb, red);
	col_tex.rgb = blend(col_tex.rgb, green);
	col_tex.rgb = blend(col_tex.rgb, blue);
	
	gl_FragColor = col_tex;
}
