
/*-------------------------------------------------------------------------------------------------
	These functions are independent, so if you delete them from the asset, it will not interfere
	with other features of PPFX.
-------------------------------------------------------------------------------------------------*/

/// Feather ignore all

/// @desc Curve LUT generator, useful for Color Curves.
/// @param {Real} size The curve size (width). Higher values allow for more accurate color adjustments. The recommended value is 512.
/// @param {Bool} mirror_x Allows the curve to mirror the first and last points.
/// @returns {Struct}
function PPFX_Curve(size=512, mirror_x=false) constructor {
	__ppf_trace($"Curve created. {__ppf_get_context()}", 3);
	__ppf_exception(size <= 0, "The LUT size must be greater than 0.");
	// They are separated: Surface and Animation Curve
	__is_ready = false;
	__cfg_mirror_x = mirror_x;
	__surface_format = surface_rgba8unorm;
	__curve_surf = -1;
	__curve_surf_backup_buff = buffer_create(0, buffer_grow, 1);
	__curve_sprite = -1;
	__curve_struct = undefined;
	__curve_width = size;
	__curve_height = 1;
	
	// file curve
	__curve_version = "1.0";
	
	// debug
	__debug_surf = -1;
	__debug_old_width = 0;
	__debug_old_height = 0;
	__debug_update_data = true;
	__bake_time_base = 8;
	__bake_time = __bake_time_base;
	
	__debug_ui_in_focus = false;
	__debug_moving_point = false;
	__debug_moving_point_index = 0;
	__debug_curve_list = [
		["", c_white, true],
		["", c_red, true],
		["", c_lime, true],
		["", c_aqua, true],
	];
	__debug_category_to_edit = 0;
	__debug_curve_to_edit = 0;
	
	#region Private Methods
	
	/// @ignore
	static __create_surface = function(recreate=true) {
		if (recreate) {
			// from scratch
			if (surface_exists(__curve_surf)) surface_free(__curve_surf);
			__curve_surf = surface_create(__curve_width, __curve_height, __surface_format);
		} else {
			// only if size changed or doesn't exists
			if (surface_exists(__curve_surf)) {
				if (surface_get_width(__curve_surf) != __curve_width) surface_free(__curve_surf);
			}
			if (!surface_exists(__curve_surf)) {
				__curve_surf = surface_create(__curve_width, __curve_height, __surface_format);
			}
		}
	}
	
	/// @ignore
	static __renderize_curve_surface = function() {
		if (__curve_struct == undefined) exit;
		
		// create a new surface if doesn't exists or if the size changed
		__create_surface(false);
		
		// get curve channels
		var _x_channel = animcurve_get_channel(__curve_struct.asset, __curve_struct.x_channel_name),
			_y_channel = animcurve_get_channel(__curve_struct.asset, __curve_struct.y_channel_name),
			_z_channel = animcurve_get_channel(__curve_struct.asset, __curve_struct.z_channel_name),
			_w_channel = animcurve_get_channel(__curve_struct.asset, __curve_struct.w_channel_name);
		
		// evaluate curves and write to texture
		surface_set_target(__curve_surf);
			draw_clear_alpha(c_black, 0);
			gpu_push_state();
			gpu_set_blendenable(false);
			//gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
			
			var i = 0, isize = __curve_width, _rec = 0, _x = 0;
			repeat(isize) {
				_rec = i / isize;
				draw_set_alpha(clamp(animcurve_channel_evaluate(_w_channel, _rec), 0, 1)); // alpha channel
				draw_set_color(
					make_color_rgb(
						clamp(animcurve_channel_evaluate(_x_channel, _rec), 0, 1)*255,
						clamp(animcurve_channel_evaluate(_y_channel, _rec), 0, 1)*255,
						clamp(animcurve_channel_evaluate(_z_channel, _rec), 0, 1)*255
					)
				);
				_x = _rec*__curve_width;
				draw_line(_x, -1, _x, __curve_height+1); // vertical line
				draw_set_alpha(1);
				draw_set_color(c_white);
				++i;
			}
			gpu_pop_state();
		surface_reset_target();
	}
	
	/// @ignore
	static __backup_surface = function() {
		if (buffer_exists(__curve_surf_backup_buff) && surface_exists(__curve_surf)) {
			buffer_get_surface(__curve_surf_backup_buff, __curve_surf, 0); // from surface to buffer
		}
	}
	
	/// @ignore
	static __restore_surface = function() {
		if (buffer_exists(__curve_surf_backup_buff)) {
			__create_surface(true);
			buffer_set_surface(__curve_surf_backup_buff, __curve_surf, 0); 
		}
	}
	
	/// @ignore
	static __debug_bake = function() {
		// Bake (renderize) debug again. Call it whenever you want to update the debug surface
		__bake_time = __bake_time_base;
	}
	
	#endregion
	
	#region Public Methods
	
	/// @func Destroy()
	/// @desc Destroy the curve with it's contents
	static Destroy = function() {
		if (surface_exists(__curve_surf)) surface_free(__curve_surf);
		if (buffer_exists(__curve_surf_backup_buff)) buffer_delete(__curve_surf_backup_buff);
		if (sprite_exists(__curve_sprite)) sprite_delete(__curve_sprite);
		if (surface_exists(__debug_surf)) surface_free(__debug_surf);
		__is_ready = false;
	}
	
	/// @func LoadAnimCurve(curve_asset, x_channel, y_channel, z_channel, w_channel)
	/// @desc Generate curve gradient from an animation curve. The curve needs 4 channels, and they are RGBA (in order).
	/// @param {Asset.GMAnimCurve} curve_asset The animation curve asset to read data from.
	/// @param {String} x_channel The name of channel X (usually red) or index (default is 0).
	/// @param {String} y_channel The name of channel Y (usually green) or index (default is 1).
	/// @param {String} z_channel The name of channel Z (usually blue) or index (default is 2).
	/// @param {String} w_channel The name of channel W (usually alpha) or index (default is 3).
	static LoadAnimCurve = function(curve_asset, x_channel=0, y_channel=1, z_channel=2, w_channel=3) {
		__ppf_exception(is_undefined(curve_asset), $"Animation Curve asset doesn't exists. Impossible to generate curve.");
		__ppf_exception(x_channel == "", $"Curve channel not found: {x_channel}");
		__ppf_exception(y_channel == "", $"Curve channel not found: {y_channel}");
		__ppf_exception(z_channel == "", $"Curve channel not found: {z_channel}");
		__ppf_exception(w_channel == "", $"Curve channel not found: {w_channel}");
		// TODO: not be limited to 4 channels (may have less)
		
		// get channels (string or real)
		var _x_channel = x_channel,
			_y_channel = y_channel,
			_z_channel = z_channel,
			_w_channel = w_channel;
		
		// turn indices into strings, because we need the channel names
		if (is_real(_x_channel) || is_real(_y_channel) || is_real(_z_channel) || is_real(_w_channel)) {
			var _anim_curve_struct = animcurve_get(curve_asset);
			_x_channel = _anim_curve_struct.channels[x_channel].name;
			_y_channel = _anim_curve_struct.channels[y_channel].name;
			_z_channel = _anim_curve_struct.channels[z_channel].name;
			_w_channel = _anim_curve_struct.channels[w_channel].name;
		}
		
		// generate new curve struct
		__curve_struct = {
			asset : curve_asset,
			x_channel_name : _x_channel,
			y_channel_name : _y_channel,
			z_channel_name : _z_channel,
			w_channel_name : _w_channel,
		};
		
		// generate surface from curve data
		__renderize_curve_surface();
		__backup_surface();
		
		__is_ready = true;
	}
	
	/// @ignore
	/// @func ResetChannel(default_curve_asset)
	/// @desc Reset current editing channel
	static ResetChannel = function(default_curve_asset) {
		var _default_curve_struct = animcurve_get(default_curve_asset);
		var _clone_curve_struct = animcurve_get(__curve_struct.asset);
		
		// create channels and copy from original
		var i = 0, isize = array_length(_default_curve_struct.channels), _current_channel = undefined;
		var _channels = array_create(isize);
		repeat(isize) {
			if (i == __debug_curve_to_edit) {
				// copy from default curve
				_current_channel = _default_curve_struct.channels[i];
			} else {
				// keep the old channels
				_current_channel = _clone_curve_struct.channels[i];
			}
				
			// write/read channels
			_channels[i] = animcurve_channel_new();
			_channels[i].name = _current_channel.name;
			_channels[i].type = _current_channel.type;
			_channels[i].iterations = _current_channel.iterations;
						
			// write/read points from/for channels
			var j = 0, jsize = array_length(_current_channel.points);
			var _points = array_create(jsize);
			repeat(jsize) {
				_points[j] = animcurve_point_new();
				_points[j].posx = _current_channel.points[j].posx;
				_points[j].value = _current_channel.points[j].value;
				++j;
			}
						
			_channels[i].points = _points;
			++i;
		}
			
		// create new curve
		__curve_struct.asset = -1;
		__curve_struct.asset = animcurve_create();
		__curve_struct.asset.name = "Curve";
		__curve_struct.asset.channels = _channels;
		
		// generate surface from curve data
		__renderize_curve_surface();
		__backup_surface();
	}
	
	/// @func LoadSprite(sprite, subimg)
	/// @desc Load a sprite to use as a curve (LDR only).
	/// The sprite size is what you want, but it will be stretched to, for example: 1024x1.
	/// @param {GM.Sprite} sprite The sprite to be used as LUT.
	/// @param {Real} subimg YRGB sprite subimg.
	/// @param {Bool} generate_alpha Allows you to create the alpha channel of an opaque sprite.
	static LoadSprite = function(sprite, subimg=0, generate_alpha=false) {
		// create a new empty surface
		__create_surface(true);
		
		// stretch sprite to fit yrgb surface
		surface_set_target(__curve_surf);
			draw_clear_alpha(c_black, 0);
			gpu_push_state();
			gpu_set_blendenable(false);
			gpu_set_tex_filter(true);
			draw_sprite_stretched(sprite, subimg, 0, 0, __curve_width, __curve_height);
			// write to alpha channel if needed
			if (generate_alpha) {
				gpu_set_colorwriteenable(false, false, false, true);
				draw_set_color(c_white);
				var i = 0, isize = __curve_width, _rec = 0, _x = 0;
				repeat(isize) {
					_rec = i / isize;
					_x = _rec*__curve_width;
					draw_set_alpha(_rec); // linear alpha channel
					draw_line(_x, -1, _x, __curve_height+1); // vertical line
					draw_set_alpha(1);
					++i;
				}
			}
			gpu_pop_state();
		surface_reset_target();
		
		// backup created lut in a buffer
		__backup_surface();
		
		// ready to use
		__is_ready = true;
	}
	
	/// @func LoadSurface(surface)
	/// @desc Load a surface to use as a curve (HDR support).
	/// The surface size is what you want, but it will be stretched to, for example: 1024x1.
	static LoadSurface = function(surface) {
		// create a new yrgb empty surface
		__create_surface(true);
		
		// stretch surface to fit yrgb surface
		surface_set_target(__curve_surf);
			draw_clear_alpha(c_black, 0);
			gpu_push_state();
			gpu_set_blendenable(false);
			draw_surface_stretched(surface, 0, 0, __curve_width, __curve_height);
			gpu_pop_state();
		surface_reset_target();
		
		// backup created lut in a buffer
		__backup_surface();
		
		// ready to use
		__is_ready = true;
	}
	
	/// @func LoadFile(file_path, secure)
	/// @desc Load a external curve file, to use as a color curve look-up table
	static LoadFile = function(file_path, secure=false) {
		if (file_path != "" && file_exists(file_path)) {
			try {
				// load buffer
				var _buffer = undefined;
				if (secure) {
					var _compressed_buffer = buffer_load(file_path);
					_buffer = buffer_decompress(_compressed_buffer);
					buffer_delete(_compressed_buffer);
				} else {
					_buffer = buffer_load(file_path);
				}
				// read all data and get JSON struct
				var _json_string = buffer_read(_buffer, buffer_text);
				var _contents_data = json_parse(_json_string);
				buffer_delete(_buffer);
			
				// -----------
				// copy data from json
				if (_contents_data.version == __curve_version) {
					var _curve_data = _contents_data.curve;
					__curve_width = _contents_data.width;
					
					// >> YRGB new anim curve generate
					if (_curve_data != -1) {
						// delete old curve, if exists
						if (__curve_struct != undefined) {
							if (__curve_struct.asset != undefined) delete __curve_struct.asset;
						}
						
						// create channels and copy from original
						var i = 0, isize = array_length(_curve_data.asset.channels), _current_channel = undefined;
						var _channels = array_create(isize);
						repeat(isize) {
							_current_channel = _curve_data.asset.channels[i];
							
							// write/read channels
							_channels[i] = animcurve_channel_new();
							_channels[i].name = _current_channel.name;
							_channels[i].type = _current_channel.type;
							_channels[i].iterations = _current_channel.iterations;
							
							// write/read points from/for channels
							var j = 0, jsize = array_length(_current_channel.points);
							var _points = array_create(jsize);
							repeat(jsize) {
								_points[j] = animcurve_point_new();
								_points[j].posx = _current_channel.points[j].posx;
								_points[j].value = _current_channel.points[j].value;
								++j;
							}
							
							_channels[i].points = _points;
							++i;
						}
						// create new curve
						__curve_struct = {
							asset : -1,
							x_channel_name : _curve_data.x_channel_name,
							y_channel_name : _curve_data.y_channel_name,
							z_channel_name : _curve_data.z_channel_name,
							w_channel_name : _curve_data.w_channel_name,
						};
						__curve_struct.asset = animcurve_create();
						__curve_struct.asset.name = "Curve";
						__curve_struct.asset.channels = _channels;
						
						// generate surface from curve data
						__renderize_curve_surface();
						__backup_surface();
					}
				} else {
					__ppf_trace($"Curve failed to load: {filename_name(file_path)}. Version not supported: {_contents_data.version} (current: {__curve_version})", 1);
					return -1;
				}
			} catch(error) {
				__ppf_trace($"Curve read error: {filename_name(file_path)}. {error.message}", 1);
				return -1;
			}
			
			__ppf_trace($"Curve loaded: {filename_name(file_path)}", 3);
			return true;
		} else {
			return -1;
		}
	}
	
	/// @func SaveFile(file_path, secure, description)
	/// @desc Save curve to a external curve file, to use as a color curve look-up table
	static SaveFile = function(file_path, secure=false, description=undefined) {
		if (file_path != "") {
			// create json file format
			var _data_struct = {
				version : __curve_version,
				description : description ?? $"Curve exported from Post-Processing FX {PPFX_VERSION}",
				width : __curve_width,
				curve : __curve_struct ?? -1
			}
			if (__curve_struct != undefined) _data_struct.curve.asset = animcurve_get(__curve_struct.asset);
			
			// save to file
			var _json_string = json_stringify(_data_struct, !secure);
			var _buffer = buffer_create(0, buffer_grow, 1);
			buffer_write(_buffer, buffer_text, _json_string);
			
			if (secure) {
				var _buffer_compressed = buffer_compress(_buffer, 0, buffer_get_size(_buffer));
				buffer_save(_buffer_compressed, file_path);
				buffer_delete(_buffer_compressed);
			} else {
				buffer_save(_buffer, file_path);
			}
			buffer_delete(_buffer);
			
			__ppf_trace($"Curve saved to: {file_path}", 3);
			return true;
		} else {
			return -1;
		}
	}
	
	/// @func SaveLUT(file_path)
	/// @desc Export color curve LUT to an external image. The image can be loaded later with .LoadSprite()
	static SaveLUT = function(file_path) {
		if (file_path != "" && surface_exists(__curve_surf)) {
			surface_save(__curve_surf, file_path);
			return true;
		}	else {
			return -1;
		}
	}
	
	/// @ignore
	/// @func DebugDraw(x1, y1, x2, y2, cursor_x, cursor_y, upper_range, lower_range, precision, alpha)
	static DebugDraw = function(x1, y1, x2, y2, cursor_x, cursor_y, upper_range=1, lower_range=0, precision=10, alpha=0) {
		var _width = x2 - x1;
		var _height = y2 - y1;
		if (_width <= 0 || _height <= 0) exit;
		
		if (__curve_struct != undefined) {
			var _in_html5 = (os_browser != browser_not_a_browser);
			// misc
			var _input_left = mouse_check_button(mb_left),
			_input_right = mouse_check_button(mb_right),
			_input_left_pressed = mouse_check_button_pressed(mb_left),
			_input_left_released = mouse_check_button_released(mb_left),
			_input_right_pressed = mouse_check_button_pressed(mb_right),
			_input_middle_pressed = mouse_check_button_pressed(mb_middle),
			_input_mouse_up = mouse_wheel_up(),
			_input_mouse_down = mouse_wheel_down(),
			_current_font = draw_get_font();
			__debug_update_data = false;
			__debug_ui_in_focus = false;
			
			// debug surface
			if (_width != __debug_old_width || _height != __debug_old_height) {
				surface_free(__debug_surf);
				__debug_old_width = _width;
				__debug_old_height = _height;
			}
			if (!surface_exists(__debug_surf)) {
				__debug_surf = surface_create(_width, _height);
				__debug_bake();
			}
			
			// only interact inside
			if (!_in_html5 && (_input_left || _input_right || _input_middle_pressed || _input_mouse_up || _input_mouse_down) && (point_in_rectangle(cursor_x, cursor_y, x1, y1, x2, y2) || __debug_moving_point)) {
				__debug_update_data = true;
				__debug_ui_in_focus = true;
				__debug_bake();
			}
			
			// renderize
			draw_set_font(-1);
			__bake_time = max(__bake_time-1, 0);
			if (__bake_time > 0) {
				// input
				var _input_mx_normalized = __ppf_linearstep(x1, x1+_width, cursor_x);
				var _input_my_normalized = __ppf_linearstep(y1, y1+_height, cursor_y);
				var _input_mx = lerp(0, _width, _input_mx_normalized);
				var _input_my = lerp(0, _height, _input_my_normalized);
				
				// render graph
				//gpu_set_blendmode(bm_add);
				surface_set_target(__debug_surf);
				draw_clear_alpha(c_black, 0);
				draw_set_alpha(alpha);
				draw_rectangle_color(0, 0, _width, _height, 0, 0, 0, 0, false);
				draw_set_alpha(1);
					// Curve Prefs
					__debug_curve_list = [
						[__curve_struct.x_channel_name, c_red, true], // curve name, color, visible
						[__curve_struct.y_channel_name, c_lime, true],
						[__curve_struct.z_channel_name, c_aqua, true],
						[__curve_struct.w_channel_name, c_white, true], 
					];
					var _curve_size = array_length(__debug_curve_list);
					__debug_curve_to_edit += _input_mouse_up - _input_mouse_down;
					__debug_curve_to_edit = clamp(__debug_curve_to_edit, 0, _curve_size-1);
					
					// >> Add Points
					if (_input_middle_pressed) {
						var _old_curve = __curve_struct.asset;
						var _old_curve_struct = animcurve_get(__curve_struct.asset);
						var _old_curve_name = _old_curve_struct.name;
						
						// find current editing channel
						var i = 0, isize = array_length(_old_curve_struct.channels);
						repeat(isize) {
							if (_old_curve_struct.channels[i].name == __debug_curve_list[__debug_curve_to_edit][0]) {
								break;
							}
							++i;
						}
						var _current_channel_index = i;
						var _current_channel_name = _old_curve_struct.channels[_current_channel_index].name;
						
						// create common/fake array
						var j = 0, jsize = array_length(_old_curve_struct.channels[_current_channel_index].points);
						var _fake_points = array_create(jsize);
						repeat(jsize) {
							_fake_points[j] = {
								___posx : _old_curve_struct.channels[_current_channel_index].points[j].posx * 1000,
								___value : _old_curve_struct.channels[_current_channel_index].points[j].value * 1000,
							};
							++j;
						}
						// add custom point to fake array
						var _posy = animcurve_channel_evaluate(_old_curve_struct.channels[_current_channel_index], _input_mx_normalized);
						_fake_points[j] = {
							___posx : _input_mx_normalized * 1000,
							___value : _posy * 1000,
						};
						// sort fake array
						array_sort(_fake_points, function(_a, _b) {
							return _a.___posx - _b.___posx;
						});
						
						// create new points array, with the new values
						var k = 0, ksize = array_length(_fake_points);
						var _new_points = array_create(ksize);
						repeat(ksize) {
							_new_points[k] = animcurve_point_new();
							_new_points[k].posx = _fake_points[k].___posx / 1000;
							_new_points[k].value = _fake_points[k].___value / 1000;
							++k;
						}
						
						// update curve
						// delete old curve, if exists
						if (__curve_struct != undefined) {
							if (__curve_struct.asset != undefined) delete __curve_struct.asset;
						}
						
						// >> CREATE NEW ANIMCURVE
						__curve_struct.asset = animcurve_create();
						
						// add data to the animcurve, keeping original values, but using the new points array instead
						var n = 0, nsize = array_length(_old_curve_struct.channels);
						var _channels = array_create(nsize);
						repeat(nsize) {
							// write/read channels
							_channels[n] = animcurve_channel_new();
							_channels[n].name = _old_curve_struct.channels[n].name;
							_channels[n].type = _old_curve_struct.channels[n].type;
							_channels[n].iterations = _old_curve_struct.channels[n].iterations;
							
							// srite/read points from/for channels
							// verificar o canal selecionado aqui e adicionar os pontos
							
							if (_channels[n].name == _current_channel_name) {
								_channels[n].points = _new_points;
							} else {
								var m = 0, msize = array_length(_old_curve_struct.channels[n].points);
								var _points = array_create(msize);
								repeat(msize) {
									_points[m] = animcurve_point_new();
									_points[m].posx = _old_curve_struct.channels[n].points[m].posx;
									_points[m].value = _old_curve_struct.channels[n].points[m].value;
									++m;
								}
								_channels[n].points = _points;
							}
							++n;
						}
						__curve_struct.asset.name = _old_curve_name;
						__curve_struct.asset.channels = _channels;
					}
					
					// Get Curve
					if (is_undefined(__curve_struct.asset)) exit;
					var _curve_asset = __curve_struct.asset;
					var _curve = animcurve_get(_curve_asset);
					
					// >> Draw
					for (var i = 0; i < _curve_size; ++i) {
						// focus (curve selected)
						var _focused = (__debug_curve_to_edit == i);
						
						// color
						var _channel_color = _focused ? __debug_curve_list[i][1] : c_dkgray;
						draw_set_color(_channel_color);
						
						// visible
						if (!__debug_curve_list[i][2]) continue;
						
						// get curve data
						var _channel_index = animcurve_get_channel_index(_curve_asset, __debug_curve_list[i][0]);
						var _channel = _curve.channels[_channel_index];
						var _points_array = _channel.points;
						
						// visual
						// draw bezier curves
						var _xp = 0;
						var _yp = 0;
						var _xn = 0;
						var _yn = 0;
						var _bezier_size = array_length(_points_array);
						var lm = (1/_bezier_size) / precision;
						for (var c = 0; c <= 1; c += lm) {
							_xp = _xn;
							_yp = _yn;
							_xn = _width*c;
							_yn = _height-_height*__ppf_linearstep(lower_range, upper_range, animcurve_channel_evaluate(_channel, c));
							//_yn = _height-_height*animcurve_channel_evaluate(_channel, c);
							if (c == 0) continue;
							draw_line(_xp, _yp, _xn, _yn);
							if (c == 1) break;
						}
						
						// draw points
						var _points_size = array_length(_points_array);
						for (var p = 0; p < _points_size; p++) {
							var _point = _points_array[p];
							
							// point position (not normalized)
							var _px = _width*_point.posx;
							var _py = _height-_height*__ppf_linearstep(lower_range, upper_range, _point.value);
							
							// manipulate points
							if (_focused) {
								// delete point
								if (_input_right_pressed) {
									// dont delete point if it's the first and last point
									if (p != 0 && p != _points_size-1) {
										if (point_distance(_input_mx, _input_my, _px, _py) < 8) {
											var _points_copy = _channel.points;
											array_delete(_points_copy, p, 1);
											_channel.points = _points_copy;
										}
									}
								}
								
								// move point (normalized)
								if (_input_left_pressed) {
									if (point_distance(_input_mx, _input_my, _px, _py) < 8) {
										__debug_moving_point = true;
										__debug_moving_point_index = p;
									}
								}
								if (__debug_moving_point && p == __debug_moving_point_index) {
									// dont move in "x" if it's the first and last point
									if (p != 0 && p != _points_size-1) {
										_point.posx = _input_mx_normalized;
										//_point.posx = clamp(_point.posx, _points_array[p-1], _points_array[p+1]);
									}
									// mirror points values (the first and last points)
									if (__cfg_mirror_x) {
										if (p == 0) {
											_points_array[_points_size-1].value = _point.value;
										} else
										if (p == _points_size-1) {
											_points_array[0].value = _point.value;
										}
									}
									_point.value = lerp(lower_range, upper_range, 1-_input_my_normalized);
									
									// clamp (normalized)
									_point.posx = clamp(_point.posx, 0, 1);
									_point.value = clamp(_point.value, lower_range, upper_range);
									
									// position text
									var _xx = clamp(_input_mx_normalized * _width, 0, _width);
									var _yy = clamp(_input_my_normalized * _height, 0, _height);
									var _str = $"({_point.posx}, {_point.value})";
									
									var _halign = fa_center;
									var _yoffset = -24;
									if (_xx < _width/4) _halign = fa_left;
									if (_xx > _width-_width/4) _halign = fa_right;
									if (_yy < _height/4) _yoffset *= -1;
									
									// draw point position on mouse
									draw_set_halign(_halign);
									draw_set_valign(fa_middle);
									draw_text(_xx, _yy+_yoffset, _str);
									draw_set_valign(fa_top);
									draw_set_halign(fa_left);
								}
							}
							
							// draw points (not normalized)
							if (_focused && point_distance(_input_mx, _input_my, _px, _py) < 16) draw_set_color(c_white);
							draw_circle(_px, _py, 4, true);
							draw_set_color(_channel_color);
						}
						
						// line target with circle
						if (_focused) {
							var _xx = _input_mx_normalized*_width;
							var _yy = _height-animcurve_channel_evaluate(_channel, _input_mx_normalized)*_height;
							//draw_circle(_xx, _yy, 2, true);
							var _col = draw_get_color();
							draw_set_color(c_silver);
							draw_line(0, _yy, _width, _yy); // horizontal
							draw_line(_xx, 0, _xx, _height); // vertical
							draw_set_color(_col);
						}
					}
					
					// HTML5 warning
					if (_in_html5) {
						draw_set_color(c_white);
						draw_set_halign(fa_center);
						draw_set_valign(fa_bottom);
						draw_text(_width/2, _height-16, "UI editing not available\nin HTML5");
						draw_set_halign(fa_left);
						draw_set_valign(fa_top);
					}
				surface_reset_target();
				gpu_set_blendmode(bm_normal);
			}
			
			// update curves
			if (__debug_update_data) __renderize_curve_surface();
			
			// not moving points
			if (__debug_moving_point) {
				if (_input_left_released) {
					__debug_moving_point = false;
					__debug_moving_point_index = 0;
					__backup_surface();
				}
			}
			draw_set_alpha(1);
			
			// draw surfaces
			draw_surface_stretched_ext(__debug_surf, x1+1, y1+1, _width, _height, c_black, 0.5);
			draw_surface_stretched(__debug_surf, x1, y1, _width, _height);
			
			// border
			draw_set_color(c_white);
			draw_rectangle(x1-1, y1-1, x2, y2, true);
			draw_set_color(c_white);
			draw_set_halign(fa_center);
			draw_set_valign(fa_middle);
			draw_text(x1+8, y1+8, upper_range);
			draw_text(x2-8, y1+8, upper_range);
			draw_text(x1+8, y2-8, lower_range);
			draw_text(x2-8, y2-8, 1);
			draw_set_valign(fa_top);
			
			// current editing channel
			draw_set_halign(fa_center);
			draw_set_color(__debug_curve_list[__debug_curve_to_edit][1]);
			draw_text(x1+_width/2, y2+16, $"Channel: {__debug_curve_list[__debug_curve_to_edit][0]}");
			draw_set_color(c_white);
			draw_set_halign(fa_left);
			
			// reset stuff
			draw_set_font(_current_font);
		}
		
		// no graph available
		if (!surface_exists(__debug_surf)) {
			var _spr_height = sprite_get_height(__spr_ppf_debug_icon);
			var _icon_x = x1+_width/2;
			var _icon_y = y1+_height/2;
			draw_sprite(__spr_ppf_debug_icon, 0, _icon_x, _icon_y-_spr_height/2);
			draw_set_color(c_white);
			draw_set_halign(fa_center);
			draw_set_valign(fa_top);
				draw_text(_icon_x, _icon_y+_spr_height/4, "Graph unavailable.\nNo AnimCurve found.");
			draw_set_halign(fa_left);
		}
		
		// LUT preview
		if (surface_exists(__curve_surf)) {
			draw_surface_stretched(__curve_surf, x1, y1+_height+8, _width, 8);
		}
		
		// return parameters for debug ui usage
		return {
			width : _width,
			height : _height + 48,
			in_focus : __debug_ui_in_focus,
		}
	}
	
	#endregion
}
