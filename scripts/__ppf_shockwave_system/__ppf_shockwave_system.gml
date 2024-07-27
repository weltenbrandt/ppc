
/*-------------------------------------------------------------------------------------------------
	These functions are independent, so if you delete them from the asset, it will not interfere
	with other features of PPFX.
-------------------------------------------------------------------------------------------------*/

// Feather ignore all

/// @desc Create shockwaves renderer. This will be responsible for drawing the shockwave objects on a surface and sending it to the PPFX_System() instance.
/// @returns {Struct}
function PPFX_ShockwaveRenderer() constructor {
	__ppf_trace($"Shockwaves renderer created. {__ppf_get_context()}", 3);
	
	__surf = -1;
	__shockwave_object_list = [];
	__destroyed = false;
	
	#region Public Methods
	
	/// @desc Destroy shockwave system, freeing it from memory.
	static Destroy = function() {
		__ppf_surface_delete(__surf);
		__destroyed = true;
	}
	
	/// @func AddObject(object)
	/// @desc Adds a shockwave object to the renderer. The system will call the Draw event of the added object whenever it exists.
	/// @param {Asset.GMObject} object Distortion object that will be used to call the Draw Event. Example: [obj_shockwave].
	static AddObject = function(object) {
		array_push(__shockwave_object_list, object);
	}
	
	/// @func RemoveObject(object)
	/// @desc This function removes a previously added renderer object.
	/// @param {Asset.GMObject} object The renderer object.
	static RemoveObject = function(object) {
		var _array = __shockwave_object_list;
		var i = 0, isize = array_length(_array);
		repeat(isize) {
			var _object = _array[i];
			if (_object == object) {
				array_delete(_array, i, 1); i -= 1;
				exit;
			}
			++i;
		}
	}
	
	/// @desc Get the surface used in the shockwave system. Used for debugging generally.
	/// @param {Struct} system_index description
	static GetSurface = function() {
		return __surf;
	}
	
	#endregion
	
	#region Render
	
	/// @func Render(pp_index, camera)
	/// @desc Renderize shockwave surface. Please note that this will not draw the surface, only generate the content.
	/// Basically this function will call the Draw Event of the objects in the array and draw them on the surface.
	/// This surface will be sent to the post-processing system automatically, for it to draw the shockwaves.
	/// @param {Struct} pp_index The returned variable by "new PPFX_System()".
	/// @param {Id.Camera} camera Your current active camera id. You can use view_camera[0].
	/// @param {Real} scale Defines the scale of the internal surface, useful for pixelated effects. Default scale is 1.
	static Render = function(pp_index, camera, scale=1) {
		// Feather disable GM1044
		if (__destroyed) exit;
		__ppf_exception(!ppfx_system_exists(pp_index), "Post-processing system does not exist.");
		
		var _ww = surface_get_width(application_surface) * scale,
			_hh = surface_get_height(application_surface) * scale;
		
		// generate distortion surface
		if (_ww > 0 && _hh > 0) {
			if (!surface_exists(__surf)) {
				__surf = surface_create(_ww, _hh, global.__ppf_main_texture_format);
				// send "normal map" texture to ppfx (you only need to reference it once - when the surface is created, for example)
				pp_index.SetEffectParameter(FX_EFFECT.SHOCKWAVES, PP_SHOCKWAVES_TEXTURE, surface_get_texture(__surf));
			}
			surface_set_target(__surf);
				draw_clear(make_color_rgb(128, 128, 255));
				gpu_push_state();
				gpu_set_tex_filter(true);
				gpu_set_blendmode_ext(bm_dest_color, bm_src_color);
				camera_apply(camera);
				shader_set(__ppf_sh_blend_normals);
				// draw normal map sprites to distort screen
				var _array = __shockwave_object_list;
				var i = 0, isize = array_length(_array);
				repeat(isize) {
					with(_array[i]) event_perform(ev_draw, 0);
					++i;
				}
				shader_reset();
				gpu_pop_state();
			surface_reset_target();
		}
	}
	
	#endregion
}

/// @desc Create a new shockwave instance.
/// @param {Real} x The horizontal X position the object will be created at.
/// @param {Real} y The vertical Y position the object will be created at.
/// @param {String|Id.Layer} layer_id The layer ID (or name) to assign the created instance to.
/// @param {Real} index The shockwave shape (image_index).
/// @param {Real} scale The shockwave size (default: 1).
/// @param {Real} speedd The shockwave speed
/// @param {Asset.GMObject} object The object to be created (shockwave object).
/// @param {Asset.GMAnimCurve} anim_curve The animation curve to be used by shockwave object. It must contain the parameters "scale" and "alpha", which range from 0 to 1.
/// @returns {Id.Instance} Instance id.
function shockwave_instance_create(x, y, layer_id, index=0, scale=1, speedd=1, object=__obj_ppf_shockwave, anim_curve=__ac_ppf_shockwave) {
	var _inst = instance_create_layer(x, y, layer_id, object, {
		visible : false,
		index : index,
		scale : scale,
		spd : speedd,
		anim_curve : anim_curve
	});
	return _inst;
}

/// @desc Check if shockwave renderer exists
/// @param {Struct} system_index The returned variable by shockwave_create().
/// @returns {Bool}
function ppfx_shockwave_renderer_exists(system_index) {
	return (is_struct(system_index) && instanceof(system_index) == "PPFX_ShockwaveRenderer");
}
