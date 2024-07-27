
/*------------------------------------------------------------------
You cannot redistribute this pixel shader source code anywhere.
Only compiled binary executables. Don't remove this notice, please.
Copyright (C) 2022 Mozart Junior (FoxyOfJungle). Kazan Games Ltd.
Website: https://foxyofjungle.itch.io/ | Discord: @foxyofjungle
-------------------------------------------------------------------*/

varying vec2 v_vTexcoord;
uniform vec2 u_texel_size;

// better, temporally stable box filtering
// [Jimenez14] http://goo.gl/eomGso
vec4 sample_box13(sampler2D tex, vec2 uv) {
    vec4 A = texture2D(tex, uv + u_texel_size * vec2(-1.0, -1.0));
    vec4 B = texture2D(tex, uv + u_texel_size * vec2( 0.0, -1.0));
    vec4 C = texture2D(tex, uv + u_texel_size * vec2( 1.0, -1.0));
    vec4 D = texture2D(tex, uv + u_texel_size * vec2(-0.5, -0.5));
    vec4 E = texture2D(tex, uv + u_texel_size * vec2( 0.5, -0.5));
    vec4 F = texture2D(tex, uv + u_texel_size * vec2(-1.0,  0.0));
    vec4 G = texture2D(tex, uv);
    vec4 H = texture2D(tex, uv + u_texel_size * vec2( 1.0,  0.0));
    vec4 I = texture2D(tex, uv + u_texel_size * vec2(-0.5,  0.5));
    vec4 J = texture2D(tex, uv + u_texel_size * vec2( 0.5,  0.5));
    vec4 K = texture2D(tex, uv + u_texel_size * vec2(-1.0,  1.0));
    vec4 L = texture2D(tex, uv + u_texel_size * vec2( 0.0,  1.0));
    vec4 M = texture2D(tex, uv + u_texel_size * vec2( 1.0,  1.0));
	
    vec2 div = 0.25 * vec2(0.5, 0.125); //(1.0 / 4.0)
	
    vec4 col = (D + E + I + J) * div.x;
	    col += (A + B + G + F) * div.y;
	    col += (B + C + H + G) * div.y;
	    col += (F + G + L + K) * div.y;
	    col += (G + H + M + L) * div.y;
    return col;
}

void main() {
	gl_FragColor = sample_box13(gm_BaseTexture, v_vTexcoord);
}
