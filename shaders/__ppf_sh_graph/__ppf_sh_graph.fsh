
varying vec2 v_vPosition;
varying vec4 v_vColour;

uniform vec4 u_pos_res;
uniform vec2 u_grid_size;
uniform int u_background_index;

#region Color Spaces

//#define GAMMA 2.2

///// @desc Converts gamma space color to linear space.
//vec3 GammaToLinear(vec3 rgb) {
//	return pow(rgb, vec3(GAMMA));
//}

///// @desc Converts linear space color to gamma space.
//vec3 LinearToGamma(vec3 rgb) {
//	return pow(rgb, vec3(1.0 / GAMMA));
//}

const float YRGB_EPSILON = 1e-4;

vec3 HUEtoRGB(in float hue) {
	// Hue [0..1] to RGB [0..1]
	// See http://www.chilliant.com/rgb2hsv.html
	vec3 rgb = abs(hue * 6. - vec3(3, 2, 4)) * vec3(1, -1, -1) + vec3(-1, 2, 2);
	return clamp(rgb, 0., 1.);
}

vec3 RGBtoHCV(in vec3 rgb) {
	// RGB [0..1] to Hue-Chroma-Value [0..1]
	// Based on work by Sam Hocevar and Emil Persson
	vec4 p = (rgb.g < rgb.b) ? vec4(rgb.bg, -1., 2. / 3.) : vec4(rgb.gb, 0., -1. / 3.);
	vec4 q = (rgb.r < p.x) ? vec4(p.xyw, rgb.r) : vec4(rgb.r, p.yzx);
	float c = q.x - min(q.w, q.y);
	float h = abs((q.w - q.y) / (6. * c + YRGB_EPSILON) + q.z);
	return vec3(h, c, q.x);
}

vec3 HSVtoRGB(in vec3 hsv) {
	// Hue-Saturation-Value [0..1] to RGB [0..1]
	vec3 rgb = HUEtoRGB(hsv.x);
	return ((rgb - 1.) * hsv.y + 1.) * hsv.z;
}

vec3 HSLtoRGB(in vec3 hsl) {
	// Hue-Saturation-Lightness [0..1] to RGB [0..1]
	vec3 rgb = HUEtoRGB(hsl.x);
	float c = (1. - abs(2. * hsl.z - 1.)) * hsl.y;
	return (rgb - 0.5) * c + hsl.z;
}

vec3 RGBtoHSV(in vec3 rgb) {
	// RGB [0..1] to Hue-Saturation-Value [0..1]
	vec3 hcv = RGBtoHCV(rgb);
	float s = hcv.y / (hcv.z + YRGB_EPSILON);
	return vec3(hcv.x, s, hcv.z);
}

vec3 RGBtoHSL(in vec3 rgb) {
	// RGB [0..1] to Hue-Saturation-Lightness [0..1]
	vec3 hcv = RGBtoHCV(rgb);
	float z = hcv.z - hcv.y * 0.5;
	float s = hcv.y / (1. - abs(z * 2. - 1.) + YRGB_EPSILON);
	return vec3(hcv.x, s, z);
}

#endregion

const float grid_alpha = 0.1;

void main() {
	vec2 position = v_vPosition-u_pos_res.xy;
	vec2 uv = position / u_pos_res.zw;
	
	vec3 col;
	if (u_background_index == 0) {
		col = HSVtoRGB(vec3(uv.x, 0.6, 2.0*abs(uv.y-0.5)));
	} else
	if (u_background_index == 1) {
		col = vec3(2.0*abs(uv.y-0.5) * uv.x);
	}
	
	float grid = dot(step(mod(position.xyxy, u_grid_size.xyxy), vec4(1.0)), vec4(grid_alpha));
	col += grid;
	
	gl_FragColor = vec4(col, v_vColour.a);
}
