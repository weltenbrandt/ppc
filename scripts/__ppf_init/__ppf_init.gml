
#macro PPFX_VERSION "v4.0.3"
#macro PPFX_RELEASE_DATE "September, 26, 2023"

show_debug_message($"Post-Processing FX {PPFX_VERSION} | Copyright (C) 2023 FoxyOfJungle");

// Feather disable all

// HDR
enum PPF_HDR_TEX_FORMAT {
	RGBA32 = surface_rgba32float,
	RGBA16 = surface_rgba16float,
}
global.__ppf_main_texture_format_base = surface_rgba8unorm;
global.__ppf_main_texture_format = global.__ppf_main_texture_format_base;


#region Verify Compatibility
if (PPFX_CFG_HARDWARE_CHECKING) {
	if (!shaders_are_supported()) {
		var _info = os_get_info(), _gpu = "", _is64 = "";
		switch(os_type) {
			case os_windows:
			case os_uwp: _gpu = $"GPU: {_info[? "video_adapter_description"]} | Dedicated Memory: {_info[? "video_adapter_dedicatedvideomemory"]/1024/1024} MB"; break;
			case os_android: _gpu = $"OpenGL: {_info[? "GL_VERSION"]} | GLSL: {_info[? "GL_SHADING_LANGUAGE_VERSION"]} | Renderer: {_info[? "GL_RENDERER"]}"; break;
			case os_ios:
			case os_tvos:
			case os_linux:
			case os_macosx: _gpu = $"{_info[? "gl_vendor_string"]} | {_info[? "gl_renderer_string"]} | {_info[? "gl_version_string"]}"; break;
			case os_xboxseriesxs: _gpu = $"{_info[? "video_d3d12_currentrt"]}"; break;
			default: _gpu = "Unknown Device."; break;
		}
		_is64 = "is64bit: " + string(_info[? "is64bit"]) + " | ";
		var _trace = "\"Post-Processing FX\" will not work. Device does not support shaders.\n\n" + _is64 + _gpu;
		__ppf_trace(_trace, 1);
		show_message_async(_trace);
	}
}

// HDR compatibility verification
if (PPFX_CFG_HDR_ENABLE) {
	if (surface_format_is_supported(PPFX_CFG_HDR_TEX_FORMAT)) {
		global.__ppf_main_texture_format = PPFX_CFG_HDR_TEX_FORMAT;
	} else {
		var _format = "N/A";
		switch(PPFX_CFG_HDR_TEX_FORMAT) {
			case PPF_HDR_TEX_FORMAT.RGBA32: _format = "RGBA32" break;
			case PPF_HDR_TEX_FORMAT.RGBA16: _format = "RGBA16" break;
		}
		__ppf_trace($"Error: {_format} Texture format is not supported on current platform!\nUsing RGBA8 (default). HDR disabled.", 1);
		global.__ppf_main_texture_format = global.__ppf_main_texture_format_base;
	}
}
#endregion
