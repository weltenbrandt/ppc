
// Feather ignore all

/// @desc Create post-processing system instance. The PPFX system essentially contains the effects renderer. It works both for full screen and for layers.
/// @returns {struct} Post-Processing system id.
function PPFX_System() constructor {
	__ppf_trace($"System created. {__ppf_get_context()}", 3);
	// Base
	__render_x = 0;
	__render_y = 0;
	__render_w = 0;
	__render_h = 0;
	__source_surface_exists = true;
	__render_surface_width = 0;
	__render_surface_height = 0;
	__render_old_surface_width = 0;
	__render_old_surface_height = 0;
	__render_res = 1;
	__render_old_res = __render_res;
	__current_profile = noone;
	__destroyed = false;
	__layered = false;
	__time = 0;
	
	// Main
	__stack_surface = array_create(PPFX_STACK.__SIZE + array_length(global.__ppf_external_effects) + array_length(global.__ppf_external_stacks), -1); // for each individual effect and shared stack
	__stack_names = array_create(array_length(__stack_surface), "");
	__stack_index = 0;
	
	// shared stacks
	__shared_stacks_array = []; // array with shared stacks structs (base, grading, final and external)
	__ppf_array_copy_all(global.__ppf_external_stacks, __shared_stacks_array);
	__shared_stacks_array_len = array_length(__shared_stacks_array);
	
	// effects
	__effects_array = []; // array with effects struct (imported via profile)
	__effects_array_len = 0;
	
	__effects_names = []; // names for effects names reference
	__ppf_array_copy_all(global.__ppf_effects_names, __effects_names);
	__effects_names_len = array_length(__effects_names);
	
	__effects_indexes = []; // indexes for effects enum reference (calculated when reordering effects)
	
	// Confs
	__is_draw_enabled = true;
	__is_render_enabled = true;
	__global_intensity = 1;
	__surface_tex_format = global.__ppf_main_texture_format;
	
	// others
	__debug_func_start = undefined;
	__debug_func_end = undefined;
	__debug_sys_usage = 0;
	__cg_linear_lut_sprite = -1;
	__cg_baked_lut_surf = -1;
	
	#region Private Methods
	
	// check if some effect exists in this system
	/// @ignore
	static __effect_exists = function(effect_index) {
		return __effects_array[__effects_indexes[effect_index]].effect_name == __effects_names[effect_index];
	}
	
	// get specific effect struct
	/// @ignore
	static __get_effect_struct = function(effect_index) {
		if (__effect_exists(effect_index)) {
			return __effects_array[__effects_indexes[effect_index]];
		} else {
			return noone;
		}
	}
	
	// count all effects in this system
	// when: ProfileLoad, ProfileUnload
	/// @ignore
	static __get_effects_count = function() {
		__effects_array_len = array_length(__effects_array);
	}
	
	// stack sort function
	/// @ignore
	static __stack_sort_func = function(a, b) {
		return a.stack_order - b.stack_order;
	}
	
	// used for reordering effects
	/// @ignore
	static __reorder_stack = function() {
		// do a bubble sort (based on stack/rendering order)
		array_sort(__effects_array, __stack_sort_func);
		
		// get effects indexes (for effect search reference)
		__effects_indexes = array_create(__effects_names_len, 0);
		var i = 0, k = 0;
		repeat(__effects_array_len) {
			k = 0;
			repeat(__effects_names_len) {
				if (__effects_array[i].effect_name == __effects_names[k]) {
					__effects_indexes[k] = i;
					break;
				}
				++k;
			}
			++i;
		}
	}
	
	// get and execute shared stack
	/// @ignore
	static __run_shared_stack = function(index, is_start, surface_width, surface_height, time, global_intensity) {
		var j = 0, _stack = undefined;
		repeat(__shared_stacks_array_len) {
			_stack = __shared_stacks_array[j];
			
			// run method if index matches
			if (index == _stack.stack_index) {
				if (is_start) {
					_stack.Start(self, surface_width, surface_height, time, global_intensity);
				} else {
					_stack.End(self, surface_width, surface_height, time, global_intensity);
				}
			}
			++j;
		}
	}
	
	// each effect has a surface (except shared stacks, which shares the same surface)
	/// @ignore
	static __create_stack_surface = function(width, height, name) {
		__stack_index++;
		if (!surface_exists(__stack_surface[__stack_index])) {
			__stack_names[__stack_index] = name;
			__stack_surface[__stack_index] = surface_create(width, height, __surface_tex_format);
		}
	}
	
	#endregion
	
	#region Public Methods
	
	/// @func ProfileLoad(profile_id)
	/// @desc This function loads a previously created profile.
	/// Which means that the post-processing system will apply the settings of the effects contained in the profile, showing them consequently.
	/// @param {Struct} profile_id Profile id created with ppfx_profile_create().
	/// @param {Bool} merge If you want to merge the profile with existing effects in the system (without replacing).
	/// @returns {undefined}
	static ProfileLoad = function(profile_id, merge=false) {
		__ppf_exception(!is_struct(profile_id), "Profile Index is not a struct.");
		if (__current_profile != profile_id) {
			// clean current effects
			if (os_browser == browser_not_a_browser) Clean(); // prevent bug in HTML5
			var _loaded_count = 0;
			
			// copy new effects
			var _profile_effects_array = profile_id.__effects_array;
			if (merge) {
				// merge
				// count effects
				__get_effects_count();
				
				//__effects_array = array_concat(__effects_array, _profile_effects_array);
				var i = 0, isize = array_length(_profile_effects_array), j = 0, _effect = undefined, _exists = false;
				repeat(isize) {
					_effect = _profile_effects_array[i];
					_exists = false;
					// check if effect already exists in this system
					j = 0;
					repeat(__effects_array_len) {
						if (_effect.effect_name == __effects_array[j].effect_name) {
							_exists = true;
							break;
						}
						++j;
					}
					if (!_exists) {
						array_push(__effects_array, _effect);
						_loaded_count++;
					}
					++i;
				}
			} else {
				// copy and replace
				_loaded_count = array_length(_profile_effects_array);
				array_resize(__effects_array, 0);
				array_copy(__effects_array, 0, _profile_effects_array, 0, _loaded_count);
			}
			
			// count effects
			__get_effects_count();
			
			// sort stack based on order
			__reorder_stack();
			
			// loaded successful
			__ppf_trace($"Profile loaded: {profile_id.__profile_name} ({_loaded_count} effects loaded) {__ppf_get_context()}", 3);
			__current_profile = profile_id;
		}
	}
	
	
	/// @func ProfileUnload()
	/// @desc This function removes any profile associated with this post-processing system.
	static ProfileUnload = function() {
		if (__current_profile != noone) {
			Clean();
			array_resize(__effects_array, 0);
			__get_effects_count();
			__ppf_trace($"Profile unloaded: {__current_profile.__profile_name} {__ppf_get_context()}", 3);
			__current_profile = noone;
		}
	}
	
	/// @func Destroy()
	/// @desc Destroy post-processing system.
	/// @returns {undefined}
	static Destroy = function() {
		if (!__destroyed) {
			ProfileUnload();
			__ppf_trace($"System deleted. {__ppf_get_context()}", 3);
			__cg_linear_lut_sprite = -1; // remove color grading bake lut sprite
			__destroyed = true;
		}
	}
	
	/// @func Clean()
	/// @desc Clean post-processing system, without destroying it.
	/// Useful for when toggling effects and want to make sure existing surfaces are destroyed.
	/// @returns {undefined}
	static Clean = function() {
		// clean system surfaces
		__ppf_surface_delete_array(__stack_surface, 1);
		__ppf_surface_delete(__cg_baked_lut_surf);
		
		// execute effects clean method
		var k = __effects_array_len-1, _effect_struct = undefined;
		repeat(__effects_array_len) {
			_effect_struct = __effects_array[k];
			if (_effect_struct.Clean != undefined) _effect_struct.Clean();
			--k;
		}
		__ppf_trace($"System cleaned. {__ppf_get_context()}", 3);
	}
	
	/// @func SetDrawEnable(enable)
	/// @desc Toggle whether the post-processing system can draw.
	/// Please note that if disabled, it may still be rendered if rendering is enabled (will continue to demand GPU).
	/// @param {real} enable Will be either true (enabled, the default value) or false (disabled). The drawing will toggle if nothing or -1 is entered.
	/// @returns {undefined}
	static SetDrawEnable = function(enable=-1) {
		if (enable == -1) {
			__is_draw_enabled = !__is_draw_enabled;
		} else {
			__is_draw_enabled = enable;
		}
	}
	
	/// @func SetRenderEnable(enable)
	/// @desc Toggle whether the post-processing system can render.
	/// Please note that if enabled, it can render to the surface even if not drawing!
	/// @param {Real} enable Will be either true (enabled, the default value) or false (disabled). The rendering will toggle if nothing or -1 is entered.
	/// @returns {undefined}
	static SetRenderEnable = function(enable=-1) {
		if (enable == -1) {
			__is_render_enabled = !__is_render_enabled;
		} else {
			__is_render_enabled = enable;
		}
	}
	
	/// @func SetGlobalIntensity(value)
	/// @desc Defines the overall draw intensity of the post-processing system.
	/// The global intensity defines the interpolation between the original image and with the effects applied.
	/// @param {real} value Intensity, 0 for none (default image), and 1 for full.
	/// @returns {undefined}
	static SetGlobalIntensity = function(value=1) {
		__global_intensity = value;
	}
	
	/// @func SetRenderResolution(resolution)
	/// @desc This function modifies the final rendering resolution of the post-processing system, based on a percentage (0 to 1).
	/// @param {real} resolution Value from 0 to 1 that is multiplied internally with the final resolution of the system's final rendering view.
	/// @returns {real} Value between 0 and 1.
	static SetRenderResolution = function(resolution=1) {
		__render_res = clamp(resolution, 0.01, 1);
		if (__render_res != __render_old_res) {
			Clean();
			// reset surface resolution to detect changes and recreate surfaces
			__render_old_surface_width = 0;
			__render_old_surface_height = 0;
			__render_old_res = __render_res;
		}
	}
	
	/// @func SetEffectParameter(effect_index, param, value)
	/// @desc Modify a single parameter (setting) of an effect.
	/// Use this to modify an effect's attribute in real-time.
	/// @param {Real} effect_index Effect index. Use the enumerator, example: FX_EFFECT.BLOOM.
	/// @param {String} param Parameter macro. Example: PP_BLOOM_COLOR.
	/// @param {Any} value Parameter value. Example: make_color_rgb_ppfx(255, 255, 255).
	/// @returns {undefined}
	static SetEffectParameter = function(effect_index, param, value) {
		if (__effects_array_len == 0) exit;
		var _ef = __effects_array[__effects_indexes[effect_index]];
		if (_ef.effect_name != __effects_names[effect_index]) {
			__ppf_trace($"'{__effects_names[effect_index]}' effect does not exists in the {instanceof(self)} instance (not loaded from a profile).", 1);
			exit;
		}
		_ef.settings[$ param] = value;
	}
	
	/// @func SetEffectParameters(effect_index, params_array, values_array)
	/// @desc Modify various parameters (settings) of an effect.
	/// Use this if you want to modify an effect's attributes in real-time.
	/// @param {Real} effect_index Effect index. Use the enumerator, example: FX_EFFECT.BLOOM.
	/// @param {Array} params_array Array with the effect parameters. Use the pre-defined macros, for example: [PP_BLOOM_COLOR, PP_BLOOM_INTENSITY].
	/// @param {Array} values_array Array with parameter values, must be in the same order.
	/// @returns {undefined}
	static SetEffectParameters = function(effect_index, params_array, values_array) {
		if (__effects_array_len == 0) exit;
		var _ef = __effects_array[__effects_indexes[effect_index]];
		if (_ef.effect_name != __effects_names[effect_index]) {
			__ppf_trace($"'{__effects_names[effect_index]}' effect does not exists in the {instanceof(self)} instance (not loaded from a profile).", 1);
			exit;
		}
		var _struct_names = variable_struct_get_names(_ef.settings),
		_len_params = array_length(params_array),
		_len_names = array_length(_struct_names),
		i = 0, _name = "";
		repeat(_len_names) {
			var j = 0;
			repeat(_len_params) {
				_name = _struct_names[i];
				if (_name == params_array[j]) {
					_ef.settings[$ _name] = values_array[j];
				}
				++j;
			}
			++i;
		}
	}
	
	/// @func SetEffectEnable(effect_index, enable)
	/// @desc This function toggles the effect rendering.
	/// @param {Real} effect_index Effect index. Use the enumerator, example: FX_EFFECT.BLOOM.
	/// @param {Real} enable Will be either true (enabled) or false (disabled). The rendering will toggle if nothing or -1 is entered.
	/// @returns {undefined}
	static SetEffectEnable = function(effect_index, enable=-1) {
		if (__effects_array_len == 0) exit;
		var _ef = __effects_array[__effects_indexes[effect_index]];
		if (_ef.effect_name != __effects_names[effect_index]) {
			__ppf_trace($"'{__effects_names[effect_index]}' effect does not exists in the {instanceof(self)} instance (not loaded from a profile).", 1);
			exit;
		}
		if (enable == -1) {
			_ef.settings.enabled = !_ef.settings.enabled;
		} else {
			if (!enable) {
				// clean effect if it was disabled
				if (_ef.Clean != undefined) _ef.Clean();
			}
			_ef.settings.enabled = enable;
		}
	}
	
	/// @func SetEffectOrder(new_order)
	/// @desc This function defines the order in which an effect will be rendered in the stack. You can use the PPFX_STACK enum to base the order on some other stacks.
	static SetEffectOrder = function(effect_index, new_order) {
		if (__effects_array_len == 0) exit;
		var _ef = __effects_array[__effects_indexes[effect_index]];
		if (_ef.effect_name != __effects_names[effect_index]) {
			__ppf_trace($"'{__effects_names[effect_index]}' effect does not exists in the {instanceof(self)} instance (not loaded from a profile).", 1);
			exit;
		}
		_ef.SetOrder(new_order);
		__reorder_stack();
	}
	
	/// @func IsEffectEnabled()
	/// @desc Returns true if effect rendering is enabled, and false if not.
	/// @param {Real} effect_index Effect index. Use the enumerator, example: FX_EFFECT.BLOOM.
	/// @returns {Bool}
	static IsEffectEnabled = function(effect_index) {
		if (__effects_array_len == 0) exit;
		var _ef = __effects_array[__effects_indexes[effect_index]];
		if (_ef.effect_name != __effects_names[effect_index]) {
			__ppf_trace($"'{__effects_names[effect_index]}' effect does not exists in the {instanceof(self)} instance (not loaded from a profile).", 1);
			exit;
		}
		return _ef.settings.enabled;
	}
	
	/// @func IsDrawEnabled()
	/// @desc Returns true if post-processing system drawing is enabled, and false if not.
	/// @returns {Bool}
	static IsDrawEnabled = function() {
		return __is_draw_enabled;
	}
	
	/// @func IsRenderEnabled()
	/// @desc Returns true if post-processing system rendering is enabled, and false if not.
	/// @returns {Bool}
	static IsRenderEnabled = function() {
		return __is_render_enabled;
	}
	
	/// @func GetRenderSurface()
	/// @desc Returns the post-processing system final rendering surface.
	/// @returns {Id.Surface} Surface index.
	static GetRenderSurface = function() {
		return __stack_surface[__stack_index];
	}
	
	/// @func GetStackSurface()
	/// @desc Returns the specific stack rendering surface.
	/// @param {Real} index The stack index.
	/// @returns {Id.Surface} Surface index.
	static GetStackSurface = function(index) {
		return __stack_surface[clamp(index, 0, __stack_index)];
	}
	
	/// @func GetRenderResolution()
	/// @desc Returns the post-processing system rendering percentage (0 to 1).
	/// @returns {real} Normalized size.
	static GetRenderResolution = function() {
		return __render_res;
	}
	
	/// @func GetEffectParameter(effect_index, param)
	/// @desc Get a single parameter (setting) value of an effect.
	/// @param {Real} effect_index Effect index. Use the enumerator, example: FX_EFFECT.BLOOM.
	/// @param {String} param Parameter macro. Example: PP_BLOOM_COLOR.
	/// @returns {Any}
	static GetEffectParameter = function(effect_index, param) {
		if (__effects_array_len == 0) exit;
		var _ef = __effects_array[__effects_indexes[effect_index]];
		if (_ef.effect_name != __effects_names[effect_index]) {
			__ppf_trace($"'{__effects_names[effect_index]}' effect does not exists in the {instanceof(self)} instance (not loaded from a profile).", 1);
			exit;
		}
		return _ef.settings[$ param];
	}
	
	/// @func GetEffectOrder(effect_index)
	/// @desc Gets the order the effect is rendered on the stack.
	/// @param {Real} effect_index Effect index. Use the enumerator, example: FX_EFFECT.BLOOM.
	/// @returns {Any}
	static GetEffectOrder = function(effect_index) {
		if (__effects_array_len == 0) exit;
		var _ef = __effects_array[__effects_indexes[effect_index]];
		if (_ef.effect_name != __effects_names[effect_index]) {
			__ppf_trace($"'{__effects_names[effect_index]}' effect does not exists in the {instanceof(self)} instance (not loaded from a profile).", 1);
			exit;
		}
		return _ef.stack_order;
	}
	
	/// @func GetGlobalIntensity()
	/// @desc Get the overall draw intensity of the post-processing system.
	/// The global intensity defines the interpolation between the original image and with the effects applied.
	/// This function returns a value between 0 and 1.
	/// @returns {Real} Value between 0 and 1.
	static GetGlobalIntensity = function() {
		return __global_intensity;
	}
	
	/// @func DisableAllEffects()
	/// @desc This function disables all system effects immediately.
	/// @returns {Undefined}
	static DisableAllEffects = function() {
		if (__effects_array_len == 0) exit;
		var i = 0;
		repeat(__effects_array_len) {
			__effects_array[i].settings.enabled = false;
			++i;
		}
	}
	
	/// @func SetBakingLUT(sprite)
	/// @desc Set a sprite (neutral LUT image) to bake all color grading stack into it
	/// @param {Asset.GMSprite} sprite The neutral linear LUT to be used to bake. You can use a LUT returned by PPFX_LUTGenerator(). Use -1 to remove it.
	/// @ignore
	static SetBakingLUT = function(sprite) {
		__cg_linear_lut_sprite = sprite;
		if (sprite == -1) {
			__ppf_surface_delete(__cg_baked_lut_surf);
		}
	}
	
	/// @func GetBakedLUT()
	/// @desc Bake all color grading stack into a LUT image
	/// @returns {Asset.GMSprite} The modified LUT to be used with FX_LUT().
	/// @ignore
	static GetBakedLUT = function() {
		if (surface_exists(__cg_baked_lut_surf)) {
			return sprite_create_from_surface(__cg_baked_lut_surf, 0, 0, surface_get_width(__cg_baked_lut_surf), surface_get_height(__cg_baked_lut_surf), false, false, 0, 0);
		}
		return undefined;
	}
	
	#endregion
	
	#region Render
	
	/// @func DrawInFullscreen(surface)
	/// @desc Easily draw Post-Processing system in full screen. It is an alternative to the normal .Draw() method.
	///
	/// This function automatically detects the draw event you are drawing (Post-Draw or Draw GUI Begin).
	///
	/// It uses the size of the referenced surface for internal rendering resolution (example: application_surface size).
	/// 
	/// For the width and height size (scaled rendering size): If drawing in Post-Draw, is the size of the window (frame buffer). If in Draw GUI Begin, the size of the GUI.
	/// @param {Id.Surface} surface Render surface to copy from. (You can use application_surface).
	static DrawInFullscreen = function(surface=application_surface) {
		var _xx = 0, _yy = 0, _width = 0, _height = 0, _surf_width = surface_get_width(surface), _surf_height = surface_get_height(surface);
		if (event_number == ev_draw_post) {
			if (os_type != os_operagx) {
				var _pos = application_get_position();
				_xx = _pos[0];
				_yy = _pos[1];
				_width = _pos[2]-_pos[0];
				_height = _pos[3]-_pos[1];
			} else {
				/*var _scale_x = 1;
				var _scale_y = 1;
				if (GM_build_type == "run") {
					var _pos = application_get_position();
					_xx = 0;
					_yy = 0;
					_width = _pos[2];
					_height = _pos[3];
				} else {
					_width = browser_width;
					_height = browser_height;
				}
				_scale_x = 960 / _width;
				_scale_y = 540 / _height;
				_width *= _scale_x;
				_height *= _scale_y;*/
				
				// because there is a bug in gx.games
				_width = display_get_gui_width();
				_height = display_get_gui_height();
			}
		} else
		if (event_number == ev_gui_begin) {
			_width = display_get_gui_width();
			_height = display_get_gui_height();
		}
		Draw(surface, _xx, _yy, _width, _height, _surf_width, _surf_height);
	}
	
	/// @func Draw(surface, x, y, w, h, surface_width, surface_height)
	/// @desc Draw post-processing system on screen. This function works like draw_surface_stretched().
	/// @param {Id.Surface} surface Render surface to copy from. (You can use application_surface).
	/// @param {real} x The x position og where to draw the surface.
	/// @param {real} y The y position og where to draw the surface.
	/// @param {real} w The width at which to draw the surface.
	/// @param {real} h The height at which to draw the surface.
	/// @param {real} surface_width Width resolution of your game screen (Can use width of application_surface or viewport).
	/// @param {real} surface_height Height resolution of your game screen (Can use height of application_surface or viewport).
	/// @returns {undefined}
	static Draw = function(surface, x, y, w, h, surface_width, surface_height) {
		if (__destroyed) exit;
		__ppf_exception(surface == application_surface && event_number != ev_draw_post && event_number != ev_gui_begin, "Failed to draw using application_surface. You cannot draw a surface within itself.\nIt can only be drawn in the Post-Draw or Draw GUI Begin event.");
		__ppf_exception(__layered && (event_number == ev_draw_post || event_number == ev_gui_begin), "You must not draw the system manually if it is already being applied to a LayerRenderer (using .Apply).");
		
		if (!surface_exists(surface)) {
			if (__source_surface_exists) {
				__ppf_trace("WARNING: trying to draw post-processing using non-existent surface.", 2);
				__source_surface_exists = false;
			}
			exit;
		}
		__source_surface_exists = true;
		gpu_push_state();
		
		// rendering
		if (__is_render_enabled && __global_intensity > 0) {
			if (__debug_func_start != undefined) __debug_func_start();
			
			// time
			__time += PPFX_CFG_SPEED; // multiply with delta time here
			if (PPFX_CFG_TIMER > 0 && __time > PPFX_CFG_TIMER) __time = 0;
			
			// pos and size (read-only)
			__render_x = x;
			__render_y = y;
			__render_w = w;
			__render_h = h;
			
			// if different resolution, delete stuff to be updated
			if (surface_width != __render_old_surface_width || surface_height != __render_old_surface_height) {
				Clean();
				__render_surface_width = surface_width * __render_res;
				__render_surface_height = surface_height * __render_res;
				__render_surface_width -= frac(__render_surface_width);
				__render_surface_height -= frac(__render_surface_height);
				
				__render_old_surface_width = surface_width;
				__render_old_surface_height = surface_height;
			}
			
			// -- STACK PROCESS --
			__stack_index = 0;
			__stack_surface[0] = surface;
			
			// run effects
			if (__effects_array_len > 0) {
				var _depth_disable = surface_get_depth_disable();
				surface_depth_disable(true);
				gpu_set_tex_repeat(false);
				//gpu_set_cullmode(cull_noculling);
				//gpu_set_zwriteenable(false);
				//gpu_set_ztestenable(false);
				
				// loop
				var _current = __effects_array[0], _next = -1,
				_stack_opened = false,
				_stack_opened_index = 0; // order of opened stack
				
				for (var i = 0; i < __effects_array_len; ++i) {
					// current effect object struct
					_current = __effects_array[i];
					
					// stack start (executed once, when opening stack)
					if (!_stack_opened) {
						if (_current.stack_shared && _current.settings.enabled) {
							__run_shared_stack(_current.stack_order, true, __render_surface_width, __render_surface_height, __time, __global_intensity);
							_stack_opened_index = _current.stack_order;
							_stack_opened = true;
						}
					}
					
					// run the draw method from effect struct.
					_current.Draw(self, __render_surface_width, __render_surface_height, __time, __global_intensity);
					
					// stack end
					if (_stack_opened) {
						_next = __effects_array[min(i+1, __effects_array_len-1)];
						if (_next.stack_order != _stack_opened_index || i == __effects_array_len-1) {
							__run_shared_stack(_current.stack_order, false, __render_surface_width, __render_surface_height, __time, __global_intensity);
							_stack_opened = false;
						}
					}
				}
				
				// reset depth buffer state
				surface_depth_disable(_depth_disable);
			}
			// -- STACK END --
			
			// final render
			if (__layered) gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha); else gpu_set_blendenable(false);
			if (__is_draw_enabled) draw_surface_stretched(__stack_surface[__stack_index], x, y, w, h);
			if (__debug_func_end != undefined) __debug_sys_usage = __debug_func_end();
		} else {
			// default surface render
			if (__layered) gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha); else gpu_set_blendenable(false);
			if (__is_draw_enabled) draw_surface_stretched(surface, x, y, w, h);
		}
		
		gpu_pop_state();
	}
	#endregion
}

/// @desc Check if post-processing system exists.
/// @param {Struct} pp_index The returned variable by ppfx_create().
/// @returns {Bool} description.
function ppfx_system_exists(pp_index) {
	return (is_struct(pp_index) && instanceof(pp_index) == "PPFX_System" && !pp_index.__destroyed);
}
