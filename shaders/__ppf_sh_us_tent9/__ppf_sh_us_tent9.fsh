
/*------------------------------------------------------------------
You cannot redistribute this pixel shader source code anywhere.
Only compiled binary executables. Don't remove this notice, please.
Copyright (C) 2022 Mozart Junior (FoxyOfJungle). Kazan Games Ltd.
Website: https://foxyofjungle.itch.io/ | Discord: @foxyofjungle
-------------------------------------------------------------------*/

varying vec2 v_vTexcoord;
uniform vec2 u_texel_size;

// 9-tap bilinear upsampler (tent filter)
vec4 upsample_tent(sampler2D tex, vec2 uv) {
	vec4 d = u_texel_size.xyxy * vec4(1.0, 1.0, -1.0, 0.0);
	
	vec4 col;
	col =  texture2D(tex, uv - d.xy);
	col += texture2D(tex, uv - d.wy) * 2.0;
	col += texture2D(tex, uv - d.zy);
	
	col += texture2D(tex, uv + d.zw) * 2.0;
	col += texture2D(tex, uv) * 4.0;
	col += texture2D(tex, uv + d.xw) * 2.0;
	
	col += texture2D(tex, uv + d.zy);
	col += texture2D(tex, uv + d.wy) * 2.0;
	col += texture2D(tex, uv + d.xy);
	
	return col * 0.0625; // ((1.0 / 16.0))
}

void main() {
	gl_FragColor = upsample_tent(gm_BaseTexture, v_vTexcoord);
	gl_FragColor = clamp(gl_FragColor, 0.0, 1.0);
}
