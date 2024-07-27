
/// Feather ignore all

/// @desc Generate color array to be usable in Post-Processing FX.
/// @param {Real} color The color. Example: c_white, make_color_rgb(), make_color_hsv(), #ffffff.
/// @returns {Array<Real>}
function make_color_ppfx(color) {
	gml_pragma("forceinline");
	return [color_get_red(color)/255, color_get_green(color)/255, color_get_blue(color)/255];
}

/// @desc Generate HDR color array to be usable in Post-Processing FX.
/// @param {Real} color The color. Example: c_white, make_color_rgb, make_color_hsv, #ffffff.
/// @param {Real} intensity The color multiplier intensity. 1 is default.
/// @returns {Array<Real>}
function make_color_hdr_ppfx(color, intensity=1) {
	gml_pragma("forceinline");
	return [(color_get_red(color)/255)*intensity, (color_get_green(color)/255)*intensity, (color_get_blue(color)/255)*intensity];
}

/// @desc Generate color array to be usable in Post-Processing FX. Only RGB colors supported.
/// @param {Real} red Red Color
/// @param {Real} green Green Color
/// @param {Real} blue Blur Color
/// @returns {Array<Real>}
function make_color_rgb_ppfx(red, green, blue) {
	gml_pragma("forceinline");
	return [red/255, green/255, blue/255];
}

/// @desc Generate color array to be usable in Post-Processing FX. Only RGB colors supported. With intensity, for HDR.
/// This can be useful for the Channel Mixer effect, as make_color_rgb() from GameMaker does not support values above 255.
/// @param {Real} red Red Color
/// @param {Real} green Green Color
/// @param {Real} blue Blur Color
/// @returns {Array<Real>}
function make_color_rgb_hdr_ppfx(red, green, blue, intensity) {
	gml_pragma("forceinline");
	return [(red/255)*intensity, (green/255)*intensity, (blue/255)*intensity];
}


// --------------------------------------------------------------------------

/// @ignore
/// @func __ppf_trace(text)
/// @param {String} text
function __ppf_trace(text, level=1) {
	gml_pragma("forceinline");
	if (level <= PPFX_CFG_TRACE_LEVEL) show_debug_message($"# PPFX >> {text}");
}

/// @ignore
function __ppf_exception(condition, text) {
	gml_pragma("forceinline");
	if (PPFX_CFG_ERROR_CHECKING_ENABLE && condition) {
		// the code below doesn't always run...
		var _stack = debug_get_callstack(4);
		var _context = _stack[array_length(_stack)-2];
		var _separator = string_repeat("-", 92);
		show_error($"{_separator}\nPost-Processing FX >> {instanceof(self)}  |  {_context}\n\n\n{text}\n\n\n{_separator}\n\n", true);
	}
}

/// @ignore
function __ppf_get_context() {
	if (PPFX_CFG_TRACE_LEVEL >= 3) {
		return $" | Origin: {instance_exists(other) ? object_get_name(other.object_index) : instanceof(other)}";
	}
	return "";
}

/// @ignore
function __ppf_relerp(oldmin, oldmax, value, newmin, newmax) {
	return (value-oldmin) / (oldmax-oldmin) * (newmax-newmin) + newmin;
}

/// @ignore
function __ppf_linearstep(minv, maxv, value) {
	return (value - minv) / (maxv - minv);
}

/// @ignore
function __ppf_array_copy_all(from, to) {
	array_copy(to, 0, from, 0, array_length(from));
}

/// @ignore
function __ppf_surface_delete_array(surfaces_array, start=0) {
	gml_pragma("forceinline");
	var isize = array_length(surfaces_array)-start, i = isize-1+start, _surf = -1;
	repeat(isize) {
		_surf = surfaces_array[i];
		if (_surf != -1 && surface_exists(_surf)) surface_free(_surf);
		--i;
	}
}

/// @ignore
function __ppf_surface_delete(surface_index) {
	gml_pragma("forceinline");
	if (surface_exists(surface_index)) surface_free(surface_index);
}

/// @desc Check if is undefined (for ppfx usage only)
/// @param {Any} val Value
/// @returns {Bool}
/// @ignore
function __ppf_is_undefined(val) {
	return (val < 0 || val == undefined);
}
