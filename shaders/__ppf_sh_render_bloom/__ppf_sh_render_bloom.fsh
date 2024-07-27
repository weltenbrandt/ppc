
/*------------------------------------------------------------------
You cannot redistribute this pixel shader source code anywhere.
Only compiled binary executables. Don't remove this notice, please.
Copyright (C) 2023 Mozart Junior (FoxyOfJungle). Kazan Games Ltd.
Website: https://foxyofjungle.itch.io/ | Discord: @foxyofjungle
-------------------------------------------------------------------*/

varying vec2 v_vTexcoord;
varying vec2 v_TexelSize;
varying vec2 v_Res;

uniform vec2 u_time_n_intensity;
uniform float u_bloom_threshold;
uniform float u_bloom_intensity;
uniform vec3 u_bloom_color;
uniform float u_bloom_white_amount;
uniform float u_bloom_dirt_enable;
uniform float u_bloom_dirt_intensity;
uniform float u_bloom_dirt_scale;
uniform float u_bloom_dirt_can_distort;
uniform float u_bloom_debug1;
uniform float u_bloom_debug2;
uniform sampler2D u_bloom_dirt_tex;
uniform sampler2D u_bloom_tex;

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

// >> effect
#region Common
vec3 saturate(vec3 x) {
    return clamp(x, 0.0, 1.0);
}

vec2 tiling_mirror(vec2 uv, vec2 tiling) {
	uv = (uv - 0.5) * tiling + 0.5;
	uv = abs(mod(uv - 1.0, 2.0) - 1.0);
	return uv;
}

vec4 sample_box4(sampler2D tex, vec2 uv, float delta) {
	vec4 d = v_TexelSize.xyxy * vec2(-delta, delta).xxyy;
	vec4 col;
	col =  (texture2D(tex, uv + d.xy));
	col += (texture2D(tex, uv + d.zy));
	col += (texture2D(tex, uv + d.xw));
	col += (texture2D(tex, uv + d.zw));
	return col * 0.25; // (1.0 / 4.0)
}

const vec3 lum_weights = vec3(0.2126, 0.7152, 0.0722);
float get_luminance(vec3 color) {
	return dot(color, lum_weights);
}

vec3 tonemap_jodie_reinhard(vec3 c, float lum) {
	vec3 tc = c / (c + 1.0);
	return mix(c / (lum + 1.0), tc, tc);
}

vec3 blend(vec3 source, vec3 dest) {
	return source + dest - source * dest;
}

vec2 get_aspect_ratio(vec2 size, vec2 res) {
	float aspect_ratio = res.x / res.y;
	return (res.x > res.y)
	? vec2(size.x * aspect_ratio, size.y)
	: vec2(size.x, size.y / aspect_ratio);
}
#endregion

void main() {
	vec2 uv = v_vTexcoord;
	vec4 col_tex = texture2D(gm_BaseTexture, uv);
	
	vec3 bloom = texture2D(u_bloom_tex, uv).rgb;
	vec3 raw_bloom = bloom;
	float bloom_lum = get_luminance(bloom);
	
	col_tex.rgb = mix(col_tex.rgb, bloom, step(0.5, u_bloom_debug1));
	
	bloom *= u_bloom_color * u_bloom_intensity * u_time_n_intensity.y;
	bloom = tonemap_jodie_reinhard(bloom, get_luminance(bloom));
	bloom = mix(bloom, vec3(1.0), bloom_lum * u_bloom_white_amount * u_time_n_intensity.y);
	
	if (u_bloom_dirt_enable > 0.5) {
		if (u_lens_distortion_enable > 0.5) {
			uv = mix(uv, lens_distortion_uv(uv, u_time_n_intensity.y), step(0.5, u_bloom_dirt_can_distort));
		}
		vec2 size = get_aspect_ratio(vec2(u_bloom_dirt_scale), v_Res);
		vec2 uv2 = tiling_mirror(uv, size);
		vec3 col_dirt = texture2D(u_bloom_dirt_tex, uv2).rgb * bloom * u_bloom_dirt_intensity * 5.0;
		col_dirt = tonemap_jodie_reinhard(col_dirt, get_luminance(bloom));
		bloom = blend(bloom, col_dirt);
	}
	
	bloom = saturate(bloom);
	col_tex.rgb = mix(blend(col_tex.rgb, bloom), raw_bloom, step(0.5, u_bloom_debug2));
	gl_FragColor = col_tex;
}
