
/*------------------------------------------------------------------
You cannot redistribute this pixel shader source code anywhere.
Only compiled binary executables. Don't remove this notice, please.
Copyright (C) 2023 Mozart Junior (FoxyOfJungle). Kazan Games Ltd.
Website: https://foxyofjungle.itch.io/ | Discord: @foxyofjungle
-------------------------------------------------------------------*/

varying vec2 v_vTexcoord;

uniform highp vec2 u_time_n_intensity;

uniform float u_texture_overlay_enable;
uniform float u_texture_overlay_intensity;
uniform sampler2D u_texture_overlay_tex;
uniform bool texture_overlay_is_outside;
uniform float u_texture_overlay_scale;
uniform int u_texture_overlay_blendmode;
uniform float u_texture_overlay_can_distort;

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
vec3 saturate(vec3 x) {
	return clamp(x, 0.0, 1.0);
}

vec4 blend(vec4 source, vec4 dest) {
	return dest * dest.a + source * (1.0-dest.a);
}

// blendmodes (c) 2015 Jamie Owen
vec3 blendmode_add(vec3 src, vec3 dst) {
    return src + dst;
}

vec3 blendmode_subtract(vec3 src, vec3 dst) {
    return src - dst;
}

vec3 blendmode_multiply(vec3 src, vec3 dst) {
    return src * dst;
}

vec3 blendmode_divide(vec3 src, vec3 dst) {
    return src / dst;
}

vec3 blendmode_color_burn(vec3 src, vec3 dst) {
    return 1.0 - ((1.0 - dst) / max(src, 0.001));
}
#endregion

vec4 texture_overlay_fx(vec4 color, vec2 uv, vec2 uvl) {
	vec2 uv2 = mix(uv, uvl, step(0.5, u_texture_overlay_can_distort));
	
	uv2 = (uv2 - 0.5) * (1.0-u_texture_overlay_scale+1.0) + 0.5;
	
	vec4 source_col = color;
	vec4 dest_col = texture2D(u_texture_overlay_tex, uv2);
	vec4 blended_col = vec4(source_col.rgb, dest_col.a);
	
	if (u_texture_overlay_blendmode == 0) {
		blended_col = dest_col;
	} else
	if (u_texture_overlay_blendmode == 1) {
		blended_col.rgb = blendmode_add(blended_col.rgb, dest_col.rgb);
	} else
	if (u_texture_overlay_blendmode == 2) {
		blended_col.rgb = blendmode_subtract(blended_col.rgb, dest_col.rgb);
	}
	if (u_texture_overlay_blendmode == 3) {
		blended_col.rgb = blendmode_multiply(blended_col.rgb, dest_col.rgb);
	} else
	if (u_texture_overlay_blendmode == 4) {
		blended_col.rgb = blendmode_divide(blended_col.rgb, dest_col.rgb);
	} else
	if (u_texture_overlay_blendmode == 5) {
		blended_col.rgb = blendmode_color_burn(blended_col.rgb, dest_col.rgb);
	}
	// add chroma key later...
	blended_col.rgb = saturate(blended_col.rgb);
	
	return mix(source_col, blend(source_col, blended_col), u_texture_overlay_intensity);
}

void main() {
	vec2 uv = v_vTexcoord;
	// [d] lens distortion
	vec2 uvl = uv;
	if (u_lens_distortion_enable > 0.5) uvl = lens_distortion_uv(uv, u_time_n_intensity.y);
	// texture overlay
	gl_FragColor = texture_overlay_fx(texture2D(gm_BaseTexture, uv), uv, uvl);
}
