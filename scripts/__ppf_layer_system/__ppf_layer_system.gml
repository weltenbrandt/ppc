
/*-------------------------------------------------------------------------------------------------
	These functions are independent, so if you delete them from the asset, nothing will happen.
-------------------------------------------------------------------------------------------------*/

/// Feather ignore all

/// @desc Create a renderer for layers, which can use a post-processing system to apply effects to layers.
/// This class also allows to only render the content of a layer to a surface, without Post-Processing.
/// @returns {Struct}
function PPFX_LayerRenderer() constructor {
	__ppf_trace($"Layer Renderer created. {__ppf_get_context()}", 3);
	
	__room_size_based = false;
	__top_layer = -1;
	__bottom_layer = -1;
	__top_method = -1;
	__bottom_method = -1;
	__ppf_index = undefined;
	__cam_index = -1;
	__surf = -1;
	__surf_x = 0;
	__surf_y = 0;
	__surf_w = 2;
	__surf_h = 2;
	__is_render_enabled = true;
	__use_ppfx = true;
	__is_ready = false;
	__destroyed = false;
	
	__surf_width = 1;
	__surf_height = 1;
	__cloned_cam = -1;
	//__temp_cam = -1;
	
	#region Private Methods
	
	/// @ignore
	static __clone_curr_cam = function() {
		if (__cloned_cam == -1) {
			__cloned_cam = camera_create();
		}
		// copy transforms from active camera
		camera_copy_transforms(__cloned_cam, camera_get_active());
	}
	
	#endregion
	
	#region Public Methods
	
	/// @func Destroy()
	/// @desc This function deletes a previously created post-processing layer, freeing memory. This function also removes layer scripts.
	/// @returns {undefined}
	static Destroy = function() {
		__ppf_surface_delete(__surf);
		layer_script_begin(__bottom_layer, -1);
		layer_script_end(__top_layer, -1);
		//if (__temp_cam != -1) {
		//	camera_destroy(__temp_cam);
		//	__temp_cam = -1;
		//}
		if (__cloned_cam != -1) {
			camera_destroy(__cloned_cam);
			__cloned_cam = -1;
		}
		__destroyed = true;
	}
	
	/// @func Clean()
	/// @desc Clean LayerRenderer, without destroying it.
	/// Useful for when toggling rendering and want to make sure existing surfaces are destroyed.
	/// NOTE: It doesn't remove the effects or disable rendering completely. If you want to destroy, use .Destroy() method.
	/// @returns {undefined}
	static Clean = function() {
		__ppf_surface_delete(__surf);
	}
	
	/// @desc Toggle whether layer renderer can render on layer.
	/// If disabled, nothing will be rendered to the surface. That is, the layer will be drawn without the effects. Disabling this releases the system usage on the GPU.
	/// @param {Real} enable Will be either true (enabled, the default value) or false (disabled). The rendering will toggle if nothing or -1 is entered.
	/// @returns {undefined}
	static SetRenderEnable = function(enable=-1) {
		if (enable == -1) {
			__is_render_enabled = !__is_render_enabled;
		} else {
			__is_render_enabled = enable;
		}
	}
	
	/// @func SetRange(top_layer_id, bottom_layer_id)
	/// @desc This function defines a new range of layers from an existing ppfx layer system.
	/// 
	/// Make sure the top layer is above the bottom layer in order. If not, it may not render correctly.
	/// 
	/// Please note: You CANNOT select a range to which the layer has already been in range by another system. This will give an unbalanced surface stack error. If you want to use more effects, just add more effects to the profile.
	/// @param {Id.Layer} top_layer_id The top layer, in the room editor.
	/// @param {Id.Layer} bottom_layer_id The bottom layer, in the room editor.
	static SetRange = function(top_layer_id, bottom_layer_id) {
		__ppf_exception(!layer_exists(top_layer_id) || !layer_exists(bottom_layer_id), "One of the layers does not exist in the current room.");
		if (layer_get_depth(top_layer_id) > layer_get_depth(bottom_layer_id)) {
			__ppf_trace("WARNING: Inverted layer range order. Failed to render between layers: " + layer_get_name(top_layer_id) + ", " + layer_get_name(bottom_layer_id), 2);
		}
		__ppf_surface_delete(__surf);
		layer_script_begin(__bottom_layer, -1);
		layer_script_end(__top_layer, -1);
		__top_layer = top_layer_id;
		__bottom_layer = bottom_layer_id;
		layer_script_begin(__bottom_layer, __top_method);
		layer_script_end(__top_layer, __bottom_method);
	}
	
	/// @func GetSurface()
	/// @desc This function gets the surface with layer contents.
	/// @param {Bool} with_effects If true, it will return the surface of the layer with the effects applied (get post-processing surface). False is without the effects (get layer surface).
	/// @returns {Id.Surface} Surface index.
	static GetSurface = function(with_effects) {
		if (with_effects) {
			__ppf_exception(!ppfx_system_exists(__ppf_index), "The post-processing system does not exist, but you tried to get your surface.");
			return __ppf_index.GetRenderSurface();
		} else {
			return __surf;
		}
	}
	
	/// @func IsReady()
	/// @desc This function checks if the post-processing layer is ready to render, which allows you to get its surface safely (especially in HTML5).
	/// @returns {Undefined}
	static IsReady = function() {
		return __is_ready;
	}
	
	/// @func IsRenderEnabled()
	/// @desc This functions checks if the rendering of effects in the layer is enabled.
	static IsRenderEnabled = function() {
		return __is_render_enabled;
	}
	
	
	#endregion
	
	#region Render
	
	/// @func Apply(pp_index, top_layer_id, bottom_layer_id, draw_layer)
	///
	/// @desc This function applies post-processing to one or more layers. You only need to call this ONCE in an object's "Create" or "Room Start" Event. Do NOT draw the post-processing system manually, if you use this. This function already draws the Post-Processing on the layer.
	///
	/// Make sure the Top Layer is above the Bottom Layer in order. If not, it may not render correctly.
	///
	/// Please note: You CANNOT select a range to which the layer has already been in range by another system. This will give an unbalanced surface stack error. If you want to use more effects, just add more effects to the profile.
	/// @param {Struct} pp_index The returned variable by "new PPFX_System()". You can use -1, noone or undefined, to not use a post-processing system, this way you can render the layer content on the surface only.
	/// @param {Id.Layer} top_layer_id The top layer, in the room editor
	/// @param {Id.Layer} bottom_layer_id The bottom layer, in the room editor
	/// @param {Bool} draw_layer If false, the surface (with layer contents) will not draw. The layer contents will still be rendered to the surface.
	/// @returns {Undefined}
	static Apply = function(pp_index, top_layer_id, bottom_layer_id, draw_layer=true) {
		__ppf_trace($"Layer rendering from: {layer_get_name(top_layer_id)} to: {layer_get_name(bottom_layer_id)}", 3);
		__ppf_exception(!layer_exists(top_layer_id), $"{top_layer_id} layer doesn't exists in the current room. Can't draw on the layer.");
		__ppf_exception(!layer_exists(bottom_layer_id), $"{bottom_layer_id} layer doesn't exists in the current room. Can't draw on the layer.");
		__ppf_exception(layer_get_depth(top_layer_id) > layer_get_depth(bottom_layer_id), "Inverted layer range order. Failed to render on layers: " + layer_get_name(top_layer_id) + ", " + layer_get_name(bottom_layer_id));
		if (event_type != ev_create && event_type != ev_other && event_type >= 0) __ppf_trace("WARNING: You are calling <LayerRenderer>.Apply() in the wrong event.", 2);
		
		// run once
		__use_ppfx = !__ppf_is_undefined(pp_index);
		if (__use_ppfx) {
			pp_index.SetDrawEnable(draw_layer);
			pp_index.__layered = true;
		}
		__top_layer = top_layer_id;
		__bottom_layer = bottom_layer_id;
		__ppf_index = pp_index;
		
		// run every step
		__top_method = function() {
			if (!__is_render_enabled) exit;
			if (event_type != ev_draw || event_number != 0) return;
			
			var _draw_surface = surface_get_target();
			var _draw_width = surface_get_width(_draw_surface);
			var _draw_height = surface_get_height(_draw_surface);
			
			if (_draw_width <= 0 || _draw_height <= 0) return;
			
			if (!surface_exists(__surf)) {
				__surf = surface_create(_draw_width, _draw_height, global.__ppf_main_texture_format);
			} else if ((__surf_width != _draw_width) || (__surf_height != _draw_height)) {
				surface_resize(__surf, _draw_width, _draw_height);
		   	}
			
			__surf_width = _draw_width;
			__surf_height = _draw_height;
			
			__clone_curr_cam();
			
			surface_set_target(__surf);
			draw_clear_alpha(c_black, 0);
			//draw_surface(_draw_surface, 0, 0);
			camera_apply(__cloned_cam);
		}
		
		__bottom_method = function() {
			if (!__is_render_enabled) exit;
			if (event_type != ev_draw || event_number != 0) return;
			
			if (surface_exists(__surf)) {
				surface_reset_target();
				
				//if (__temp_cam == -1) {
				//	__temp_cam = camera_create_view(0, 0, __surf_width, __surf_height);
				//} else {
				//	camera_set_view_size(__temp_cam, __surf_width, __surf_height);
				//}
				
				//camera_apply(__temp_cam);
				if (__use_ppfx) __ppf_index.Draw(__surf, camera_get_view_x(__cloned_cam), camera_get_view_y(__cloned_cam), camera_get_view_width(__cloned_cam), camera_get_view_height(__cloned_cam), __surf_width, __surf_height);
				
				//draw_surface(__surf, 0, 0);
				//camera_apply(__cloned_cam);
				
				__is_ready = true;
			}
		}
		
		layer_script_begin(__bottom_layer, __top_method);
		layer_script_end(__top_layer, __bottom_method);
	}
	
	#endregion
}

/// @desc Checks if a previously created post-processing layer exists.
/// @param {any} pp_layer_index description
/// @returns {bool} description
function ppfx_layer_renderer_exists(pp_layer_index) {
	return (is_struct(pp_layer_index) && instanceof(pp_layer_index) == "PPFX_LayerRenderer");
}
