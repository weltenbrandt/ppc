
/// Feather ignore all

#region Enums
/// @ignore
// Order doesn't 'really' matter, but this is the default rendering order
enum PPFX_STACK {
		BASE,
	HQ4X,
	FXAA,
	BLOOM,
	SLOW_MOTION,
	SUNSHAFTS,
	DEPTH_OF_FIELD,
	MOTION_BLUR,
	BLUR_RADIAL,
		COLOR_GRADING,
	TEXTURE_OVERLAY,
	PALETTE_SWAP,
	BLUR_KAWASE,
	BLUR_GAUSSIAN,
	VHS,
	CHROMATIC_ABERRATION,
		FINAL,
	COMPARE,
	__SIZE,
}

// Order must match __ppf_effects_names array
enum FX_EFFECT {
	ROTATION,
	ZOOM,
	SHAKE,
	LENS_DISTORTION,
	PIXELIZE,
	SWIRL,
	PANORAMA,
	SINE_WAVE,
	GLITCH,
	SHOCKWAVES,
	DISPLACEMAP,
	WHITE_BALANCE,
	BORDER,
	HQ4X,
	FXAA,
	BLOOM,
	SLOW_MOTION,
	SUNSHAFTS,
	DEPTH_OF_FIELD,
	MOTION_BLUR,
	BLUR_RADIAL,
	LUT,
	EXPOSURE,
	POSTERIZATION,
	BRIGHTNESS,
	CONTRAST,
	CHANNEL_MIXER,
	SHADOW_MIDTONE_HIGHLIGHT,
	LIFT_GAMMA_GAIN,
	SATURATION,
	HUE_SHIFT,
	COLORIZE,
	COLOR_TINT,
	INVERT_COLORS,
	TONE_MAPPING,
	TEXTURE_OVERLAY,
	PALETTE_SWAP,
	BLUR_KAWASE,
	BLUR_GAUSSIAN,
	VHS,
	COLOR_CURVES,
	CHROMATIC_ABERRATION,
	MIST,
	SPEEDLINES,
	DITHERING,
	NOISE_GRAIN,
	VIGNETTE,
	NES_FADE,
	FADE,
	SCANLINES,
	CINEMA_BARS,
	COLOR_BLINDNESS,
	CHANNELS,
	COMPARE,
	__SIZE,
}

// Order must match FX_EFFECT enum
global.__ppf_effects_names = [
	"rotation",
	"zoom",
	"shake",
	"lens_distortion",
	"pixelize",
	"swirl",
	"panorama",
	"sine_wave",
	"glitch",
	"shockwaves",
	"displacemap",
	"white_balance",
	"border",
	"hq4x",
	"fxaa",
	"bloom",
	"slow_motion",
	"sunshafts",
	"depth_of_field",
	"motion_blur",
	"radial_blur",
	"lut",
	"exposure",
	"posterization",
	"brightness",
	"contrast",
	"channel_mixer",
	"shadow_midtone_highlight",
	"lift_gamma_gain",
	"saturation",
	"hue_shift",
	"colorize",
	"color_tint",
	"invert_colors",
	"tone_mapping",
	"texture_overlay",
	"palette_swap",
	"kawase_blur",
	"gaussian_blur",
	"vhs",
	"color_curves",
	"chromatic_aberration",
	"mist",
	"speedlines",
	"dithering",
	"noise_grain",
	"vignette",
	"nes_fade",
	"fade",
	"scanlines",
	"cinema_bars",
	"color_blindness",
	"channels",
	"compare",
];

#endregion


#region Shared Stacks

// Shared stacks are NOT reordered by PPFX_System(). The order is defined by the PPFX_STACK enum

/// @ignore
function __ppf_st_super_class() {
	stack_name = "N/A";
	stack_index = -1; // PPFX_STACK.
	shader_index = -1; // sh_test
}

#region Base

/// @ignore
function __ST_Base() : __ppf_st_super_class() constructor {
	stack_name = "base";
	stack_index = PPFX_STACK.BASE;
	shader_index = __ppf_sh_render_base;
	uni_resolution = shader_get_uniform(shader_index, "u_resolution");
	uni_time_n_intensity = shader_get_uniform(shader_index, "u_time_n_intensity");
	
	uni_rotation_enable = shader_get_uniform(shader_index, "u_rotation_enable");
	uni_zoom_enable = shader_get_uniform(shader_index, "u_zoom_enable");
	uni_shake_enable = shader_get_uniform(shader_index, "u_shake_enable");
	uni_lens_distortion_enable = shader_get_uniform(shader_index, "u_lens_distortion_enable");
	uni_pixelize_enable = shader_get_uniform(shader_index, "u_pixelize_enable");
	uni_swirl_enable = shader_get_uniform(shader_index, "u_swirl_enable");
	uni_panorama_enable = shader_get_uniform(shader_index, "u_panorama_enable");
	uni_sinewave_enable = shader_get_uniform(shader_index, "u_sinewave_enable");
	uni_glitch_enable = shader_get_uniform(shader_index, "u_glitch_enable");
	uni_shockwaves_enable = shader_get_uniform(shader_index, "u_shockwaves_enable");
	uni_displacemap_enable = shader_get_uniform(shader_index, "u_displacemap_enable");
	uni_white_balance_enable = shader_get_uniform(shader_index, "u_white_balance_enable");
	
	static Start = function(renderer, surface_width, surface_height, time, global_intensity) {
		// create stack surface
		renderer.__create_stack_surface(surface_width, surface_height, stack_name);
		
		// start stack
		surface_set_target(renderer.__stack_surface[renderer.__stack_index]);
			draw_clear_alpha(c_black, 0);
			gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
			shader_set(shader_index);
			shader_set_uniform_f(uni_resolution, surface_width, surface_height);
			shader_set_uniform_f(uni_time_n_intensity, time, global_intensity);
			// reseting effects to disabled (later they will overwrite this)
			shader_set_uniform_f(uni_rotation_enable, false);
			shader_set_uniform_f(uni_zoom_enable, false);
			shader_set_uniform_f(uni_shake_enable, false);
			shader_set_uniform_f(uni_lens_distortion_enable, false);
			shader_set_uniform_f(uni_pixelize_enable, false);
			shader_set_uniform_f(uni_swirl_enable, false);
			shader_set_uniform_f(uni_panorama_enable, false);
			shader_set_uniform_f(uni_sinewave_enable, false);
			shader_set_uniform_f(uni_glitch_enable, false);
			shader_set_uniform_f(uni_shockwaves_enable, false);
			shader_set_uniform_f(uni_displacemap_enable, false);
			shader_set_uniform_f(uni_white_balance_enable, false);
	}
	
	static End = function(renderer, surface_width, surface_height, time, global_intensity) {
			// end stack
			draw_surface_stretched(renderer.__stack_surface[renderer.__stack_index-1], 0, 0, surface_width, surface_height);
			shader_reset();
			gpu_set_blendmode(bm_normal);
		surface_reset_target();
	}	
}

#endregion

#region Color Grading

/// @ignore
function __ST_ColorGrading() : __ppf_st_super_class() constructor {
	stack_name = "color_grading";
	stack_index = PPFX_STACK.COLOR_GRADING;
	shader_index = __ppf_sh_render_color_grading;
	uni_resolution = shader_get_uniform(shader_index, "u_resolution");
	uni_time_n_intensity = shader_get_uniform(shader_index, "u_time_n_intensity");
	
	uni_lut_enable = shader_get_uniform(shader_index, "u_lut_enable");
	uni_exposure_enable = shader_get_uniform(shader_index, "u_exposure_enable");
	uni_brightness_enable = shader_get_uniform(shader_index, "u_brightness_enable");
	uni_contrast_enable = shader_get_uniform(shader_index, "u_contrast_enable");
	uni_color_balance_enable = shader_get_uniform(shader_index, "u_color_balance_enable");
	uni_saturation_enable = shader_get_uniform(shader_index, "u_saturation_enable");
	uni_hueshift_enable = shader_get_uniform(shader_index, "u_hueshift_enable");
	uni_hueshift_hsv = shader_get_uniform(shader_index, "u_hueshift_hsv");
	uni_colortint_enable = shader_get_uniform(shader_index, "u_colortint_enable");
	uni_colorize_enable = shader_get_uniform(shader_index, "u_colorize_enable");
	uni_channel_mixer_enable = shader_get_uniform(shader_index, "u_channel_mixer_enable");
	uni_posterization_enable = shader_get_uniform(shader_index, "u_posterization_enable");
	uni_invert_colors_enable = shader_get_uniform(shader_index, "u_invert_colors_enable");
	uni_lift_gamma_gain_enable = shader_get_uniform(shader_index, "u_lift_gamma_gain_enable");
	uni_color_curves_enable = shader_get_uniform(shader_index, "u_curves_enable");
	uni_tone_mapping_enable = shader_get_uniform(shader_index, "u_tone_mapping_enable");
	
	static Start = function(renderer, surface_width, surface_height, time, global_intensity) {
		// create stack surface
		renderer.__create_stack_surface(surface_width, surface_height, stack_name);
		
		// start stack
		surface_set_target(renderer.__stack_surface[renderer.__stack_index]);
			draw_clear_alpha(c_black, 0);
			gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
			shader_set(shader_index);
			shader_set_uniform_f(uni_resolution, surface_width, surface_height);
			shader_set_uniform_f(uni_time_n_intensity, time, global_intensity);
			// reseting effects parameters (later they will overwrite this)
			shader_set_uniform_f(uni_lut_enable, false);
			shader_set_uniform_f(uni_exposure_enable, false);
			shader_set_uniform_f(uni_brightness_enable, false);
			shader_set_uniform_f(uni_contrast_enable, false);
			shader_set_uniform_f(uni_color_balance_enable, false);
			shader_set_uniform_f(uni_saturation_enable, false);
			shader_set_uniform_f(uni_hueshift_enable, false);
			shader_set_uniform_f(uni_hueshift_hsv, 0, 1, 1);
			shader_set_uniform_f(uni_colortint_enable, false);
			shader_set_uniform_f(uni_colorize_enable, false);
			shader_set_uniform_f(uni_channel_mixer_enable, false);
			shader_set_uniform_f(uni_posterization_enable, false);
			shader_set_uniform_f(uni_invert_colors_enable, false);
			shader_set_uniform_f(uni_lift_gamma_gain_enable, false);
			shader_set_uniform_f(uni_color_curves_enable, false);
			shader_set_uniform_f(uni_tone_mapping_enable, false);
	}
	
	static End = function(renderer, surface_width, surface_height, time, global_intensity) {
			// bake color grading stack into a lut (if needed)
			if (sprite_exists(renderer.__cg_linear_lut_sprite)) {
				var _linear_lut_sprite = renderer.__cg_linear_lut_sprite;
				if (!surface_exists(renderer.__cg_baked_lut_surf)) {
					renderer.__cg_baked_lut_surf = surface_create(sprite_get_width(_linear_lut_sprite), sprite_get_height(_linear_lut_sprite));
				}
				surface_set_target(renderer.__cg_baked_lut_surf);
				draw_sprite(_linear_lut_sprite, 0, 0, 0);
				surface_reset_target();
			}
			// end stack
			draw_surface_stretched(renderer.__stack_surface[renderer.__stack_index-1], 0, 0, surface_width, surface_height);
			shader_reset();
			gpu_set_blendmode(bm_normal);
		surface_reset_target();
	}
}

#endregion

#region Final

/// @ignore
function __ST_Final() : __ppf_st_super_class() constructor {
	stack_name = "final";
	stack_index = PPFX_STACK.FINAL;
	shader_index = __ppf_sh_render_final;
	uni_resolution = shader_get_uniform(shader_index, "u_resolution");
	uni_time_n_intensity = shader_get_uniform(shader_index, "u_time_n_intensity");
	uni_mist_enable = shader_get_uniform(shader_index, "u_mist_enable");
	uni_speedlines_enable = shader_get_uniform(shader_index, "u_speedlines_enable");
	uni_dither_enable = shader_get_uniform(shader_index, "u_dither_enable");
	uni_noise_grain_enable = shader_get_uniform(shader_index, "u_noise_grain_enable");
	uni_vignette_enable = shader_get_uniform(shader_index, "u_vignette_enable");
	uni_nes_fade_enable = shader_get_uniform(shader_index, "u_nes_fade_enable");
	uni_fade_enable = shader_get_uniform(shader_index, "u_fade_enable");
	uni_scanlines_enable = shader_get_uniform(shader_index, "u_scanlines_enable");
	uni_cinema_bars_enable = shader_get_uniform(shader_index, "u_cinama_bars_enable");
	uni_color_blindness_enable = shader_get_uniform(shader_index, "u_color_blindness_enable");
	uni_channels_enable = shader_get_uniform(shader_index, "u_channels_enable");
	uni_border_enable = shader_get_uniform(shader_index, "u_border_enable");
	// dependencies
	uni_d_lens_distortion_enable = shader_get_uniform(shader_index, "u_lens_distortion_enable");
	uni_d_lens_distortion_amount = shader_get_uniform(shader_index, "u_lens_distortion_amount");
	
	static Start = function(renderer, surface_width, surface_height, time, global_intensity) {
		// create stack surface
		renderer.__create_stack_surface(surface_width, surface_height, stack_name);
		
		// start stack
		surface_set_target(renderer.__stack_surface[renderer.__stack_index]);
			draw_clear_alpha(c_black, 0);
			gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
			shader_set(shader_index);
			shader_set_uniform_f(uni_resolution, surface_width, surface_height);
			shader_set_uniform_f(uni_time_n_intensity, time, global_intensity);
			// reseting effects to disabled (later they will overwrite this)
			shader_set_uniform_f(uni_mist_enable, false);
			shader_set_uniform_f(uni_speedlines_enable, false);
			shader_set_uniform_f(uni_dither_enable, false);
			shader_set_uniform_f(uni_noise_grain_enable, false);
			shader_set_uniform_f(uni_vignette_enable, false);
			shader_set_uniform_f(uni_nes_fade_enable, false);
			shader_set_uniform_f(uni_fade_enable, false);
			shader_set_uniform_f(uni_scanlines_enable, false);
			shader_set_uniform_f(uni_cinema_bars_enable, false);
			shader_set_uniform_f(uni_color_blindness_enable, false);
			shader_set_uniform_f(uni_channels_enable, false);
			shader_set_uniform_f(uni_border_enable, false);
			shader_set_uniform_f(uni_d_lens_distortion_enable, false);
			var _lens_effect = renderer.__get_effect_struct(FX_EFFECT.LENS_DISTORTION);
			if (_lens_effect != noone) {
				shader_set_uniform_f(uni_d_lens_distortion_enable, _lens_effect.settings.enabled);
				shader_set_uniform_f(uni_d_lens_distortion_amount, _lens_effect.settings.amount);
			}
	}
	
	static End = function(renderer, surface_width, surface_height, time, global_intensity) {
			// end stack
			draw_surface_stretched(renderer.__stack_surface[renderer.__stack_index-1], 0, 0, surface_width, surface_height);
			shader_reset();
			gpu_set_blendmode(bm_normal);
		surface_reset_target();
	}	
}

#endregion

#endregion


#region Effects

// These effects are reordered by PPFX_System(). Note that effects with shared stacks have the same order!

/// @ignore
function __ppf_fx_super_class() {
	effect_name = "N/A";
	stack_order = -1; // which order the effect will be rendered. effects within shared stacks have the same order
	stack_shared = false; // the effect shares the same stack with another
	can_change_order = true;
	order_was_changed = false;
	
	// override this, when needed
	static Draw = undefined; // for rendering
	static Clean = undefined; // for data clean
	static ExportData = undefined; // for profile stringify
	static GetEditorData = undefined; // for external effects with editor data
	
	/// @desc This function defines a new rendering order for this effect. The order defines which effect should renderize above or below another effect.
	/// @func SetOrder(new_order)
	/// @param {Real} new_order The new rendering order.
	static SetOrder = function(new_order) {
		if (!can_change_order) {
			__ppf_trace($"Unable to set order of '{effect_name}' effect to {new_order}. Using {stack_order}. Not allowed.", 1);
		} else
		if (new_order == PPFX_STACK.BASE || new_order == PPFX_STACK.COLOR_GRADING || new_order == PPFX_STACK.FINAL) {
			__ppf_trace($"The new order {new_order} of '{effect_name}' cannot be within the order of shared stacks. Using {stack_order}.", 1);
		} else {
			stack_order = new_order;
			order_was_changed = true;
		}
		return self;
	}
	
	/// @desc Returns the current stack order
	/// @func GetOrder()
	static GetOrder = function() {
		return stack_order;
	}
}

// Independent Effects

#region Bloom

/// @desc The Bloom effect makes bright areas in your image glow, making a realistic simulation of light.
/// @param {Bool} enabled Defines whether the effect starts active or not.
/// @param {Real} iterations Sets Bloom’s scattering, which is how far the effect reaches. Max: 16. recommended: 8.
/// @param {Real} threshold Set the level of brightness to filter out pixels under this level. 0 means full brightness. Values above 1 are HDR (which allows Bloom to glow without affecting the rest of the game's artwork).
/// @param {Real} intensity Set the strength of the Bloom filter. 0 to 5 recommended. There is not maximum amount.
/// @param {Real} color The color that is multiplied by the bloom’s final color. Default is c_white.
/// @param {Real} white_amount How close to white Bloom will look, in very saturated colors. 1 is full white.
/// @param {Bool} dirt_enable Defines whether to use dirt textures.
/// @param {Pointer.Texture} dirt_texture The texture id used for the Dirt Lens. Use sprite_get_texture() or surface_get_texture(). NOTE: You need to enable "Separate Texture Page" in sprite properties, otherwise you will get visual artifacts.
/// @param {Real} dirt_intensity The intensity of Dirt Lens. 0 to 3 recommended.
/// @param {Real} dirt_scale The scale of Dirt Lens. 0.25 to 3 recommended.
/// @param {Bool} dirt_can_distort If active, the dirt texture will distort according to the lens distortion effect.
/// @param {Real} downscale Sets the downscale of the Bloom, this affects the performance. 1 is full resolution = more resources needed, but look better.
/// @param {Bool} debug1 Allows you to see the final bloom result alone.
/// @param {Bool} debug2 Allows you to see exactly where the bloom is hitting the light parts.
function FX_Bloom(enabled, iterations=8, threshold=0.4, intensity=4.5, color=c_white, white_amount=0, dirt_enable=false, dirt_texture=undefined, dirt_intensity=2.5, dirt_scale=1, dirt_can_distort=false, downscale=1, debug1=false, debug2=false) : __ppf_fx_super_class() constructor {
	effect_name = "bloom";
	stack_order = PPFX_STACK.BLOOM;
	
	settings = {
		enabled : enabled,
		iterations : iterations,
		threshold : threshold,
		intensity : intensity,
		color : make_color_ppfx(color),
		white_amount : white_amount,
		dirt_enable : dirt_enable,
		dirt_texture : __ppf_is_undefined(dirt_texture) ? __PPF_ST.default_dirt_lens : dirt_texture,
		dirt_intensity : dirt_intensity,
		dirt_scale : dirt_scale,
		dirt_can_distort : dirt_can_distort,
		downscale : downscale,
		debug1 : debug1,
		debug2 : debug2,
	};
	
	uni_pre_filter_res = shader_get_uniform(__ppf_sh_render_bloom_pre_filter, "u_resolution");
	uni_pre_filter_threshold = shader_get_uniform(__ppf_sh_render_bloom_pre_filter, "u_bloom_threshold");
	uni_pre_filter_intensity = shader_get_uniform(__ppf_sh_render_bloom_pre_filter, "u_bloom_intensity");
	uni_resolution = shader_get_uniform(__ppf_sh_render_bloom, "u_resolution");
	uni_u_time_n_intensity = shader_get_uniform(__ppf_sh_render_bloom, "u_time_n_intensity");
	uni_threshold = shader_get_uniform(__ppf_sh_render_bloom, "u_bloom_threshold");
	uni_intensity = shader_get_uniform(__ppf_sh_render_bloom, "u_bloom_intensity");
	uni_colorr = shader_get_uniform(__ppf_sh_render_bloom, "u_bloom_color");
	uni_white_amount = shader_get_uniform(__ppf_sh_render_bloom, "u_bloom_white_amount");
	uni_dirt_enable = shader_get_uniform(__ppf_sh_render_bloom, "u_bloom_dirt_enable");
	uni_dirt_intensity = shader_get_uniform(__ppf_sh_render_bloom, "u_bloom_dirt_intensity");
	uni_dirt_scale = shader_get_uniform(__ppf_sh_render_bloom, "u_bloom_dirt_scale");
	uni_dirt_can_distort = shader_get_uniform(__ppf_sh_render_bloom, "u_bloom_dirt_can_distort");
	uni_dirt_tex = shader_get_sampler_index(__ppf_sh_render_bloom, "u_bloom_dirt_tex");
	uni_bloom_tex = shader_get_sampler_index(__ppf_sh_render_bloom, "u_bloom_tex");
	uni_debug1 = shader_get_uniform(__ppf_sh_render_bloom, "u_bloom_debug1");
	uni_debug2 = shader_get_uniform(__ppf_sh_render_bloom, "u_bloom_debug2");
	uni_downsample_box4_texel_size = shader_get_uniform(__ppf_sh_ds_box4, "u_texel_size");
	uni_downsample_box13_texel_size = shader_get_uniform(__ppf_sh_ds_box13, "u_texel_size");
	uni_upsample_tent_texel_size = shader_get_uniform(__ppf_sh_us_tent9, "u_texel_size");
	// dependencies
	uni_d_lens_distortion_enable = shader_get_uniform(__ppf_sh_render_bloom, "u_lens_distortion_enable");
	uni_d_lens_distortion_amount = shader_get_uniform(__ppf_sh_render_bloom, "u_lens_distortion_amount");
	
	bloom_surface = array_create(10, -1);
	bloom_downscale = 0;
	
	static Draw = function(renderer, screen_width, screen_height, time, global_intensity) {
		if (!settings.enabled || settings.intensity <= 0) exit;
		
		// settings
		var _iterations = clamp(settings.iterations, 2, 8),
			_ds = clamp(settings.downscale, 0.1, 1),
			_ww = screen_width*_ds, _hh = screen_height*_ds,
			_tex_format = renderer.__surface_tex_format;
		
		if (bloom_downscale != _ds) {
			Clean();
			bloom_downscale = _ds;
		}
		
		// pre filter (surface_blit)
		if (!surface_exists(bloom_surface[0])) {
			bloom_surface[0] = surface_create(_ww, _hh, _tex_format);
		}
		var _current_destination = bloom_surface[0];
		gpu_push_state();
		gpu_set_tex_filter(true);
		surface_set_target(_current_destination);
			shader_set(__ppf_sh_render_bloom_pre_filter);
			shader_set_uniform_f(uni_pre_filter_res, _ww, _hh);
			shader_set_uniform_f(uni_pre_filter_threshold, settings.threshold);
			shader_set_uniform_f(uni_pre_filter_intensity, settings.intensity);
			draw_surface_stretched(renderer.__stack_surface[renderer.__stack_index], 0, 0, _ww, _hh); // source (current stack)
			shader_reset();
		surface_reset_target();
		
		var _current_source = _current_destination;
		
		// downsampling (surface_blit)
		shader_set(__ppf_sh_ds_box13);
		var i = 1; // there is already a texture in slot 0
		repeat(_iterations) {
			_ww /= 2;
			_hh /= 2;
			_ww -= frac(_ww);
			_hh -= frac(_hh);
			//if (min(_ww, _hh) < 2) break;
			if (_ww < 2 || _hh < 2) break;
			if (!surface_exists(bloom_surface[i])) {
				bloom_surface[i] = surface_create(_ww, _hh, _tex_format);
			}
			_current_destination = bloom_surface[i];
				surface_set_target(_current_destination);
					shader_set_uniform_f(uni_downsample_box13_texel_size, 1/_ww, 1/_hh);
					draw_surface_stretched(_current_source, 0, 0, _ww, _hh);
				surface_reset_target();
			_current_source = _current_destination;
			++i;
		}
		shader_reset();
		
		// upsampling (surface_blit)
		gpu_set_blendmode(bm_max);
		shader_set(__ppf_sh_us_tent9);
		for(i -= 2; i >= 0; i--) { // 7, 6, 5, 4, 3, 2, 1, 0
			_current_destination = bloom_surface[i];
				_ww = surface_get_width(_current_destination);
				_hh = surface_get_height(_current_destination);
				surface_set_target(_current_destination);
					shader_set_uniform_f(uni_upsample_tent_texel_size, 1/_ww, 1/_hh);
					draw_surface_stretched(_current_source, 0, 0, _ww, _hh);
				surface_reset_target();
			_current_source = _current_destination;
		}
		shader_reset();
		
		// create stack surface
		renderer.__create_stack_surface(screen_width, screen_height, effect_name);
		
		// render
		surface_set_target(renderer.__stack_surface[renderer.__stack_index]);
			draw_clear_alpha(c_black, 0);
			gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
			
			shader_set(__ppf_sh_render_bloom);
			shader_set_uniform_f(uni_resolution, screen_width, screen_height);
			shader_set_uniform_f(uni_u_time_n_intensity, time, global_intensity);
			shader_set_uniform_f(uni_threshold, settings.threshold);
			shader_set_uniform_f(uni_intensity, settings.intensity);
			shader_set_uniform_f_array(uni_colorr, settings.color);
			shader_set_uniform_f(uni_white_amount, settings.white_amount);
			shader_set_uniform_f(uni_dirt_enable, settings.dirt_enable);
			shader_set_uniform_f(uni_dirt_intensity, settings.dirt_intensity);
			shader_set_uniform_f(uni_dirt_scale, settings.dirt_scale);
			shader_set_uniform_f(uni_dirt_can_distort, settings.dirt_can_distort);
			texture_set_stage(uni_bloom_tex, surface_get_texture(_current_destination));
			if (settings.dirt_texture != undefined) texture_set_stage(uni_dirt_tex, settings.dirt_texture);
			
			if (settings.dirt_can_distort) {
				var _lens_effect = renderer.__get_effect_struct(FX_EFFECT.LENS_DISTORTION);
				if (_lens_effect != noone) {
					shader_set_uniform_f(uni_d_lens_distortion_enable, _lens_effect.settings.enabled);
					shader_set_uniform_f(uni_d_lens_distortion_amount, _lens_effect.settings.amount);
				}
			}
			
			gpu_set_tex_repeat_ext(uni_dirt_tex, false);
			shader_set_uniform_f(uni_debug1, settings.debug1);
			shader_set_uniform_f(uni_debug2, settings.debug2);
			draw_surface_stretched(renderer.__stack_surface[renderer.__stack_index-1], 0, 0, screen_width, screen_height);
			shader_reset();
		surface_reset_target();
		
		gpu_pop_state();
	}
	
	static Clean = function() {
		__ppf_surface_delete_array(bloom_surface);
	}
	
	/// @ignore
	static ExportData = function() {
		return {
			name : instanceof(self),
			params : [settings.enabled, settings.iterations, settings.threshold, settings.intensity, ["color", settings.color], settings.white_amount, settings.dirt_enable, settings.dirt_texture, settings.dirt_intensity, settings.dirt_scale, settings.dirt_can_distort, settings.downscale, settings.debug1, settings.debug2],
		};
	}
}

#endregion

#region Depth of Field

/// @desc Is an effect that describes the extent to which objects that are more or less close to the plane of focus appear to be sharp.
/// This effect is given by an optical phenomenon called circles of confusion, which progressively increase as objects move away from the plane of focus;
/// @param {Bool} enabled Defines whether the effect starts active or not.
/// @param {Real} radius Focus radius.
/// @param {Real} intensity Bokeh bright intensity
/// @param {Bool} shaped Defines whether the bokeh is shaped.
/// @param {Real} blades_aperture Sets shape's edge number.
/// @param {Real} blades_angle Sets the shape angle, in degrees.
/// @param {Bool} use_zdepth Defines if the DOF will use a depth map.
/// @param {Pointer.Texture} zdepth_tex Depth map (Z-Buffer) texture.
/// @param {Real} focus_distance Set the distance from the Camera to the focus point.
/// @param {Real} focus_range Set the range, between the Camera sensor and the Camera lens. The larger the value is, the shallower the depth of field.
/// @param {Real} downscale Sets the downscale of the Depth of Field, this changes the performance.
/// @param {Bool} debug Allows you to see exactly where the Bokeh is blurring. Colors in cyan color are where the blur hits.
function FX_DepthOfField(enabled, radius=10, intensity=1, shaped=false, blades_aperture=6, blades_angle=0, use_zdepth=false, zdepth_tex=undefined, focus_distance=0.2, focus_range=0.02, downscale=0.5, debug=false) : __ppf_fx_super_class() constructor {
	effect_name = "depth_of_field";
	stack_order = PPFX_STACK.DEPTH_OF_FIELD;
	
	settings = {
		enabled : enabled,
		radius : radius,
		intensity : intensity,
		shaped : shaped,
		blades_aperture : blades_aperture,
		blades_angle : blades_angle,
		use_zdepth : use_zdepth,
		zdepth_tex : zdepth_tex,
		focus_distance : focus_distance,
		focus_range : focus_range,
		downscale : downscale,
		debug : debug,
	};
	
	uni_coc_focus_distance = shader_get_uniform(__ppf_sh_render_dof_bokeh, "u_focus_distance");
	uni_coc_focus_range = shader_get_uniform(__ppf_sh_render_dof_bokeh, "u_focus_range");
	uni_coc_d_lens_distortion_enable = shader_get_uniform(__ppf_sh_render_dof_bokeh, "u_lens_distortion_enable");
	uni_coc_d_lens_distortion_amount = shader_get_uniform(__ppf_sh_render_dof_bokeh, "u_lens_distortion_amount");
	
	uni_bokeh_resolution = shader_get_uniform(__ppf_sh_render_dof_bokeh, "u_resolution");
	uni_bokeh_time_n_intensity = shader_get_uniform(__ppf_sh_render_dof_bokeh, "u_time_n_intensity");
	uni_bokeh_radius = shader_get_uniform(__ppf_sh_render_dof_bokeh, "u_bokeh_radius");
	uni_bokeh_intensity = shader_get_uniform(__ppf_sh_render_dof_bokeh, "u_bokeh_intensity");
	uni_bokeh_shaped = shader_get_uniform(__ppf_sh_render_dof_bokeh, "u_bokeh_shaped");
	uni_bokeh_blades_aperture = shader_get_uniform(__ppf_sh_render_dof_bokeh, "u_bokeh_blades_aperture");
	uni_bokeh_blades_angle = shader_get_uniform(__ppf_sh_render_dof_bokeh, "u_bokeh_blades_angle");
	uni_bokeh_debug = shader_get_uniform(__ppf_sh_render_dof_bokeh, "u_dof_debug");
	uni_bokeh_zdepth_tex = shader_get_sampler_index(__ppf_sh_render_dof_bokeh, "u_zdepth_tex");
	
	uni_downsample_box13_texel_size = shader_get_uniform(__ppf_sh_ds_box13, "u_texel_size");
	uni_upsample_tent_texel_size = shader_get_uniform(__ppf_sh_us_tent9, "u_texel_size");
	
	// data
	dof_pre_filter_surf = -1;
	dof_bokeh_surf = -1;
	dof_post_filter_surf = -1;
	dof_downscale = 0;
	
	static Draw = function(renderer, surface_width, surface_height, time, global_intensity) {
		if (!settings.enabled || settings.radius <= 0) exit;
		
		// settings
		var _source = renderer.__stack_surface[renderer.__stack_index],
			_pass_source = _source,
			_surf_format = renderer.__surface_tex_format,
			_more_samples = false,
			_ds = clamp(settings.downscale, 0.1, 1),
			_ww = surface_width,
			_hh = surface_height;
		
		if (dof_downscale != _ds) {
			Clean();
			dof_downscale = _ds;
		}
		_more_samples = !settings.use_zdepth;
		gpu_push_state();
		
		// resolution and interpolation
		gpu_set_tex_filter(true);
		gpu_set_texrepeat(false);
		gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
		_ww = surface_width*_ds; _hh = surface_height*_ds; // half res
		_ww -= frac(_ww);
		_hh -= frac(_hh);
		
		// pre filter
		if (_more_samples) {
			if (!surface_exists(dof_pre_filter_surf)) dof_pre_filter_surf = surface_create(_ww, _hh, _surf_format);
			surface_set_target(dof_pre_filter_surf);
				shader_set(__ppf_sh_ds_box13);
				draw_clear_alpha(c_black, 0);
				shader_set_uniform_f(uni_downsample_box13_texel_size, 1/_ww, 1/_hh);
				draw_surface_stretched(_source, 0, 0, _ww, _hh);
				shader_reset();
			surface_reset_target();
			_pass_source = dof_pre_filter_surf; // set source to pre filter pass
		}
		
		// bokeh (surface_blit)
		if (!surface_exists(dof_bokeh_surf)) dof_bokeh_surf = surface_create(_ww, _hh, _surf_format);
		surface_set_target(dof_bokeh_surf); // destination
			draw_clear_alpha(c_black, 0);
			
			shader_set(__ppf_sh_render_dof_bokeh);
			shader_set_uniform_f(uni_bokeh_resolution, _ww, _hh);
			shader_set_uniform_f(uni_bokeh_time_n_intensity, time, global_intensity);
			shader_set_uniform_f(uni_coc_focus_distance, settings.focus_distance);
			shader_set_uniform_f(uni_coc_focus_range, 1-settings.focus_range);
			var _lens_effect = renderer.__get_effect_struct(FX_EFFECT.LENS_DISTORTION);
			if (_lens_effect != noone) {
				shader_set_uniform_f(uni_coc_d_lens_distortion_enable, _lens_effect.settings.enabled);
				shader_set_uniform_f(uni_coc_d_lens_distortion_amount, _lens_effect.settings.amount);
			}
			shader_set_uniform_f(uni_bokeh_radius, settings.radius);
			shader_set_uniform_f(uni_bokeh_intensity,  settings.intensity);
			shader_set_uniform_f(uni_bokeh_shaped, settings.shaped);
			shader_set_uniform_f(uni_bokeh_blades_aperture, max(3, settings.blades_aperture));
			shader_set_uniform_f(uni_bokeh_blades_angle, settings.blades_angle);
			shader_set_uniform_f(uni_bokeh_debug, settings.debug);
			
			// send depth buffer, or a white pixel, if not defined
			if (settings.use_zdepth) {
				if (settings.zdepth_tex != undefined) {
					gpu_set_tex_filter_ext(uni_bokeh_zdepth_tex, false);
					texture_set_stage(uni_bokeh_zdepth_tex, settings.zdepth_tex);
				}
			} else {
				texture_set_stage(uni_bokeh_zdepth_tex, sprite_get_texture(__spr_ppf_pixel, 0));
			}
			draw_surface_stretched(_pass_source, 0, 0, _ww, _hh); // source 
			shader_reset();
		surface_reset_target();
		_pass_source = dof_bokeh_surf; // set source to bokeh pass
		
		// post filter (surface_blit)
		if (_more_samples) {
			_ww /= 2; _hh /= 2;
			_ww -= frac(_ww);
			_hh -= frac(_hh);
			if (!surface_exists(dof_post_filter_surf)) dof_post_filter_surf = surface_create(_ww, _hh, _surf_format);
			surface_set_target(dof_post_filter_surf); // destination
				draw_clear_alpha(c_black, 0);
				shader_set(__ppf_sh_us_tent9);
				shader_set_uniform_f(uni_upsample_tent_texel_size, 1/_ww, 1/_hh);
				draw_surface_stretched(_pass_source, 0, 0, _ww, _hh); // source
				shader_reset();
			surface_reset_target();
			_pass_source = dof_post_filter_surf; // set source to post filter pass
		}
		
		// create stack surface
		renderer.__create_stack_surface(surface_width, surface_height, effect_name);
		
		// render
		surface_set_target(renderer.__stack_surface[renderer.__stack_index]) {
			draw_clear_alpha(c_black, 0);
			draw_surface_stretched(_pass_source, 0, 0, surface_width, surface_height);
			surface_reset_target();
		}
		
		gpu_pop_state();
	}
	
	static Clean = function() {
		__ppf_surface_delete(dof_pre_filter_surf);
		__ppf_surface_delete(dof_bokeh_surf);
		__ppf_surface_delete(dof_post_filter_surf);
	}
	
	/// @ignore
	static ExportData = function() {
		return {
			name : instanceof(self),
			params : [settings.enabled, settings.radius, settings.intensity, settings.shaped, settings.blades_aperture, settings.blades_angle, settings.use_zdepth, settings.zdepth_tex, settings.focus_distance, settings.focus_range, settings.downscale, settings.debug],
		};
	}
}

#endregion

#region Chromatic Aberration

/// @desc It mimics the color distortion that a real-world camera produces when its lens fails to join all colors to the same point;
/// @param {Bool} enabled Defines whether the effect starts active or not.
/// @param {Real} intensity How much the channels are distorted. 0 to 50 recommended.
/// @param {Real} angle The chromatic angle. Default it 35.
/// @param {bool} inner Defines how much the chromatic will be applied only to the edges, or entirely. 0 to 1. Where 0 = no certer distortion.
/// @param {Real} center_radius How much the effect is blended with the center. 0 to 3 recommended.
/// @param {Bool} blur_enable Defines whether to blur the chromatic effect.
/// @param {Pointer.Texture} prisma_lut_tex The spectral LUT texture, used to define the spectral colors. NOTE: You need to enable "Separate Texture Page" in sprite properties, otherwise you will get visual artifacts.
/// Texture should be 8x3, with RGB channels horizontally. Use sprite_get_texture() or surface_get_texture().
function FX_ChromaticAberration(enabled, intensity=5, angle=35, inner=1, center_radius=0, blur_enable=false, prisma_lut_tex=undefined) : __ppf_fx_super_class() constructor {
	effect_name = "chromatic_aberration";
	stack_order = PPFX_STACK.CHROMATIC_ABERRATION;
	
	settings = {
		enabled : enabled,
		intensity : intensity,
		angle : angle,
		inner : inner,
		center_radius : center_radius,
		blur_enable : blur_enable,
		prisma_lut_tex : __ppf_is_undefined(prisma_lut_tex) ? __PPF_ST.default_chromaber_prisma_lut : prisma_lut_tex,
	};
	
	uni_resolution = shader_get_uniform(__ppf_sh_render_chromaber, "u_resolution");
	uni_u_time_n_intensity = shader_get_uniform(__ppf_sh_render_chromaber, "u_time_n_intensity");
	uni_intensity = shader_get_uniform(__ppf_sh_render_chromaber, "u_chromaber_intensity");
	uni_angle = shader_get_uniform(__ppf_sh_render_chromaber, "u_chromaber_angle");
	uni_inner = shader_get_uniform(__ppf_sh_render_chromaber, "u_chromaber_inner");
	uni_center_radius = shader_get_uniform(__ppf_sh_render_chromaber, "u_chromaber_center_radius");
	uni_blur_enable = shader_get_uniform(__ppf_sh_render_chromaber, "u_chromaber_blur_enable");
	uni_prisma_lut_tex = shader_get_sampler_index(__ppf_sh_render_chromaber, "u_chromaber_prisma_lut");
	
	static Draw = function(renderer, surface_width, surface_height, time, global_intensity) {
		if (!settings.enabled || settings.intensity <= 0) exit;
		
		// settings
		gpu_push_state();
		gpu_set_tex_filter_ext(uni_prisma_lut_tex, false);
		gpu_set_tex_repeat_ext(uni_prisma_lut_tex, false);
		
		// create stack surface
		renderer.__create_stack_surface(surface_width, surface_height, effect_name);
		
		// render
		surface_set_target(renderer.__stack_surface[renderer.__stack_index]);
			draw_clear_alpha(c_black, 0);
			gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
			
			shader_set(__ppf_sh_render_chromaber);
			shader_set_uniform_f(uni_resolution, surface_width, surface_height);
			shader_set_uniform_f(uni_u_time_n_intensity, time, global_intensity);
			shader_set_uniform_f(uni_intensity, settings.intensity);
			shader_set_uniform_f(uni_angle, settings.angle);
			shader_set_uniform_f(uni_inner, settings.inner);
			shader_set_uniform_f(uni_center_radius, settings.center_radius);
			shader_set_uniform_f(uni_blur_enable, settings.blur_enable);
			texture_set_stage(uni_prisma_lut_tex, settings.prisma_lut_tex);
			draw_surface_stretched(renderer.__stack_surface[renderer.__stack_index-1], 0, 0, surface_width, surface_height);
			shader_reset();
					
		surface_reset_target();
		
		gpu_pop_state();
	}
	
	/// @ignore
	static ExportData = function() {
		return {
			name : instanceof(self),
			params : [settings.enabled, settings.intensity, settings.angle, settings.inner, settings.center_radius, settings.blur_enable, ["texture", settings.prisma_lut_tex]],
		};
	}
}

#endregion

#region VHS

/// @desc VHS (80s decade) effect simulation.
/// @param {Bool} enabled Defines whether the effect starts active or not.
/// @param {Real} chromatic_aberration Sets the amount of chromatic aberration to use. 0 to 10 recommended.
/// @param {Real} scan_aberration Sets the amount of chromatic aberration to use on scan lines. 0 to 10 recommended.
/// @param {Real} grain_intensity Sets the amount of granular. 0 to 1.
/// @param {Real} grain_height Sets the height of a granular bar. 1 to 100 recommended. Low values make the bar thinner.
/// @param {Real} grain_fade Creates a gradient effect to smoothly fade the grain to the bottom. 0 to 1.
/// @param {Real} grain_amount Defines the number of repetitions of the grain bars. 1 to 100 recommended.
/// @param {Real} grain_speed Defines the grain movement speed. 0 to 1 recommended.
/// @param {Real} grain_interval Allows smoothing between grain bar variation and more spread. 0 to 1.
/// @param {Real} scan_speed Sets the speed at which scan glitch move. 0 to 10 recommended.
/// @param {Real} scan_size Set scan glitch size. 0 to 1.
/// @param {Real} scan_offset Set scan glitch offset, which is how much it will move horizontally. 0 to 1.
/// @param {Real} hscan_offset Sets how much the horizontal fixed scan will change sporadically. 0 to 1.
/// @param {Real} flickering_intensity Sets the intensity of the flickering/blinking effect. 0 to 1.
/// @param {Real} flickering_speed Sets the flickering animation speed. 0 to 10.0 recommended.
/// @param {Real} wiggle_amplitude Defines how much the image should shake vertically. 0 to 1.
function FX_VHS(enabled, chromatic_aberration=1.5, scan_aberration=0.25, grain_intensity=0.08, grain_height=2, grain_fade=0.7, grain_amount=4, grain_speed=0.2, grain_interval=0.2, scan_speed=1, scan_size=0.08, scan_offset=0.05, hscan_offset=0.001, flickering_intensity=0.06, flickering_speed=1, wiggle_amplitude=0.001) : __ppf_fx_super_class() constructor {
	effect_name = "vhs";
	stack_order = PPFX_STACK.VHS;
	
	settings = {
		enabled : enabled,
		chromatic_aberration : chromatic_aberration,
		scan_aberration : scan_aberration,
		grain_intensity : grain_intensity,
		grain_height : grain_height,
		grain_fade : grain_fade,
		grain_amount : grain_amount,
		grain_speed : grain_speed,
		grain_interval : grain_interval,
		scan_speed : scan_speed,
		scan_size : scan_size,
		scan_offset : scan_offset,
		hscan_offset : hscan_offset,
		flickering_intensity : flickering_intensity,
		flickering_speed : flickering_speed,
		wiggle_amplitude : wiggle_amplitude,
	};
	
	uni_resolution = shader_get_uniform(__ppf_sh_render_vhs, "u_resolution");
	uni_u_time_n_intensity = shader_get_uniform(__ppf_sh_render_vhs, "u_time_n_intensity");
	uni_chromatic_aberration = shader_get_uniform(__ppf_sh_render_vhs, "u_vhs_chromatic_aberration");
	uni_scan_aberration = shader_get_uniform(__ppf_sh_render_vhs, "u_vhs_scan_aberration");
	uni_grain_intensity = shader_get_uniform(__ppf_sh_render_vhs, "u_vhs_grain_intensity");
	uni_grain_height = shader_get_uniform(__ppf_sh_render_vhs, "u_vhs_grain_height");
	uni_grain_fade = shader_get_uniform(__ppf_sh_render_vhs, "u_vhs_grain_fade");
	uni_grain_amount = shader_get_uniform(__ppf_sh_render_vhs, "u_vhs_grain_amount");
	uni_grain_speed = shader_get_uniform(__ppf_sh_render_vhs, "u_vhs_grain_speed");
	uni_grain_interval = shader_get_uniform(__ppf_sh_render_vhs, "u_vhs_grain_interval");
	uni_scan_speed = shader_get_uniform(__ppf_sh_render_vhs, "u_vhs_scan_speed");
	uni_scan_size = shader_get_uniform(__ppf_sh_render_vhs, "u_vhs_scan_size");
	uni_scan_offset = shader_get_uniform(__ppf_sh_render_vhs, "u_vhs_scan_offset");
	uni_hscan_offset = shader_get_uniform(__ppf_sh_render_vhs, "u_vhs_hscan_offset");
	uni_flickering_intensity = shader_get_uniform(__ppf_sh_render_vhs, "u_vhs_flickering_intensity");
	uni_flickering_speed = shader_get_uniform(__ppf_sh_render_vhs, "u_vhs_flickering_speed");
	uni_wiggle_amplitude = shader_get_uniform(__ppf_sh_render_vhs, "u_vhs_wiggle_amplitude");
	// dependencies
	uni_d_lens_distortion_enable = shader_get_uniform(__ppf_sh_render_vhs, "u_lens_distortion_enable");
	uni_d_lens_distortion_amount = shader_get_uniform(__ppf_sh_render_vhs, "u_lens_distortion_amount");
	
	static Draw = function(renderer, surface_width, surface_height, time, global_intensity) {
		if (!settings.enabled) exit;
		
		// create stack surface
		renderer.__create_stack_surface(surface_width, surface_height, effect_name);
		
		// get current gpu state
		gpu_push_state();
		gpu_set_tex_repeat(true);
		
		// render
		surface_set_target(renderer.__stack_surface[renderer.__stack_index]);
			draw_clear_alpha(c_black, 0);
			gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
			
			shader_set(__ppf_sh_render_vhs);
			shader_set_uniform_f(uni_resolution, surface_width, surface_height);
			shader_set_uniform_f(uni_u_time_n_intensity, time, global_intensity);
			shader_set_uniform_f(uni_chromatic_aberration, settings.chromatic_aberration);
			shader_set_uniform_f(uni_scan_aberration, settings.scan_aberration);
			shader_set_uniform_f(uni_grain_intensity, settings.grain_intensity);
			shader_set_uniform_f(uni_grain_height, settings.grain_height);
			shader_set_uniform_f(uni_grain_fade, settings.grain_fade);
			shader_set_uniform_f(uni_grain_amount, settings.grain_amount);
			shader_set_uniform_f(uni_grain_speed, settings.grain_speed);
			shader_set_uniform_f(uni_grain_interval, settings.grain_interval);
			shader_set_uniform_f(uni_scan_speed, settings.scan_speed);
			shader_set_uniform_f(uni_scan_size, settings.scan_size);
			shader_set_uniform_f(uni_scan_offset, settings.scan_offset);
			shader_set_uniform_f(uni_hscan_offset, settings.hscan_offset);
			shader_set_uniform_f(uni_flickering_intensity, settings.flickering_intensity);
			shader_set_uniform_f(uni_flickering_speed, settings.flickering_speed);
			shader_set_uniform_f(uni_wiggle_amplitude, settings.wiggle_amplitude);
			var _lens_effect = renderer.__get_effect_struct(FX_EFFECT.LENS_DISTORTION);
			if (_lens_effect != noone) {
				shader_set_uniform_f(uni_d_lens_distortion_enable, _lens_effect.settings.enabled);
				shader_set_uniform_f(uni_d_lens_distortion_amount, _lens_effect.settings.amount);
			}
			draw_surface_stretched(renderer.__stack_surface[renderer.__stack_index-1], 0, 0, surface_width, surface_height);
			shader_reset();
			
		surface_reset_target();
		
		gpu_pop_state();
	}
	
	/// @ignore
	static ExportData = function() {
		return {
			name : instanceof(self),
			params : [settings.enabled, settings.chromatic_aberration, settings.scan_aberration, settings.grain_intensity, settings.grain_height, settings.grain_fade, settings.grain_amount, settings.grain_speed, settings.grain_interval, settings.scan_speed, settings.scan_size, settings.scan_offset, settings.hscan_offset, settings.flickering_intensity, settings.flickering_speed, settings.wiggle_amplitude],
		};
	}
}

#endregion

#region Gaussian Blur

/// @desc Gaussian Blur effect.
/// @param {Bool} enabled Defines whether the effect starts active or not.
/// @param {Real} amount The amout to blur. 0 to 1.
/// @param {Real} mask_power Defines the radial center area of the mask, based on position. 0 to 15 recommended.
/// @param {Real} mask_scale Defines the radial mask scale. 0 to 3 recommended.
/// @param {Real} mask_smoothness Defines the mask border smoothness. 0 to 1.
/// @param {Real} downscale How much to downscale image. Higher numbers mean higher performance at the cost of sharpness. 2 recommended.
function FX_GaussianBlur(enabled, amount=0.3, mask_power=0, mask_scale=1, mask_smoothness=1, downscale=0.5) : __ppf_fx_super_class() constructor {
	effect_name = "gaussian_blur";
	stack_order = PPFX_STACK.BLUR_GAUSSIAN;
	
	settings = {
		enabled : enabled,
		amount : amount,
		mask_power : mask_power,
		mask_scale : mask_scale,
		mask_smoothness : mask_smoothness,
		downscale : downscale,
	};
	
	uni_resolution = shader_get_uniform(__ppf_sh_render_gaussian_blur, "u_resolution");
	uni_u_time_n_intensity = shader_get_uniform(__ppf_sh_render_gaussian_blur, "u_time_n_intensity");
	uni_amount = shader_get_uniform(__ppf_sh_render_gaussian_blur, "u_gaussian_amount");
	uni_angle = shader_get_uniform(__ppf_sh_render_gaussian_blur, "u_gaussian_angle");
	uni_gnmask_power = shader_get_uniform(__ppf_sh_generic_mask, "u_mask_power");
	uni_gnmask_scale = shader_get_uniform(__ppf_sh_generic_mask, "u_mask_scale");
	uni_gnmask_smoothness = shader_get_uniform(__ppf_sh_generic_mask, "u_mask_smoothness");
	uni_gnmask_texture = shader_get_sampler_index(__ppf_sh_generic_mask, "u_mask_tex");
	uni_downsample_box4_texel_size = shader_get_uniform(__ppf_sh_ds_box4, "u_texel_size");
	
	gaussian_blur_pang_surface = -1;
	gaussian_blur_ping_surface = -1;
	gaussian_blur_pong_surface = -1;
	gaussian_blur_downscale = 0;
	
	static Draw = function(renderer, surface_width, surface_height, time, global_intensity) {
		if (!settings.enabled || settings.amount <= 0) exit;
		
		// settings
		var _source = renderer.__stack_surface[renderer.__stack_index],
		_ds = clamp(settings.downscale, 0.1, 1),
		_ww = surface_width*_ds, _hh = surface_height*_ds;
		
		_ww -= frac(_ww);
		_hh -= frac(_hh);
		
		gpu_push_state();
		gpu_set_tex_filter(true);
		gpu_set_tex_repeat(false);
		
		if (gaussian_blur_downscale != _ds) {
			Clean();
			gaussian_blur_downscale = _ds;
		}
		if (!surface_exists(gaussian_blur_ping_surface)) {
			gaussian_blur_ping_surface = surface_create(_ww, _hh);
			gaussian_blur_pong_surface = surface_create(_ww, _hh);
			gaussian_blur_pang_surface = surface_create(_ww/2, _hh/2);
		}
		gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
		
		// gaussian pass
		shader_set(__ppf_sh_render_gaussian_blur);
			shader_set_uniform_f(uni_resolution, _ww, _hh);
			shader_set_uniform_f(uni_amount, settings.amount * 4);
			shader_set_uniform_f(uni_u_time_n_intensity, 0, global_intensity);
			
			// pass 1 (h)
			shader_set_uniform_f(uni_angle, 0);
			surface_set_target(gaussian_blur_ping_surface);
				draw_clear_alpha(c_black, 0);
				draw_surface_stretched(_source, 0, 0, _ww, _hh);
			surface_reset_target();
			
			// pass 2 (v)
			shader_set_uniform_f(uni_angle, 90);
			surface_set_target(gaussian_blur_pong_surface);
				draw_clear_alpha(c_black, 0);
				draw_surface_stretched(gaussian_blur_ping_surface, 0, 0, _ww, _hh);
			surface_reset_target();
		shader_reset();
		
		// pass 3 (post filter)
		surface_set_target(gaussian_blur_pang_surface);
			draw_clear_alpha(c_black, 0);
			shader_set(__ppf_sh_ds_box4);
			shader_set_uniform_f(uni_downsample_box4_texel_size, (1/_ww)/2, (1/_hh)/2);
			draw_surface_stretched(gaussian_blur_pong_surface, 0, 0, _ww/2, _hh/2);
			shader_reset();
		surface_reset_target();
		
		// create stack surface
		renderer.__create_stack_surface(surface_width, surface_height, effect_name);
		
		// render
		surface_set_target(renderer.__stack_surface[renderer.__stack_index]);
			draw_clear_alpha(c_black, 0);
			
			shader_set(__ppf_sh_generic_mask);
			shader_set_uniform_f(uni_gnmask_power, settings.mask_power);
			shader_set_uniform_f(uni_gnmask_scale, settings.mask_scale);
			shader_set_uniform_f(uni_gnmask_smoothness, settings.mask_smoothness);
			texture_set_stage(uni_gnmask_texture, surface_get_texture(gaussian_blur_pang_surface));
			draw_surface_stretched(renderer.__stack_surface[renderer.__stack_index-1], 0, 0, surface_width, surface_height);
			shader_reset();
			
		surface_reset_target();
		
		gpu_pop_state();
	}
	
	static Clean = function() {
		__ppf_surface_delete(gaussian_blur_pang_surface);
		__ppf_surface_delete(gaussian_blur_ping_surface);
		__ppf_surface_delete(gaussian_blur_pong_surface);
	}
	
	/// @ignore
	static ExportData = function() {
		return {
			name : instanceof(self),
			params : [settings.enabled, settings.amount, settings.mask_power, settings.mask_scale, settings.mask_smoothness, settings.downscale]
		};
	}
}

#endregion

#region Kawase Blur

/// @desc Blur effect similar to Gaussian Blur, but with better performance on low-end devices.
/// @param {Bool} enabled Defines whether the effect starts active or not.
/// @param {Real} amount The amount to blur. This parameter is currently a multiplication with "iterations". 0 to 1.
/// @param {Real} mask_power Defines the radial center area of the mask, based on position. 0 to 15 recommended.
/// @param {Real} mask_scale Defines the radial mask scale. 0 to 3 recommended.
/// @param {Real} mask_smoothness Defines the mask border smoothness. 0 to 1.
/// @param {Real} downscale How much to downscale image. Higher numbers mean higher quality. 1 to 0.5 recommended.
/// @param {Real} iterations The amount of blur passes. Larger numbers require more processing. 8 recommended.
function FX_KawaseBlur(enabled, amount=0.3, mask_power=0, mask_scale=1, mask_smoothness=1, downscale=1, iterations=8) : __ppf_fx_super_class() constructor {
	effect_name = "kawase_blur";
	stack_order = PPFX_STACK.BLUR_KAWASE;
	
	settings = {
		enabled : enabled,
		amount : amount,
		mask_power : mask_power,
		mask_scale : mask_scale,
		mask_smoothness : mask_smoothness,
		downscale : downscale,
		iterations : iterations,
	};
	
	uni_u_time_n_intensity = shader_get_uniform(__ppf_sh_render_kawase_blur, "u_time_n_intensity");
	uni_mask_power = shader_get_uniform(__ppf_sh_render_kawase_blur, "u_kawase_blur_mask_power");
	uni_mask_scale = shader_get_uniform(__ppf_sh_render_kawase_blur, "u_kawase_blur_mask_scale");
	uni_mask_smoothness = shader_get_uniform(__ppf_sh_render_kawase_blur, "u_kawase_blur_mask_smoothness");
	uni_blur_tex = shader_get_sampler_index(__ppf_sh_render_kawase_blur, "u_kawase_blur_tex");
	uni_downsample_box4_texel_size = shader_get_uniform(__ppf_sh_ds_box4, "u_texel_size");
	uni_downsample_box13_texel_size = shader_get_uniform(__ppf_sh_ds_box13, "u_texel_size");
	uni_upsample_tent_texel_size = shader_get_uniform(__ppf_sh_us_tent9, "u_texel_size");
	
	kawase_blur_surface = array_create(16, -1);
	
	static Draw = function(renderer, surface_width, surface_height, time, global_intensity) {
		if (!settings.enabled || settings.amount <= 0) exit;
		
		// settings
		var _ds = clamp(settings.downscale, 0.1, 1),
		_iterations = clamp(settings.iterations * settings.amount, 1, 8),
		_ww = surface_width * _ds,
		_hh = surface_height * _ds,
		
		_source = renderer.__stack_surface[renderer.__stack_index],
		_current_destination = _source,
		_current_source = _source;
		
		gpu_push_state();
		gpu_set_tex_filter(true);
		gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
		
		// downsampling
		shader_set(__ppf_sh_ds_box13);
		var i = 0;
		repeat(_iterations) {
			_ww /= 2;
			_hh /= 2;
			_ww -= frac(_ww);
			_hh -= frac(_hh);
			if (_ww < 2 || _hh < 2) break;
			if (!surface_exists(kawase_blur_surface[i])) {
				kawase_blur_surface[i] = surface_create(_ww, _hh);
			}
			_current_destination = kawase_blur_surface[i];
			
			// blit
			surface_set_target(_current_destination);
				draw_clear_alpha(c_black, 0);
				shader_set_uniform_f(uni_downsample_box13_texel_size, 1/_ww, 1/_hh);
				draw_surface_stretched(_current_source, 0, 0, surface_get_width(_current_destination), surface_get_height(_current_destination));
			surface_reset_target();
					
			_current_source = _current_destination;
			++i;
		}
		shader_reset();
		
		// upsampling
		shader_set(__ppf_sh_us_tent9);
		for(i -= 2; i >= 0; i--) {
			_current_destination = kawase_blur_surface[i];
					
			// blit
			_ww = surface_get_width(_current_destination);
			_hh = surface_get_height(_current_destination);
			surface_set_target(_current_destination);
				draw_clear_alpha(c_black, 0);
				shader_set_uniform_f(uni_upsample_tent_texel_size, 1/_ww, 1/_hh);
				draw_surface_stretched(_current_source, 0, 0, _ww, _hh);
			surface_reset_target();
					
			_current_source = _current_destination;
		}
		shader_reset();
		
		// create stack surface
		renderer.__create_stack_surface(surface_width, surface_height, effect_name);
		
		// render
		surface_set_target(renderer.__stack_surface[renderer.__stack_index]);
			draw_clear_alpha(c_black, 0);
			
			shader_set(__ppf_sh_render_kawase_blur);
			shader_set_uniform_f(uni_u_time_n_intensity, time, global_intensity);
			shader_set_uniform_f(uni_mask_power, settings.mask_power);
			shader_set_uniform_f(uni_mask_scale, settings.mask_scale);
			shader_set_uniform_f(uni_mask_smoothness, settings.mask_smoothness);
			texture_set_stage(uni_blur_tex, surface_get_texture(_current_destination));
			draw_surface_stretched(renderer.__stack_surface[renderer.__stack_index-1], 0, 0, surface_width, surface_height);
			shader_reset();
			
		surface_reset_target();
		
		gpu_pop_state();
	}
	
	static Clean = function() {
		__ppf_surface_delete_array(kawase_blur_surface);
	}
	
	/// @ignore
	static ExportData = function() {
		return {
			name : instanceof(self),
			params : [settings.enabled, settings.amount, settings.mask_power, settings.mask_scale, settings.mask_smoothness, settings.downscale, settings.iterations],
		};
	}
}

#endregion

#region Palette Swap

/// @desc Replace all colors in the image with colors from a palette, based on luminosity.
/// @param {Bool} enabled Defines whether the effect starts active or not.
/// @param {Real} row Vertical position on palette sprite, to use pixels in sequence.
/// @param {Bool} flip Sets whether to invert luminosity.
/// @param {Pointer.Texture} texture The palette LUT texture. Use sprite_get_texture() or surface_get_texture(). NOTE: You need to enable "Separate Texture Page" in sprite properties, otherwise you will get visual artifacts.
/// @param {Real} pal_height Palette sprite height.
/// @param {Real} threshold Set the level of brightness to filter out pixels under this level. 0 to 1; 0 means all light pixels.
/// @param {Real} smoothness How much smoothness to apply to the threshold.
/// @param {Bool} limit_colors Defines whether you want to limit the number of colors in the image to the number of colors in the palette.
function FX_PaletteSwap(enabled, row=1, flip=false, texture=undefined, pal_height=1, threshold=0, smoothness=0, limit_colors=true) : __ppf_fx_super_class() constructor {
	effect_name = "palette_swap";
	stack_order = PPFX_STACK.PALETTE_SWAP;
	
	settings = {
		enabled : enabled,
		row : row,
		flip : flip,
		texture : __ppf_is_undefined(texture) ? __PPF_ST.default_palette : texture,
		pal_height : pal_height,
		threshold : threshold,
		smoothness : smoothness,
		limit_colors : limit_colors,
	};
	
	uni_u_time_n_intensity = shader_get_uniform(__ppf_sh_render_palette_swap, "u_time_n_intensity");
	uni_texel = shader_get_uniform(__ppf_sh_render_palette_swap, "u_palette_swap_texel");
	uni_row = shader_get_uniform(__ppf_sh_render_palette_swap, "u_palette_swap_row");
	uni_pal_height = shader_get_uniform(__ppf_sh_render_palette_swap, "u_palette_swap_height");
	uni_threshold = shader_get_uniform(__ppf_sh_render_palette_swap, "u_palette_swap_threshold");
	uni_flip = shader_get_uniform(__ppf_sh_render_palette_swap, "u_palette_swap_flip");
	uni_smoothness = shader_get_uniform(__ppf_sh_render_palette_swap, "u_palette_swap_smoothness");
	uni_texture = shader_get_sampler_index(__ppf_sh_render_palette_swap, "u_palette_swap_tex");
	
	static Draw = function(renderer, surface_width, surface_height, time, global_intensity) {
		if (!settings.enabled) exit;
		
		// create stack surface
		renderer.__create_stack_surface(surface_width, surface_height, effect_name);
		
		// render
		surface_set_target(renderer.__stack_surface[renderer.__stack_index]);
			draw_clear_alpha(c_black, 0);
			gpu_push_state();
			gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
			
			shader_set(__ppf_sh_render_palette_swap);
			shader_set_uniform_f(uni_texel, 1/settings.pal_height);
			shader_set_uniform_f(uni_u_time_n_intensity, time, global_intensity);
			shader_set_uniform_f(uni_row, settings.row);
			shader_set_uniform_f(uni_pal_height, settings.pal_height);
			shader_set_uniform_f(uni_threshold, settings.threshold);
			shader_set_uniform_f(uni_flip, settings.flip);
			shader_set_uniform_f(uni_smoothness, settings.smoothness);
			if (settings.texture != undefined) texture_set_stage(uni_texture, settings.texture);
			gpu_set_tex_filter_ext(uni_texture, !settings.limit_colors);
			if (gpu_get_tex_mip_enable()) gpu_set_tex_mip_enable_ext(uni_texture, mip_off);
			
			draw_surface_stretched(renderer.__stack_surface[renderer.__stack_index-1], 0, 0, surface_width, surface_height);
			shader_reset();
			gpu_pop_state();
		surface_reset_target();
	}
	
	/// @ignore
	static ExportData = function() {
		return {
			name : instanceof(self),
			params : [settings.enabled, settings.row, settings.flip, ["texture", settings.texture], settings.pal_height, settings.threshold, settings.limit_colors],
		};
	}
}

#endregion

#region HQ4x

/// @desc Pixel-art upscaling 4x filter.
/// @param {Bool} enabled Defines whether the effect starts active or not.
/// @param {Real} smoothness Edges smoothness.
/// @param {Real} sharpness Edges sharpness.
/// @param {Real} downscale Compensate for varying pixel sizes.
function FX_HQ4x(enabled, smoothness=0.5, sharpness=1, downscale=2) : __ppf_fx_super_class() constructor {
	effect_name = "hq4x";
	stack_order = PPFX_STACK.HQ4X;
	
	settings = {
		enabled : enabled,
		smoothness : smoothness,
		sharpness : sharpness,
		downscale : downscale,
	};
	
	uni_resolution = shader_get_uniform(__ppf_sh_render_hq4x, "u_resolution");
	uni_smoothness = shader_get_uniform(__ppf_sh_render_hq4x, "u_smoothness");
	uni_sharpness = shader_get_uniform(__ppf_sh_render_hq4x, "u_sharpness");
	
	static Draw = function(renderer, surface_width, surface_height, time, global_intensity) {
		if (!settings.enabled) exit;
		
		// settings
		var _ds = round(clamp(settings.downscale, 2, 8));
		
		// create stack surface
		renderer.__create_stack_surface(surface_width, surface_height, effect_name);
		
		// render
		surface_set_target(renderer.__stack_surface[renderer.__stack_index])
			draw_clear_alpha(c_black, 0);
			gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
					
			shader_set(__ppf_sh_render_hq4x);
			shader_set_uniform_f(uni_resolution, surface_width/_ds, surface_height/_ds);
			shader_set_uniform_f(uni_smoothness, settings.smoothness);
			shader_set_uniform_f(uni_sharpness, settings.sharpness);
			draw_surface_stretched(renderer.__stack_surface[renderer.__stack_index-1], 0, 0, surface_width, surface_height);
			shader_reset();
					
			gpu_set_blendmode(bm_normal);
		surface_reset_target();
	}
	
	/// @ignore
	static ExportData = function() {
		return {
			name : instanceof(self),
			params : [settings.enabled, settings.smoothness, settings.sharpness, settings.downscale],
		};
	}
}

#endregion

#region FXAA

/// @desc Fast Approximate Anti-Aliasing is a screen-space anti-aliasing algorithm to remove sharp edges.
/// @param {Bool} enabled Defines whether the effect starts active or not.
/// @param {Real} strength Anti-aliasing strength.
function FX_FXAA(enabled, strength=2) : __ppf_fx_super_class() constructor {
	effect_name = "fxaa";
	stack_order = PPFX_STACK.FXAA;
	
	settings = {
		enabled : enabled,
		strength : strength,
	};
	
	uni_resolution = shader_get_uniform(__ppf_sh_render_fxaa, "u_resolution");
	uni_strength = shader_get_uniform(__ppf_sh_render_fxaa, "u_fxaa_strength");
	
	static Draw = function(renderer, surface_width, surface_height, time, global_intensity) {
		if (!settings.enabled || settings.strength <= 0) exit;
		
		// create stack surface
		renderer.__create_stack_surface(surface_width, surface_height, effect_name);
		
		// render
		surface_set_target(renderer.__stack_surface[renderer.__stack_index])
			draw_clear_alpha(c_black, 0);
			gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
					
			shader_set(__ppf_sh_render_fxaa);
			shader_set_uniform_f(uni_resolution, surface_width, surface_height);
			shader_set_uniform_f(uni_strength, settings.strength);
			draw_surface_stretched(renderer.__stack_surface[renderer.__stack_index-1], 0, 0, surface_width, surface_height);
			shader_reset();
					
			gpu_set_blendmode(bm_normal);
		surface_reset_target();
	}
	
	/// @ignore
	static ExportData = function() {
		return {
			name : instanceof(self),
			params : [settings.enabled, settings.strength],
		};
	}
}

#endregion

#region Slow Motion

/// @desc Double/Drunk vision effect (or just Slow Motion).
/// @param {Bool} enabled Defines whether the effect starts active or not.
/// @param {Real} threshold Set the level of brightness to filter out pixels under this level. 0 means full brightness. Values above 1 are HDR.
/// @param {Real} intensity Sets the intensity level of the effect. 0.85 recommended.
/// @param {Real} iterations Defines how long the old frame remains on the screen. 5 to 30 recommended.
/// @param {Real} force Sets how strongly the slow motion effect is applied based on the threshold.
/// @param {Bool} debug Lets you see where the threshold reaches.
/// @param {Real} source_offset Source stack offset. Indicates which stack the slow motion effect will use as a source to emit lightning. The default is 0, which is the Slow Motion stack. Note: the shift happens to the previous stack always, no matter if the value is negative or positive.
function FX_SlowMotion(enabled, threshold=0, intensity=1, iterations=30, force=5, debug=false, source_offset=0) : __ppf_fx_super_class() constructor {
	effect_name = "slow_motion";
	stack_order = PPFX_STACK.SLOW_MOTION;
	
	settings = {
		enabled : enabled,
		threshold : threshold,
		intensity : intensity,
		iterations : iterations,
		force : force,
		debug : debug,
		source_offset : source_offset,
	};
	
	uni_pre_filter_threshold = shader_get_uniform(__ppf_sh_render_slowmo_pre_filter, "u_slowmo_threshold");
	uni_pre_filter_force = shader_get_uniform(__ppf_sh_render_slowmo_pre_filter, "u_slowmo_force");
	uni_u_time_n_intensity = shader_get_uniform(__ppf_sh_render_slowmo, "u_time_n_intensity");
	uni_resolution = shader_get_uniform(__ppf_sh_render_slowmo, "u_resolution");
	uni_threshold = shader_get_uniform(__ppf_sh_render_slowmo, "u_slowmo_threshold");
	uni_debug = shader_get_uniform(__ppf_sh_render_slowmo, "u_slowmo_debug");
	uni_slowmo_tex = shader_get_sampler_index(__ppf_sh_render_slowmo, "u_slowmo_tex");
	
	slow_motion_surf = array_create(3, -1);
	
	static Draw = function(renderer, surface_width, surface_height, time, global_intensity) {
		if (!settings.enabled) exit;
		
		// settings
		var _surface_format = renderer.__surface_tex_format;
		
		// get source (from first/previous stack or threshold)
		var _source = renderer.__stack_surface[renderer.__stack_index];
		if (settings.threshold > 0) {
			// threshold (surface_blit)
			if (!surface_exists(slow_motion_surf[0])) {
				slow_motion_surf[0] = surface_create(surface_width, surface_height, _surface_format);
			}
			var _surf_index = clamp(renderer.__stack_index-abs(settings.source_offset), 0, renderer.__stack_index);
			surface_set_target(slow_motion_surf[0]); // destination
				shader_set(__ppf_sh_render_slowmo_pre_filter);
				shader_set_uniform_f(uni_pre_filter_threshold, settings.threshold);
				shader_set_uniform_f(uni_pre_filter_force, settings.force);
				draw_surface_stretched(renderer.__stack_surface[_surf_index], 0, 0, surface_width, surface_height);
				shader_reset();
			surface_reset_target();
			_source = slow_motion_surf[0];
		}
		
		// buffer a (surface_blit)
		if (!surface_exists(slow_motion_surf[1])) {
			slow_motion_surf[1] = surface_create(surface_width, surface_height, _surface_format);
		}
		surface_set_target(slow_motion_surf[1]);
			if (surface_exists(_source)) draw_surface_stretched_ext(_source, 0, 0, surface_width, surface_height, c_white, 1-clamp(settings.intensity, 0, 0.9));
		surface_reset_target();
		
		// intensity (surface_blit)
		if (!surface_exists(slow_motion_surf[2])) {
			slow_motion_surf[2] = surface_create(surface_width, surface_height, _surface_format);
		}
		surface_set_target(slow_motion_surf[2]);
			draw_clear_alpha(c_black, 0);
			var _iterations = max(1, settings.iterations);
			repeat(_iterations) {
				draw_surface_stretched(slow_motion_surf[1], 0, 0, surface_width, surface_height);
			}
		surface_reset_target();
		
		// create stack surface
		renderer.__create_stack_surface(surface_width, surface_height, effect_name);
		
		// render
		surface_set_target(renderer.__stack_surface[renderer.__stack_index]);
			draw_clear_alpha(c_black, 0);
			gpu_push_state();
			gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
			
			shader_set(__ppf_sh_render_slowmo);
			shader_set_uniform_f(uni_u_time_n_intensity, time, global_intensity);
			shader_set_uniform_f(uni_resolution, surface_width, surface_height);
			shader_set_uniform_f(uni_threshold, settings.threshold);
			shader_set_uniform_f(uni_debug, settings.debug);
			texture_set_stage(uni_slowmo_tex, surface_get_texture(slow_motion_surf[2]));
			draw_surface_stretched(renderer.__stack_surface[renderer.__stack_index-1], 0, 0, surface_width, surface_height);
			shader_reset();
			
			gpu_pop_state();
		surface_reset_target();
	}
	
	static Clean = function() {
		__ppf_surface_delete_array(slow_motion_surf);
	}
	
	/// @ignore
	static ExportData = function() {
		return {
			name : instanceof(self),
			params : [settings.enabled, settings.threshold, settings.intensity, settings.iterations, settings.force, settings.debug, settings.source_offset],
		};
	}
}

#endregion

#region Sunshafts

/// @desc Simulates the radial light scattering that arises when a very bright light source is partly obscured.
/// @param {Bool} enabled Defines whether the effect starts active or not.
/// @param {Array<Real>} position Sun position. An array with the normalized values (0 to 1), in this format: [x, y]. Please Note: The value is in screen-space. So it depends on where you are going to draw post-processing. Example: normalized GUI coordinates.
/// @param {Real} threshold Set the level of brightness to filter out pixels under this level. 0 means full brightness. Values above 1 are HDR (which allows Sunshafts to glow without affecting the rest of the game's artwork, useful for sun effect).
/// @param {Real} intensity Set the strength of the Sunshafts effect. 0 to 5 recommended.
/// @param {Real} dimmer Maximum brightness level to be reduced. 0 to 5 recommended.
/// @param {Real} scattering How far the sun's rays are projected. 0 to 1.
/// @param {Real} center_smoothness Softness of the central circle, to improve the visualization of the sun. 0 to 1.
/// @param {Bool} noise_enable Defines whether to use noise variations in the sun.
/// @param {Real} rays_intensity The intensity of noise rays. 0 to 1.
/// @param {Real} rays_tiling Repetition of noise rays. 1 to 10 recommended.
/// @param {Real} rays_speed The rays speed. 0 to 1 recommended.
/// @param {Real} downscale Sets the downscale of the sun shafts, this changes the performance.
/// @param {Pointer.Texture} noise_tex The noise texture, used for rays. NOTE: You need to enable "Separate Texture Page" in sprite properties, otherwise you will get visual artifacts.
/// @param {Bool} debug Allows you to see exactly where the sunshaft is hitting the light parts.
/// @param {Real} source_offset Source stack offset. Indicates which stack the sunshafts effect will use as a source to emit lightning. The default is 0, which is the Sunshafts stack. Note: the shift happens to the previous stack always, no matter if the value is negative or positive.
function FX_SunShafts(enabled, position=[0.5, 0.5], threshold=0.5, intensity=3, dimmer=1.4, scattering=0.9, center_smoothness=0.3, noise_enable=false, rays_intensity=1, rays_tiling=1, rays_speed=0.03, downscale=0.5, noise_tex=undefined, debug=false, source_offset=0) : __ppf_fx_super_class() constructor {
	effect_name = "sunshafts";
	stack_order = PPFX_STACK.SUNSHAFTS;
	
	settings = {
		enabled : enabled,
		position : position,
		threshold : threshold,
		intensity : intensity,
		dimmer : dimmer,
		scattering : scattering,
		center_smoothness : center_smoothness,
		noise_enable : noise_enable,
		rays_intensity : rays_intensity,
		rays_tiling : rays_tiling,
		rays_speed : rays_speed,
		downscale : downscale,
		noise_tex : __ppf_is_undefined(noise_tex) ? __PPF_ST.noise_perlin : noise_tex,
		debug : debug,
		source_offset : source_offset,
	};
	
	uni_resolution = shader_get_uniform(__ppf_sh_render_sunshafts, "u_resolution");
	uni_sunshaft_tex = shader_get_sampler_index(__ppf_sh_render_sunshafts, "u_sunshaft_tex");
	uni_noise_tex = shader_get_sampler_index(__ppf_sh_render_sunshafts, "u_sunshaft_noise_tex");
	uni_noise_size = shader_get_uniform(__ppf_sh_render_sunshafts, "u_sunshaft_noise_size");
	uni_u_time_n_intensity = shader_get_uniform(__ppf_sh_render_sunshafts, "u_time_n_intensity");
	uni_position = shader_get_uniform(__ppf_sh_render_sunshafts, "u_sunshaft_position");
	uni_center_smoothness = shader_get_uniform(__ppf_sh_render_sunshafts, "u_sunshaft_center_smoothness");
	uni_threshold = shader_get_uniform(__ppf_sh_render_sunshafts, "u_sunshaft_threshold");
	uni_intensity = shader_get_uniform(__ppf_sh_render_sunshafts, "u_sunshaft_intensity");
	uni_dimmer = shader_get_uniform(__ppf_sh_render_sunshafts, "u_sunshaft_dimmer");
	uni_scattering = shader_get_uniform(__ppf_sh_render_sunshafts, "u_sunshaft_scattering");
	uni_noise_enable = shader_get_uniform(__ppf_sh_render_sunshafts, "u_sunshaft_noise_enable");
	uni_rays_intensity = shader_get_uniform(__ppf_sh_render_sunshafts, "u_sunshaft_rays_intensity");
	uni_rays_tiling = shader_get_uniform(__ppf_sh_render_sunshafts, "u_sunshaft_rays_tiling");
	uni_rays_speed = shader_get_uniform(__ppf_sh_render_sunshafts, "u_sunshaft_rays_speed");
	uni_rays_noise_tex = shader_get_sampler_index(__ppf_sh_render_sunshafts, "u_sunshaft_rays_noise_tex");
	uni_debug = shader_get_uniform(__ppf_sh_render_sunshafts, "u_sunshaft_debug");
	
	sunshaft_surf = -1;
	sunshaft_downscale = 0;
	noise_sprite = __spr_ppf_noise_point;
	noise_texture = sprite_get_texture(noise_sprite, 0);
	noise_width = sprite_get_width(noise_sprite);
	noise_height = sprite_get_height(noise_sprite);
	
	static Draw = function(renderer, surface_width, surface_height, time, global_intensity) {
		if (!settings.enabled || settings.intensity <= 0 || settings.scattering <= 0) exit;
		
		// NOTE: this effect should not be affected by Bloom or Slow Motion, for better visual aspect
		// settings
		
		
		var _surf_index = clamp(renderer.__stack_index-abs(settings.source_offset), 0, renderer.__stack_index);
		var _source = renderer.__stack_surface[_surf_index], // get base surface, to be used by sunshafts
		_ds = clamp(settings.downscale, 0.1, 1),
		_ww = surface_width*_ds, _hh = surface_height*_ds;
		
		if (sunshaft_downscale != _ds) {
			Clean();
			sunshaft_downscale = _ds;
		}
		
		gpu_push_state();
		gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
		
		if (!surface_exists(sunshaft_surf)) {
			sunshaft_surf = surface_create(_ww, _hh, renderer.__surface_tex_format);
		}
		surface_set_target(sunshaft_surf);
		draw_clear_alpha(c_black, 0);
		draw_surface_stretched(_source, 0, 0, _ww, _hh);
		surface_reset_target();
		
		// create stack surface
		renderer.__create_stack_surface(surface_width, surface_height, effect_name);
		
		// render
		surface_set_target(renderer.__stack_surface[renderer.__stack_index]) {
			draw_clear_alpha(c_black, 0);
			
			shader_set(__ppf_sh_render_sunshafts);
			
			texture_set_stage(uni_sunshaft_tex, surface_get_texture(sunshaft_surf));
			gpu_set_tex_repeat_ext(uni_rays_noise_tex, true);
			if (settings.noise_tex != undefined) texture_set_stage(uni_rays_noise_tex, settings.noise_tex);
			shader_set_uniform_f(uni_resolution, surface_width, surface_height);
			shader_set_uniform_f(uni_u_time_n_intensity, time, global_intensity);
			
			gpu_set_tex_repeat_ext(uni_noise_tex, true);
			texture_set_stage(uni_noise_tex, noise_texture);
			shader_set_uniform_f(uni_noise_size, noise_width, noise_height);
			
			shader_set_uniform_f_array(uni_position, settings.position);
			shader_set_uniform_f(uni_center_smoothness, settings.center_smoothness);
			shader_set_uniform_f(uni_threshold, settings.threshold);
			shader_set_uniform_f(uni_intensity, settings.intensity);
			shader_set_uniform_f(uni_dimmer, settings.dimmer);
			shader_set_uniform_f(uni_scattering, settings.scattering);
			shader_set_uniform_f(uni_noise_enable, settings.noise_enable);
			shader_set_uniform_f(uni_rays_intensity, settings.rays_intensity);
			shader_set_uniform_f(uni_rays_tiling, settings.rays_tiling);
			shader_set_uniform_f(uni_rays_speed, settings.rays_speed);
			shader_set_uniform_f(uni_debug, settings.debug);
			
			draw_surface_stretched(renderer.__stack_surface[renderer.__stack_index-1], 0, 0, surface_width, surface_height);
			shader_reset();
			
			surface_reset_target();
		}
		
		gpu_pop_state();
	}
	
	static Clean = function() {
		__ppf_surface_delete(sunshaft_surf);
	}
	
	/// @ignore
	static ExportData = function() {
		return {
			name : instanceof(self),
			params : [settings.enabled, ["vec2", settings.position], settings.threshold, settings.intensity, settings.dimmer, settings.scattering, settings.center_smoothness, settings.noise_enable, settings.rays_intensity, settings.rays_tiling, settings.rays_speed, settings.downscale, settings.noise_tex, settings.debug, settings.source_offset],
		};
	}
}

#endregion

#region Motion Blur

/// @desc Simulates the blur that occurs in an image when a real-world camera films objects moving faster than the camera’s exposure time.
/// 
/// NOTE: If using an overlay_texture, if the radius is set to 0, the effect will not be automatically disabled (as is normal).
/// @param {Bool} enabled Defines whether the effect starts active or not.
/// @param {Real} angle The angle to create fast movement effect.
/// @param {Real} radius The amount of blur. 0 to 1 recommended.
/// @param {Array<Real>} center Focus position. An array with the normalized values (0 to 1), in this format: [x, y].
/// @param {Real} mask_power Defines the radial center area of the mask, based on position. 0 to 15 recommended.
/// @param {Real} mask_scale Defines the radial mask scale. 0 to 3 recommended.
/// @param {Real} mask_smoothness Defines the mask border smoothness. 0 to 1.
/// @param {Pointer.Texture} overlay_texture Uses a texture to render things that aren't affected by motion blur.
function FX_MotionBlur(enabled, angle=0, radius=0, center=[0.5,0.5], mask_power=0, mask_scale=1.2, mask_smoothness=1, overlay_texture=undefined) : __ppf_fx_super_class() constructor {
	effect_name = "motion_blur";
	stack_order = PPFX_STACK.MOTION_BLUR;
	
	settings = {
		enabled : enabled,
		angle : angle,
		radius : radius,
		center : center,
		mask_power : mask_power,
		mask_scale : mask_scale,
		mask_smoothness : mask_smoothness,
		overlay_texture : overlay_texture,
	};
	
	uni_angle = shader_get_uniform(__ppf_sh_render_motion_blur, "u_motion_blur_direction");
	uni_radius = shader_get_uniform(__ppf_sh_render_motion_blur, "u_motion_blur_radius");
	uni_center = shader_get_uniform(__ppf_sh_render_motion_blur, "u_motion_blur_center");
	uni_mask_power = shader_get_uniform(__ppf_sh_render_motion_blur, "u_motion_blur_mask_power");
	uni_mask_scale = shader_get_uniform(__ppf_sh_render_motion_blur, "u_motion_blur_mask_scale");
	uni_mask_smoothness = shader_get_uniform(__ppf_sh_render_motion_blur, "u_motion_blur_mask_smoothness");
	uni_using_overlay_texture = shader_get_uniform(__ppf_sh_render_motion_blur, "u_motion_blur_using_overlay_texture");
	uni_overlay_texture = shader_get_sampler_index(__ppf_sh_render_motion_blur, "u_motion_blur_overlay_tex");
	uni_u_time_n_intensity = shader_get_uniform(__ppf_sh_render_motion_blur, "u_time_n_intensity");
	uni_noise_tex = shader_get_sampler_index(__ppf_sh_render_motion_blur, "u_motion_blur_noise_tex");
	uni_noise_size = shader_get_uniform(__ppf_sh_render_motion_blur, "u_motion_blur_noise_size");
	
	noise_sprite = __spr_ppf_noise_blue;
	noise_texture = sprite_get_texture(noise_sprite, 0);
	noise_width = sprite_get_width(noise_sprite);
	noise_height = sprite_get_height(noise_sprite);
	
	static Draw = function(renderer, surface_width, surface_height, time, global_intensity) {
		if (!settings.enabled || (settings.radius <= 0 && __ppf_is_undefined(settings.overlay_texture))) exit;
		
		var _using_overlay_texture = !__ppf_is_undefined(settings.overlay_texture);
		
		// create stack surface
		renderer.__create_stack_surface(surface_width, surface_height, effect_name);
		
		// render
		surface_set_target(renderer.__stack_surface[renderer.__stack_index]);
			draw_clear_alpha(c_black, 0);
			gpu_push_state();
			gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
			
			shader_set(__ppf_sh_render_motion_blur);
			shader_set_uniform_f(uni_u_time_n_intensity, time, global_intensity);
			shader_set_uniform_f(uni_angle, settings.angle);
			shader_set_uniform_f(uni_radius, settings.radius);
			shader_set_uniform_f_array(uni_center, settings.center);
			shader_set_uniform_f(uni_mask_power, settings.mask_power);
			shader_set_uniform_f(uni_mask_scale, settings.mask_scale);
			shader_set_uniform_f(uni_mask_smoothness, settings.mask_smoothness);
			shader_set_uniform_f(uni_using_overlay_texture, _using_overlay_texture);
			if (_using_overlay_texture) texture_set_stage(uni_overlay_texture, settings.overlay_texture);
			gpu_set_tex_repeat_ext(uni_noise_tex, true);
			texture_set_stage(uni_noise_tex, noise_texture);
			shader_set_uniform_f(uni_noise_size, noise_width, noise_height);
			
			draw_surface_stretched(renderer.__stack_surface[renderer.__stack_index-1], 0, 0, surface_width, surface_height);
			shader_reset();
			
			gpu_pop_state();
		surface_reset_target();
	}
	
	/// @ignore
	static ExportData = function() {
		return {
			name : instanceof(self),
			params : [settings.enabled, settings.angle, settings.radius, ["vec2", settings.center], settings.mask_power, settings.mask_scale, settings.mask_smoothness, ["texture", settings.overlay_texture]],
		};
	}
}

#endregion

#region Radial Blur

/// @desc Blurred zoom effect to give the impression of speed;
/// @param {Bool} enabled Defines whether the effect starts active or not.
/// @param {Real} radius The amount of blur. 0 to 1 recommended.
/// @param {Real} inner How far the blur extends from the center.
/// @param {Array<Real>} center Focus position. An array with the normalized values (0 to 1), in this format: [x, y].
function FX_RadialBlur(enabled, radius=0.5, inner=1.5, center=[0.5,0.5]) : __ppf_fx_super_class() constructor {
	effect_name = "radial_blur";
	stack_order = PPFX_STACK.BLUR_RADIAL;
	
	settings = {
		enabled : enabled,
		radius : radius,
		inner : inner,
		center : center,
	};
	
	uni_u_time_n_intensity = shader_get_uniform(__ppf_sh_render_radial_blur, "u_time_n_intensity");
	uni_radius = shader_get_uniform(__ppf_sh_render_radial_blur, "u_radial_blur_radius");
	uni_center = shader_get_uniform(__ppf_sh_render_radial_blur, "u_radial_blur_center");
	uni_inner = shader_get_uniform(__ppf_sh_render_radial_blur, "u_radial_blur_inner");
	uni_noise_tex = shader_get_sampler_index(__ppf_sh_render_radial_blur, "u_radial_blur_noise_tex");
	uni_noise_size = shader_get_uniform(__ppf_sh_render_radial_blur, "u_radial_blur_noise_size");
	
	noise_sprite = __spr_ppf_noise_blue;
	noise_texture = sprite_get_texture(noise_sprite, 0);
	noise_width = sprite_get_width(noise_sprite);
	noise_height = sprite_get_height(noise_sprite);
	
	static Draw = function(renderer, surface_width, surface_height, time, global_intensity) {
		if (!settings.enabled || settings.radius <= 0) exit;
		
		// create stack surface
		renderer.__create_stack_surface(surface_width, surface_height, effect_name);
		
		// render
		surface_set_target(renderer.__stack_surface[renderer.__stack_index]);
			draw_clear_alpha(c_black, 0);
			gpu_push_state();
			gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
			
			shader_set(__ppf_sh_render_radial_blur);
			shader_set_uniform_f(uni_u_time_n_intensity, time, global_intensity);
			shader_set_uniform_f(uni_radius, settings.radius);
			shader_set_uniform_f_array(uni_center, settings.center);
			shader_set_uniform_f(uni_inner, settings.inner);
			gpu_set_tex_repeat_ext(uni_noise_tex, true);
			texture_set_stage(uni_noise_tex, noise_texture);
			shader_set_uniform_f(uni_noise_size, noise_width, noise_height);
			draw_surface_stretched(renderer.__stack_surface[renderer.__stack_index-1], 0, 0, surface_width, surface_height);
			shader_reset();
			
			gpu_pop_state();
		surface_reset_target();
	}
	
	/// @ignore
	static ExportData = function() {
		return {
			name : instanceof(self),
			params : [settings.enabled, settings.radius, settings.inner, ["vec2", settings.center]],
		};
	}
}

#endregion

#region Texture Overlay

/// @desc Texture to be drawn after one of the lastest rendered effects. It is drawn after the "Invert Colors" effect and before the "Lift, Gamma, Gain" effect
/// @param {Bool} enabled Defines whether the effect starts active or not.
/// @param {Real} intensity Texture alpha. 0 to 1.
/// @param {Real} scale Texture scale. 0 to 2 recommended.
/// @param {Pointer.Texture} texture The texture to be used. Use sprite_get_texture() or surface_get_texture(). NOTE: You need to enable "Separate Texture Page" in sprite properties, otherwise you will get visual artifacts.
/// @param {real} blendmode Defines the way the texture will blend with everything below. 0 = normal, 1 = add, 2 = subtract, 3 - light
/// @param {Bool} can_distort If active, the texture will distort according to the lens distortion effect.
function FX_TextureOverlay(enabled, intensity=1, scale=1, texture=undefined, blendmode=0, can_distort=false) : __ppf_fx_super_class() constructor {
	effect_name = "texture_overlay";
	stack_order = PPFX_STACK.TEXTURE_OVERLAY;
	
	settings = {
		enabled : enabled,
		intensity : intensity,
		texture : __ppf_is_undefined(texture) ? __PPF_ST.default_overlay_tex : texture,
		scale : scale,
		blendmode : blendmode,
		can_distort : can_distort,
	};
	
	uni_u_time_n_intensity = shader_get_uniform(__ppf_sh_render_texture_overlay, "u_time_n_intensity");
	uni_enable = shader_get_uniform(__ppf_sh_render_texture_overlay, "u_texture_overlay_enable");
	uni_intensity = shader_get_uniform(__ppf_sh_render_texture_overlay, "u_texture_overlay_intensity");
	uni_texture = shader_get_sampler_index(__ppf_sh_render_texture_overlay, "u_texture_overlay_tex");
	uni_scale = shader_get_uniform(__ppf_sh_render_texture_overlay, "u_texture_overlay_scale");
	uni_blendmode = shader_get_uniform(__ppf_sh_render_texture_overlay, "u_texture_overlay_blendmode");
	uni_can_distort = shader_get_uniform(__ppf_sh_render_texture_overlay, "u_texture_overlay_can_distort");
	// dependencies
	uni_d_lens_distortion_enable = shader_get_uniform(__ppf_sh_render_texture_overlay, "u_lens_distortion_enable");
	uni_d_lens_distortion_amount = shader_get_uniform(__ppf_sh_render_texture_overlay, "u_lens_distortion_amount");
	
	static Draw = function(renderer, surface_width, surface_height, time, global_intensity) {
		if (!settings.enabled || settings.intensity <= 0) exit;
		
		// create stack surface
		renderer.__create_stack_surface(surface_width, surface_height, effect_name);
		
		// render
		surface_set_target(renderer.__stack_surface[renderer.__stack_index]);
			draw_clear_alpha(c_black, 0);
			gpu_push_state();
			gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
			
			shader_set(__ppf_sh_render_texture_overlay);
			shader_set_uniform_f(uni_u_time_n_intensity, time, global_intensity);
			shader_set_uniform_f(uni_enable, settings.enabled);
			shader_set_uniform_f(uni_intensity, settings.intensity);
			shader_set_uniform_f(uni_scale, settings.scale);
			shader_set_uniform_i(uni_blendmode, settings.blendmode);
			shader_set_uniform_f(uni_can_distort, settings.can_distort);
			if (settings.texture != undefined) texture_set_stage(uni_texture, settings.texture);
			gpu_set_texrepeat_ext(uni_texture, false);
			
			if (settings.can_distort) {
				var _lens_effect = renderer.__get_effect_struct(FX_EFFECT.LENS_DISTORTION);
				if (_lens_effect != noone) {
					shader_set_uniform_f(uni_d_lens_distortion_enable, _lens_effect.settings.enabled);
					shader_set_uniform_f(uni_d_lens_distortion_amount, _lens_effect.settings.amount);
				}
			}
			
			draw_surface_stretched(renderer.__stack_surface[renderer.__stack_index-1], 0, 0, surface_width, surface_height);
			shader_reset();
			
			gpu_pop_state();
		surface_reset_target();
	}
	
	/// @ignore
	static ExportData = function() {
		return {
			name : instanceof(self),
			params : [settings.enabled, settings.intensity, settings.scale, ["texture", settings.texture], settings.blendmode, settings.can_distort],
		};
	}
}

#endregion

#region Compare (DEBUG)

/// @desc With this function, it is possible to compare one stack with another. The default is to compare the last stack with the selected stack (stack_index), but it is possible to change the stack order with .SetOrder().
/// @param {Bool} enabled Defines whether the effect starts active or not.
/// @param {Bool} side_by_side Lets you show the same images side by side.
/// @param {Real} x_offset Defines the comparison's x position. Value from 0 to 1.
/// @param {Real} stack_index The stack index to compare. From 0 to the current stack.
function FX_Compare(enabled, side_by_side=false, x_offset=0.5, stack_index=0) : __ppf_fx_super_class() constructor {
	effect_name = "compare";
	stack_order = PPFX_STACK.COMPARE;
	
	settings = {
		enabled : enabled,
		side_by_side : side_by_side,
		x_offset : x_offset,
		stack_index : stack_index,
	};
	
	static Draw = function(renderer, surface_width, surface_height, time, global_intensity) {
		if (!settings.enabled) exit;
		
		// create stack surface
		renderer.__create_stack_surface(surface_width, surface_height, effect_name);
		
		// render
		surface_set_target(renderer.__stack_surface[renderer.__stack_index]);
			draw_clear_alpha(c_black, 0);
			gpu_push_state();
			gpu_set_blendenable(false);
			
			var _line_x = 0;
			// draw surfaces
			if (!settings.side_by_side) {
				_line_x = surface_width*settings.x_offset;
				// current surface
				draw_surface_stretched(renderer.__stack_surface[renderer.__stack_index-1], 0, 0, surface_width, surface_height);
				
				// first (or selected) surface
				var _stack_surf = renderer.__stack_surface[clamp(settings.stack_index, 0, renderer.__stack_index-1)],
					_ww = surface_get_width(_stack_surf),
					_hh = surface_get_height(_stack_surf),
					_xs = surface_width / _ww,
					_ys = surface_height / _hh;
				draw_surface_part_ext(_stack_surf, 0, 0, _ww*settings.x_offset, _hh, 0, 0, _xs, _ys, c_white, 1);
			} else {
				_line_x = surface_width*0.5;
				
				// first (or selected) surface
				var _stack_surf2 = renderer.__stack_surface[clamp(settings.stack_index, 0, renderer.__stack_index-1)],
					_ww = surface_get_width(_stack_surf2),
					_hh = surface_get_height(_stack_surf2),
					_xs = surface_width / _ww,
					_ys = surface_height / _hh,
					_xoffset = lerp(0, _ww/2, settings.x_offset);
				draw_surface_part_ext(_stack_surf2, _xoffset, 0, _ww+_xoffset, _hh, 0, 0, _xs, _ys, c_white, 1);
				
				// current surface
				var _stack_surf1 = renderer.__stack_surface[renderer.__stack_index-1],
					_ww = surface_get_width(_stack_surf1),
					_hh = surface_get_height(_stack_surf1),
					_xs = surface_width / _ww,
					_ys = surface_height / _hh,
					_xoffset = lerp(0, _ww/2, settings.x_offset);
				draw_surface_part_ext(_stack_surf1, _xoffset, 0, _ww+_xoffset, _hh, _ww/2, 0, _xs, _ys, c_white, 1);
			}
			
			// line
			draw_line_width_color(_line_x, 0, _line_x, surface_height, 2, c_black, c_black);
			
			gpu_pop_state();
		surface_reset_target();
	}
	
	/// @ignore
	static ExportData = function() {
		return {
			name : instanceof(self),
			params : [settings.enabled, settings.side_by_side, settings.x_offset, settings.stack_index],
		};
	}
}

#endregion

// Base Stack

#region Rotation

/// @desc This effect rotates the screen, maintaining aspect ratio.
/// @param {Bool} enabled Defines whether the effect starts active or not.
/// @param {Real} angle Rotation angle in degrees.
function FX_Rotation(enabled, angle=0) : __ppf_fx_super_class() constructor {
	effect_name = "rotation";
	can_change_order = false;
	stack_order = PPFX_STACK.BASE;
	stack_shared = true;
	
	settings = {
		enabled : enabled,
		angle : angle,
	};
	
	uni_enable = shader_get_uniform(__ppf_sh_render_base, "u_rotation_enable");
	uni_angle = shader_get_uniform(__ppf_sh_render_base, "u_rotation_angle");
	
	static Draw = function(renderer) {
		if (!settings.enabled) exit;
		shader_set_uniform_f(uni_enable, settings.enabled);
		shader_set_uniform_f(uni_angle, settings.angle);
	}
	
	/// @ignore
	static ExportData = function() {
		return {
			name : instanceof(self),
			params : [settings.enabled, settings.angle],
		};
	}
}

#endregion

#region Zoom

/// @desc This effect zooms (enlarges the image), following the normalized center position.
/// @param {Bool} enabled Defines whether the effect starts active or not.
/// @param {Real} amount Zoom amount: 1 to 2.
/// @param {Real} range Zoom range. Example: 1 or 10.
/// @param {Array<Real>} center Zoom focus position. An array with the normalized values (0 to 1), in this format: [x, y].
function FX_Zoom(enabled, amount=1, range=1, center=[0.5, 0.5]) : __ppf_fx_super_class() constructor {
	effect_name = "zoom";
	can_change_order = false;
	stack_order = PPFX_STACK.BASE;
	stack_shared = true;
	
	settings = {
		enabled : enabled,
		amount : amount,
		range : range,
		center : center,
	};
	
	uni_enable = shader_get_uniform(__ppf_sh_render_base, "u_zoom_enable");
	uni_amount = shader_get_uniform(__ppf_sh_render_base, "u_zoom_amount");
	uni_range = shader_get_uniform(__ppf_sh_render_base, "u_zoom_range");
	uni_center = shader_get_uniform(__ppf_sh_render_base, "u_zoom_center");
	
	static Draw = function(renderer) {
		if (!settings.enabled) exit;
		shader_set_uniform_f(uni_enable, settings.enabled);
		shader_set_uniform_f(uni_amount, settings.amount);
		shader_set_uniform_f(uni_range, settings.range);
		shader_set_uniform_f_array(uni_center, settings.center);
	}
	
	/// @ignore
	static ExportData = function() {
		return {
			name : instanceof(self),
			params : [settings.enabled, settings.amount, settings.range, ["vec2", settings.center]],
		};
	}
}

#endregion

#region Shake

/// @desc This effect causes the screen to shake.
/// @param {Bool} enabled Defines whether the effect starts active or not.
/// @param {Real} speedd Shake speed. A value from 0 to +inf.
/// @param {Real} magnitude Sets how far the screen will flicker, higher values means more shaking. Try values from 0 to 1.
/// @param {Real} hspeedd Horizontal shake speed.
/// @param {Real} vspeedd Vertical shake speed.
function FX_Shake(enabled, speedd=0.25, magnitude=0.01, hspeedd=1, vspeedd=1) : __ppf_fx_super_class() constructor {
	effect_name = "shake";
	can_change_order = false;
	stack_order = PPFX_STACK.BASE;
	stack_shared = true;
	
	settings = {
		enabled : enabled,
		speedd : speedd,
		magnitude : magnitude,
		hspeedd : hspeedd,
		vspeedd : vspeedd,
	};
	
	uni_enable = shader_get_uniform(__ppf_sh_render_base, "u_shake_enable");
	uni_speedd = shader_get_uniform(__ppf_sh_render_base, "u_shake_speed");
	uni_magnitude = shader_get_uniform(__ppf_sh_render_base, "u_shake_magnitude");
	uni_hspeedd = shader_get_uniform(__ppf_sh_render_base, "u_shake_hspeed");
	uni_vspeedd = shader_get_uniform(__ppf_sh_render_base, "u_shake_vspeed");
	
	static Draw = function(renderer) {
		if (!settings.enabled) exit;
		shader_set_uniform_f(uni_enable, settings.enabled);
		shader_set_uniform_f(uni_speedd, settings.speedd);
		shader_set_uniform_f(uni_magnitude, settings.magnitude);
		shader_set_uniform_f(uni_hspeedd, settings.hspeedd);
		shader_set_uniform_f(uni_vspeedd, settings.vspeedd);
	}
	
	/// @ignore
	static ExportData = function() {
		return {
			name : instanceof(self),
			params : [settings.enabled, settings.speedd, settings.magnitude, settings.hspeedd, settings.vspeedd],
		};
	}
}

#endregion

#region Lens Distortion

/// @desc This effect simulates CRT distortion, where the distortion can be positive or negative.
/// @param {Bool} enabled Defines whether the effect starts active or not.
/// @param {Real} amount Distortion amount. Positive = Barrel, Negative = Pincushion. 0 = No distortion. Recommended: -1 to 1
function FX_LensDistortion(enabled, amount=0) : __ppf_fx_super_class() constructor {
	effect_name = "lens_distortion";
	can_change_order = false;
	stack_order = PPFX_STACK.BASE;
	stack_shared = true;
	
	settings = {
		enabled : enabled,
		amount : amount,
	};
	
	uni_enable = shader_get_uniform(__ppf_sh_render_base, "u_lens_distortion_enable");
	uni_amount = shader_get_uniform(__ppf_sh_render_base, "u_lens_distortion_amount"); // not needed anymore - it will be declared in the others effect constructor itself
	
	static Draw = function(renderer) {
		if (!settings.enabled) exit;
		shader_set_uniform_f(uni_enable, settings.enabled);
		shader_set_uniform_f(uni_amount, settings.amount);
	}
	
	/// @ignore
	static ExportData = function() {
		return {
			name : instanceof(self),
			params : [settings.enabled, settings.amount],
		};
	}
}

#endregion

#region Pixelization

/// @desc Turn small pixels into artificial big pixels.
/// @param {Bool} enabled Defines whether the effect starts active or not.
/// @param {Real} amount Pixel resolution. 0 to 1.
/// @param {Real} squares_max Maximum amount of squares. 20 recommended.
/// @param {Real} steps Steps to change pixelation intensity. Helps prevent sudden change.
function FX_Pixelize(enabled, amount=0.5, squares_max=20, steps=50) : __ppf_fx_super_class() constructor {
	effect_name = "pixelize";
	can_change_order = false;
	stack_order = PPFX_STACK.BASE;
	stack_shared = true;
	
	settings = {
		enabled : enabled,
		amount : amount,
		squares_max : squares_max,
		steps : steps,
	};
	
	uni_enable = shader_get_uniform(__ppf_sh_render_base, "u_pixelize_enable");
	uni_amount = shader_get_uniform(__ppf_sh_render_base, "u_pixelize_amount");
	uni_squares_max = shader_get_uniform(__ppf_sh_render_base, "u_pixelize_squares_max");
	uni_steps = shader_get_uniform(__ppf_sh_render_base, "u_pixelize_steps");
	
	static Draw = function(renderer) {
		if (!settings.enabled) exit;
		shader_set_uniform_f(uni_enable, settings.enabled);
		shader_set_uniform_f(uni_amount, settings.amount);
		shader_set_uniform_f(uni_squares_max, settings.squares_max);
		shader_set_uniform_f(uni_steps, settings.steps);
	}
	
	/// @ignore
	static ExportData = function() {
		return {
			name : instanceof(self),
			params : [settings.enabled, settings.amount, settings.squares_max, settings.steps],
		};
	}
}

#endregion

#region Swirl

/// @desc Creates a swirl effect (like a Black Hole) at the defined position.
/// @param {Bool} enabled Defines whether the effect starts active or not.
/// @param {Real} angle Swirl angle. In degress, 0 to 360.
/// @param {Real} radius Swirl radius. 0 to 1.
/// @param {Array<Real>} center The position. An array with the normalized values (0 to 1), in this format: [x, y].
function FX_Swirl(enabled, angle=35, radius=1, center=[0.5,0.5]) : __ppf_fx_super_class() constructor {
	effect_name = "swirl";
	can_change_order = false;
	stack_order = PPFX_STACK.BASE;
	stack_shared = true;
	
	settings = {
		enabled : enabled,
		angle : angle,
		radius : radius,
		center : center,
	};
	
	uni_enable = shader_get_uniform(__ppf_sh_render_base, "u_swirl_enable");
	uni_angle = shader_get_uniform(__ppf_sh_render_base, "u_swirl_angle");
	uni_radius = shader_get_uniform(__ppf_sh_render_base, "u_swirl_radius");
	uni_center = shader_get_uniform(__ppf_sh_render_base, "u_swirl_center");
	
	static Draw = function(renderer) {
		if (!settings.enabled) exit;
		shader_set_uniform_f(uni_enable, settings.enabled);
		shader_set_uniform_f(uni_angle, settings.angle);
		shader_set_uniform_f(uni_radius, settings.radius);
		shader_set_uniform_f_array(uni_center, settings.center);
	}
	
	/// @ignore
	static ExportData = function() {
		return {
			name : instanceof(self),
			params : [settings.enabled, settings.angle, settings.radius, ["vec2", settings.center]],
		};
	}
}

#endregion

#region Panorama

/// @desc Creates a side warp effect to simulate perspective.
/// @param {Bool} enabled Defines whether the effect starts active or not.
/// @param {Real} depth_x The horizontal distortion depth. 0 to 3.
/// @param {Real} depth_y The vertical distortion depth. 0 to 3.
function FX_Panorama(enabled, depth_x=1, depth_y=0) : __ppf_fx_super_class() constructor {
	effect_name = "panorama";
	can_change_order = false;
	stack_order = PPFX_STACK.BASE;
	stack_shared = true;
	
	settings = {
		enabled : enabled,
		depth_x : depth_x,
		depth_y : depth_y,
	};
	
	uni_enable = shader_get_uniform(__ppf_sh_render_base, "u_panorama_enable");
	uni_depth_x = shader_get_uniform(__ppf_sh_render_base, "u_panorama_depth_x");
	uni_depth_y = shader_get_uniform(__ppf_sh_render_base, "u_panorama_depth_y");
	
	static Draw = function(renderer) {
		if (!settings.enabled) exit;
		shader_set_uniform_f(uni_enable, settings.enabled);
		shader_set_uniform_f(uni_depth_x, settings.depth_x);
		shader_set_uniform_f(uni_depth_y, settings.depth_y);
	}
	
	/// @ignore
	static ExportData = function() {
		return {
			name : instanceof(self),
			params : [settings.enabled, settings.depth_x, settings.depth_y],
		};
	}
}

#endregion

#region Sine Wave

/// @desc Create a sine wave effect on the screen, using frequency and amplitude.
/// @param {Bool} enabled Defines whether the effect starts active or not.
/// @param {Real} speedd Animation speed.
/// @param {Array<Real>} amplitude Sine wave amplitude.
/// @param {Array<Real>} frequency Sine wave frequency.
/// @param {Array<Real>} offset Position offset. Use the camera position. An array with absolute values, in this format: [cam_x, cam_y].
function FX_SineWave(enabled, speedd=0.5, amplitude=[0.02,0.02], frequency=[10,10], offset=[0,0]) : __ppf_fx_super_class() constructor {
	effect_name = "sine_wave";
	can_change_order = false;
	stack_order = PPFX_STACK.BASE;
	stack_shared = true;
	
	settings = {
		enabled : enabled,
		speedd : speedd,
		amplitude : amplitude,
		frequency : frequency,
		offset : offset,
	};
	
	uni_enable = shader_get_uniform(__ppf_sh_render_base, "u_sinewave_enable");
	uni_frequency = shader_get_uniform(__ppf_sh_render_base, "u_sinewave_frequency");
	uni_amplitude = shader_get_uniform(__ppf_sh_render_base, "u_sinewave_amplitude");
	uni_speedd = shader_get_uniform(__ppf_sh_render_base, "u_sinewave_speed");
	uni_offset = shader_get_uniform(__ppf_sh_render_base, "u_sinewave_offset");
	
	static Draw = function(renderer) {
		if (!settings.enabled) exit;
		shader_set_uniform_f(uni_enable, settings.enabled);
		shader_set_uniform_f_array(uni_frequency, settings.frequency);
		shader_set_uniform_f_array(uni_amplitude, settings.amplitude);
		shader_set_uniform_f(uni_speedd, settings.speedd);
		shader_set_uniform_f_array(uni_offset, settings.offset);
	}
	
	/// @ignore
	static ExportData = function() {
		return {
			name : instanceof(self),
			params : [settings.enabled, settings.speedd, ["vec2", settings.amplitude], ["vec2", settings.frequency], ["vec2", settings.offset]],
		};
	}
}

#endregion

#region Glitch

/// @desc Create on-screen glitch effects to simulate broadcast glitches like old TV or cyber futuristic.
/// @param {Bool} enabled Defines whether the effect starts active or not.
/// @param {Real} speedd Glitch animation speed.
/// @param {Real} block_size Vertical bars size.
/// @param {Real} interval Interval to start failure. Closer to 1 means rarer.
/// @param {Real} intensity Displace amount.
/// @param {Real} peak_amplitude1 Distortion when reaching the interval.
/// @param {Real} peak_amplitude2 Distortion out of interval.
function FX_Glitch(enabled, speedd=1, block_size=0.9, interval=0.995, intensity=0.2, peak_amplitude1=2, peak_amplitude2=1.5) : __ppf_fx_super_class() constructor {
	effect_name = "glitch";
	can_change_order = false;
	stack_order = PPFX_STACK.BASE;
	stack_shared = true;
	
	settings = {
		enabled : enabled,
		speedd : speedd,
		block_size : block_size,
		interval : interval,
		intensity : intensity,
		peak_amplitude1 : peak_amplitude1,
		peak_amplitude2 : peak_amplitude2,
	};
	
	uni_enable = shader_get_uniform(__ppf_sh_render_base, "u_glitch_enable");
	uni_speedd = shader_get_uniform(__ppf_sh_render_base, "u_glitch_speed");
	uni_block_size = shader_get_uniform(__ppf_sh_render_base, "u_glitch_block_size");
	uni_interval = shader_get_uniform(__ppf_sh_render_base, "u_glitch_interval");
	uni_intensity = shader_get_uniform(__ppf_sh_render_base, "u_glitch_intensity");
	uni_peak_amplitude1 = shader_get_uniform(__ppf_sh_render_base, "u_glitch_peak_amplitude1");
	uni_peak_amplitude2 = shader_get_uniform(__ppf_sh_render_base, "u_glitch_peak_amplitude2");
	
	static Draw = function(renderer) {
		if (!settings.enabled) exit;
		shader_set_uniform_f(uni_enable, settings.enabled);
		shader_set_uniform_f(uni_speedd, settings.speedd);
		shader_set_uniform_f(uni_block_size, settings.block_size);
		shader_set_uniform_f(uni_interval, settings.interval);
		shader_set_uniform_f(uni_intensity, settings.intensity);
		shader_set_uniform_f(uni_peak_amplitude1, settings.peak_amplitude1);
		shader_set_uniform_f(uni_peak_amplitude2, settings.peak_amplitude2);
	}
	
	/// @ignore
	static ExportData = function() {
		return {
			name : instanceof(self),
			params : [settings.enabled, settings.speedd, settings.block_size, settings.interval, settings.intensity, settings.peak_amplitude1, settings.peak_amplitude2],
		};
	}
}

#endregion

#region Shockwaves

/// @desc Shockwaves screen distortion effect, perfect for enhancing explosion simulation or related stuff.
/// @param {Bool} enabled Defines whether the effect starts active or not.
/// @param {Real} amount Displacement amount. 0 to 1.
/// @param {Real} aberration Chromatic aberration offset amount. 0 to 1.
/// @param {Pointer.Texture} prisma_lut_tex Spectral The spectral LUT texture, used to define the spectral colors.
/// Texture should be 8x3, with RGB channels horizontally. Use sprite_get_texture() or surface_get_texture().
/// @param {Pointer.Texture} texture Normalmap surface. Use shockwave_render() to make it easy.
function FX_Shockwaves(enabled, amount=0.1, aberration=0.1, prisma_lut_tex=undefined, texture=undefined) : __ppf_fx_super_class() constructor {
	effect_name = "shockwaves";
	can_change_order = false;
	stack_order = PPFX_STACK.BASE;
	stack_shared = true;
	
	settings = {
		enabled : enabled,
		amount : amount,
		aberration : aberration,
		prisma_lut_tex : __ppf_is_undefined(prisma_lut_tex) ? __PPF_ST.default_shockwaves_prisma_lut : prisma_lut_tex,
		texture : __ppf_is_undefined(texture) ? __PPF_ST.default_normal : texture,
	};
	
	uni_enable = shader_get_uniform(__ppf_sh_render_base, "u_shockwaves_enable");
	uni_amount = shader_get_uniform(__ppf_sh_render_base, "u_shockwaves_amount");
	uni_aberration = shader_get_uniform(__ppf_sh_render_base, "u_shockwaves_aberration");
	uni_texture = shader_get_sampler_index(__ppf_sh_render_base, "u_shockwaves_tex");
	uni_prisma_lut_tex = shader_get_sampler_index(__ppf_sh_render_base, "u_shockwaves_prisma_lut_tex");
	
	static Draw = function(renderer) {
		if (!settings.enabled) exit;
		shader_set_uniform_f(uni_enable, settings.enabled);
		shader_set_uniform_f(uni_amount, settings.amount);
		shader_set_uniform_f(uni_aberration, settings.aberration);
		if (settings.texture != undefined) texture_set_stage(uni_texture, settings.texture);
		if (settings.prisma_lut_tex != undefined) texture_set_stage(uni_prisma_lut_tex, settings.prisma_lut_tex);
	}
	
	/// @ignore
	static ExportData = function() {
		return {
			name : instanceof(self),
			params : [settings.enabled, settings.aberration, ["texture", settings.prisma_lut_tex], settings.texture],
		};
	}
}

#endregion

#region Displacemaps

/// @desc Displacement screen distortion effect, perfect for simulating rain, water drops/drops on the screen and related things
/// @param {Bool} enabled Defines whether the effect starts active or not.
/// @param {Real} amount Displacement amount. 0 to 1.
/// @param {Real} scale The scale amount. Default is 1 (no scale). 0.25 to 20 recommended.
/// @param {Real} speedd Movement speed.
/// @param {Real} angle Movemente direction.
/// @param {Pointer.Texture} texture Normal map texture with distortion information.
/// @param {Array<Real>} offset Position offset. Use the camera position. An array with absolute values, in this format: [cam_x, cam_y].
function FX_DisplaceMap(enabled, amount=0.1, scale=1, speedd=0.1, angle=0, texture=undefined, offset=[0,0]) : __ppf_fx_super_class() constructor {
	effect_name = "displacemap";
	can_change_order = false;
	stack_order = PPFX_STACK.BASE;
	stack_shared = true;
	
	settings = {
		enabled : enabled,
		amount : amount,
		scale : scale,
		angle : angle,
		speedd : speedd,
		texture : __ppf_is_undefined(texture) ? __PPF_ST.default_normal : texture,
		offset : offset,
	};
	
	uni_enable = shader_get_uniform(__ppf_sh_render_base, "u_displacemap_enable");
	uni_amount = shader_get_uniform(__ppf_sh_render_base, "u_displacemap_amount");
	uni_scale = shader_get_uniform(__ppf_sh_render_base, "u_displacemap_scale");
	uni_angle = shader_get_uniform(__ppf_sh_render_base, "u_displacemap_angle");
	uni_speedd = shader_get_uniform(__ppf_sh_render_base, "u_displacemap_speed");
	uni_texture = shader_get_sampler_index(__ppf_sh_render_base, "u_displacemap_tex");
	uni_offset = shader_get_uniform(__ppf_sh_render_base, "u_displacemap_offset");
	
	static Draw = function(renderer) {
		if (!settings.enabled) exit;
		shader_set_uniform_f(uni_enable, settings.enabled);
		shader_set_uniform_f(uni_amount, settings.amount);
		shader_set_uniform_f(uni_scale, settings.scale);
		shader_set_uniform_f(uni_angle, settings.angle);
		shader_set_uniform_f(uni_speedd, settings.speedd);
		if (settings.texture != undefined) texture_set_stage(uni_texture, settings.texture);
		shader_set_uniform_f_array(uni_offset, settings.offset);
	}
	
	/// @ignore
	static ExportData = function() {
		return {
			name : instanceof(self),
			params : [settings.enabled, settings.amount, settings.scale, settings.speedd, settings.angle, settings.texture, ["vec2", settings.offset]],
		};
	}
}

#endregion

#region White Balance

/// @desc White balance is used to adjust colors to match the color of the light source so that white objects appear white.
/// @param {Bool} enabled Defines whether the effect starts active or not.
/// @param {Real} temperature Higher values result in a warmer color temperature and lower values result in a colder color temperature. -1.67 to 1.67.
/// @param {Real} tint Compensate for a green or magenta tint.
function FX_WhiteBalance(enabled, temperature=0, tint=0) : __ppf_fx_super_class() constructor {
	effect_name = "white_balance";
	can_change_order = false;
	stack_order = PPFX_STACK.BASE;
	stack_shared = true;
	
	settings = {
		enabled : enabled,
		temperature : temperature,
		tint : tint,
	};
	
	uni_enable = shader_get_uniform(__ppf_sh_render_base, "u_white_balance_enable");
	uni_chromaticity = shader_get_uniform(__ppf_sh_render_base, "u_white_balance_chromaticity");
	
	static Draw = function(renderer) {
		if (!settings.enabled) exit;
		shader_set_uniform_f(uni_enable, settings.enabled);
		// Get the CIE xy chromaticity of the reference white point
		// 0.31271 = x value on the D65 white point
		var _temperature = clamp(__ppf_relerp(-1, 1, settings.temperature, -1.67, 1.67), -1.67, 1.67),
		_x = 0.31271 - _temperature * (_temperature < 0 ? 0.1 : 0.05),
		_standard_lum_y = 2.87 * _x - 3.0 * _x * _x - 0.27509507,
		_y = _standard_lum_y + settings.tint * 0.05;
		
		shader_set_uniform_f(uni_chromaticity, _x, _y);
	}
	
	/// @ignore
	static ExportData = function() {
		return {
			name : instanceof(self),
			params : [settings.enabled, settings.temperature, settings.tint],
		};
	}
}

#endregion

// Color Grading

#region LUT

/// @desc Uses a LUT texture to apply color correction (useful for Mobile as it's lightweight).
/// @param {Bool} enabled Defines whether the effect starts active or not.
/// @param {Real} intensity How much the LUT-modified image merges with the original image.
/// @param {Real} type The LUT type to be used.  0: Strip | 1: Grid | 2: Hald Grid (Cube).
/// @param {Real} horizontal_squares Horizontal LUT squares. Example: 16 (Strip), 8 (Grid), 8 (Hald Grid).
/// @param {Pointer.Texture} texture The LUT texture. Use sprite_get_texture() or surface_get_texture(). NOTE: You need to enable "Separate Texture Page" in sprite properties, otherwise you will get visual artifacts.
function FX_LUT(enabled, intensity=1, type=1, horizontal_squares=8, texture=undefined) : __ppf_fx_super_class() constructor {
	effect_name = "lut";
	can_change_order = false;
	stack_order = PPFX_STACK.COLOR_GRADING;
	stack_shared = true;
	
	settings = {
		enabled : enabled,
		type : type,
		texture : texture,
		intensity : intensity,
		squares : horizontal_squares
	};
	
	uni_enable = shader_get_uniform(__ppf_sh_render_color_grading, "u_lut_enable");
	uni_size = shader_get_uniform(__ppf_sh_render_color_grading, "u_lut_size");
	uni_squares = shader_get_uniform(__ppf_sh_render_color_grading, "u_lut_squares");
	uni_intensity = shader_get_uniform(__ppf_sh_render_color_grading, "u_lut_intensity");
	uni_tex_lookup = shader_get_sampler_index(__ppf_sh_render_color_grading, "u_lut_tex");
	
	static Draw = function(renderer) {
		if (!settings.enabled) exit;
		shader_set_uniform_f(uni_enable, settings.enabled);
		var _tex = settings.texture;
		if (_tex != undefined) {
			var _type = settings.type, _squares = settings.squares, _width = 0, _height = 0, _squares_w = 1, _squares_h = 1;
			if (_type == 0) {
				// Strip
				_squares_w = _squares;
				_squares_h = 1;
				_width = _squares * _squares;
				_height = _squares;
			} else
			if (_type == 1) {
				// Grid
				_squares_w = _squares;
				_squares_h = _squares;
				_width = power(_squares, 3);
				_height = _width;
			} else
			if (_type == 2) {
				// Hald Grid
				_squares_w = _squares;
				_squares_h = _squares * _squares;
				_width = power(_squares, 3);
				_height = _width;
			}
			shader_set_uniform_f(uni_size, _width, _height);
			shader_set_uniform_f(uni_squares, _squares_w, _squares_h);
			shader_set_uniform_f(uni_intensity, settings.intensity);
			gpu_set_tex_repeat_ext(uni_tex_lookup, false);
			gpu_set_tex_filter_ext(uni_tex_lookup, true);
			if (gpu_get_tex_mip_enable()) gpu_set_tex_mip_enable_ext(uni_tex_lookup, mip_off);
			texture_set_stage(uni_tex_lookup, _tex);
		}
	}
	
	/// @ignore
	static ExportData = function() {
		return {
			name : instanceof(self),
			params : [settings.enabled, settings.intensity, settings.type, settings.squares, ["texture", settings.texture]],
		};
	}
}

#endregion

#region Exposure

/// @desc Adjusts the overall exposure of the screen.
/// @param {Bool} enabled Defines whether the effect starts active or not.
/// @param {real} value Exposure amount. 0 to 2 recommended.
function FX_Exposure(enabled, value=1) : __ppf_fx_super_class() constructor {
	effect_name = "exposure";
	can_change_order = false;
	stack_order = PPFX_STACK.COLOR_GRADING;
	stack_shared = true;
	
	settings = {
		enabled : enabled,
		value : value,
	};
	
	uni_enable = shader_get_uniform(__ppf_sh_render_color_grading, "u_exposure_enable");
	uni_value = shader_get_uniform(__ppf_sh_render_color_grading, "u_exposure_val");
	
	static Draw = function(renderer) {
		if (!settings.enabled) exit;
		shader_set_uniform_f(uni_enable, settings.enabled);
		shader_set_uniform_f(uni_value, settings.value);
	}
	
	/// @ignore
	static ExportData = function() {
		return {
			name : instanceof(self),
			params : [settings.enabled, settings.value],
		};
	}
}

#endregion

#region Brightness

/// @desc The amount of white color mixed with the image.
/// @param {Bool} enabled Defines whether the effect starts active or not.
/// @param {Real} value The amount of brightness. 0 to 2 recommended.
function FX_Brightness(enabled, value=1) : __ppf_fx_super_class() constructor {
	effect_name = "brightness";
	can_change_order = false;
	stack_order = PPFX_STACK.COLOR_GRADING;
	stack_shared = true;
	
	settings = {
		enabled : enabled,
		value : value,
	};
	
	uni_enable = shader_get_uniform(__ppf_sh_render_color_grading, "u_brightness_enable");
	uni_value = shader_get_uniform(__ppf_sh_render_color_grading, "u_brightness_val");
	
	static Draw = function(renderer) {
		if (!settings.enabled) exit;
		shader_set_uniform_f(uni_enable, settings.enabled);
		shader_set_uniform_f(uni_value, settings.value);
	}
	
	/// @ignore
	static ExportData = function() {
		return {
			name : instanceof(self),
			params : [settings.enabled, settings.value],
		};
	}
}

#endregion

#region Contrast

/// @desc The overall range of tonal values.
/// @param {Bool} enabled Defines whether the effect starts active or not.
/// @param {Real} value The contrast amount. 0 to 2 recommended.
function FX_Contrast(enabled, value=1) : __ppf_fx_super_class() constructor {
	effect_name = "contrast";
	can_change_order = false;
	stack_order = PPFX_STACK.COLOR_GRADING;
	stack_shared = true;
	
	settings = {
		enabled : enabled,
		value : value,
	};
	
	uni_enable = shader_get_uniform(__ppf_sh_render_color_grading, "u_contrast_enable");
	uni_value = shader_get_uniform(__ppf_sh_render_color_grading, "u_contrast_val");
	
	static Draw = function(renderer) {
		if (!settings.enabled) exit;
		shader_set_uniform_f(uni_enable, settings.enabled);
		shader_set_uniform_f(uni_value, settings.value);
	}
	
	/// @ignore
	static ExportData = function() {
		return {
			name : instanceof(self),
			params : [settings.enabled, settings.value],
		};
	}
}

#endregion

#region Channel Mixer

/// @desc Channel Mixer allows you to take the red, green, and blue channels and boost or pull back the levels of each one.
/// @param {Bool} enabled Defines whether the effect starts active or not.
/// @param {Real} red Color.
/// @param {Real} green Color
/// @param {Real} blue Color.
function FX_ChannelMixer(enabled, red=make_color_rgb(255, 0, 0), green=make_color_rgb(0, 255, 0), blue=make_color_rgb(0, 0, 255)) : __ppf_fx_super_class() constructor {
	effect_name = "channel_mixer";
	can_change_order = false;
	stack_order = PPFX_STACK.COLOR_GRADING;
	stack_shared = true;
	
	settings = {
		enabled : enabled,
		red : make_color_ppfx(red),
		green : make_color_ppfx(green),
		blue : make_color_ppfx(blue),
	};
	
	uni_enable = shader_get_uniform(__ppf_sh_render_color_grading, "u_channel_mixer_enable");
	uni_red = shader_get_uniform(__ppf_sh_render_color_grading, "u_channel_mixer_red");
	uni_green = shader_get_uniform(__ppf_sh_render_color_grading, "u_channel_mixer_green");
	uni_blue = shader_get_uniform(__ppf_sh_render_color_grading, "u_channel_mixer_blue");
	
	static Draw = function(renderer) {
		if (!settings.enabled) exit;
		shader_set_uniform_f(uni_enable, settings.enabled);
		shader_set_uniform_f_array(uni_red, settings.red);
		shader_set_uniform_f_array(uni_green, settings.green);
		shader_set_uniform_f_array(uni_blue, settings.blue);
	}
	
	/// @ignore
	static ExportData = function() {
		return {
			name : instanceof(self),
			params : [settings.enabled, ["color", settings.red], ["color", settings.green], ["color", settings.blue]],
		};
	}
}

#endregion

#region Color Balance (Shadow, Midtone, Highlight)

/// @desc This effect separately controls the shadows, midtones, and highlights of the render.
/// Unlike Lift, Gamma, Gain, you can use this effect to precisely define the tonal range for shadows, midtones, and highlights.
/// @param {Bool} enabled Defines whether the effect starts active or not.
/// @param {Real} shadow_color Shadows color.
/// @param {Real} midtone_color Midtones color.
/// @param {Real} highlight_color Highlights color.
/// @param {Real} shadow_range Sets the value at which shadows will start to be affected. Default is 0.93.
/// @param {Real} highlight_range Sets the value at which hightlights will start to be affected. Default is 0.66.
function FX_ShadowMidtoneHighlight(enabled, shadow_color=c_white, midtone_color=c_white, highlight_color=c_white, shadow_range=0.93, highlight_range=0.66) : __ppf_fx_super_class() constructor {
	effect_name = "shadow_midtone_highlight";
	can_change_order = false;
	stack_order = PPFX_STACK.COLOR_GRADING;
	stack_shared = true;
	
	settings = {
		enabled : enabled,
		shadow_color : make_color_ppfx(shadow_color),
		midtone_color : make_color_ppfx(midtone_color),
		highlight_color : make_color_ppfx(highlight_color),
		shadow_range : shadow_range,
		highlight_range : highlight_range,
	};
	
	uni_enable = shader_get_uniform(__ppf_sh_render_color_grading, "u_color_balance_enable");
	uni_shadow_color = shader_get_uniform(__ppf_sh_render_color_grading, "u_shadow_color");
	uni_midtone_color = shader_get_uniform(__ppf_sh_render_color_grading, "u_midtone_color");
	uni_highlight_color = shader_get_uniform(__ppf_sh_render_color_grading, "u_highlight_color");
	uni_shadow_range = shader_get_uniform(__ppf_sh_render_color_grading, "u_shadow_range");
	uni_highlight_range = shader_get_uniform(__ppf_sh_render_color_grading, "u_highlight_range");
	
	static Draw = function(renderer) {
		if (!settings.enabled) exit;
		shader_set_uniform_f(uni_enable, settings.enabled);
		shader_set_uniform_f_array(uni_shadow_color, settings.shadow_color);
		shader_set_uniform_f_array(uni_midtone_color, settings.midtone_color);
		shader_set_uniform_f_array(uni_highlight_color, settings.highlight_color);
		shader_set_uniform_f(uni_shadow_range, settings.shadow_range);
		shader_set_uniform_f(uni_highlight_range, settings.highlight_range);
	}
	
	/// @ignore
	static ExportData = function() {
		return {
			name : instanceof(self),
			params : [settings.enabled, ["color", settings.shadow_color], ["color", settings.midtone_color], ["color", settings.highlight_color], settings.shadow_range, settings.highlight_range],
		};
	}
}

#endregion

#region Saturation

/// @desc Relative bandwidth of the visible output from a light source;
/// @param {Bool} enabled Defines whether the effect starts active or not.
/// @param {Real} value How much the grayscale is blended with the original image. 0 to 5 recommended.
function FX_Saturation(enabled, value=1) : __ppf_fx_super_class() constructor {
	effect_name = "saturation";
	can_change_order = false;
	stack_order = PPFX_STACK.COLOR_GRADING;
	stack_shared = true;
	
	settings = {
		enabled : enabled,
		value : value,
	};
	
	uni_enable = shader_get_uniform(__ppf_sh_render_color_grading, "u_saturation_enable");
	uni_value = shader_get_uniform(__ppf_sh_render_color_grading, "u_saturation_val");
	
	static Draw = function(renderer) {
		if (!settings.enabled) exit;
		shader_set_uniform_f(uni_value, settings.value);
		shader_set_uniform_f(uni_enable, settings.enabled);
	}
	
	/// @ignore
	static ExportData = function() {
		return {
			name : instanceof(self),
			params : [settings.enabled, settings.value],
		};
	}
}

#endregion

#region Hue Shift

/// @desc Change the overall color tone of an image.
/// @param {Bool} enabled Defines whether the effect starts active or not.
/// @param {Real} hue The hue, in degrees. 0 to 255. Tip: you can use color_get_hue(color) here.
/// @param {Real} saturation The saturation. 0 to 1.
/// @param {Real} preserve_luminance Sets whether curves should preserve luminance.
function FX_HueShift(enabled, hue=0, saturation=255, preserve_luminance=false) : __ppf_fx_super_class() constructor {
	effect_name = "hue_shift";
	can_change_order = false;
	stack_order = PPFX_STACK.COLOR_GRADING;
	stack_shared = true;
	
	settings = {
		enabled : enabled,
		hue : 0,
		saturation : saturation,
		preserve_luminance : preserve_luminance,
	};
	
	uni_enable = shader_get_uniform(__ppf_sh_render_color_grading, "u_hueshift_enable");
	uni_hsv = shader_get_uniform(__ppf_sh_render_color_grading, "u_hueshift_hsv");
	uni_preserve_lum = shader_get_uniform(__ppf_sh_render_color_grading, "u_hueshift_preserve_lum");
	
	static Draw = function(renderer) {
		if (!settings.enabled) exit;
		shader_set_uniform_f(uni_enable, settings.enabled);
		shader_set_uniform_f(uni_hsv, settings.hue/255, settings.saturation/255, 1);
		shader_set_uniform_f(uni_preserve_lum, settings.preserve_luminance);
	}
	
	/// @ignore
	static ExportData = function() {
		return {
			name : instanceof(self),
			params : [settings.enabled, settings.hue, settings.saturation, settings.preserve_luminance],
		};
	}
}

#endregion

#region Color Tint

/// @desc Multiply the image by a color.
/// @param {Bool} enabled Defines whether the effect starts active or not.
/// @param {Real} color The color. Example: c_white | make_color_rgb() | make_color_hsv().
function FX_ColorTint(enabled, color=c_white) : __ppf_fx_super_class() constructor {
	effect_name = "color_tint";
	can_change_order = false;
	stack_order = PPFX_STACK.COLOR_GRADING;
	stack_shared = true;
	
	settings = {
		enabled : enabled,
		color : make_color_ppfx(color),
	};
	
	uni_enable = shader_get_uniform(__ppf_sh_render_color_grading, "u_colortint_enable");
	uni_color = shader_get_uniform(__ppf_sh_render_color_grading, "u_colortint_color");
	
	static Draw = function(renderer) {
		if (!settings.enabled) exit;
		shader_set_uniform_f(uni_enable, settings.enabled);
		shader_set_uniform_f_array(uni_color, settings.color);
	}
	
	/// @ignore
	static ExportData = function() {
		return {
			name : instanceof(self),
			params : [settings.enabled, ["color", settings.color]],
		};
	}
}

#endregion

#region Colorize

/// @desc Colorize image preserving white colors.
/// @param {Bool} enabled Defines whether the effect starts active or not.
/// @param {Real} hue The hue shift offset. 0 to 255.
/// @param {Real} saturation The color saturation. 0 to 255.
/// @param {Real} value The color luminosity. 0 to 255.
/// @param {Real} intensity How much to blend the colored image with the original image. 0 to 1.
function FX_Colorize(enabled, hue=0, saturation=140, value=255, intensity=1) : __ppf_fx_super_class() constructor {
	effect_name = "colorize";
	can_change_order = false;
	stack_order = PPFX_STACK.COLOR_GRADING;
	stack_shared = true;
	
	settings = {
		enabled : enabled,
		hue : hue,
		saturation : saturation,
		value : value,
		intensity : intensity,
	};
	
	uni_enable = shader_get_uniform(__ppf_sh_render_color_grading, "u_colorize_enable");
	uni_hsv = shader_get_uniform(__ppf_sh_render_color_grading, "u_colorize_hsv");
	uni_intensity = shader_get_uniform(__ppf_sh_render_color_grading, "u_colorize_intensity");
	
	static Draw = function(renderer) {
		if (!settings.enabled) exit;
		shader_set_uniform_f(uni_enable, settings.enabled);
		shader_set_uniform_f(uni_hsv, settings.hue/255, settings.saturation/255, settings.value/255);
		shader_set_uniform_f(uni_intensity, settings.intensity);
	}
	
	/// @ignore
	static ExportData = function() {
		return {
			name : instanceof(self),
			params : [settings.enabled, settings.hue, settings.saturation, settings.value, settings.intensity],
		};
	}
}

#endregion

#region Posterization

/// @desc Defines the amount of color displayed on the screen.
/// @param {Bool} enabled Defines whether the effect starts active or not.
/// @param {Real} color_factor The amount of colors. 2 to 256 recommended.
function FX_Posterization(enabled, color_factor=8) : __ppf_fx_super_class() constructor {
	effect_name = "posterization";
	can_change_order = false;
	stack_order = PPFX_STACK.COLOR_GRADING;
	stack_shared = true;
	
	settings = {
		enabled : enabled,
		color_factor : color_factor,
	};
	
	uni_enable = shader_get_uniform(__ppf_sh_render_color_grading, "u_posterization_enable");
	uni_color_factor = shader_get_uniform(__ppf_sh_render_color_grading, "u_posterization_col_factor");
	
	static Draw = function(renderer) {
		if (!settings.enabled) exit;
		shader_set_uniform_f(uni_enable, settings.enabled);
		shader_set_uniform_f(uni_color_factor, settings.color_factor);
	}
	
	/// @ignore
	static ExportData = function() {
		return {
			name : instanceof(self),
			params : [settings.enabled, settings.color_factor],
		};
	}
}

#endregion

#region Invert Colors

/// @desc Invert all colors, such that white becomes black and vice versa.
/// @param {Bool} enabled Defines whether the effect starts active or not.
/// @param {Real} intensity How much the inverted image merges with the original image. 0 to 1.
function FX_InvertColors(enabled, intensity=1) : __ppf_fx_super_class() constructor {
	effect_name = "invert_colors";
	can_change_order = false;
	stack_order = PPFX_STACK.COLOR_GRADING;
	stack_shared = true;
	
	settings = {
		enabled : enabled,
		intensity : intensity,
	};
	
	uni_enable = shader_get_uniform(__ppf_sh_render_color_grading, "u_invert_colors_enable");
	uni_intensity = shader_get_uniform(__ppf_sh_render_color_grading, "u_invert_colors_intensity");
	
	static Draw = function(renderer) {
		if (!settings.enabled) exit;
		shader_set_uniform_f(uni_enable, settings.enabled);
		shader_set_uniform_f(uni_intensity, settings.intensity);
	}
	
	/// @ignore
	static ExportData = function() {
		return {
			name : instanceof(self),
			params : [settings.enabled, settings.intensity],
		};
	}
}

#endregion

#region Lift Gamma Gain

/// @desc This effect allows you to perform three-way color grading.
/// 
/// Lift controls the dark tones;
/// 
/// Gamma controls the mid-range tones with a power function;
// 
/// Gain is used to increase the signal and make highlights brighter;
/// 
/// @param {Bool} enabled Defines whether the effect starts active or not.
/// @param {Real} lift_color The RGB lift color. Example: c_white.
/// @param {Real} gamma_color The RGB gamma color. Example: c_white.
/// @param {Real} gain_color The RGB gain color. Example: c_white.
function FX_LiftGammaGain(enabled, lift_color=c_white, gamma_color=c_white, gain_color=c_white, lift_intensity=1, gamma_intensity=1, gain_intensity=1) : __ppf_fx_super_class() constructor {
	effect_name = "lift_gamma_gain";
	can_change_order = false;
	stack_order = PPFX_STACK.COLOR_GRADING;
	stack_shared = true;
	
	settings = {
		enabled : enabled,
		lift : make_color_hdr_ppfx(lift_color, lift_intensity),
		gamma : make_color_hdr_ppfx(gamma_color, gamma_intensity),
		gain : make_color_hdr_ppfx(gain_color, gain_intensity),
	};
	
	uni_enable = shader_get_uniform(__ppf_sh_render_color_grading, "u_lift_gamma_gain_enable");
	uni_lift = shader_get_uniform(__ppf_sh_render_color_grading, "u_lift_rgb");
	uni_gamma = shader_get_uniform(__ppf_sh_render_color_grading, "u_gamma_rgb");
	uni_gain = shader_get_uniform(__ppf_sh_render_color_grading, "u_gain_rgb");
	
	static Draw = function(renderer) {
		if (!settings.enabled) exit;
		shader_set_uniform_f(uni_enable, settings.enabled);
		shader_set_uniform_f_array(uni_lift, settings.lift);
		shader_set_uniform_f_array(uni_gamma, settings.gamma);
		shader_set_uniform_f_array(uni_gain, settings.gain);
	}
	
	/// @ignore
	static ExportData = function() {
		return {
			name : instanceof(self),
			params : [settings.enabled, ["color", settings.lift], ["color", settings.gamma], ["color", settings.gain]],
		};
	}
}

#endregion

#region Color Curves

/// @desc Color grading curves provide an advanced method for fine-tuning specific ranges of hue, saturation or luminosity in an image. You can manipulate the curves using graphs to accomplish effects like saturation in certain colors.
/// @param {Bool} enabled Defines whether the effect starts active or not.
/// @param {Real} preserve_luminance Sets whether curves should preserve luminance.
/// @param {Struct} yrgb_curve A curve generated with PPFX_Curve().
/// @param {Struct} hhsl_curve A curve generated with PPFX_Curve().
function FX_ColorCurves(enabled, preserve_luminance=false, yrgb_curve=undefined, hhsl_curve=undefined) : __ppf_fx_super_class() constructor {
	effect_name = "color_curves";
	can_change_order = false;
	stack_order = PPFX_STACK.COLOR_GRADING;
	stack_shared = true;
	
	settings = {
		enabled : enabled,
		preserve_luminance : preserve_luminance,
		yrgb_curve : yrgb_curve,
		hhsl_curve : hhsl_curve,
	};
	
	uni_enable = shader_get_uniform(__ppf_sh_render_color_grading, "u_curves_enable");
	uni_preserve_lum = shader_get_uniform(__ppf_sh_render_color_grading, "u_curves_preserve_lum");
	uni_yrgb_is_ready = shader_get_uniform(__ppf_sh_render_color_grading, "u_curves_yrgb_is_ready");
	uni_hhsl_is_ready = shader_get_uniform(__ppf_sh_render_color_grading, "u_curves_hhsl_is_ready");
	uni_yrgb_gradient_tex = shader_get_sampler_index(__ppf_sh_render_color_grading, "u_curves_yrgb_tex");
	uni_hhsl_gradient_tex = shader_get_sampler_index(__ppf_sh_render_color_grading, "u_curves_hhsl_tex");
	
	static Draw = function(renderer) {
		var _yrgb_curve = settings.yrgb_curve, _hhsl_curve = settings.hhsl_curve;
		
		if (!settings.enabled || (_yrgb_curve == undefined && _hhsl_curve == undefined)) exit;
		
		shader_set_uniform_f(uni_enable, settings.enabled);
		shader_set_uniform_f(uni_preserve_lum, settings.preserve_luminance);
		shader_set_uniform_f(uni_yrgb_is_ready, false);
		shader_set_uniform_f(uni_hhsl_is_ready, false);
		if (_yrgb_curve != undefined) {
			if (!surface_exists(_yrgb_curve.__curve_surf)) _yrgb_curve.__restore_surface();
			texture_set_stage(uni_yrgb_gradient_tex, surface_get_texture(_yrgb_curve.__curve_surf));
			shader_set_uniform_f(uni_yrgb_is_ready, true);
		}
		if (_hhsl_curve != undefined) {
			if (!surface_exists(_hhsl_curve.__curve_surf)) _hhsl_curve.__restore_surface();
			texture_set_stage(uni_hhsl_gradient_tex, surface_get_texture(_hhsl_curve.__curve_surf));
			shader_set_uniform_f(uni_hhsl_is_ready, true);
		}
	}
	
	/// @ignore
	static ExportData = function() {
		return {
			name : instanceof(self),
			params : [settings.enabled, settings.preserve_luminance, undefined, undefined],
		};
	}
}

#endregion

#region Tone Mapping

/// @desc Compress the dynamic range of an image to make it more suitable for display on devices with limited dynamic range (HDR to LDR). It is also used for aesthetic purposes.
/// @param {Bool} enabled Defines whether the effect starts active or not.
/// @param {Real} mode Tone Mapping mode. 0 = ACES film | 1 = Lottes | 2 = Uncharted 2 | 3 = Unreal 3
function FX_ToneMapping(enabled, mode=0) : __ppf_fx_super_class() constructor {
	effect_name = "tone_mapping";
	can_change_order = false;
	stack_order = PPFX_STACK.COLOR_GRADING;
	stack_shared = true;
	
	settings = {
		enabled : enabled,
		mode : mode,
	};
	
	uni_enable = shader_get_uniform(__ppf_sh_render_color_grading, "u_tone_mapping_enable");
	uni_mode = shader_get_uniform(__ppf_sh_render_color_grading, "u_tone_mapping_mode");
	
	static Draw = function(renderer) {
		if (!settings.enabled) exit;
		shader_set_uniform_f(uni_enable, settings.enabled);
		shader_set_uniform_i(uni_mode, settings.mode);
	}
	
	/// @ignore
	static ExportData = function() {
		return {
			name : instanceof(self),
			params : [settings.enabled, settings.mode],
		};
	}
}

#endregion

// Final

#region Mist

/// @desc A fog/mist effect to give a gloomy look, which can be used in forests, imitate fire, and among others.
/// @param {Bool} enabled Defines whether the effect starts active or not.
/// @param {Real} intensity The mist intensity. 0 to 1 recommended.
/// @param {Real} scale Noise scale. 0 to 1.
/// @param {Real} tiling Repetition of noise rays. 0.25 to 10 recommended.
/// @param {Real} speedd Noise movement speed.
/// @param {Real} angle Noise angle.
/// @param {Real} contrast Noise contrast.
/// @param {Real} powerr Helps make noise sharper. 0 to 1 recommended.
/// @param {Real} remap Central softness. 0 to 0.99 recommended.
/// @param {Real} color Mist color tint.
/// @param {Real} mix Blending intensity with image lights.
/// @param {Real} mix_threshold The level of brightness to filter out pixels under this level. 0 to 1; 0 means all light pixels.
/// @param {Pointer.Texture} noise_tex The noise texture to be used as mist/fog. NOTE: You need to enable "Separate Texture Page" in sprite properties, otherwise you will get visual artifacts.
/// @param {Array<Real>} offset Position offset. Use the camera position. An array with absolute values, in this format: [cam_x, cam_y].
/// @param {Real} fade_amount Partial fade amount.
/// @param {Real} fade_angle Partial fade angle.
function FX_Mist(enabled, intensity=0.5, scale=0.5, tiling=1, speedd=0.2, angle=0, contrast=0.8, powerr=1, remap=0.8, color=c_white, mix=0, mix_threshold=0, noise_tex=undefined, offset=[0.0,0.0], fade_amount=0, fade_angle=270) : __ppf_fx_super_class() constructor {
	effect_name = "mist";
	can_change_order = false;
	stack_order = PPFX_STACK.FINAL;
	stack_shared = true;
	
	settings = {
		enabled : enabled,
		intensity : intensity,
		scale : scale,
		tiling : tiling,
		speedd : speedd,
		angle : angle,
		contrast : contrast,
		powerr : powerr,
		remap : remap,
		color : make_color_ppfx(color),
		mix : mix,
		mix_threshold : mix_threshold,
		noise_tex : __ppf_is_undefined(noise_tex) ? __PPF_ST.noise_perlin : noise_tex,
		offset : offset,
		fade_amount : fade_amount,
		fade_angle : fade_angle,
	}
	
	uni_enable = shader_get_uniform(__ppf_sh_render_final, "u_mist_enable");
	uni_intensity = shader_get_uniform(__ppf_sh_render_final, "u_mist_intensity");
	uni_scale = shader_get_uniform(__ppf_sh_render_final, "u_mist_scale");
	uni_tiling = shader_get_uniform(__ppf_sh_render_final, "u_mist_tiling");
	uni_speedd = shader_get_uniform(__ppf_sh_render_final, "u_mist_speed");
	uni_angle = shader_get_uniform(__ppf_sh_render_final, "u_mist_angle");
	uni_contrast = shader_get_uniform(__ppf_sh_render_final, "u_mist_contrast");
	uni_powerr = shader_get_uniform(__ppf_sh_render_final, "u_mist_power");
	uni_remap = shader_get_uniform(__ppf_sh_render_final, "u_mist_remap");
	uni_colorr = shader_get_uniform(__ppf_sh_render_final, "u_mist_color");
	uni_mix = shader_get_uniform(__ppf_sh_render_final, "u_mist_mix");
	uni_mix_threshold = shader_get_uniform(__ppf_sh_render_final, "u_mist_mix_threshold");
	uni_noise_tex = shader_get_sampler_index(__ppf_sh_render_final, "u_mist_noise_tex");
	uni_offset = shader_get_uniform(__ppf_sh_render_final, "u_mist_offset");
	uni_fade_amount = shader_get_uniform(__ppf_sh_render_final, "u_mist_fade_amount");
	uni_fade_angle = shader_get_uniform(__ppf_sh_render_final, "u_mist_fade_angle");
	
	static Draw = function(renderer) {
		if (!settings.enabled) exit;
		shader_set_uniform_f(uni_enable, settings.enabled);
		shader_set_uniform_f(uni_intensity, settings.intensity);
		shader_set_uniform_f(uni_scale, settings.scale);
		shader_set_uniform_f(uni_tiling,settings.tiling);
		shader_set_uniform_f(uni_speedd,settings.speedd * 0.1);
		shader_set_uniform_f(uni_angle, settings.angle);
		shader_set_uniform_f(uni_contrast, settings.contrast);
		shader_set_uniform_f(uni_powerr, settings.powerr);
		shader_set_uniform_f(uni_remap, settings.remap);
		shader_set_uniform_f_array(uni_colorr, settings.color);
		shader_set_uniform_f(uni_mix, settings.mix);
		shader_set_uniform_f(uni_mix_threshold, settings.mix_threshold);
		if (settings.noise_tex != undefined) texture_set_stage(uni_noise_tex, settings.noise_tex);
		gpu_set_tex_repeat_ext(uni_noise_tex, true);
		shader_set_uniform_f_array(uni_offset, settings.offset);
		shader_set_uniform_f(uni_fade_amount, settings.fade_amount);
		shader_set_uniform_f(uni_fade_angle, settings.fade_angle);
	}
	
	/// @ignore
	static ExportData = function() {
		return {
			name : instanceof(self),
			params : [settings.enabled, settings.intensity, settings.scale, settings.tiling, settings.speedd, settings.angle, settings.contrast, settings.powerr, settings.remap, ["color", settings.color], settings.mix, settings.mix_threshold, ["texture", settings.noise_tex], ["vec2", settings.offset], settings.fade_amount, settings.fade_angle],
		};
	}
}

#endregion

#region Speedlines

/// @desc Anime-like speedlines effect. Useful for demonstrating amazement in visual novels or speed in racing games, among others.
/// @param {Bool} enabled Defines whether the effect starts active or not.
/// @param {Real} scale Noise scale. Values close to 0 make lines more stretched. 0 to 20 recommended.
/// @param {Real} tiling Repetition of noise rays. 1 to 16 recommended.
/// @param {Real} speedd Lines movement speed.
/// @param {Real} rot_speed Rotation speed.
/// @param {Real} contrast Lines contrast.
/// @param {Real} powerr Helps make lines sharper. 0 to 1 recommended.
/// @param {Real} remap Central softness. 0 to 0.99 recommended.
/// @param {Real} color The speedlines color tint.
/// @param {Real} mask_power Defines the radial center area of the mask, based on position. 0 to 15 recommended.
/// @param {Real} mask_scale Defines the radial mask scale. 0 to 3 recommended.
/// @param {Real} mask_smoothness Defines the mask border smoothness. 0 to 1.
/// @param {Pointer.Texture} noise_tex The noise texture to be used by the effect. NOTE: You need to enable "Separate Texture Page" in sprite properties, otherwise you will get visual artifacts.
function FX_SpeedLines(enabled, scale=0.1, tiling=5, speedd=2, rot_speed=1, contrast=0.5, powerr=1, remap=0.8, color=c_white, mask_power=5, mask_scale=1.2, mask_smoothness=1, noise_tex=undefined) : __ppf_fx_super_class() constructor {
	effect_name = "speedlines";
	can_change_order = false;
	stack_order = PPFX_STACK.FINAL;
	stack_shared = true;
	
	settings = {
		enabled : enabled,
		scale : scale,
		tiling : tiling,
		speedd : speedd,
		rot_speed : rot_speed,
		contrast : contrast,
		powerr : powerr,
		remap : remap,
		color : make_color_ppfx(color),
		mask_power : mask_power,
		mask_scale : mask_scale,
		mask_smoothness : mask_smoothness,
		noise_tex : __ppf_is_undefined(noise_tex) ? __PPF_ST.noise_simplex : noise_tex,
	};
	
	uni_enable = shader_get_uniform(__ppf_sh_render_final, "u_speedlines_enable");
	uni_scale = shader_get_uniform(__ppf_sh_render_final, "u_speedlines_scale");
	uni_tiling = shader_get_uniform(__ppf_sh_render_final, "u_speedlines_tiling");
	uni_speedd = shader_get_uniform(__ppf_sh_render_final, "u_speedlines_speed");
	uni_rot_speed = shader_get_uniform(__ppf_sh_render_final, "u_speedlines_rot_speed");
	uni_contrast = shader_get_uniform(__ppf_sh_render_final, "u_speedlines_contrast");
	uni_powerr = shader_get_uniform(__ppf_sh_render_final, "u_speedlines_power");
	uni_remap = shader_get_uniform(__ppf_sh_render_final, "u_speedlines_remap");
	uni_colorr = shader_get_uniform(__ppf_sh_render_final, "u_speedlines_color");
	uni_mask_power = shader_get_uniform(__ppf_sh_render_final, "u_speedlines_mask_power");
	uni_mask_scale = shader_get_uniform(__ppf_sh_render_final, "u_speedlines_mask_scale");
	uni_mask_smoothness = shader_get_uniform(__ppf_sh_render_final, "u_speedlines_mask_smoothness");
	uni_noise_tex = shader_get_sampler_index(__ppf_sh_render_final, "u_speedlines_noise_tex");
	
	static Draw = function(renderer) {
		if (!settings.enabled) exit;
		shader_set_uniform_f(uni_enable, settings.enabled);
		shader_set_uniform_f(uni_scale, settings.scale);
		shader_set_uniform_f(uni_tiling, settings.tiling);
		shader_set_uniform_f(uni_speedd, settings.speedd);
		shader_set_uniform_f(uni_rot_speed, settings.rot_speed);
		shader_set_uniform_f(uni_contrast, settings.contrast);
		shader_set_uniform_f(uni_powerr, settings.powerr);
		shader_set_uniform_f(uni_remap, settings.remap);
		shader_set_uniform_f(uni_mask_power, settings.mask_power);
		shader_set_uniform_f(uni_mask_scale, settings.mask_scale);
		shader_set_uniform_f(uni_mask_smoothness, settings.mask_smoothness);
		shader_set_uniform_f_array(uni_colorr, settings.color);
		if (settings.noise_tex != undefined) texture_set_stage(uni_noise_tex, settings.noise_tex);
		gpu_set_tex_repeat_ext(uni_noise_tex, true);
	}
	
	/// @ignore
	static ExportData = function() {
		return {
			name : instanceof(self),
			params : [settings.enabled, settings.scale, settings.tiling, settings.speedd, settings.rot_speed, settings.contrast, settings.powerr, settings.remap, ["color", settings.color], settings.mask_power, settings.mask_scale, settings.mask_smoothness, ["texture", settings.noise_tex]],
		};
	}
}

#endregion

#region Dithering

/// @desc Dithering removes color banding artifacts in gradients, usually seen in sky boxes due to color quantization. It is also used for aesthetic purposes.
/// @param {Bool} enabled Defines whether the effect starts active or not.
/// @param {Real} mode Dithering technique to be used. 0 = Traditional | 1 = Custom | 2 = Custom | 3 = Luminance based
/// @param {Real} intensity How intense the dithering effect is applied.
/// @param {Real} bit_levels The color bit levels.
/// @param {Real} contrast The dithering contrast (not available in mode 0). Default is 1.
/// @param {Real} threshold Set the level of brightness to filter out pixels under this level. 0 to 1; 0 means all light pixels.
/// @param {Real} scale Pixel scale to compensate viewport size.
/// @param {Pointer.Texture} [bayer_texture] Bayer texture to be used by dithering. This is a small square texture. NOTE: You need to enable "Separate Texture Page" in sprite properties, otherwise you will get visual artifacts.
/// @param {Real} bayer_size Dithering square texture sprite side size.
function FX_Dithering(enabled, mode=0, intensity=1, bit_levels=8, contrast=1, threshold=0, scale=1, bayer_texture=undefined, bayer_size=8) : __ppf_fx_super_class() constructor {
	effect_name = "dithering";
	can_change_order = false;
	stack_order = PPFX_STACK.FINAL;
	stack_shared = true;
	
	settings = {
		enabled : enabled,
		mode : mode,
		intensity : intensity,
		bit_levels : bit_levels,
		contrast : contrast,
		threshold : threshold,
		scale : scale,
		bayer_texture : __ppf_is_undefined(bayer_texture) ? __PPF_ST.bayer_8x8 : bayer_texture,
		bayer_size : bayer_size,
	};
	
	uni_enable = shader_get_uniform(__ppf_sh_render_final, "u_dither_enable");
	uni_mode = shader_get_uniform(__ppf_sh_render_final, "u_dither_mode");
	uni_intensity = shader_get_uniform(__ppf_sh_render_final, "u_dither_intensity");
	uni_bit_levels = shader_get_uniform(__ppf_sh_render_final, "u_dither_bit_levels");
	uni_contrast = shader_get_uniform(__ppf_sh_render_final, "u_dither_contrast");
	uni_threshold = shader_get_uniform(__ppf_sh_render_final, "u_dither_threshold");
	uni_scale = shader_get_uniform(__ppf_sh_render_final, "u_dither_scale");
	uni_bayer_texture = shader_get_sampler_index(__ppf_sh_render_final, "u_dither_bayer_tex");
	uni_bayer_size = shader_get_uniform(__ppf_sh_render_final, "u_dither_bayer_size");
	
	static Draw = function(renderer) {
		if (!settings.enabled) exit;
		shader_set_uniform_f(uni_enable, settings.enabled);
		shader_set_uniform_f(uni_mode, settings.mode);
		shader_set_uniform_f(uni_intensity, settings.intensity);
		shader_set_uniform_f(uni_bit_levels, settings.bit_levels);
		shader_set_uniform_f(uni_contrast, settings.contrast);
		shader_set_uniform_f(uni_threshold, settings.threshold);
		shader_set_uniform_f(uni_scale, settings.scale);
		shader_set_uniform_f(uni_bayer_size, settings.bayer_size);
		if (settings.bayer_texture != undefined) texture_set_stage(uni_bayer_texture, settings.bayer_texture);
	}
	
	/// @ignore
	static ExportData = function() {
		return {
			name : instanceof(self),
			params : [settings.enabled, settings.mode, settings.intensity, settings.bit_levels, settings.contrast, settings.threshold, settings.scale, settings.bayer_texture, settings.bayer_size],
		};
	}
}

#endregion

#region Noise Grain

/// @desc Simulates the random optical texture of photographic film, usually caused by small particles being present on the physical film;
/// @param {Bool} enabled Defines whether the effect starts active or not.
/// @param {Real} intensity Noise grain texture alpha. 0 to 1.
/// @param {Real} luminosity The brightness level of the noise. 0 to 1.
/// @param {Real} scale Noise scale. 0 to 1 recommended.
/// @param {Bool} speedd Define if the Noise Grain speed.
/// @param {Bool} mix Defines if the noise is mixed with the screen.
/// @param {Pointer.Texture} noise_tex Noise texture. Use sprite_get_texture() or surface_get_texture(). NOTE: You need to enable "Separate Texture Page" in sprite properties, otherwise you will get visual artifacts.
/// @param {Real} noise_size Noise texture size. The size is used for both width and height. Example: 256 (pixels).
function FX_NoiseGrain(enabled, intensity=0.3, luminosity=0.0, scale=0.5, speedd=true, mix=true, noise_tex=undefined, noise_size=256) : __ppf_fx_super_class() constructor {
	effect_name = "noise_grain";
	can_change_order = false;
	stack_order = PPFX_STACK.FINAL;
	stack_shared = true;
	
	settings = {
		enabled : enabled,
		intensity : intensity,
		luminosity : luminosity,
		scale : scale,
		speedd : speedd,
		mix : mix,
		noise_tex : __ppf_is_undefined(noise_tex) ? __PPF_ST.noise_point : noise_tex,
		noise_size : noise_size,
	};
	
	uni_enable = shader_get_uniform(__ppf_sh_render_final, "u_noise_grain_enable");
	uni_resolution = shader_get_uniform(__ppf_sh_render_final, "u_noise_grain_res");
	uni_intensity = shader_get_uniform(__ppf_sh_render_final, "u_noise_grain_intensity");
	uni_luminosity = shader_get_uniform(__ppf_sh_render_final, "u_noise_grain_luminosity");
	uni_scale = shader_get_uniform(__ppf_sh_render_final, "u_noise_grain_scale");
	uni_speedd = shader_get_uniform(__ppf_sh_render_final, "u_noise_grain_speed");
	uni_mix = shader_get_uniform(__ppf_sh_render_final, "u_noise_grain_mix");
	uni_noise_tex = shader_get_sampler_index(__ppf_sh_render_final, "u_noise_grain_tex");
	
	static Draw = function(renderer) {
		if (!settings.enabled) exit;
		shader_set_uniform_f(uni_enable, settings.enabled);
		shader_set_uniform_f(uni_intensity, settings.intensity);
		shader_set_uniform_f(uni_luminosity, settings.luminosity);
		shader_set_uniform_f(uni_scale, settings.scale);
		shader_set_uniform_f(uni_speedd, settings.speedd);
		shader_set_uniform_f(uni_mix, settings.mix);
		if (settings.noise_tex != undefined) {
			shader_set_uniform_f(uni_resolution, settings.noise_size, settings.noise_size);
			texture_set_stage(uni_noise_tex, settings.noise_tex);
		}
		gpu_set_tex_repeat_ext(uni_noise_tex, true);
	}
	
	/// @ignore
	static ExportData = function() {
		return {
			name : instanceof(self),
			params : [settings.enabled, settings.intensity, settings.luminosity, settings.scale, settings.speedd, settings.mix, ["texture", settings.noise_tex]],
		};
	}
}

#endregion

#region Vignette

/// @desc Vignetting is the term for the darkening and/or desaturating towards the edges of an image compared to the center. You can use vignetting to draw focus to the center of an image;
/// @param {Bool} enabled Defines whether the effect starts active or not.
/// @param {Real} intensity Vignette alpha/transparency.
/// @param {Real} curvature Vignette roundness.
/// @param {Real} inner The inside area of Vignette. From 0 to 2.
/// @param {Real} outer The outside area of Vignette. From 0 to 2.
/// @param {Real} color Vigentte color.
/// @param {Array<Real>} center The position. An array with the normalized values (0 to 1), in this format: [x, y].
/// @param {Bool} rounded Defines that the Vignette will be a perfect circle.
/// @param {Bool} linear Use a linear curve or not.
function FX_Vignette(enabled, intensity=0.7, curvature=0.3, inner=0.3, outer=1, color=c_black, center=[0.5,0.5], rounded=false, linear=false) : __ppf_fx_super_class() constructor {
	effect_name = "vignette";
	can_change_order = false;
	stack_order = PPFX_STACK.FINAL;
	stack_shared = true;
	
	settings = {
		enabled : enabled,
		intensity : intensity,
		curvature : curvature,
		inner : inner,
		outer : outer,
		color : make_color_ppfx(color),
		center : center,
		rounded : rounded,
		linear : linear,
	};
	
	uni_enable = shader_get_uniform(__ppf_sh_render_final, "u_vignette_enable");
	uni_intensity = shader_get_uniform(__ppf_sh_render_final, "u_vignette_intensity");
	uni_curvature = shader_get_uniform(__ppf_sh_render_final, "u_vignette_curvature");
	uni_inner = shader_get_uniform(__ppf_sh_render_final, "u_vignette_inner");
	uni_outer = shader_get_uniform(__ppf_sh_render_final, "u_vignette_outer");
	uni_colorr = shader_get_uniform(__ppf_sh_render_final, "u_vignette_color");
	uni_center = shader_get_uniform(__ppf_sh_render_final, "u_vignette_center");
	uni_rounded = shader_get_uniform(__ppf_sh_render_final, "u_vignette_rounded");
	uni_linear = shader_get_uniform(__ppf_sh_render_final, "u_vignette_linear");
	
	static Draw = function(renderer) {
		if (!settings.enabled) exit;
		shader_set_uniform_f(uni_enable, settings.enabled);
		shader_set_uniform_f(uni_intensity, settings.intensity);
		shader_set_uniform_f(uni_curvature, settings.curvature);
		shader_set_uniform_f(uni_inner, settings.inner);
		shader_set_uniform_f(uni_outer, settings.outer);
		shader_set_uniform_f_array(uni_colorr, settings.color);
		shader_set_uniform_f_array(uni_center, settings.center);
		shader_set_uniform_f(uni_rounded, settings.rounded);
		shader_set_uniform_f(uni_linear, settings.linear);
	}
	
	/// @ignore
	static ExportData = function() {
		return {
			name : instanceof(self),
			params : [settings.enabled, settings.intensity, settings.curvature, settings.inner, settings.outer, ["color", settings.color], ["vec2", settings.center]],
		};
	}
}

#endregion

#region Nes Fade

/// @desc Simulation of the NES transition.
/// @param {Bool} enabled Defines whether the effect starts active or not.
/// @param {Real} amount Fade amount. 1 is full dark.
/// @param {Real} levels Number of colors to be used (posterization).
function FX_NESFade(enabled, amount=0, levels=8) : __ppf_fx_super_class() constructor {
	effect_name = "nes_fade";
	can_change_order = false;
	stack_order = PPFX_STACK.FINAL;
	stack_shared = true;
	
	settings = {
		enabled : enabled,
		amount : amount,
		levels : levels,
	};
	
	uni_enable = shader_get_uniform(__ppf_sh_render_final, "u_nes_fade_enable");
	uni_amount = shader_get_uniform(__ppf_sh_render_final, "u_nes_fade_amount");
	uni_levels = shader_get_uniform(__ppf_sh_render_final, "u_nes_fade_levels");
	
	static Draw = function(renderer) {
		if (!settings.enabled) exit;
		shader_set_uniform_f(uni_enable, settings.enabled);
		shader_set_uniform_f(uni_amount, settings.amount);
		shader_set_uniform_f(uni_levels, settings.levels);
	}
	
	/// @ignore
	static ExportData = function() {
		return {
			name : instanceof(self),
			params : [settings.enabled, settings.amount, settings.levels],
		};
	}
}

#endregion

#region Fade

/// @desc Simple fade to color effect (color overlay).
/// @param {Bool} enabled Defines whether the effect starts active or not.
/// @param {Real} amount Fade amount. 1 is full blended.
/// @param {Real} color The fade color.
function FX_Fade(enabled, amount=0, color=c_black) : __ppf_fx_super_class() constructor {
	effect_name = "fade";
	can_change_order = false;
	stack_order = PPFX_STACK.FINAL;
	stack_shared = true;
	
	settings = {
		enabled : enabled,
		amount : amount,
		color : make_color_ppfx(color),
	};
	
	uni_enable = shader_get_uniform(__ppf_sh_render_final, "u_fade_enable");
	uni_amount = shader_get_uniform(__ppf_sh_render_final, "u_fade_amount");
	uni_colorr = shader_get_uniform(__ppf_sh_render_final, "u_fade_color");
	
	static Draw = function(renderer) {
		if (!settings.enabled) exit;
		shader_set_uniform_f(uni_enable, settings.enabled);
		shader_set_uniform_f(uni_amount, settings.amount);
		shader_set_uniform_f_array(uni_colorr, settings.color);
	}
	
	/// @ignore
	static ExportData = function() {
		return {
			name : instanceof(self),
			params : [settings.enabled, settings.amount, ["color", settings.color]],
		};
	}
}

#endregion

#region Scanlines

/// @desc Draw horizontal lines over the screen. It helps to simulate the effects of old CRT TVs.
/// @param {Bool} enabled Defines whether the effect starts active or not.
/// @param {Real} intensity Lines alpha. 0 to 1.
/// @param {Real} sharpness Lines sharpness. 0 to 1.
/// @param {Real} speedd Lines vertical movement speed. 0 to 5 recommended.
/// @param {Real} amount Lines amount. 0 to 1.
/// @param {Real} color Lines color tint. Example: c_black.
/// @param {Real} mask_power Defines the radial center area of the mask, based on position. 0 to 15 recommended.
/// @param {Real} mask_scale Defines the radial mask scale. 0 to 3 recommended.
/// @param {Real} mask_smoothness Defines the mask border smoothness. 0 to 1.
function FX_ScanLines(enabled, intensity=0.1, sharpness=0, speedd=0.3, amount=0.7, color=c_black, mask_power=0, mask_scale=1.2, mask_smoothness=1) : __ppf_fx_super_class() constructor {
	effect_name = "scanlines";
	can_change_order = false;
	stack_order = PPFX_STACK.FINAL;
	stack_shared = true;
	
	settings = {
		enabled : enabled,
		intensity : intensity,
		sharpness : sharpness,
		speedd : speedd,
		amount : amount,
		color : make_color_ppfx(color),
		mask_power : mask_power,
		mask_scale : mask_scale,
		mask_smoothness : mask_smoothness,
	};
	
	uni_enable = shader_get_uniform(__ppf_sh_render_final, "u_scanlines_enable");
	uni_intensity = shader_get_uniform(__ppf_sh_render_final, "u_scanlines_intensity");
	uni_sharpness = shader_get_uniform(__ppf_sh_render_final, "u_scanlines_sharpness");
	uni_speedd = shader_get_uniform(__ppf_sh_render_final, "u_scanlines_speed");
	uni_amount = shader_get_uniform(__ppf_sh_render_final, "u_scanlines_amount");
	uni_colorr = shader_get_uniform(__ppf_sh_render_final, "u_scanlines_color");
	uni_mask_power = shader_get_uniform(__ppf_sh_render_final, "u_scanlines_mask_power");
	uni_mask_scale = shader_get_uniform(__ppf_sh_render_final, "u_scanlines_mask_scale");
	uni_mask_smoothness = shader_get_uniform(__ppf_sh_render_final, "u_scanlines_mask_smoothness");
	
	static Draw = function(renderer) {
		if (!settings.enabled) exit;
		shader_set_uniform_f(uni_enable, settings.enabled);
		shader_set_uniform_f(uni_intensity, settings.intensity);
		shader_set_uniform_f(uni_sharpness, settings.sharpness);
		shader_set_uniform_f(uni_speedd, settings.speedd * 10);
		shader_set_uniform_f(uni_amount, settings.amount);
		shader_set_uniform_f_array(uni_colorr, settings.color);
		shader_set_uniform_f(uni_mask_power, settings.mask_power);
		shader_set_uniform_f(uni_mask_scale, settings.mask_scale);
		shader_set_uniform_f(uni_mask_smoothness, settings.mask_smoothness);
	}
	
	/// @ignore
	static ExportData = function() {
		return {
			name : instanceof(self),
			params : [settings.enabled, settings.intensity, settings.sharpness, settings.speedd, settings.amount, ["color", settings.color], settings.mask_power, settings.mask_scale, settings.mask_smoothness],
		};
	}
}

#endregion

#region Cinema Bars

/// @desc Creates vertical and horizontal bars for artistic cinematic effects.
/// @param {Bool} enabled Defines whether the effect starts active or not.
/// @param {Real} amount Bars level. 0 to 1.
/// @param {Real} intensity Bars alpha. 0 to 1.
/// @param {Real} color Bars color. Example: c_black.
/// @param {Bool} vertical_enable Enable vertical bars.
/// @param {Bool} horizontal_enable Enable horizontal bars.
/// @param {Bool} can_distort If active, the bars will distort according to the lens distortion effect.
function FX_CinemaBars(enabled, amount=0.2, intensity=1, color=c_black, vertical_enable=true, horizontal_enable=false, can_distort=false) : __ppf_fx_super_class() constructor {
	effect_name = "cinema_bars";
	can_change_order = false;
	stack_order = PPFX_STACK.FINAL;
	stack_shared = true;
	
	settings = {
		enabled : enabled,
		amount : amount,
		intensity : intensity,
		color : make_color_ppfx(color),
		vertical_enable : vertical_enable,
		horizontal_enable : horizontal_enable,
		can_distort : can_distort,
	};
	
	uni_enable = shader_get_uniform(__ppf_sh_render_final, "u_cinama_bars_enable");
	uni_amount = shader_get_uniform(__ppf_sh_render_final, "u_cinema_bars_amount");
	uni_intensity = shader_get_uniform(__ppf_sh_render_final, "u_cinema_bars_intensity");
	uni_colorr = shader_get_uniform(__ppf_sh_render_final, "u_cinema_bars_color");
	uni_vertical_enable = shader_get_uniform(__ppf_sh_render_final, "u_cinema_bars_vertical_enable");
	uni_horizontal_enable = shader_get_uniform(__ppf_sh_render_final, "u_cinema_bars_horizontal_enable");
	uni_can_distort = shader_get_uniform(__ppf_sh_render_final, "u_cinema_bars_can_distort");
	
	static Draw = function(renderer) {
		if (!settings.enabled) exit;
		shader_set_uniform_f(uni_enable, settings.enabled);
		shader_set_uniform_f(uni_amount, settings.amount);
		shader_set_uniform_f(uni_intensity, settings.intensity);
		shader_set_uniform_f_array(uni_colorr, settings.color);
		shader_set_uniform_f(uni_vertical_enable, settings.vertical_enable);
		shader_set_uniform_f(uni_horizontal_enable, settings.horizontal_enable);
		shader_set_uniform_f(uni_can_distort, settings.can_distort);
	}
	
	/// @ignore
	static ExportData = function() {
		return {
			name : instanceof(self),
			params : [settings.enabled, settings.amount, settings.intensity, ["color", settings.color], settings.vertical_enable, settings.horizontal_enable, settings.can_distort],
		};
	}
}

#endregion

#region Color Blindness

/// @desc Try to fix color blindness of Protanopia, Deutanopia and Tritanopia.
/// @param {Bool} enabled Defines whether the effect starts active or not.
/// @param {Real} mode Fix mode: 0 > Protanopia | 1 > Deutanopia | 2 > Tritanopia.
function FX_ColorBlindness(enabled, mode=0) : __ppf_fx_super_class() constructor {
	effect_name = "color_blindness";
	can_change_order = false;
	stack_order = PPFX_STACK.FINAL;
	stack_shared = true;
	
	settings = {
		enabled : enabled,
		mode : mode,
	};
	
	uni_enable = shader_get_uniform(__ppf_sh_render_final, "u_color_blindness_enable");
	uni_mode = shader_get_uniform(__ppf_sh_render_final, "u_color_blindness_mode");
	
	static Draw = function(renderer) {
		if (!settings.enabled) exit;
		shader_set_uniform_f(uni_enable, settings.enabled);
		shader_set_uniform_f(uni_mode, settings.mode);
	}
	
	/// @ignore
	static ExportData = function() {
		return {
			name : instanceof(self),
			params : [settings.enabled, settings.mode],
		};
	}
}

#endregion

#region Channels

/// @desc Sets color levels per channel.
/// @param {Bool} enabled Defines whether the effect starts active or not.
/// @param {real} red The red amount. 0 to 1.
/// @param {real} green The green amount. 0 to 1.
/// @param {real} blue The blue amount. 0 to 1.
function FX_Channels(enabled, red=1, green=1, blue=1) : __ppf_fx_super_class() constructor {
	effect_name = "channels";
	can_change_order = false;
	stack_order = PPFX_STACK.FINAL;
	stack_shared = true;
	
	settings = {
		enabled : enabled,
		red : red,
		green : green,
		blue : blue,
	};
	
	uni_enable = shader_get_uniform(__ppf_sh_render_final, "u_channels_enable");
	uni_rgb = shader_get_uniform(__ppf_sh_render_final, "u_channel_rgb");
	
	static Draw = function(renderer) {
		if (!settings.enabled) exit;
		shader_set_uniform_f(uni_enable, settings.enabled);
		shader_set_uniform_f(uni_rgb, settings.red, settings.green, settings.blue);
	}
	
	/// @ignore
	static ExportData = function() {
		return {
			name : instanceof(self),
			params : [settings.enabled, settings.red, settings.green, settings.blue],
		};
	}
}

#endregion

#region Border

/// @desc Creates an edge gradient effect at the corners of the screen. Intended to be used when using Lens Distortion effect, to hide non-UV artifacts.
/// @param {Bool} enabled Defines whether the effect starts active or not.
/// @param {Real} curvature The border curvature. 0 to 1 recommended.
/// @param {Real} smooth Border smoothness. 0 to 1 recommended.
/// @param {Real} color The border color. Example: c_black.
function FX_Border(enabled, curvature=0, smooth=0, color=c_black) : __ppf_fx_super_class() constructor {
	effect_name = "border";
	can_change_order = false;
	stack_order = PPFX_STACK.FINAL;
	stack_shared = true;
	
	settings = {
		enabled : enabled,
		curvature : curvature,
		smooth : smooth,
		color : make_color_ppfx(color),
	};
	
	uni_enable = shader_get_uniform(__ppf_sh_render_final, "u_border_enable");
	uni_curvature = shader_get_uniform(__ppf_sh_render_final, "u_border_curvature");
	uni_smooth = shader_get_uniform(__ppf_sh_render_final, "u_border_smooth");
	uni_color = shader_get_uniform(__ppf_sh_render_final, "u_border_color");
	
	Draw = function(renderer) {
		if (!settings.enabled) exit;
		shader_set_uniform_f(uni_enable, settings.enabled);
		shader_set_uniform_f(uni_curvature, settings.curvature);
		shader_set_uniform_f(uni_smooth, settings.smooth);
		shader_set_uniform_f_array(uni_color, settings.color);
	}
	
	/// @ignore
	static ExportData = function() {
		return {
			name : instanceof(self),
			params : [settings.enabled, settings.curvature, settings.smooth, ["color", settings.color]],
		};
	}
}

#endregion

#endregion


#region Modding
#region Internal [don't touch]

global.__ppf_external_effects = [];
global.__ppf_external_stacks = [new __ST_Base(), new __ST_ColorGrading(), new __ST_Final()];

// This is used to access the index (__effects_indexes) of the effect (order matter)
// wrong values can give "out of range" errors
#macro FX_EFFECT_EXT global.__ppf_effect_ext_enum
global.__ppf_effect_ext_enum = {}; // example: SSAO : FX_EFFECT.__SIZE+1


/// @ignore
function __ppf_include_external_shared_stacks(classes_array=undefined) {
	if (is_undefined(classes_array) && !is_array(classes_array)) exit;
	var _size = array_length(classes_array), _temp_shared_stack_struct = undefined;
	if (_size == 0) exit;
	
	for (var i = 0; i < _size; ++i) {
		// instantiate stack to access data from it
		_temp_shared_stack_struct = new classes_array[i]();
		
		array_push(global.__ppf_external_stacks, _temp_shared_stack_struct);
	}
	__ppf_trace($"External stacks loaded: {_size}", 2);
}

/// @ignore
function __ppf_include_external_effects(classes_array=undefined) {
	if (is_undefined(classes_array) && !is_array(classes_array)) exit;
	var _size = array_length(classes_array), _temp_effect_struct = undefined;
	if (_size == 0) exit;
	
	var _from_index = FX_EFFECT.__SIZE;
	
	for (var i = 0; i < _size; ++i) {
		// instantiate effect to access data from it
		_temp_effect_struct = new classes_array[i]();
		
		global.__ppf_effect_ext_enum[$ string_upper(_temp_effect_struct.effect_name)] = _from_index + i; // for FX_EFFECT_EXT.
		array_push(global.__ppf_effects_names, _temp_effect_struct.effect_name); // for effect name reference
		array_push(global.__ppf_external_effects, _temp_effect_struct);
	}
	__ppf_trace($"External effects loaded: {_size}", 2);
}

#endregion


// ---------- Import stuff ------------
// Load external stacks (only use constructor names). Include your shared stacks in an array
__ppf_include_external_shared_stacks();
	
// Load external effects (only use constructor names). Include your effects in an array. Example: [FX_Sketch, FX_Halftone]
__ppf_include_external_effects();


#endregion
