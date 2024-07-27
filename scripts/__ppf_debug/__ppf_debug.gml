
/*-------------------------------------------------------------------------------------------------
	These functions are independent, so if you delete them from the asset, nothing will happen.
-------------------------------------------------------------------------------------------------*/

/// Feather ignore all

#region UI INSPECTORS

/// @ignore
function __PPFX_DebugInspectorGenerator() constructor {
	static __PPFX_ClassSelector = function() {
		#region UI
		
		selected_item = 0;
		selected_item_variable = "";
		
		// get instance variables (only if is a struct)
		var _variable_names_array = variable_instance_get_names(other);
		variables_array = [];
		var i = 0, isize = array_length(_variable_names_array), _item = undefined, _variable = undefined;
		repeat(isize) {
			_item = _variable_names_array[i];
			_variable = other[$ _item];
			
			// only add if match
			if (is_struct(_variable) && string_count(string_upper("ppfx"), instanceof(_variable)) > 0) {
				array_push(variables_array, {
					variable_name : _item,
					type : typeof(_variable),
					instof : instanceof(_variable)
				});
			}
			++i;
		}
		
		// Class Selector
		inspector_struct = new __PPF_UIInspector("ClassSelector")
			.AddElement(new __ppf_ui_menu("CLASS SELECTOR | Post-Processing FX", true, 4))
				.AddElement(new __ppf_ui_text_ext("Info", 0, function(element) {
					var _width = element.parent.__panel_width-element.xx-element.parent.__element_xpadding;
					element.width = _width;
					var _text = "Here are listed the classes available in the current object. Select one to open and debug it.\n\nNote: click on the empty space in the upper corner whenever you want to return to this window. RMB to move, RMB+MMB to maximize.";
					return _text;
				}))
			.AddElement(new __ppf_ui_separator())
			.AddElement(new __ppf_ui_method("Names", 0, undefined,
				function(element) {
					// draw variables list
					var _array = variables_array, _text_height = 0, _item = undefined,
					isize = array_length(_array), i = 0,
					_xx = element.xx,
					_yy = element.yy,
					_mx = element.parent.__input_m_x,
					_my = element.parent.__input_m_y,
					_mlp = element.parent.__input_m_left_pressed,
					_mlr = element.parent.__input_m_left_released,
					_height = 0;
					
					draw_set_alpha(element.alpha);
					repeat(isize) {
						_item = _array[i];
						_text_height = string_height(_item);
						
						// select item
						if (point_in_rectangle(_mx, _my, _xx, _yy, _xx+300, _yy+_text_height)) {
							if (_mlp) selected_item = i;
						}
						
						// item selected
						if (i == selected_item) {
							selected_item_variable = _item.variable_name;
							draw_set_color(c_red);
						} else {
							draw_set_color(c_white);
						}
						
						// draw item
						draw_text(_xx, _yy, $"{_item.variable_name} ({_item.type}) | {_item.instof}");
						
						_yy += _text_height + 4;
						_height += _text_height + 4;
						++i;
					}
					draw_set_alpha(1);
					
					return _height + 16;
				}))
			
			.AddElement(new __ppf_ui_button("Open", function() {
				// Set new class for debugging (calling from PPFX_DebugUI) - we are in the same context
				SetClass(other[$ selected_item_variable]);
			}))
		
		// callback [must have it]
		return inspector_struct;
		#endregion
	}
	
	static __PPFX_System = function() {
		#region UI
		// Help:
		// __inspected_class   >>  PPFX_System
		// inspector_struct  >>  __PPF_UIInspector
		// This function is binded to PPFX_DebugUI instance, so I can use it's variables and methods
		
		// Built-in effects
		#region Helper variables
		gui_preset_profiles = new __PPFX_PresetProfile();
		
		gui_ef_set_param_simple = function(value, effect_enum, param) {
			if (__inspected_class.__effects_array_len == 0 || !__inspected_class.__effect_exists(effect_enum)) exit;
			__inspected_class.SetEffectParameter(effect_enum, param, value);
		}
		gui_ef_set_param_enable = function(checked, effect_enum, param) {
			if (__inspected_class.__effects_array_len == 0 || !__inspected_class.__effect_exists(effect_enum)) exit;
			var _check = !checked;
			__inspected_class.SetEffectParameter(effect_enum, param, _check);
			return _check;
		}
		gui_ef_set_enabled = function(checked, effect_enum) {
			//if (!__inspected_class.__effect_exists(effect_enum)) exit;
			var _check = !checked;
			__inspected_class.SetEffectEnable(effect_enum, _check);
			return _check;
		}
		gui_ef_set_param_color_red = function(value, effect_enum, param) {
			if (__inspected_class.__effects_array_len == 0 || !__inspected_class.__effect_exists(effect_enum)) exit;
			__inspected_class.SetEffectParameter(effect_enum, param,
			make_color_rgb_ppfx(value, __inspected_class.GetEffectParameter(effect_enum, param)[1]*255, __inspected_class.GetEffectParameter(effect_enum, param)[2]*255));
		}
		gui_ef_set_param_color_green = function(value, effect_enum, param) {
			if (__inspected_class.__effects_array_len == 0 || !__inspected_class.__effect_exists(effect_enum)) exit;
			__inspected_class.SetEffectParameter(effect_enum, param,
			make_color_rgb_ppfx(__inspected_class.GetEffectParameter(effect_enum, param)[0]*255, value, __inspected_class.GetEffectParameter(effect_enum, param)[2]*255));	
		}
		gui_ef_set_param_color_blue = function(value, effect_enum, param) {
			if (__inspected_class.__effects_array_len == 0 || !__inspected_class.__effect_exists(effect_enum)) exit;
			__inspected_class.SetEffectParameter(effect_enum, param,
			make_color_rgb_ppfx(__inspected_class.GetEffectParameter(effect_enum, param)[0]*255, __inspected_class.GetEffectParameter(effect_enum, param)[1]*255, value));
		}
		gui_ef_set_param_vec2_x = function(value, effect_enum, param) {
			if (__inspected_class.__effects_array_len == 0 || !__inspected_class.__effect_exists(effect_enum)) exit;
			__inspected_class.SetEffectParameter(effect_enum, param, [value, __inspected_class.GetEffectParameter(effect_enum, param)[1]]);
		}
		gui_ef_set_param_vec2_y = function(value, effect_enum, param) {
			if (__inspected_class.__effects_array_len == 0 || !__inspected_class.__effect_exists(effect_enum)) exit;
			__inspected_class.SetEffectParameter(effect_enum, param, [__inspected_class.GetEffectParameter(effect_enum, param)[0], value]);
		}
		
		gui_ef_get_param_simple = function(effect_enum, param) {
			if (__inspected_class.__effects_array_len == 0 || !__inspected_class.__effect_exists(effect_enum)) return 0;
			return __inspected_class.GetEffectParameter(effect_enum, param);
		}
		gui_ef_get_enabled = function(effect_enum) {
			if (__inspected_class.__effects_array_len == 0 || !__inspected_class.__effect_exists(effect_enum)) return false;
			return __inspected_class.IsEffectEnabled(effect_enum);
		}
		gui_ef_get_param_color_red = function(effect_enum, param) {
			if (__inspected_class.__effects_array_len == 0 || !__inspected_class.__effect_exists(effect_enum)) return 0;
			return __inspected_class.GetEffectParameter(effect_enum, param)[0]*255;
		}
		gui_ef_get_param_color_green = function(effect_enum, param) {
			if (__inspected_class.__effects_array_len == 0 || !__inspected_class.__effect_exists(effect_enum)) return 0;
			return __inspected_class.GetEffectParameter(effect_enum, param)[1]*255;
		}
		gui_ef_get_param_color_blue = function(effect_enum, param) {
			if (__inspected_class.__effects_array_len == 0 || !__inspected_class.__effect_exists(effect_enum)) return 0;
			return __inspected_class.GetEffectParameter(effect_enum, param)[2]*255;
		}
		gui_ef_get_param_vec2_x = function(effect_enum, param) {
			if (__inspected_class.__effects_array_len == 0 || !__inspected_class.__effect_exists(effect_enum)) return 0;
			return __inspected_class.GetEffectParameter(effect_enum, param)[0];
		}
		gui_ef_get_param_vec2_y = function(effect_enum, param) {
			if (__inspected_class.__effects_array_len == 0 || !__inspected_class.__effect_exists(effect_enum)) return 0;
			return __inspected_class.GetEffectParameter(effect_enum, param)[1];
		}
		
		gui_bloom_dirtlens_texture_id = -1;
		gui_dof_zdepth_spritetex_id = -1;
		gui_ppfx_info_type = 0;
		gui_yrgb_curve_sprite_id = -1;
		gui_lut_texture_id = -1;
		gui_palette_texture_id = -1;
		gui_motion_blur_texture_id = -1;
		gui_textureoverlay_spritetex_id = -1;
		gui_displacemap_texture_id = -1;
		gui_chromaber_prisma_tex_list = [__spr_ppf_prism_lut_rb, __spr_ppf_prism_lut_gp, __spr_ppf_prism_lut_cp, __spr_ppf_prism_lut_cr, __spr_ppf_prism_lut_bw];
		gui_chromaber_prisma_type = 0;
		gui_noisegrain_noise_tex_list = [__spr_ppf_noise_point, __spr_ppf_noise_blue, __spr_ppf_noise_perlin, __spr_ppf_noise_simplex];
		gui_noisegrain_noise_type = 0;
		gui_colorblind_cur_mode = 0;
		gui_dithering_mode = 0;
		gui_speedlines_noise_tex_list = [__spr_ppf_noise_point, __spr_ppf_noise_blue, __spr_ppf_noise_perlin, __spr_ppf_noise_simplex];
		gui_speedlines_noise_type = 0;
		gui_mist_noise_tex_list = [__spr_ppf_noise_perlin, __spr_ppf_noise_blue, __spr_ppf_noise_simplex, __spr_ppf_noise_point];
		gui_mist_noise_type = 0;
		gui_dithering_bayers = [
			[__spr_ppf_bayer2x2, 2],
			[__spr_ppf_bayer4x4, 4],
			[__spr_ppf_bayer8x8, 8],
			[__spr_ppf_bayer16x16, 16],
		];
		gui_dithering_index = 2;
		gui_shockwaves_lut_list = [__spr_ppf_prism_lut_rb, __spr_ppf_prism_lut_gp, __spr_ppf_prism_lut_cp, __spr_ppf_prism_lut_cr];
		gui_shockwaves_lut_type = 0;
		gui_color_curves_struct = undefined;
		gui_color_curves_curve_index = -1;
		gui_color_curves_get_graph = function() {
			if (__inspected_class.__effects_array_len > 0) {
				var _effect_struct = __inspected_class.__get_effect_struct(FX_EFFECT.COLOR_CURVES);
				if (_effect_struct != noone) {
					gui_color_curves_curve_index += 1;
					if (gui_color_curves_curve_index > 1) gui_color_curves_curve_index = 0;
					switch(gui_color_curves_curve_index) {
						case 0: gui_color_curves_struct = _effect_struct.settings.yrgb_curve; break;
						case 1: gui_color_curves_struct = _effect_struct.settings.hhsl_curve; break;
					}
				}
			}
		}
		gui_color_curves_secure_file = false;
		gui_system_profile_copy = undefined;
		__inspected_class.__debug_func_start = __debug_func_start;
		__inspected_class.__debug_func_end = __debug_func_end;
		#endregion
		
		#region >> MAIN
		// Create ui system
		inspector_struct = new __PPF_UIInspector("PPFX_System")
		
		// main menu
		.AddElement(new __ppf_ui_menu($"RENDERER | Post-Processing FX {PPFX_VERSION}", true, 34))
		// from system
			.AddElement(new __ppf_ui_text_ext("Info", 0, function(element) {
					var _width = element.parent.__panel_width-element.xx-element.parent.__element_xpadding;
					element.width = _width;
					var _text = "The system is responsible for drawing the effects on the screen. You need to import a profile with effects to be able to render something.";
					return _text;
				}))
			.AddElement(new __ppf_ui_separator())
			//.AddElement(new __ppf_ui_text("System:", 0, undefined))
			.AddElement(new __ppf_ui_checkbox("Enable Render", 0, __inspected_class.IsRenderEnabled(), function(checked) {var _check = !checked; __inspected_class.SetRenderEnable(_check); return _check;}))
			.AddElement(new __ppf_ui_checkbox("Enable Drawing", 1, __inspected_class.IsDrawEnabled(), function(checked) {var _check = !checked; __inspected_class.SetDrawEnable(_check); return _check;}))
			.AddElement(new __ppf_ui_slider("Render Resolution", 0, false, __inspected_class.GetRenderResolution(), 0, 1, false, function(output) {__inspected_class.SetRenderResolution(output);}))
			.AddElement(new __ppf_ui_text("0x0", 1, function() {var _surf = __inspected_class.GetRenderSurface(); return $"{surface_get_width(_surf)}x{surface_get_height(_surf)}";}))
			.AddElement(new __ppf_ui_text("Usage:", 1, function() { return __inspected_class.__debug_sys_usage; }))
			.AddElement(new __ppf_ui_checkbox("Bilinear Filtering", 0, gpu_get_tex_filter(), function(checked) {var _check = !checked; gpu_set_tex_filter(_check); return _check;}))
			
			// Profile
			.AddElement(new __ppf_ui_folder("Profile", false, 14))
				.AddElement(new __ppf_ui_folder("Presets", true, 3))
					.AddElement(new __ppf_ui_button("Load Default (Merge)", function() {
						// reset ppfx system profile id, so we can load the same profile again
						__inspected_class.__current_profile = noone;
					
						// load the default profile
						__inspected_class.ProfileLoad(gui_preset_profiles.GetDefault("Game"), true);
					
						// update debug ui to be related to the new profile (default profile)
						UpdateUI();
					}))
					
					.AddElement(new __ppf_ui_button("Load Default (Overwrite)", function() {
						// reset ppfx system profile id, so we can load the same profile again
						__inspected_class.__current_profile = noone;
					
						// load the default profile
						__inspected_class.ProfileLoad(gui_preset_profiles.GetDefault("Game"), false);
					
						// update debug ui to be related to the new profile (default profile)
						UpdateUI();
					}))
				
					.AddElement(new __ppf_ui_separator())
				
				.AddElement(new __ppf_ui_text("From this renderer:", 0, undefined))
				
				.AddElement(new __ppf_ui_button("Export (only enabled effects)", function() {
					var _profile = __inspected_class.__current_profile;
					if (_profile != noone) {
						var _text = _profile.Stringify(false, true, __inspected_class);
						clipboard_set_text(_text);
					} else {
						__ppf_trace("Debug: No profile found in the system.", 0);
					}
				}))
				
				.AddElement(new __ppf_ui_button("Export (all effects)", function() {
					var _profile = __inspected_class.__current_profile;
					if (_profile != noone) {
						var _text = _profile.Stringify(false, false, __inspected_class);
						clipboard_set_text(_text);
					} else {
						__ppf_trace("Debug: No profile found in the system.", 0);
					}
				}))
				
				.AddElement(new __ppf_ui_button("Unload", function() {
					if (__inspected_class.__current_profile != noone) {
						// copy profile before unloading
						gui_system_profile_copy = variable_clone(__inspected_class.__current_profile);
					} else {
						show_debug_message("Debug: Failed to save current profile.");
					}
					// load the default profile
					__inspected_class.ProfileUnload();
				}))
				
				.AddElement(new __ppf_ui_button("Reload (last profile)", function() {
					// load last profile
					if (gui_system_profile_copy != undefined) {
						__inspected_class.ProfileLoad(gui_system_profile_copy, false);
					} else {
						show_debug_message("Debug: Failed to load previous profile.");
					}
				}))
				
				.AddElement(new __ppf_ui_folder("Effects Loaded", false, 4))
					.AddElement(new __ppf_ui_text_ext("Info", 0, function(element) {
						var _width = element.parent.__panel_width-element.xx*2;
						element.width = _width;
						return "Effects that are higher in the list are those that are rendered last (at the top in the stack).\n\n[Experimental] Click and hold to change the effect order. The new order will be the replaced by the yellow effect.\n\nNames in gray are effects with shared stacks (changing order is not allowed here).";
					}))
					.AddElement(new __ppf_ui_separator())
					.AddElement(new __ppf_ui_text("Count", 0, function() {
						return $"Count: {__inspected_class.__effects_array_len} | [enabled] (order) name";
					}))
					.AddElement(new __ppf_ui_method("Effects Array", 0,
						function() {
							current_item = 0;
							selected_item = 0;
							selected_item_struct = noone;
							is_dragging_item = false;
							dragging_item_my = 0;
						},
						function(element) {
							// enable real time ui
							//inspector_struct.__bake();
							
							// draw item list
							var _effects = __inspected_class.__effects_array, _rec = 0, _text = "", _text_height = 0, _effect = undefined, _hovering = false,
							isize = array_length(_effects), i = isize-1,
							_xx = element.xx,
							_yy = element.yy,
							_mx = element.parent.__input_m_x,
							_my = element.parent.__input_m_y,
							_height = 0,
							_ml = element.parent.__input_m_left,
							_mlp = element.parent.__input_m_left_pressed,
							_mlr = element.parent.__input_m_left_released;
							repeat(isize) {
								_rec = i / isize; 
								_effect = _effects[i];
								_text = $"[{_effect.settings.enabled ? "x" : "  "}] ({  string_replace_all(string_format(_effect.stack_order, 3, 0), " ", "0")}) {_effect.effect_name}" + "\n";
								_text_height = string_height(_text);
								
								// get item
								_hovering = point_in_rectangle(_mx, _my, _xx, _yy, _xx+300, _yy+_text_height);
								if (_hovering) {
									// select item
									if (_mlp) {
										selected_item = i;
										selected_item_struct = _effect;
									}
								}
								
								// item selected
								if (i == selected_item) {
									if (_mlp) {
										// get current mouse y
										if (!is_dragging_item) {
											dragging_item_my = _my;
											is_dragging_item = true;
										}
									}
									
									draw_set_color(c_red);
								} else {
									if (_effect.stack_shared) {
										draw_set_color(c_gray);
									} else {
										draw_set_color(c_white);
									}
									
									// draw drag position
									if (is_dragging_item && _hovering) {
										draw_set_color(c_yellow);
										
										if (_ml) {
											var _drag_y_diff = (_yy+_text_height/2) - _my; // get text center difference draw_text(_xx+150, _yy, _drag_y_diff);
											if (_drag_y_diff > 0) {
												// up
												draw_line(_xx, _yy, _xx+300, _yy);
												//current_item = min(i+1, isize-1);
											} else {
												// down
												draw_line(_xx, _yy+_text_height, _xx+300, _yy+_text_height);
												//current_item = max(i-1, 0);
											}
											current_item = i;
										}
									}
								}
								
								// draw item
								draw_text(_xx, _yy, _text);
									
								_yy += _text_height + 2;
								_height += _text_height + 2;
								--i;
							}
							//draw_text(_mx, _my, _effects[current_item].effect_name);
							
							var _swap_mode = true;
							
							// Drag and Swap item order
							if (is_dragging_item && selected_item_struct != noone) {
								// holding left mouse button
								if (_mlr) {
									var _drag_y_diff = dragging_item_my-_my;
									// move if enough dragging
									if (abs(_drag_y_diff) > _text_height/2) {
										if (_swap_mode) {
											var _current_order = selected_item_struct.GetOrder();
											var _new_order = _effects[current_item].GetOrder();
											_effects[current_item].SetOrder(_current_order);
											_effects[selected_item].SetOrder(_new_order);
										} else {
											// -------
											//var _dd = sign(current_item-selected_item);
											//selected_item_struct.SetOrder(_effects[current_item].GetOrder());
											
											// -------
											//var _new_order = _effects[current_item].GetOrder();
											//_effects[selected_item].SetOrder(_new_order);
											
											//for (var k = current_item; k < isize; ++k) {
											//	_effects[k].stack_order += 1 * sign(current_item-selected_item);
											//}
											
											// -------
											//var _orders = [];
											//var _new_order = _effects[current_item].GetOrder();
											
											//// fill order array
											//for (var i = 0; i < isize; ++i) {
											//	_orders[i] = _effects[i].GetOrder();
											//}
											
											//// find the position to insert the new number
											//var _insert_position = 0;
											//while(_insert_position < array_length(_orders) && _orders[_insert_position] < _new_order) {
											//	_insert_position++;
											//}
											
											//// insert new order
											//array_insert(_orders, _insert_position, _new_order);
											
											//// shift numbers to the right
											//for (var i = _insert_position + 1; i < array_length(_orders); i++) {
											//	_orders[i]++;
											//}
											
											//// redefine orders
											//for (var i = 0; i < isize; ++i) {
											//	_effects[i].stack_order = _orders[i];
											//}
										}
										
										// update effects order
										__inspected_class.__reorder_stack();
										selected_item = -1;
									}
									
									// reset stuff
									dragging_item_my = 0;
									selected_item_struct = noone;
									is_dragging_item = false;
								}
							}
							
							return _height + 16;
						}))
			// Stack
			.AddElement(new __ppf_ui_folder("Stack", false, 5))
				.AddElement(new __ppf_ui_text_ext("Info", 0, function(element) {
					var _width = element.parent.__panel_width-element.xx*2;
					element.width = _width;
					return "Channels Histogram";
				}))
				.AddElement(new __ppf_ui_method("Histogram", 0,
					function() {
						uni_histogram_pos_res = shader_get_uniform(__ppf_sh_histogram, "u_pos_res");
						uni_histogram_data_tex = shader_get_sampler_index(__ppf_sh_histogram, "u_data_tex");
					},
					function(element) {
						// draw Histogram
						var _x1 = element.xx,
						_y1 = element.yy,
						_width = element.parent.__panel_width - element.xx - element.parent.__element_xpadding,
						_height = _width,
						_mx = element.parent.__input_m_x,
						_my = element.parent.__input_m_y,
						_mlp = element.parent.__input_m_left_pressed,
						_mlr = element.parent.__input_m_left_released,
						_old_color = draw_get_color(),
						_old_halign = draw_get_halign(),
						_old_blendmode = gpu_get_blendmode();
						
						draw_set_color(c_white);
						shader_set(__ppf_sh_histogram);
						shader_set_uniform_f(uni_histogram_pos_res, _x1, _y1, _width, _width);
						texture_set_stage(uni_histogram_data_tex, surface_get_texture(__inspected_class.GetRenderSurface())); 
						draw_sprite_stretched_ext(__spr_ppf_pixel, 0, _x1, _y1, _width, _width, c_black, 1);
						shader_reset();
						
						gpu_set_blendmode(_old_blendmode);
						draw_set_halign(_old_halign);
						draw_set_color(_old_color);
						
						// bake graph in realtime
						inspector_struct.__bake();
						return _height + 32;
					}))
				
				.AddElement(new __ppf_ui_text_ext("Info", 0, function(element) {
					var _width = element.parent.__panel_width-element.xx*2;
					element.width = _width;
					return "Stack Surfaces\n- Shared stacks also appear here.\n- The \"source\" is not created by the system.\n\nPreview:";
				}))
				.AddElement(new __ppf_ui_method("Surfaces", 0,
					function() {
						preview_stack_surface = -1;
						preview_stack_surface_height = 135;
						preview_stack_surface_aspect = 0;
						preview_stack_name = "";
					},
					function(element) {
						// draw graph
						var _x1 = element.xx,
						_y1 = element.yy,
						_width = element.parent.__panel_width - element.xx - element.parent.__element_xpadding,
						_height = 0,
						_mx = element.parent.__input_m_x,
						_my = element.parent.__input_m_y,
						_mlp = element.parent.__input_m_left_pressed,
						_mlr = element.parent.__input_m_left_released,
						_old_color = draw_get_color(),
						_old_halign = draw_get_halign(),
						_old_blendmode = gpu_get_blendmode();
						
						// preview
						if (surface_exists(preview_stack_surface)) {
							preview_stack_surface_aspect = surface_get_width(preview_stack_surface)/surface_get_height(preview_stack_surface);
							preview_stack_surface_height = _width / preview_stack_surface_aspect;
							draw_surface_stretched(preview_stack_surface, _x1, _y1, _width, preview_stack_surface_height);
							gpu_push_state();
							gpu_set_blendmode(bm_max);
							draw_text(_x1, _y1, $"{preview_stack_name} | ratio: {string_format(preview_stack_surface_aspect, 2, 3)}");
							gpu_pop_state();
						} else {
							preview_stack_surface_aspect = 0;
							draw_set_color(make_color_rgb(20, 20, 20));
							draw_rectangle(_x1, _y1, _x1+_width, _y1+preview_stack_surface_height, false);
							draw_set_color(c_white);
							draw_sprite(__spr_ppf_debug_icon, 0, _x1+_width/2, _y1+preview_stack_surface_height/2);
						}
						
						// separator
						_height += preview_stack_surface_height + 10;
						draw_set_color(c_white);
						draw_line(_x1, _y1+_height, _x1+(element.parent.__panel_width-_x1-element.parent.__element_xpadding), _y1+_height);
						
						// draw stacks
						_height += 10;
						var _stacks_surf_array = __inspected_class.__stack_surface,
							_stacks_names_array = __inspected_class.__stack_names,
							i = 0, isize = __inspected_class.__stack_index+1,
							_stack_surf = -1,
							_stack_name = "",
							_stack_xx = 0,
							_stack_yy = 0,
							_stacks_h_amount = ceil(isize/2),
							_stacks_v_amount = 2,
							_stack_cell_w = _width/_stacks_h_amount,
							_stack_cell_h = 256/_stacks_v_amount,
							_stack_txt = "";
						repeat(isize) {
							_stack_surf = _stacks_surf_array[i];
							_stack_name = _stacks_names_array[i];
							if (surface_exists(_stack_surf)) {
								_stack_xx = i mod _stacks_h_amount;
								_stack_yy = i div _stacks_h_amount;
								var _x = _x1 + (_stack_xx*_stack_cell_w);
								var _y = _y1 + _height + (_stack_yy*_stack_cell_h);
								if (i == 0) {
									_stack_txt = $"{i} (source)";
								} else {
									_stack_txt = $"{i} ({_stack_name})";
								}
								draw_surface_stretched(_stack_surf, _x, _y, _stack_cell_w, _stack_cell_h);
											
								if (point_in_rectangle(_mx, _my, _x, _y, _x+_stack_cell_w, _y+_stack_cell_h)) {
									preview_stack_surface = _stack_surf;
									preview_stack_name = _stack_name;
								}
										
								draw_set_color(c_white);
								gpu_set_blendmode(bm_max);
								draw_text(_x, _y, _stack_txt);
								gpu_set_blendmode(bm_normal);
							}
							i++;
						}
						_height += 256;
						
						gpu_set_blendmode(_old_blendmode);
						draw_set_halign(_old_halign);
						draw_set_color(_old_color);
						
						// bake graph in realtime
						inspector_struct.__bake();
						return _height + 32;
					}))
				.AddElement(new __ppf_ui_button("Clean Stacks (update)", function() {
					__inspected_class.Clean();
				}))
				
			// Misc
			.AddElement(new __ppf_ui_folder("Misc", false, 4))
				.AddElement(new __ppf_ui_button("Close All Tabs", function() {
					inspector_struct.SetTabsFolding(false, 16);
				}))
				.AddElement(new __ppf_ui_button("Open All Tabs", function() {
					inspector_struct.SetTabsFolding(true, 16);
				}))
				.AddElement(new __ppf_ui_button("Disable All Effects", function() {
					__inspected_class.DisableAllEffects();
				}))
				.AddElement(new __ppf_ui_slider("Global Intensity", 0, false, __inspected_class.GetGlobalIntensity(), 0, 1, true, function(output) {__inspected_class.SetGlobalIntensity(output);}))
		#endregion
		
		#region >> CATEGORY: LIGHTING & LENS
		inspector_struct
		.AddElement(new __ppf_ui_category("Lighting & Lens", false, 136))
		
		// effect: BLOOM
		.AddElement(new __ppf_ui_menu("BLOOM", false, 18))
			.AddElement(new __ppf_ui_checkbox("Effect Enabled", 0, gui_ef_get_enabled(FX_EFFECT.BLOOM), function(checked) {return gui_ef_set_enabled(checked, FX_EFFECT.BLOOM);}))
			.AddElement(new __ppf_ui_slider("Iterations", 16, false, gui_ef_get_param_simple(FX_EFFECT.BLOOM, PP_BLOOM_ITERATIONS), 0, 16, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.BLOOM, PP_BLOOM_ITERATIONS);}))
			.AddElement(new __ppf_ui_slider("Threshold", 0, false, gui_ef_get_param_simple(FX_EFFECT.BLOOM, PP_BLOOM_THRESHOLD), 0, 3, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.BLOOM, PP_BLOOM_THRESHOLD);}))
			.AddElement(new __ppf_ui_slider("Intensity", 0, false, gui_ef_get_param_simple(FX_EFFECT.BLOOM, PP_BLOOM_INTENSITY), 0, 5, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.BLOOM, PP_BLOOM_INTENSITY);}))
				.AddElement(new __ppf_ui_folder("Color", false, 3))
				.AddElement(new __ppf_ui_slider("Red", 0, false, gui_ef_get_param_color_red(FX_EFFECT.BLOOM, PP_BLOOM_COLOR), 0, 255, true, function(output) {gui_ef_set_param_color_red(output, FX_EFFECT.BLOOM, PP_BLOOM_COLOR);}))
				.AddElement(new __ppf_ui_slider("Green", 0, false, gui_ef_get_param_color_green(FX_EFFECT.BLOOM, PP_BLOOM_COLOR), 0, 255, true, function(output) {gui_ef_set_param_color_green(output, FX_EFFECT.BLOOM, PP_BLOOM_COLOR);}))
				.AddElement(new __ppf_ui_slider("Blue", 0, false, gui_ef_get_param_color_blue(FX_EFFECT.BLOOM, PP_BLOOM_COLOR), 0, 255, true, function(output) {gui_ef_set_param_color_blue(output, FX_EFFECT.BLOOM, PP_BLOOM_COLOR);}))
			.AddElement(new __ppf_ui_slider("White Amount", 0, false, gui_ef_get_param_simple(FX_EFFECT.BLOOM, PP_BLOOM_WHITE_AMOUNT), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.BLOOM, PP_BLOOM_WHITE_AMOUNT);}))
				.AddElement(new __ppf_ui_folder("Dirt Lens", false, 5))
					.AddElement(new __ppf_ui_checkbox("Enable", 0, gui_ef_get_param_simple(FX_EFFECT.BLOOM, PP_BLOOM_DIRT_ENABLED), function(checked) {return gui_ef_set_param_enable(checked, FX_EFFECT.BLOOM, PP_BLOOM_DIRT_ENABLED);}))
					.AddElement(new __ppf_ui_slider("Intensity", 0, false, gui_ef_get_param_simple(FX_EFFECT.BLOOM, PP_BLOOM_DIRT_INTENSITY), 0, 3, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.BLOOM, PP_BLOOM_DIRT_INTENSITY);}))
					.AddElement(new __ppf_ui_slider("Scale", 0, false, gui_ef_get_param_simple(FX_EFFECT.BLOOM, PP_BLOOM_DIRT_SCALE), 0.25, 3, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.BLOOM, PP_BLOOM_DIRT_SCALE);}))
					.AddElement(new __ppf_ui_checkbox("Can Distort", 0, gui_ef_get_param_simple(FX_EFFECT.BLOOM, PP_BLOOM_DIRT_CAN_DISTORT), function(checked) {return gui_ef_set_param_enable(checked, FX_EFFECT.BLOOM, PP_BLOOM_DIRT_CAN_DISTORT);}))
					.AddElement(new __ppf_ui_button("Texture", function() {
						var _file = get_open_filename("PNG Image|*.png", "*.png");
						if (_file != "") {
							if (sprite_exists(gui_bloom_dirtlens_texture_id)) sprite_delete(gui_bloom_dirtlens_texture_id);
							gui_bloom_dirtlens_texture_id = sprite_add(_file, 0, 0, 0, 0, 0);
							gui_ef_set_param_simple(sprite_get_texture(gui_bloom_dirtlens_texture_id, 0), FX_EFFECT.BLOOM, PP_BLOOM_DIRT_TEXTURE, sprite_get_texture(gui_bloom_dirtlens_texture_id, 0));
						}
					}))
			.AddElement(new __ppf_ui_slider("Downscale", 0, false, gui_ef_get_param_simple(FX_EFFECT.BLOOM, PP_BLOOM_DOWNSCALE), 0, 1, false, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.BLOOM, PP_BLOOM_DOWNSCALE)}))
			.AddElement(new __ppf_ui_checkbox("Debug 1", 0, gui_ef_get_param_simple(FX_EFFECT.BLOOM, PP_BLOOM_DEBUG_1), function(checked) {return gui_ef_set_param_enable(checked, FX_EFFECT.BLOOM, PP_BLOOM_DEBUG_1);}))
			.AddElement(new __ppf_ui_checkbox("Debug 2", 0, gui_ef_get_param_simple(FX_EFFECT.BLOOM, PP_BLOOM_DEBUG_2), function(checked) {return gui_ef_set_param_enable(checked, FX_EFFECT.BLOOM, PP_BLOOM_DEBUG_2);}))
		
		// effect: SUNSHAFTS
		.AddElement(new __ppf_ui_menu("SUNSHAFTS (GODRAYS)", false, 16)) // 15
			.AddElement(new __ppf_ui_checkbox("Effect Enabled", 0, gui_ef_get_enabled(FX_EFFECT.SUNSHAFTS), function(checked) {return gui_ef_set_enabled(checked, FX_EFFECT.SUNSHAFTS);}))
			.AddElement(new __ppf_ui_slider("Position X", 0, false, gui_ef_get_param_vec2_x(FX_EFFECT.SUNSHAFTS, PP_SUNSHAFTS_POSITION), 0, 1, true, function(output) {gui_ef_set_param_vec2_x(output, FX_EFFECT.SUNSHAFTS, PP_SUNSHAFTS_POSITION);}))
			.AddElement(new __ppf_ui_slider("Position Y", 0, false, gui_ef_get_param_vec2_y(FX_EFFECT.SUNSHAFTS, PP_SUNSHAFTS_POSITION), 0, 1, true, function(output) {gui_ef_set_param_vec2_y(output, FX_EFFECT.SUNSHAFTS, PP_SUNSHAFTS_POSITION);}))
			.AddElement(new __ppf_ui_slider("Center Smoothness", 0, false, gui_ef_get_param_simple(FX_EFFECT.SUNSHAFTS, PP_SUNSHAFTS_CENTER_SMOOTHNESS), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.SUNSHAFTS, PP_SUNSHAFTS_CENTER_SMOOTHNESS);}))
			.AddElement(new __ppf_ui_slider("Threshold", 0, false, gui_ef_get_param_simple(FX_EFFECT.SUNSHAFTS, PP_SUNSHAFTS_THRESHOLD), 0, 3, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.SUNSHAFTS, PP_SUNSHAFTS_THRESHOLD);}))
			.AddElement(new __ppf_ui_slider("Intensity", 0, false, gui_ef_get_param_simple(FX_EFFECT.SUNSHAFTS, PP_SUNSHAFTS_INTENSITY), 0, 5, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.SUNSHAFTS, PP_SUNSHAFTS_INTENSITY);}))
			.AddElement(new __ppf_ui_slider("Dimmer", 0, false, gui_ef_get_param_simple(FX_EFFECT.SUNSHAFTS, PP_SUNSHAFTS_DIMMER), 0, 5, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.SUNSHAFTS, PP_SUNSHAFTS_DIMMER);}))
			.AddElement(new __ppf_ui_slider("Scattering", 0, false, gui_ef_get_param_simple(FX_EFFECT.SUNSHAFTS, PP_SUNSHAFTS_SCATTERING), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.SUNSHAFTS, PP_SUNSHAFTS_SCATTERING);}))
			.AddElement(new __ppf_ui_checkbox("Noise Enable", 0, gui_ef_get_param_simple(FX_EFFECT.SUNSHAFTS, PP_SUNSHAFTS_NOISE_ENABLE), function(checked) {return gui_ef_set_param_enable(checked, FX_EFFECT.SUNSHAFTS, PP_SUNSHAFTS_NOISE_ENABLE);}))
			.AddElement(new __ppf_ui_folder("Rays", false, 3))
				.AddElement(new __ppf_ui_slider("Rays Intensity", 0, false, gui_ef_get_param_simple(FX_EFFECT.SUNSHAFTS, PP_SUNSHAFTS_RAYS_INTENSITY), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.SUNSHAFTS, PP_SUNSHAFTS_RAYS_INTENSITY);}))
				.AddElement(new __ppf_ui_slider("Rays Tiling", 0, false, gui_ef_get_param_simple(FX_EFFECT.SUNSHAFTS, PP_SUNSHAFTS_RAYS_TILING), 0, 10, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.SUNSHAFTS, PP_SUNSHAFTS_RAYS_TILING);}))
				.AddElement(new __ppf_ui_slider("Rays Speed", 0, false, gui_ef_get_param_simple(FX_EFFECT.SUNSHAFTS, PP_SUNSHAFTS_RAYS_SPEED), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.SUNSHAFTS, PP_SUNSHAFTS_RAYS_SPEED);}))
			.AddElement(new __ppf_ui_slider("Downscale", 0, false, gui_ef_get_param_simple(FX_EFFECT.SUNSHAFTS, PP_SUNSHAFTS_DOWNSCALE), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.SUNSHAFTS, PP_SUNSHAFTS_DOWNSCALE);}))
			.AddElement(new __ppf_ui_checkbox("Debug", 0, gui_ef_get_param_simple(FX_EFFECT.SUNSHAFTS, PP_SUNSHAFTS_DEBUG), function(checked) {return gui_ef_set_param_enable(checked, FX_EFFECT.SUNSHAFTS, PP_SUNSHAFTS_DEBUG);}))
			.AddElement(new __ppf_ui_slider("Source Offset", 10, false, gui_ef_get_param_simple(FX_EFFECT.SUNSHAFTS, PP_SUNSHAFTS_SOURCE_OFFSET), -10, 0, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.SUNSHAFTS, PP_SUNSHAFTS_SOURCE_OFFSET);}))
		
		// effect: CHROMATIC ABERRATION
		.AddElement(new __ppf_ui_menu("CHROMATIC ABERRATION", false, 7))
			.AddElement(new __ppf_ui_checkbox("Effect Enabled", 0, gui_ef_get_enabled(FX_EFFECT.CHROMATIC_ABERRATION), function(checked) {return gui_ef_set_enabled(checked, FX_EFFECT.CHROMATIC_ABERRATION);}))
			.AddElement(new __ppf_ui_slider("Intensity", 0, false, gui_ef_get_param_simple(FX_EFFECT.CHROMATIC_ABERRATION, PP_CHROMABER_INTENSITY), 0, 50, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.CHROMATIC_ABERRATION, PP_CHROMABER_INTENSITY);}))
			.AddElement(new __ppf_ui_slider("Angle", 0, false, gui_ef_get_param_simple(FX_EFFECT.CHROMATIC_ABERRATION, PP_CHROMABER_ANGLE), 0, 360, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.CHROMATIC_ABERRATION, PP_CHROMABER_ANGLE);}))
			.AddElement(new __ppf_ui_slider("Center Radius", 0, false, gui_ef_get_param_simple(FX_EFFECT.CHROMATIC_ABERRATION, PP_CHROMABER_CENTER_RADIUS), 0, 3, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.CHROMATIC_ABERRATION, PP_CHROMABER_CENTER_RADIUS);}))
			.AddElement(new __ppf_ui_slider("Inner", 0, false, gui_ef_get_param_simple(FX_EFFECT.CHROMATIC_ABERRATION, PP_CHROMABER_INNER), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.CHROMATIC_ABERRATION, PP_CHROMABER_INNER);}))
			.AddElement(new __ppf_ui_checkbox("Blur Enable", 0, gui_ef_get_param_simple(FX_EFFECT.CHROMATIC_ABERRATION, PP_CHROMABER_BLUR_ENABLE), function(checked) {return gui_ef_set_param_enable(checked, FX_EFFECT.CHROMATIC_ABERRATION, PP_CHROMABER_BLUR_ENABLE);}))
			.AddElement(new __ppf_ui_button("Spectral/Prism LUT", function() {
				gui_chromaber_prisma_type += 1;
				if (gui_chromaber_prisma_type >= array_length(gui_chromaber_prisma_tex_list)) gui_chromaber_prisma_type = 0;
				gui_ef_set_param_simple(sprite_get_texture(gui_chromaber_prisma_tex_list[gui_chromaber_prisma_type], 0), FX_EFFECT.CHROMATIC_ABERRATION, PP_CHROMABER_PRISMA_LUT_TEX);
			}))
		
		// effect: DEPTH OF FIELD
		.AddElement(new __ppf_ui_menu("DEPTH OF FIELD", false, 14))
			.AddElement(new __ppf_ui_checkbox("Effect Enabled", 0, gui_ef_get_enabled(FX_EFFECT.DEPTH_OF_FIELD), function(checked) {return gui_ef_set_enabled(checked, FX_EFFECT.DEPTH_OF_FIELD);}))
			.AddElement(new __ppf_ui_slider("Radius", 0, false, gui_ef_get_param_simple(FX_EFFECT.DEPTH_OF_FIELD, PP_DOF_RADIUS), 0, 20, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.DEPTH_OF_FIELD, PP_DOF_RADIUS);}))
			.AddElement(new __ppf_ui_slider("Intensity", 0, false, gui_ef_get_param_simple(FX_EFFECT.DEPTH_OF_FIELD, PP_DOF_INTENSITY), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.DEPTH_OF_FIELD, PP_DOF_INTENSITY);}))
				.AddElement(new __ppf_ui_folder("Shape", false, 3))
					.AddElement(new __ppf_ui_checkbox("Shaped", 0, false, function(checked) {return gui_ef_set_param_enable(checked, FX_EFFECT.DEPTH_OF_FIELD, PP_DOF_SHAPED);}))
					.AddElement(new __ppf_ui_slider("Aperture", 8, false, gui_ef_get_param_simple(FX_EFFECT.DEPTH_OF_FIELD, PP_DOF_BLADES_APERTURE), 0, 8, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.DEPTH_OF_FIELD, PP_DOF_BLADES_APERTURE);}))
					.AddElement(new __ppf_ui_slider("Angle", 360, false, gui_ef_get_param_simple(FX_EFFECT.DEPTH_OF_FIELD, PP_DOF_BLADES_ANGLE), 0, 360, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.DEPTH_OF_FIELD, PP_DOF_BLADES_ANGLE);}))
				.AddElement(new __ppf_ui_folder("Z-Depth", false, 5))
					.AddElement(new __ppf_ui_checkbox("Enabled", 0, gui_ef_get_param_simple(FX_EFFECT.DEPTH_OF_FIELD, PP_DOF_USE_ZDEPTH), function(checked) {return gui_ef_set_param_enable(checked, FX_EFFECT.DEPTH_OF_FIELD, PP_DOF_USE_ZDEPTH);}))
					.AddElement(new __ppf_ui_button("Texture", function() {
						var _file = get_open_filename("PNG Image|*.png", "*.png");
						if (_file != "") {
							if (sprite_exists(gui_dof_zdepth_spritetex_id)) sprite_delete(gui_dof_zdepth_spritetex_id);
							gui_dof_zdepth_spritetex_id = sprite_add(_file, 0, 0, 0, 0, 0);
							gui_ef_set_param_simple(sprite_get_texture(gui_dof_zdepth_spritetex_id, 0), FX_EFFECT.DEPTH_OF_FIELD, PP_DOF_ZDEPTH_TEXTURE);
						}
					}))
					.AddElement(new __ppf_ui_slider("Focus Distance", 0, false, gui_ef_get_param_simple(FX_EFFECT.DEPTH_OF_FIELD, PP_DOF_FOCUS_DISTANCE), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.DEPTH_OF_FIELD, PP_DOF_FOCUS_DISTANCE);}))
					.AddElement(new __ppf_ui_slider("Focus Range", 0, false, gui_ef_get_param_simple(FX_EFFECT.DEPTH_OF_FIELD, PP_DOF_FOCUS_RANGE), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.DEPTH_OF_FIELD, PP_DOF_FOCUS_RANGE);}))
					.AddElement(new __ppf_ui_checkbox("Debug", 0, false, function(checked) {return gui_ef_set_param_enable(checked, FX_EFFECT.DEPTH_OF_FIELD, PP_DOF_DEBUG);}))
				.AddElement(new __ppf_ui_slider("Downscale", 0, false, gui_ef_get_param_simple(FX_EFFECT.DEPTH_OF_FIELD, PP_DOF_DOWNSCALE), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.DEPTH_OF_FIELD, PP_DOF_DOWNSCALE);}))
		
		// effect: GAUSSIAN BLUR
		.AddElement(new __ppf_ui_menu("GAUSSIAN BLUR", false, 6))
			.AddElement(new __ppf_ui_checkbox("Effect Enabled", 0, gui_ef_get_enabled(FX_EFFECT.BLUR_GAUSSIAN), function(checked) {return gui_ef_set_enabled(checked, FX_EFFECT.BLUR_GAUSSIAN);}))
			.AddElement(new __ppf_ui_slider("Radius", 0, false, gui_ef_get_param_simple(FX_EFFECT.BLUR_GAUSSIAN, PP_BLUR_GAUSSIAN_AMOUNT), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.BLUR_GAUSSIAN, PP_BLUR_GAUSSIAN_AMOUNT);}))
			.AddElement(new __ppf_ui_slider("Mask Power", 0, false, gui_ef_get_param_simple(FX_EFFECT.BLUR_GAUSSIAN, PP_BLUR_GAUSSIAN_MASK_POWER), 0, 15, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.BLUR_GAUSSIAN, PP_BLUR_GAUSSIAN_MASK_POWER);}))
			.AddElement(new __ppf_ui_slider("Mask Scale", 0, false, gui_ef_get_param_simple(FX_EFFECT.BLUR_GAUSSIAN, PP_BLUR_GAUSSIAN_MASK_SCALE), 0, 3, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.BLUR_GAUSSIAN, PP_BLUR_GAUSSIAN_MASK_SCALE);}))
			.AddElement(new __ppf_ui_slider("Mask Smoothness", 0, false, gui_ef_get_param_simple(FX_EFFECT.BLUR_GAUSSIAN, PP_BLUR_GAUSSIAN_MASK_SMOOTHNESS), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.BLUR_GAUSSIAN, PP_BLUR_GAUSSIAN_MASK_SMOOTHNESS);}))
			.AddElement(new __ppf_ui_slider("Downscale", 0, false, gui_ef_get_param_simple(FX_EFFECT.BLUR_GAUSSIAN, PP_BLUR_GAUSSIAN_DOWNSCALE), 0.25, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.BLUR_GAUSSIAN, PP_BLUR_GAUSSIAN_DOWNSCALE);}))
		
		// effect: KAWASE BLUR
		.AddElement(new __ppf_ui_menu("KAWASE BLUR", false, 7))
			.AddElement(new __ppf_ui_checkbox("Effect Enabled", 0, gui_ef_get_enabled(FX_EFFECT.BLUR_KAWASE), function(checked) {return gui_ef_set_enabled(checked, FX_EFFECT.BLUR_KAWASE);}))
			.AddElement(new __ppf_ui_slider("Amount", 0, false, gui_ef_get_param_simple(FX_EFFECT.BLUR_KAWASE, PP_BLUR_KAWASE_AMOUNT), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.BLUR_KAWASE, PP_BLUR_KAWASE_AMOUNT);}))
			.AddElement(new __ppf_ui_slider("Mask Power", 0, false, gui_ef_get_param_simple(FX_EFFECT.BLUR_KAWASE, PP_BLUR_KAWASE_MASK_POWER), 0, 15, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.BLUR_KAWASE, PP_BLUR_KAWASE_MASK_POWER);}))
			.AddElement(new __ppf_ui_slider("Mask Scale", 0, false, gui_ef_get_param_simple(FX_EFFECT.BLUR_KAWASE, PP_BLUR_KAWASE_MASK_SCALE), 0, 3, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.BLUR_KAWASE, PP_BLUR_KAWASE_MASK_SCALE);}))
			.AddElement(new __ppf_ui_slider("Mask Smoothness", 0, false, gui_ef_get_param_simple(FX_EFFECT.BLUR_KAWASE, PP_BLUR_KAWASE_MASK_SMOOTHNESS), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.BLUR_KAWASE, PP_BLUR_KAWASE_MASK_SMOOTHNESS);}))
			.AddElement(new __ppf_ui_slider("Downscale", 0, false, gui_ef_get_param_simple(FX_EFFECT.BLUR_KAWASE, PP_BLUR_KAWASE_DOWNSCALE), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.BLUR_KAWASE, PP_BLUR_KAWASE_DOWNSCALE);}))
			.AddElement(new __ppf_ui_slider("Iterations", 0, false, gui_ef_get_param_simple(FX_EFFECT.BLUR_KAWASE, PP_BLUR_KAWASE_ITERATIONS), 2, 20, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.BLUR_KAWASE, PP_BLUR_KAWASE_ITERATIONS);}))
		
		// effect: MOTION BLUR
		.AddElement(new __ppf_ui_menu("MOTION BLUR", false, 10))
			.AddElement(new __ppf_ui_checkbox("Effect Enabled", 0, gui_ef_get_enabled(FX_EFFECT.MOTION_BLUR), function(checked) {return gui_ef_set_enabled(checked, FX_EFFECT.MOTION_BLUR);}))
			.AddElement(new __ppf_ui_slider("Angle", 0, false, gui_ef_get_param_simple(FX_EFFECT.MOTION_BLUR, PP_MOTION_BLUR_ANGLE), 0, 360, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.MOTION_BLUR, PP_MOTION_BLUR_ANGLE);}))
			.AddElement(new __ppf_ui_slider("Radius", 0, false, gui_ef_get_param_simple(FX_EFFECT.MOTION_BLUR, PP_MOTION_BLUR_RADIUS), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.MOTION_BLUR, PP_MOTION_BLUR_RADIUS);}))
			.AddElement(new __ppf_ui_slider("Mask Power", 0, false, gui_ef_get_param_simple(FX_EFFECT.MOTION_BLUR, PP_MOTION_BLUR_MASK_POWER), 0, 15, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.MOTION_BLUR, PP_MOTION_BLUR_MASK_POWER);}))
			.AddElement(new __ppf_ui_slider("Mask Scale", 0, false, gui_ef_get_param_simple(FX_EFFECT.MOTION_BLUR, PP_MOTION_BLUR_MASK_SCALE), 0, 3, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.MOTION_BLUR, PP_MOTION_BLUR_MASK_SCALE);}))
			.AddElement(new __ppf_ui_slider("Mask Smoothness", 0, false, gui_ef_get_param_simple(FX_EFFECT.MOTION_BLUR, PP_MOTION_BLUR_MASK_SMOOTHNESS), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.MOTION_BLUR, PP_MOTION_BLUR_MASK_SMOOTHNESS);}))
			.AddElement(new __ppf_ui_folder("Focus", false, 2))
				.AddElement(new __ppf_ui_slider("Center X", 0, false, gui_ef_get_param_vec2_x(FX_EFFECT.MOTION_BLUR, PP_MOTION_BLUR_CENTER), 0, 1, true, function(output) {gui_ef_set_param_vec2_x(output, FX_EFFECT.MOTION_BLUR, PP_MOTION_BLUR_CENTER);}))
				.AddElement(new __ppf_ui_slider("Center Y", 0, false, gui_ef_get_param_vec2_y(FX_EFFECT.MOTION_BLUR, PP_MOTION_BLUR_CENTER), 0, 1, true, function(output) {gui_ef_set_param_vec2_y(output, FX_EFFECT.MOTION_BLUR, PP_MOTION_BLUR_CENTER);}))
			.AddElement(new __ppf_ui_button("Overlay Texture", function() {
				var _file = get_open_filename("PNG Image|*.png", "*.png");
				if (_file != "") {
					if (sprite_exists(gui_motion_blur_texture_id)) sprite_delete(gui_motion_blur_texture_id);
					gui_motion_blur_texture_id = sprite_add(_file, 0, 0, 0, 0, 0);
					gui_ef_set_param_simple(sprite_get_texture(gui_motion_blur_texture_id, 0), FX_EFFECT.MOTION_BLUR, PP_MOTION_BLUR_TEXTURE);
				}
			}))
		
		// effect: RADIAL BLUR
		.AddElement(new __ppf_ui_menu("RADIAL BLUR", false, 6))
			.AddElement(new __ppf_ui_checkbox("Effect Enabled", 0, gui_ef_get_enabled(FX_EFFECT.BLUR_RADIAL), function(checked) {return gui_ef_set_enabled(checked, FX_EFFECT.BLUR_RADIAL)}))
			.AddElement(new __ppf_ui_slider("Radius", 0, false, gui_ef_get_param_simple(FX_EFFECT.BLUR_RADIAL, PP_BLUR_RADIAL_RADIUS), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.BLUR_RADIAL, PP_BLUR_RADIAL_RADIUS);}))
			.AddElement(new __ppf_ui_slider("Inner", 0, false, gui_ef_get_param_simple(FX_EFFECT.BLUR_RADIAL, PP_BLUR_RADIAL_INNER), 0, 3, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.BLUR_RADIAL, PP_BLUR_RADIAL_INNER);}))
			.AddElement(new __ppf_ui_folder("Center", false, 2))
				.AddElement(new __ppf_ui_slider("Center X", 0, false, gui_ef_get_param_vec2_x(FX_EFFECT.BLUR_RADIAL, PP_BLUR_RADIAL_CENTER), 0, 1, true, function(output) {gui_ef_set_param_vec2_x(output, FX_EFFECT.BLUR_RADIAL, PP_BLUR_RADIAL_CENTER);}))
				.AddElement(new __ppf_ui_slider("Center Y", 0, false, gui_ef_get_param_vec2_y(FX_EFFECT.BLUR_RADIAL, PP_BLUR_RADIAL_CENTER), 0, 1, true, function(output) {gui_ef_set_param_vec2_y(output, FX_EFFECT.BLUR_RADIAL, PP_BLUR_RADIAL_CENTER);}))
		
		// effect: SLOW MOTION
		.AddElement(new __ppf_ui_menu("SLOW MOTION", false, 7))
			.AddElement(new __ppf_ui_checkbox("Effect Enabled", 0, gui_ef_get_enabled(FX_EFFECT.SLOW_MOTION), function(checked) {return gui_ef_set_enabled(checked, FX_EFFECT.SLOW_MOTION);}))
			.AddElement(new __ppf_ui_slider("Threshold", 0, false, gui_ef_get_param_simple(FX_EFFECT.SLOW_MOTION, PP_SLOW_MOTION_THRESHOLD), 0, 3, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.SLOW_MOTION, PP_SLOW_MOTION_THRESHOLD);}))
			.AddElement(new __ppf_ui_slider("Force", 0, false, gui_ef_get_param_simple(FX_EFFECT.SLOW_MOTION, PP_SLOW_MOTION_FORCE), 0, 25, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.SLOW_MOTION, PP_SLOW_MOTION_FORCE);}))
			.AddElement(new __ppf_ui_slider("Intensity", 0, false, gui_ef_get_param_simple(FX_EFFECT.SLOW_MOTION, PP_SLOW_MOTION_INTENSITY), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.SLOW_MOTION, PP_SLOW_MOTION_INTENSITY);}))
			.AddElement(new __ppf_ui_slider("Iterations", 0, false, gui_ef_get_param_simple(FX_EFFECT.SLOW_MOTION, PP_SLOW_MOTION_ITERATIONS), 1, 30, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.SLOW_MOTION, PP_SLOW_MOTION_ITERATIONS);}))
			.AddElement(new __ppf_ui_checkbox("Debug", 0, gui_ef_get_param_simple(FX_EFFECT.SLOW_MOTION, PP_SLOW_MOTION_DEBUG), function(checked) {return gui_ef_set_param_enable(checked, FX_EFFECT.SLOW_MOTION, PP_SLOW_MOTION_DEBUG);}))
			.AddElement(new __ppf_ui_slider("Source Offset", 10, false, gui_ef_get_param_simple(FX_EFFECT.SUNSHAFTS, PP_SLOW_MOTION_SOURCE_OFFSET), -10, 0, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.SUNSHAFTS, PP_SLOW_MOTION_SOURCE_OFFSET);}))
		
		// effect: MIST
		.AddElement(new __ppf_ui_menu("MIST", false, 20))
			.AddElement(new __ppf_ui_checkbox("Effect Enabled", 0, gui_ef_get_enabled(FX_EFFECT.MIST), function(checked) {return gui_ef_set_enabled(checked, FX_EFFECT.MIST);}))
			.AddElement(new __ppf_ui_slider("Intensity", 0, false, gui_ef_get_param_simple(FX_EFFECT.MIST, PP_MIST_INTENSITY), 0, 2, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.MIST, PP_MIST_INTENSITY);}))
			.AddElement(new __ppf_ui_slider("Scale", 0, false, gui_ef_get_param_simple(FX_EFFECT.MIST, PP_MIST_SCALE), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.MIST, PP_MIST_SCALE);}))
			.AddElement(new __ppf_ui_slider("Tiling", 0, false, gui_ef_get_param_simple(FX_EFFECT.MIST, PP_MIST_TILING), 0.25, 16, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.MIST, PP_MIST_TILING);}))
			.AddElement(new __ppf_ui_slider("Speed", 0, false, gui_ef_get_param_simple(FX_EFFECT.MIST, PP_MIST_SPEED), -10, 10, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.MIST, PP_MIST_SPEED);}))
			.AddElement(new __ppf_ui_slider("Angle", 0, false, gui_ef_get_param_simple(FX_EFFECT.MIST, PP_MIST_ANGLE), 0, 360, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.MIST, PP_MIST_ANGLE);}))
			.AddElement(new __ppf_ui_slider("Contrast", 0, false, gui_ef_get_param_simple(FX_EFFECT.MIST, PP_MIST_CONTRAST), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.MIST, PP_MIST_CONTRAST);}))
			.AddElement(new __ppf_ui_slider("Power", 0, false, gui_ef_get_param_simple(FX_EFFECT.MIST, PP_MIST_POWER), 0, 4, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.MIST, PP_MIST_POWER);}))
			.AddElement(new __ppf_ui_slider("Remap", 0, false, gui_ef_get_param_simple(FX_EFFECT.MIST, PP_MIST_REMAP), 0, 0.99, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.MIST, PP_MIST_REMAP);}))
				.AddElement(new __ppf_ui_folder("Color", false, 3))
				.AddElement(new __ppf_ui_slider("Red", 0, false, gui_ef_get_param_color_red(FX_EFFECT.MIST, PP_MIST_COLOR), 0, 255, true, function(output) {gui_ef_set_param_color_red(output, FX_EFFECT.MIST, PP_MIST_COLOR);}))
				.AddElement(new __ppf_ui_slider("Green", 0, false, gui_ef_get_param_color_green(FX_EFFECT.MIST, PP_MIST_COLOR), 0, 255, true, function(output) {gui_ef_set_param_color_green(output, FX_EFFECT.MIST, PP_MIST_COLOR);}))
				.AddElement(new __ppf_ui_slider("Blue", 0, false, gui_ef_get_param_color_blue(FX_EFFECT.MIST, PP_MIST_COLOR), 0, 255, true, function(output) {gui_ef_set_param_color_blue(output, FX_EFFECT.MIST, PP_MIST_COLOR);}))
			.AddElement(new __ppf_ui_slider("Mix", 0, false, gui_ef_get_param_simple(FX_EFFECT.MIST, PP_MIST_MIX), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.MIST, PP_MIST_MIX);}))
			.AddElement(new __ppf_ui_slider("Mix Threshold", 0, false, gui_ef_get_param_simple(FX_EFFECT.MIST, PP_MIST_MIX_THRESHOLD), -0.5, 0.5, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.MIST, PP_MIST_MIX_THRESHOLD);}))
			.AddElement(new __ppf_ui_button("Noise Texture", function() {
				gui_mist_noise_type += 1;
				if (gui_mist_noise_type >= array_length(gui_mist_noise_tex_list)) gui_mist_noise_type = 0;
				gui_ef_set_param_simple(sprite_get_texture(gui_mist_noise_tex_list[gui_mist_noise_type], 0), FX_EFFECT.MIST, PP_MIST_NOISE_TEX);
			}))
			.AddElement(new __ppf_ui_slider("Offset X", 0, false, gui_ef_get_param_vec2_x(FX_EFFECT.MIST, PP_MIST_OFFSET), -100, 100, true, function(output) {gui_ef_set_param_vec2_x(output, FX_EFFECT.MIST, PP_MIST_OFFSET);}))
			.AddElement(new __ppf_ui_slider("Offset Y", 0, false, gui_ef_get_param_vec2_y(FX_EFFECT.MIST, PP_MIST_OFFSET), -100, 100, true, function(output) {gui_ef_set_param_vec2_y(output, FX_EFFECT.MIST, PP_MIST_OFFSET);}))
			.AddElement(new __ppf_ui_slider("Fade Amount", 0, false, gui_ef_get_param_simple(FX_EFFECT.MIST, PP_MIST_FADE_AMOUNT), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.MIST, PP_MIST_FADE_AMOUNT);}))
			.AddElement(new __ppf_ui_slider("Fade Angle", 0, false, gui_ef_get_param_simple(FX_EFFECT.MIST, PP_MIST_FADE_ANGLE), 0, 360, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.MIST, PP_MIST_FADE_ANGLE);}))
		
		// effect: VIGNETTE
		.AddElement(new __ppf_ui_menu("VIGNETTE", false, 14))
			.AddElement(new __ppf_ui_checkbox("Effect Enabled", 0, gui_ef_get_enabled(FX_EFFECT.VIGNETTE), function(checked) {return gui_ef_set_enabled(checked, FX_EFFECT.VIGNETTE);}))
			.AddElement(new __ppf_ui_slider("Intensity", 0, false, gui_ef_get_param_simple(FX_EFFECT.VIGNETTE, PP_VIGNETTE_INTENSITY), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.VIGNETTE, PP_VIGNETTE_INTENSITY);}))
			.AddElement(new __ppf_ui_slider("Curvature", 0, false, gui_ef_get_param_simple(FX_EFFECT.VIGNETTE, PP_VIGNETTE_CURVATURE), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.VIGNETTE, PP_VIGNETTE_CURVATURE);}))
			.AddElement(new __ppf_ui_slider("Inner", 0, false, gui_ef_get_param_simple(FX_EFFECT.VIGNETTE, PP_VIGNETTE_INNER), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.VIGNETTE, PP_VIGNETTE_INNER);}))
			.AddElement(new __ppf_ui_slider("Outer", 0, false, gui_ef_get_param_simple(FX_EFFECT.VIGNETTE, PP_VIGNETTE_OUTER), 0, 3, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.VIGNETTE, PP_VIGNETTE_OUTER);}))
				.AddElement(new __ppf_ui_folder("Color", false, 3))
					.AddElement(new __ppf_ui_slider("Red", 0, false, gui_ef_get_param_color_red(FX_EFFECT.VIGNETTE, PP_VIGNETTE_COLOR), 0, 255, true, function(output) {gui_ef_set_param_color_red(output, FX_EFFECT.VIGNETTE, PP_VIGNETTE_COLOR);}))
					.AddElement(new __ppf_ui_slider("Green", 0, false, gui_ef_get_param_color_green(FX_EFFECT.VIGNETTE, PP_VIGNETTE_COLOR), 0, 255, true, function(output) {gui_ef_set_param_color_green(output, FX_EFFECT.VIGNETTE, PP_VIGNETTE_COLOR);}))
					.AddElement(new __ppf_ui_slider("Blue", 0, false, gui_ef_get_param_color_blue(FX_EFFECT.VIGNETTE, PP_VIGNETTE_COLOR), 0, 255, true, function(output) {gui_ef_set_param_color_blue(output, FX_EFFECT.VIGNETTE, PP_VIGNETTE_COLOR);}))
				.AddElement(new __ppf_ui_folder("Center", false, 2))
					.AddElement(new __ppf_ui_slider("Center X", 0, false, gui_ef_get_param_vec2_x(FX_EFFECT.VIGNETTE, PP_VIGNETTE_CENTER), 0, 1, true, function(output) {gui_ef_set_param_vec2_x(output, FX_EFFECT.VIGNETTE, PP_VIGNETTE_CENTER);}))
					.AddElement(new __ppf_ui_slider("Center Y", 0, false, gui_ef_get_param_vec2_y(FX_EFFECT.VIGNETTE, PP_VIGNETTE_CENTER), 0, 1, true, function(output) {gui_ef_set_param_vec2_y(output, FX_EFFECT.VIGNETTE, PP_VIGNETTE_CENTER);}))
			.AddElement(new __ppf_ui_checkbox("Rounded", 0, gui_ef_get_param_simple(FX_EFFECT.VIGNETTE, PP_VIGNETTE_ROUNDED), function(checked) {return gui_ef_set_param_enable(checked, FX_EFFECT.VIGNETTE, PP_VIGNETTE_ROUNDED);}))
			.AddElement(new __ppf_ui_checkbox("Linear", 0, gui_ef_get_param_simple(FX_EFFECT.VIGNETTE, PP_VIGNETTE_LINEAR), function(checked) {return gui_ef_set_param_enable(checked, FX_EFFECT.VIGNETTE, PP_VIGNETTE_LINEAR);}));
		#endregion
		
		#region >> CATEGORY: COLOR GRADING
		inspector_struct
		.AddElement(new __ppf_ui_category("Color Grading", false, 126))
		
		// effect: Color Curves
		.AddElement(new __ppf_ui_menu("COLOR CURVES", false, 17))
			.AddElement(new __ppf_ui_checkbox("Effect Enabled", 0, gui_ef_get_enabled(FX_EFFECT.COLOR_CURVES), function(checked) {return gui_ef_set_enabled(checked, FX_EFFECT.COLOR_CURVES);}))
			.AddElement(new __ppf_ui_text_ext("Info", 0, function(element) {
					var _width = element.parent.__panel_width-element.xx*2;
					element.width = _width;
					return "Below you can choose between editing the YRGB or HHSL curves.\n\nGraph commands:\nMiddle Mouse Button > Add\nLeft Mouse Button > Move\nRight Mouse Button > Delete\nMouse wheel > Choose channel";
				}))
			.AddElement(new __ppf_ui_separator())
			.AddElement(new __ppf_ui_button("Change Curve", function() {
				gui_color_curves_get_graph();
			}))
			.AddElement(new __ppf_ui_text("YRGB/HHSL:", 0, function(output) {
				switch(gui_color_curves_curve_index) {
					case 0: return "YRGB Curve"; break;
					case 1: return "HHSL Curve"; break;
				}
			}))
			.AddElement(new __ppf_ui_method("Curves", 0, function() {
					uni_curve_background_pos_res = shader_get_uniform(__ppf_sh_graph, "u_pos_res");
					uni_curve_background_index = shader_get_uniform(__ppf_sh_graph, "u_background_index");
					uni_curve_background_grid_size = shader_get_uniform(__ppf_sh_graph, "u_grid_size");
					gui_color_curves_get_graph();
				},
				function(element) {
					var _x1 = element.xx,
						_y1 = element.yy,
						_x2 = element.parent.__panel_width-element.xx,
						_y2 = element.yy+256,
						_width = _x2 - _x1,
						_height = _y2 - _y1;
					
					// curves graph
					if (gui_color_curves_struct != undefined) {
						// background
						var _background_index = -1;
						if (gui_color_curves_curve_index == 1) {
							var _curve_to_edit_index = gui_color_curves_struct.__debug_curve_to_edit;
							if (_curve_to_edit_index == 0 || _curve_to_edit_index == 1) _background_index = 0; else
							if (_curve_to_edit_index == 2 || _curve_to_edit_index == 3) _background_index = 1;
						}
						draw_set_color(c_white);
						draw_set_alpha(element.alpha * 0.85);
						shader_set(__ppf_sh_graph);
						shader_set_uniform_f(uni_curve_background_pos_res, _x1, _y1, _width, _height);
						shader_set_uniform_f(uni_curve_background_grid_size, 256/10, 256/10);
						shader_set_uniform_i(uni_curve_background_index, _background_index);
						draw_sprite_stretched(__spr_ppf_pixel, 0, _x1, _y1, _width, _height);
						shader_reset();
						draw_set_alpha(1);
						
						// draw graph
						var _graph = gui_color_curves_struct.DebugDraw(_x1, _y1, _x2, _y2, element.parent.__input_m_x, element.parent.__input_m_y, 1, 0,,0.5);
						if (surface_exists(gui_color_curves_struct.__debug_surf)) {
							inspector_struct.__bake();
							inspector_struct.__scroll_enable = !_graph.in_focus;
						}
						return _graph.height;
					} else {
						draw_set_halign(fa_center);
						draw_text(_x1+_width/2, _y1, "< Curve not found>\nSet one via parameter.");
						draw_set_halign(fa_left);
						return 48;
					}
				}))
			.AddElement(new __ppf_ui_checkbox("Preserve Luminance", 0, gui_ef_get_param_simple(FX_EFFECT.COLOR_CURVES, PP_COLOR_CURVES_PRESERVE_LUMA), function(checked) {return gui_ef_set_param_enable(checked, FX_EFFECT.COLOR_CURVES, PP_COLOR_CURVES_PRESERVE_LUMA);}))
			.AddElement(new __ppf_ui_folder("Data", false, 9))
			.AddElement(new __ppf_ui_button("Reset Channel", function() {
				if (gui_color_curves_struct != undefined) {
					switch(gui_color_curves_curve_index) {
						case 0: gui_color_curves_struct.ResetChannel(__ac_ppf_yrgb_curve); break;
						case 1: gui_color_curves_struct.ResetChannel(__ac_ppf_hhsl_curve); break;
					}
					inspector_struct.__bake();
					gui_color_curves_struct.__debug_bake();
				}
			}))
			.AddElement(new __ppf_ui_button("Reset Curve", function() {
				if (gui_color_curves_struct != undefined) {
					switch(gui_color_curves_curve_index) {
						case 0: gui_color_curves_struct.LoadAnimCurve(__ac_ppf_yrgb_curve); break;
						case 1: gui_color_curves_struct.LoadAnimCurve(__ac_ppf_hhsl_curve); break;
					}
					inspector_struct.__bake();
					gui_color_curves_struct.__debug_bake();
				}
			}))
			.AddElement(new __ppf_ui_separator())
			.AddElement(new __ppf_ui_button($"Export Curve ({PPFX_CFG_COLOR_CURVES_FORMAT})", function() {
				if (gui_color_curves_struct != undefined) {
					var _file = get_save_filename($"Curve File|*{PPFX_CFG_COLOR_CURVES_FORMAT}", $"Curve{PPFX_CFG_COLOR_CURVES_FORMAT}");
					if (_file != "") {
						gui_color_curves_struct.SaveFile(_file, gui_color_curves_secure_file);
					}
				}
			}))
			.AddElement(new __ppf_ui_button($"Import Curve ({PPFX_CFG_COLOR_CURVES_FORMAT})", function() {
				if (gui_color_curves_struct != undefined) {
					var _file = get_open_filename($"Curve File|*{PPFX_CFG_COLOR_CURVES_FORMAT}", $"Curve{PPFX_CFG_COLOR_CURVES_FORMAT}");
					if (_file != "") {
						gui_color_curves_struct.LoadFile(_file, gui_color_curves_secure_file);
						inspector_struct.__bake();
						gui_color_curves_struct.__debug_bake();
					}
				}
			}))
			.AddElement(new __ppf_ui_checkbox("File Protection", 0, gui_color_curves_secure_file, function(checked) {var _check = !checked; gui_color_curves_secure_file = _check; return _check;}))
			.AddElement(new __ppf_ui_separator())
			.AddElement(new __ppf_ui_button("Export LUT (.png)", function() {
				if (gui_color_curves_struct != undefined) {
					var _file = get_save_filename("PNG Image|*.png", "Curve.png");
					if (_file != "") {
						gui_color_curves_struct.SaveLUT(_file);
					}
				}
			}))
			.AddElement(new __ppf_ui_button("Import LUT (.png)", function() {
				if (gui_color_curves_struct != undefined) {
					var _file = get_open_filename("PNG Image|*.png", "Curve.png");
					if (_file != "") {
						if (sprite_exists(gui_yrgb_curve_sprite_id)) sprite_delete(gui_yrgb_curve_sprite_id);
						gui_yrgb_curve_sprite_id = sprite_add(_file, 0, 0, 0, 0, 0);
						gui_color_curves_struct.LoadSprite(gui_yrgb_curve_sprite_id, 0);
					}
				}
			}))
		
		// effect: LUT
		.AddElement(new __ppf_ui_menu("LUT", false, 8))
			.AddElement(new __ppf_ui_checkbox("Effect Enabled", 0, gui_ef_get_enabled(FX_EFFECT.LUT), function(checked) {return gui_ef_set_enabled(checked, FX_EFFECT.LUT);}))
			.AddElement(new __ppf_ui_slider("Intensity", 0, false, gui_ef_get_param_simple(FX_EFFECT.LUT, PP_LUT_INTENSITY), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.LUT, PP_LUT_INTENSITY);}))
				
			.AddElement(new __ppf_ui_folder("Type", false, 3))
				.AddElement(new __ppf_ui_button("Strip", function() {
					gui_ef_set_param_simple(0, FX_EFFECT.LUT, PP_LUT_TYPE);
				}))
				.AddElement(new __ppf_ui_button("Grid", function() {
					gui_ef_set_param_simple(1, FX_EFFECT.LUT, PP_LUT_TYPE);
				}))
				.AddElement(new __ppf_ui_button("Hald Grid (.Cube)", function() {
					gui_ef_set_param_simple(2, FX_EFFECT.LUT, PP_LUT_TYPE);
				}))
				
			.AddElement(new __ppf_ui_slider("Horizontal Squares", 64, false, gui_ef_get_param_simple(FX_EFFECT.LUT, PP_LUT_SQUARES), 0, 64, false, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.LUT, PP_LUT_SQUARES);}))
			.AddElement(new __ppf_ui_button("Texture", function() {
				var _file = get_open_filename("PNG Image|*.png", "*.png");
				if (_file != "") {
					if (sprite_exists(gui_lut_texture_id)) sprite_delete(gui_lut_texture_id);
					gui_lut_texture_id = sprite_add(_file, 0, 0, 0, 0, 0);
					gui_ef_set_param_simple(sprite_get_texture(gui_lut_texture_id, 0), FX_EFFECT.LUT, PP_LUT_TEXTURE);
				}
			}))
		
		// effect: PALETTE SWAP
		.AddElement(new __ppf_ui_menu("PALETTE SWAP", false, 8))
			.AddElement(new __ppf_ui_checkbox("Effect Enabled", 0, gui_ef_get_enabled(FX_EFFECT.PALETTE_SWAP), function(checked) {return gui_ef_set_enabled(checked, FX_EFFECT.PALETTE_SWAP);}))
			.AddElement(new __ppf_ui_slider("Row", 8, false, gui_ef_get_param_simple(FX_EFFECT.PALETTE_SWAP, PP_PALETTE_SWAP_ROW), 0, 8, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.PALETTE_SWAP, PP_PALETTE_SWAP_ROW);}))
			.AddElement(new __ppf_ui_slider("Height", 8, false, gui_ef_get_param_simple(FX_EFFECT.PALETTE_SWAP, PP_PALETTE_SWAP_PAL_HEIGHT), 0, 8, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.PALETTE_SWAP, PP_PALETTE_SWAP_PAL_HEIGHT);}))
			.AddElement(new __ppf_ui_slider("Threshold", 0, false, gui_ef_get_param_simple(FX_EFFECT.PALETTE_SWAP, PP_PALETTE_SWAP_THRESHOLD), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.PALETTE_SWAP, PP_PALETTE_SWAP_THRESHOLD);}))
			.AddElement(new __ppf_ui_slider("Smoothness", 0, false, gui_ef_get_param_simple(FX_EFFECT.PALETTE_SWAP, PP_PALETTE_SWAP_SMOOTHNESS), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.PALETTE_SWAP, PP_PALETTE_SWAP_SMOOTHNESS);}))
			.AddElement(new __ppf_ui_checkbox("Flip", 0, gui_ef_get_param_simple(FX_EFFECT.PALETTE_SWAP, PP_PALETTE_SWAP_FLIP), function(checked) {return gui_ef_set_param_enable(checked, FX_EFFECT.PALETTE_SWAP, PP_PALETTE_SWAP_FLIP);}))
			.AddElement(new __ppf_ui_checkbox("Limit Colors", 0, gui_ef_get_param_simple(FX_EFFECT.PALETTE_SWAP, PP_PALETTE_SWAP_LIMIT_COLORS), function(checked) {return gui_ef_set_param_enable(checked, FX_EFFECT.PALETTE_SWAP, PP_PALETTE_SWAP_LIMIT_COLORS);}))
			.AddElement(new __ppf_ui_button("Texture", function() {
				var _file = get_open_filename("PNG Image|*.png", "*.png");
				if (_file != "") {
					if (sprite_exists(gui_palette_texture_id)) sprite_delete(gui_palette_texture_id);
					gui_palette_texture_id = sprite_add(_file, 0, 0, 0, 0, 0);
					gui_ef_set_param_simple(sprite_get_texture(gui_palette_texture_id, 0), FX_EFFECT.PALETTE_SWAP, PP_PALETTE_SWAP_TEXTURE);
				}
			}))
		
		// effect: SHADOW, MIDTONE, HIGHLIGHT
		.AddElement(new __ppf_ui_menu("SHADOW, MIDTONE, HIGHLIGHT", false, 15))
			.AddElement(new __ppf_ui_checkbox("Effect Enabled", 0, gui_ef_get_enabled(FX_EFFECT.SHADOW_MIDTONE_HIGHLIGHT), function(checked) {return gui_ef_set_enabled(checked, FX_EFFECT.SHADOW_MIDTONE_HIGHLIGHT);}))
			.AddElement(new __ppf_ui_folder("Shadow", false, 3))
				.AddElement(new __ppf_ui_slider("Shadow - Red", 0, false, gui_ef_get_param_color_red(FX_EFFECT.SHADOW_MIDTONE_HIGHLIGHT, PP_SHADOW_COLOR), 0, 512, true, function(output) {gui_ef_set_param_color_red(output, FX_EFFECT.SHADOW_MIDTONE_HIGHLIGHT, PP_SHADOW_COLOR);}))
				.AddElement(new __ppf_ui_slider("Shadow - Green", 0, false, gui_ef_get_param_color_green(FX_EFFECT.SHADOW_MIDTONE_HIGHLIGHT, PP_SHADOW_COLOR), 0, 512, true, function(output) {gui_ef_set_param_color_green(output, FX_EFFECT.SHADOW_MIDTONE_HIGHLIGHT, PP_SHADOW_COLOR);}))
				.AddElement(new __ppf_ui_slider("Shadow - Blue", 0, false, gui_ef_get_param_color_blue(FX_EFFECT.SHADOW_MIDTONE_HIGHLIGHT, PP_SHADOW_COLOR), 0, 512, true, function(output) {gui_ef_set_param_color_blue(output, FX_EFFECT.SHADOW_MIDTONE_HIGHLIGHT, PP_SHADOW_COLOR);}))
			.AddElement(new __ppf_ui_folder("Midtone", false, 3))
				.AddElement(new __ppf_ui_slider("Midtone - Red", 0, false, gui_ef_get_param_color_red(FX_EFFECT.SHADOW_MIDTONE_HIGHLIGHT, PP_MIDTONE_COLOR), 0, 512, true, function(output) {gui_ef_set_param_color_red(output, FX_EFFECT.SHADOW_MIDTONE_HIGHLIGHT, PP_MIDTONE_COLOR);}))
				.AddElement(new __ppf_ui_slider("Midtone - Green", 0, false, gui_ef_get_param_color_green(FX_EFFECT.SHADOW_MIDTONE_HIGHLIGHT, PP_MIDTONE_COLOR), 0, 512, true, function(output) {gui_ef_set_param_color_green(output, FX_EFFECT.SHADOW_MIDTONE_HIGHLIGHT, PP_MIDTONE_COLOR);}))
				.AddElement(new __ppf_ui_slider("Midtone - Blue", 0, false, gui_ef_get_param_color_blue(FX_EFFECT.SHADOW_MIDTONE_HIGHLIGHT, PP_MIDTONE_COLOR), 0, 512, true, function(output) {gui_ef_set_param_color_blue(output, FX_EFFECT.SHADOW_MIDTONE_HIGHLIGHT, PP_MIDTONE_COLOR);}))
			.AddElement(new __ppf_ui_folder("Highlight", false, 3))
				.AddElement(new __ppf_ui_slider("Highlight - Red", 0, false, gui_ef_get_param_color_red(FX_EFFECT.SHADOW_MIDTONE_HIGHLIGHT, PP_HIGHLIGHT_COLOR), 0, 512, true, function(output) {gui_ef_set_param_color_red(output, FX_EFFECT.SHADOW_MIDTONE_HIGHLIGHT, PP_HIGHLIGHT_COLOR);}))
				.AddElement(new __ppf_ui_slider("Highlight - Green", 0, false, gui_ef_get_param_color_green(FX_EFFECT.SHADOW_MIDTONE_HIGHLIGHT, PP_HIGHLIGHT_COLOR), 0, 512, true, function(output) {gui_ef_set_param_color_green(output, FX_EFFECT.SHADOW_MIDTONE_HIGHLIGHT, PP_HIGHLIGHT_COLOR);}))
				.AddElement(new __ppf_ui_slider("Highlight - Blue", 0, false, gui_ef_get_param_color_blue(FX_EFFECT.SHADOW_MIDTONE_HIGHLIGHT, PP_HIGHLIGHT_COLOR), 0, 512, true, function(output) {gui_ef_set_param_color_blue(output, FX_EFFECT.SHADOW_MIDTONE_HIGHLIGHT, PP_HIGHLIGHT_COLOR);}))
			.AddElement(new __ppf_ui_slider("Shadow Range", 0, false, gui_ef_get_param_simple(FX_EFFECT.SHADOW_MIDTONE_HIGHLIGHT, PP_SHADOW_RANGE), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.SHADOW_MIDTONE_HIGHLIGHT, PP_SHADOW_RANGE);}))
			.AddElement(new __ppf_ui_slider("Highlight Range", 0, false, gui_ef_get_param_simple(FX_EFFECT.SHADOW_MIDTONE_HIGHLIGHT, PP_HIGHLIGHT_RANGE), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.SHADOW_MIDTONE_HIGHLIGHT, PP_HIGHLIGHT_RANGE);}))
		
		// effect: LIFT, GAMMA, GAIN
		.AddElement(new __ppf_ui_menu("LIFT, GAMMA, GAIN", false, 13))
			.AddElement(new __ppf_ui_checkbox("Effect Enabled", 0, gui_ef_get_enabled(FX_EFFECT.LIFT_GAMMA_GAIN), function(checked) {return gui_ef_set_enabled(checked, FX_EFFECT.LIFT_GAMMA_GAIN);}))
			.AddElement(new __ppf_ui_folder("Lift", false, 3))
				.AddElement(new __ppf_ui_slider("Lift - Red", 0, false, gui_ef_get_param_color_red(FX_EFFECT.LIFT_GAMMA_GAIN, PP_LIFT), 0, 512, true, function(output) {gui_ef_set_param_color_red(output, FX_EFFECT.LIFT_GAMMA_GAIN, PP_LIFT);}))
				.AddElement(new __ppf_ui_slider("Lift - Green", 0, false, gui_ef_get_param_color_green(FX_EFFECT.LIFT_GAMMA_GAIN, PP_LIFT), 0, 512, true, function(output) {gui_ef_set_param_color_green(output, FX_EFFECT.LIFT_GAMMA_GAIN, PP_LIFT);}))
				.AddElement(new __ppf_ui_slider("Lift - Blue", 0, false, gui_ef_get_param_color_blue(FX_EFFECT.LIFT_GAMMA_GAIN, PP_LIFT), 0, 512, true, function(output) {gui_ef_set_param_color_blue(output, FX_EFFECT.LIFT_GAMMA_GAIN, PP_LIFT);}))
			.AddElement(new __ppf_ui_folder("Gamma", false, 3))
				.AddElement(new __ppf_ui_slider("Gamma - Red", 0, false, gui_ef_get_param_color_red(FX_EFFECT.LIFT_GAMMA_GAIN, PP_GAMMA), 0, 512, true, function(output) {gui_ef_set_param_color_red(output, FX_EFFECT.LIFT_GAMMA_GAIN, PP_GAMMA);}))
				.AddElement(new __ppf_ui_slider("Gamma - Green", 0, false, gui_ef_get_param_color_green(FX_EFFECT.LIFT_GAMMA_GAIN, PP_GAMMA), 0, 512, true, function(output) {gui_ef_set_param_color_green(output, FX_EFFECT.LIFT_GAMMA_GAIN, PP_GAMMA);}))
				.AddElement(new __ppf_ui_slider("Gamma - Blue", 0, false, gui_ef_get_param_color_blue(FX_EFFECT.LIFT_GAMMA_GAIN, PP_GAMMA), 0, 512, true, function(output) {gui_ef_set_param_color_blue(output, FX_EFFECT.LIFT_GAMMA_GAIN, PP_GAMMA);}))
			.AddElement(new __ppf_ui_folder("Gain", false, 3))
				.AddElement(new __ppf_ui_slider("Gain - Red", 0, false, gui_ef_get_param_color_red(FX_EFFECT.LIFT_GAMMA_GAIN, PP_GAIN), 0, 512, true, function(output) {gui_ef_set_param_color_red(output, FX_EFFECT.LIFT_GAMMA_GAIN, PP_GAIN);}))
				.AddElement(new __ppf_ui_slider("Gain - Green", 0, false, gui_ef_get_param_color_green(FX_EFFECT.LIFT_GAMMA_GAIN, PP_GAIN), 0, 512, true, function(output) {gui_ef_set_param_color_green(output, FX_EFFECT.LIFT_GAMMA_GAIN, PP_GAIN);}))
				.AddElement(new __ppf_ui_slider("Gain - Blue", 0, false, gui_ef_get_param_color_blue(FX_EFFECT.LIFT_GAMMA_GAIN, PP_GAIN), 0, 512, true, function(output) {gui_ef_set_param_color_blue(output, FX_EFFECT.LIFT_GAMMA_GAIN, PP_GAIN);}))
		
		// effect: HUE SHIFT
		.AddElement(new __ppf_ui_menu("HUE SHIFT", false, 4))
			.AddElement(new __ppf_ui_checkbox("Effect Enabled", 0, gui_ef_get_enabled(FX_EFFECT.HUE_SHIFT), function(checked) {return gui_ef_set_enabled(checked, FX_EFFECT.HUE_SHIFT);}))
			.AddElement(new __ppf_ui_slider("Hue", 0, false, gui_ef_get_param_simple(FX_EFFECT.HUE_SHIFT, PP_HUE_SHIFT_HUE), 0, 255, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.HUE_SHIFT, PP_HUE_SHIFT_HUE);}))
			.AddElement(new __ppf_ui_slider("Saturation", gui_ef_get_param_simple(FX_EFFECT.HUE_SHIFT, PP_HUE_SHIFT_SATURATION), false, 255, 0, 510, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.HUE_SHIFT, PP_HUE_SHIFT_SATURATION);}))
			.AddElement(new __ppf_ui_checkbox("Preserve Luminance", 0, gui_ef_get_param_simple(FX_EFFECT.HUE_SHIFT, PP_HUE_SHIFT_PRESERVE_LUMA), function(checked) {return gui_ef_set_param_enable(checked, FX_EFFECT.HUE_SHIFT, PP_HUE_SHIFT_PRESERVE_LUMA);}))
		
		// effect: COLORIZE
		.AddElement(new __ppf_ui_menu("COLORIZE", false, 5))
			.AddElement(new __ppf_ui_checkbox("Effect Enabled", 0, gui_ef_get_enabled(FX_EFFECT.COLORIZE), function(checked) {return gui_ef_set_enabled(checked, FX_EFFECT.COLORIZE);}))
			.AddElement(new __ppf_ui_slider("Hue", 0, false, gui_ef_get_param_simple(FX_EFFECT.COLORIZE, PP_COLORIZE_HUE), 0, 255, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.COLORIZE, PP_COLORIZE_HUE);}))
			.AddElement(new __ppf_ui_slider("Saturation", 0, false, gui_ef_get_param_simple(FX_EFFECT.COLORIZE, PP_COLORIZE_SATURATION), 0, 255, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.COLORIZE, PP_COLORIZE_SATURATION);}))
			.AddElement(new __ppf_ui_slider("Value", 0, false, gui_ef_get_param_simple(FX_EFFECT.COLORIZE, PP_COLORIZE_VALUE), 0, 255, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.COLORIZE, PP_COLORIZE_VALUE);}))
			.AddElement(new __ppf_ui_slider("Intensity", 0, false, gui_ef_get_param_simple(FX_EFFECT.COLORIZE, PP_COLORIZE_INTENSITY), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.COLORIZE, PP_COLORIZE_INTENSITY);}))
		
		// effect: COLOR TINT
		.AddElement(new __ppf_ui_menu("COLOR TINT", false, 4))
			.AddElement(new __ppf_ui_checkbox("Effect Enabled", 0, gui_ef_get_enabled(FX_EFFECT.COLOR_TINT), function(checked) {return gui_ef_set_enabled(checked, FX_EFFECT.COLOR_TINT);}))
			.AddElement(new __ppf_ui_slider("Red", 0, false, gui_ef_get_param_color_red(FX_EFFECT.COLOR_TINT, PP_COLOR_TINT_COLOR), 0, 255, true, function(output) {gui_ef_set_param_color_red(output, FX_EFFECT.COLOR_TINT, PP_COLOR_TINT_COLOR);}))
			.AddElement(new __ppf_ui_slider("Green", 0, false, gui_ef_get_param_color_green(FX_EFFECT.COLOR_TINT, PP_COLOR_TINT_COLOR), 0, 255, true, function(output) {gui_ef_set_param_color_green(output, FX_EFFECT.COLOR_TINT, PP_COLOR_TINT_COLOR);}))
			.AddElement(new __ppf_ui_slider("Blue", 0, false, gui_ef_get_param_color_blue(FX_EFFECT.COLOR_TINT, PP_COLOR_TINT_COLOR), 0, 255, true, function(output) {gui_ef_set_param_color_blue(output, FX_EFFECT.COLOR_TINT, PP_COLOR_TINT_COLOR);}))
		
		// effect: CHANNEL MIXER
		.AddElement(new __ppf_ui_menu("CHANNEL MIXER", false, 13))
			.AddElement(new __ppf_ui_checkbox("Effect Enabled", 0, gui_ef_get_enabled(FX_EFFECT.CHANNEL_MIXER), function(checked) {return gui_ef_set_enabled(checked, FX_EFFECT.CHANNEL_MIXER);}))
			.AddElement(new __ppf_ui_folder("Red", false, 3))
				.AddElement(new __ppf_ui_slider("Red", 0, false, gui_ef_get_param_color_red(FX_EFFECT.CHANNEL_MIXER, PP_CHANNEL_MIXER_RED), 0, 512, true, function(output) {gui_ef_set_param_color_red(output, FX_EFFECT.CHANNEL_MIXER, PP_CHANNEL_MIXER_RED);}))
				.AddElement(new __ppf_ui_slider("Green", 0, false, gui_ef_get_param_color_green(FX_EFFECT.CHANNEL_MIXER, PP_CHANNEL_MIXER_RED), 0, 512, true, function(output) {gui_ef_set_param_color_green(output, FX_EFFECT.CHANNEL_MIXER, PP_CHANNEL_MIXER_RED);}))
				.AddElement(new __ppf_ui_slider("Blue", 0, false, gui_ef_get_param_color_blue(FX_EFFECT.CHANNEL_MIXER, PP_CHANNEL_MIXER_RED), 0, 512, true, function(output) {gui_ef_set_param_color_blue(output, FX_EFFECT.CHANNEL_MIXER, PP_CHANNEL_MIXER_RED);}))
			.AddElement(new __ppf_ui_folder("Green", false, 3))
				.AddElement(new __ppf_ui_slider("Red", 0, false, gui_ef_get_param_color_red(FX_EFFECT.CHANNEL_MIXER, PP_CHANNEL_MIXER_GREEN), 0, 512, true, function(output) {gui_ef_set_param_color_red(output, FX_EFFECT.CHANNEL_MIXER, PP_CHANNEL_MIXER_GREEN);}))
				.AddElement(new __ppf_ui_slider("Green", 0, false, gui_ef_get_param_color_green(FX_EFFECT.CHANNEL_MIXER, PP_CHANNEL_MIXER_GREEN), 0, 512, true, function(output) {gui_ef_set_param_color_green(output, FX_EFFECT.CHANNEL_MIXER, PP_CHANNEL_MIXER_GREEN);}))
				.AddElement(new __ppf_ui_slider("Blue", 0, false, gui_ef_get_param_color_blue(FX_EFFECT.CHANNEL_MIXER, PP_CHANNEL_MIXER_GREEN), 0, 512, true, function(output) {gui_ef_set_param_color_blue(output, FX_EFFECT.CHANNEL_MIXER, PP_CHANNEL_MIXER_GREEN);}))
			.AddElement(new __ppf_ui_folder("Blue", false, 3))
				.AddElement(new __ppf_ui_slider("Red", 0, false, gui_ef_get_param_color_red(FX_EFFECT.CHANNEL_MIXER, PP_CHANNEL_MIXER_BLUE), 0, 512, true, function(output) {gui_ef_set_param_color_red(output, FX_EFFECT.CHANNEL_MIXER, PP_CHANNEL_MIXER_BLUE);}))
				.AddElement(new __ppf_ui_slider("Green", 0, false, gui_ef_get_param_color_green(FX_EFFECT.CHANNEL_MIXER, PP_CHANNEL_MIXER_BLUE), 0, 512, true, function(output) {gui_ef_set_param_color_green(output, FX_EFFECT.CHANNEL_MIXER, PP_CHANNEL_MIXER_BLUE);}))
				.AddElement(new __ppf_ui_slider("Blue", 0, false, gui_ef_get_param_color_blue(FX_EFFECT.CHANNEL_MIXER, PP_CHANNEL_MIXER_BLUE), 0, 512, true, function(output) {gui_ef_set_param_color_blue(output, FX_EFFECT.CHANNEL_MIXER, PP_CHANNEL_MIXER_BLUE);}))
		
		// effect: INVERT COLORS
		.AddElement(new __ppf_ui_menu("INVERT COLORS", false, 2))
			.AddElement(new __ppf_ui_checkbox("Effect Enabled", 0, gui_ef_get_enabled(FX_EFFECT.INVERT_COLORS), function(checked) {return gui_ef_set_enabled(checked, FX_EFFECT.INVERT_COLORS);}))
			.AddElement(new __ppf_ui_slider("Intensity", 0, false, gui_ef_get_param_simple(FX_EFFECT.INVERT_COLORS, PP_INVERT_COLORS_INTENSITY), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.INVERT_COLORS, PP_INVERT_COLORS_INTENSITY);}))
		
		// effect: EXPOSURE
		.AddElement(new __ppf_ui_menu("EXPOSURE", false, 2))
			.AddElement(new __ppf_ui_checkbox("Effect Enabled", 0, gui_ef_get_enabled(FX_EFFECT.EXPOSURE), function(checked) {return gui_ef_set_enabled(checked, FX_EFFECT.EXPOSURE);}))
			.AddElement(new __ppf_ui_slider("Amount", 0, false, gui_ef_get_param_simple(FX_EFFECT.EXPOSURE, PP_EXPOSURE), 0, 10, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.EXPOSURE, PP_EXPOSURE);}))
		
		// effect: BRIGHTNESS
		.AddElement(new __ppf_ui_menu("BRIGHTNESS", false, 2))
			.AddElement(new __ppf_ui_checkbox("Effect Enabled", 0, gui_ef_get_enabled(FX_EFFECT.BRIGHTNESS), function(checked) {return gui_ef_set_enabled(checked, FX_EFFECT.BRIGHTNESS);}))
			.AddElement(new __ppf_ui_slider("Amount", 0, false, gui_ef_get_param_simple(FX_EFFECT.BRIGHTNESS, PP_BRIGHTNESS), 0, 2, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.BRIGHTNESS, PP_BRIGHTNESS);}))
		
		// effect: SATURATION
		.AddElement(new __ppf_ui_menu("SATURATION", false, 2))
			.AddElement(new __ppf_ui_checkbox("Effect Enabled", 0, gui_ef_get_enabled(FX_EFFECT.SATURATION), function(checked) {return gui_ef_set_enabled(checked, FX_EFFECT.SATURATION);}))
			.AddElement(new __ppf_ui_slider("Amount", 0, false, gui_ef_get_param_simple(FX_EFFECT.SATURATION, PP_SATURATION), 0, 2, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.SATURATION, PP_SATURATION);}))
		
		// effect: CONTRAST
		.AddElement(new __ppf_ui_menu("CONTRAST", false, 2))
			.AddElement(new __ppf_ui_checkbox("Effect Enabled", 0, gui_ef_get_enabled(FX_EFFECT.CONTRAST), function(checked) {return gui_ef_set_enabled(checked, FX_EFFECT.CONTRAST);}))
			.AddElement(new __ppf_ui_slider("Amount", 0, false, gui_ef_get_param_simple(FX_EFFECT.CONTRAST, PP_CONTRAST), 0, 3, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.CONTRAST, PP_CONTRAST);}))
		
		// effect: CHANNELS
		.AddElement(new __ppf_ui_menu("CHANNELS", false, 4))
			.AddElement(new __ppf_ui_checkbox("Effect Enabled", 0, gui_ef_get_enabled(FX_EFFECT.CHANNELS), function(checked) {return gui_ef_set_enabled(checked, FX_EFFECT.CHANNELS);}))
			.AddElement(new __ppf_ui_slider("Red Amount", 0, false, gui_ef_get_param_simple(FX_EFFECT.CHANNELS, PP_CHANNEL_RED), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.CHANNELS, PP_CHANNEL_RED);}))
			.AddElement(new __ppf_ui_slider("Green Amount", 0, false, gui_ef_get_param_simple(FX_EFFECT.CHANNELS, PP_CHANNEL_GREEN), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.CHANNELS, PP_CHANNEL_GREEN);}))
			.AddElement(new __ppf_ui_slider("Blue Amount", 0, false, gui_ef_get_param_simple(FX_EFFECT.CHANNELS, PP_CHANNEL_BLUE), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.CHANNELS, PP_CHANNEL_BLUE);}))
		
		// effect: POSTERIZATION
		.AddElement(new __ppf_ui_menu("POSTERIZATION", false, 2))
			.AddElement(new __ppf_ui_checkbox("Effect Enabled", 0, gui_ef_get_enabled(FX_EFFECT.POSTERIZATION), function(checked) {return gui_ef_set_enabled(checked, FX_EFFECT.POSTERIZATION);}))
			.AddElement(new __ppf_ui_slider("Color Factor", 128, false, gui_ef_get_param_simple(FX_EFFECT.POSTERIZATION, PP_POSTERIZATION_COL_FACTOR), 0, 128, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.POSTERIZATION, PP_POSTERIZATION_COL_FACTOR);}))
		
		// effect: WHITE BALANCE
		.AddElement(new __ppf_ui_menu("WHITE BALANCE", false, 3))
			.AddElement(new __ppf_ui_checkbox("Effect Enabled", 0, gui_ef_get_enabled(FX_EFFECT.WHITE_BALANCE), function(checked) {return gui_ef_set_enabled(checked, FX_EFFECT.WHITE_BALANCE);}))
			.AddElement(new __ppf_ui_slider("Temperature", 0, false, gui_ef_get_param_simple(FX_EFFECT.WHITE_BALANCE, PP_WHITE_BALANCE_TEMPERATURE), -1, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.WHITE_BALANCE, PP_WHITE_BALANCE_TEMPERATURE);}))
			.AddElement(new __ppf_ui_slider("Tint", gui_ef_get_param_simple(FX_EFFECT.WHITE_BALANCE, PP_WHITE_BALANCE_TINT), false, 0, -1, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.WHITE_BALANCE, PP_WHITE_BALANCE_TINT);}))
		
		// export color grading LUT
		.AddElement(new __ppf_ui_folder("Export Stack", false, 2))
		.AddElement(new __ppf_ui_text_ext("Info", 0, function(element) {
			var _width = element.parent.__panel_width-element.xx-element.parent.__element_xpadding;
			element.width = _width;
			var _text = "Use this option to bake all modifications to a color grading LUT sprite/image. This is useful for mobile platforms, as it saves a lot of math calculations in shaders.\n\nNOTE: The following effects in this category are not included in the LUT:\n\nWhite Balance, Palette Swap.";
			return _text;
		}))
		.AddElement(new __ppf_ui_button("Export color grading as LUT", function() {
			var _sprite = __inspected_class.GetBakedLUT();
			if (_sprite != undefined) {
				var _file = get_save_filename("*.png", "GradingLUT.png");
				if (_file != "") {
					sprite_save(_sprite, 0, _file);
				}
			} else {
				__ppf_trace("Neutral LUT not found. Use .SetBakingLUT() to set one.");
			}
		}));
		
		#endregion
		
		#region >> CATEGORY: TRANSFORM
		inspector_struct
		.AddElement(new __ppf_ui_category("Transform", false, 59))
		
		// effect: DISPLACEMENT MAPS
		.AddElement(new __ppf_ui_menu("DISPLACEMENT MAPS", false, 9))
			.AddElement(new __ppf_ui_checkbox("Effect Enabled", 0, gui_ef_get_enabled(FX_EFFECT.DISPLACEMAP), function(checked) {return gui_ef_set_enabled(checked, FX_EFFECT.DISPLACEMAP);}))
			.AddElement(new __ppf_ui_slider("Amount", 0, false, gui_ef_get_param_simple(FX_EFFECT.DISPLACEMAP, PP_DISPLACEMAP_AMOUNT), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.DISPLACEMAP, PP_DISPLACEMAP_AMOUNT);}))
			.AddElement(new __ppf_ui_slider("Scale", 0, false, gui_ef_get_param_simple(FX_EFFECT.DISPLACEMAP, PP_DISPLACEMAP_SCALE), 0, 20, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.DISPLACEMAP, PP_DISPLACEMAP_SCALE);}))
			.AddElement(new __ppf_ui_slider("Angle", 0, false, gui_ef_get_param_simple(FX_EFFECT.DISPLACEMAP, PP_DISPLACEMAP_ANGLE), 0, 360, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.DISPLACEMAP, PP_DISPLACEMAP_ANGLE);}))
			.AddElement(new __ppf_ui_slider("Speed", 0, false, gui_ef_get_param_simple(FX_EFFECT.DISPLACEMAP, PP_DISPLACEMAP_SPEED), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.DISPLACEMAP, PP_DISPLACEMAP_SPEED);}))
			.AddElement(new __ppf_ui_folder("Offset", false, 2))
				.AddElement(new __ppf_ui_slider("Offset X", 0, false, gui_ef_get_param_vec2_x(FX_EFFECT.DISPLACEMAP, PP_DISPLACEMAP_OFFSET), -100, 100, true, function(output) {gui_ef_set_param_vec2_x(output, FX_EFFECT.DISPLACEMAP, PP_DISPLACEMAP_OFFSET);}))
				.AddElement(new __ppf_ui_slider("Offset Y", 0, false, gui_ef_get_param_vec2_y(FX_EFFECT.DISPLACEMAP, PP_DISPLACEMAP_OFFSET), -100, 100, true, function(output) {gui_ef_set_param_vec2_y(output, FX_EFFECT.DISPLACEMAP, PP_DISPLACEMAP_OFFSET);}))
			.AddElement(new __ppf_ui_button("Texture", function() {
				var _file = get_open_filename("PNG Image|*.png", "*.png");
				if (_file != "") {
					if (sprite_exists(gui_displacemap_texture_id)) sprite_delete(gui_displacemap_texture_id);
					gui_displacemap_texture_id = sprite_add(_file, 0, 0, 0, 0, 0);
					gui_ef_set_param_simple(sprite_get_texture(gui_displacemap_texture_id, 0), FX_EFFECT.DISPLACEMAP, PP_DISPLACEMAP_TEXTURE, sprite_get_texture(gui_displacemap_texture_id, 0));
				}
			}))
		
		// effect: LENS DISTORTION
		.AddElement(new __ppf_ui_menu("LENS DISTORTION", false, 2))
			.AddElement(new __ppf_ui_checkbox("Effect Enabled", 0, gui_ef_get_enabled(FX_EFFECT.LENS_DISTORTION), function(checked) {return gui_ef_set_enabled(checked, FX_EFFECT.LENS_DISTORTION);}))
			.AddElement(new __ppf_ui_slider("Amount", 0, false, gui_ef_get_param_simple(FX_EFFECT.LENS_DISTORTION, PP_LENS_DISTORTION_AMOUNT), -1, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.LENS_DISTORTION, PP_LENS_DISTORTION_AMOUNT);}))
		
		// effect: PANORAMA
		.AddElement(new __ppf_ui_menu("PANORAMA", false, 3))
			.AddElement(new __ppf_ui_checkbox("Effect Enabled", 0, gui_ef_get_enabled(FX_EFFECT.PANORAMA), function(checked) {return gui_ef_set_enabled(checked, FX_EFFECT.PANORAMA);}))
			.AddElement(new __ppf_ui_slider("Depth X", 0, false, gui_ef_get_param_simple(FX_EFFECT.PANORAMA, PP_PANORAMA_DEPTH_X), 0, 3, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.PANORAMA, PP_PANORAMA_DEPTH_X);}))
			.AddElement(new __ppf_ui_slider("Depth Y", 0, false, gui_ef_get_param_simple(FX_EFFECT.PANORAMA, PP_PANORAMA_DEPTH_Y), 0, 3, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.PANORAMA, PP_PANORAMA_DEPTH_Y);}))
		
		// effect: PIXELIZE
		.AddElement(new __ppf_ui_menu("PIXELIZE", false, 4))
			.AddElement(new __ppf_ui_checkbox("Effect Enabled", 0, gui_ef_get_enabled(FX_EFFECT.PIXELIZE), function(checked) {return gui_ef_set_enabled(checked, FX_EFFECT.PIXELIZE);}))
			.AddElement(new __ppf_ui_slider("Amount", 0, false, gui_ef_get_param_simple(FX_EFFECT.PIXELIZE, PP_PIXELIZE_AMOUNT), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.PIXELIZE, PP_PIXELIZE_AMOUNT);}))
			.AddElement(new __ppf_ui_slider("Squares Max", 40, false, gui_ef_get_param_simple(FX_EFFECT.PIXELIZE, PP_PIXELIZE_SQUARES_MAX), 0, 40, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.PIXELIZE, PP_PIXELIZE_SQUARES_MAX);}))
			.AddElement(new __ppf_ui_slider("Steps", 50, false, gui_ef_get_param_simple(FX_EFFECT.PIXELIZE, PP_PIXELIZE_STEPS), 0, 50, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.PIXELIZE, PP_PIXELIZE_STEPS);}))
		
		// effect: ROTATION
		.AddElement(new __ppf_ui_menu("ROTATION", false, 2))
			.AddElement(new __ppf_ui_checkbox("Effect Enabled", 0, gui_ef_get_enabled(FX_EFFECT.ROTATION), function(checked) {return gui_ef_set_enabled(checked, FX_EFFECT.ROTATION);}))
			.AddElement(new __ppf_ui_slider("Angle", 0, false, gui_ef_get_param_simple(FX_EFFECT.ROTATION, PP_ROTATION_ANGLE), 0, 360, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.ROTATION, PP_ROTATION_ANGLE);}))
		
		// effect: SINE WAVE
		.AddElement(new __ppf_ui_menu("SINE WAVE", false, 8))
			.AddElement(new __ppf_ui_checkbox("Effect Enabled", 0, gui_ef_get_enabled(FX_EFFECT.SINE_WAVE), function(checked) {return gui_ef_set_enabled(checked, FX_EFFECT.SINE_WAVE);}))
			.AddElement(new __ppf_ui_slider("Speed", 0, false, gui_ef_get_param_simple(FX_EFFECT.SINE_WAVE, PP_SINE_WAVE_SPEED), 0, 20, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.SINE_WAVE, PP_SINE_WAVE_SPEED);}))
			.AddElement(new __ppf_ui_slider("Amplitude X", 0, false, gui_ef_get_param_vec2_x(FX_EFFECT.SINE_WAVE, PP_SINE_WAVE_AMPLITUDE), -1, 1, true, function(output) {gui_ef_set_param_vec2_x(output, FX_EFFECT.SINE_WAVE, PP_SINE_WAVE_AMPLITUDE);}))
			.AddElement(new __ppf_ui_slider("Amplitude Y", 0, false, gui_ef_get_param_vec2_y(FX_EFFECT.SINE_WAVE, PP_SINE_WAVE_AMPLITUDE), -1, 1, true, function(output) {gui_ef_set_param_vec2_y(output, FX_EFFECT.SINE_WAVE, PP_SINE_WAVE_AMPLITUDE);}))
			.AddElement(new __ppf_ui_slider("Frequency X", 0, false, gui_ef_get_param_vec2_x(FX_EFFECT.SINE_WAVE, PP_SINE_WAVE_FREQUENCY), 0, 50, true, function(output) {gui_ef_set_param_vec2_x(output, FX_EFFECT.SINE_WAVE, PP_SINE_WAVE_FREQUENCY);}))
			.AddElement(new __ppf_ui_slider("Frequency Y", 0, false, gui_ef_get_param_vec2_y(FX_EFFECT.SINE_WAVE, PP_SINE_WAVE_FREQUENCY), 0, 50, true, function(output) {gui_ef_set_param_vec2_y(output, FX_EFFECT.SINE_WAVE, PP_SINE_WAVE_FREQUENCY);}))
			.AddElement(new __ppf_ui_slider("Offset X", 0, false, gui_ef_get_param_vec2_x(FX_EFFECT.SINE_WAVE, PP_SINE_WAVE_OFFSET), -100, 100, true, function(output) {gui_ef_set_param_vec2_x(output, FX_EFFECT.SINE_WAVE, PP_SINE_WAVE_OFFSET);}))
			.AddElement(new __ppf_ui_slider("Offset Y", 0, false, gui_ef_get_param_vec2_y(FX_EFFECT.SINE_WAVE, PP_SINE_WAVE_OFFSET), -100, 100, true, function(output) {gui_ef_set_param_vec2_y(output, FX_EFFECT.SINE_WAVE, PP_SINE_WAVE_OFFSET);}))
		
		// effect: SHAKE
		.AddElement(new __ppf_ui_menu("SHAKE", false, 5))
			.AddElement(new __ppf_ui_checkbox("Effect Enabled", 0, gui_ef_get_enabled(FX_EFFECT.SHAKE), function(checked) {return gui_ef_set_enabled(checked, FX_EFFECT.SHAKE);}))
			.AddElement(new __ppf_ui_slider("Speed", 0, false, gui_ef_get_param_simple(FX_EFFECT.SHAKE, PP_SHAKE_SPEED), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.SHAKE, PP_SHAKE_SPEED);}))
			.AddElement(new __ppf_ui_slider("Magnitude", 0, false, gui_ef_get_param_simple(FX_EFFECT.SHAKE, PP_SHAKE_MAGNITUDE), 0, 0.1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.SHAKE, PP_SHAKE_MAGNITUDE);}))
			.AddElement(new __ppf_ui_slider("Hspeed", 0, false, gui_ef_get_param_simple(FX_EFFECT.SHAKE, PP_SHAKE_HSPEED), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.SHAKE, PP_SHAKE_HSPEED);}))
			.AddElement(new __ppf_ui_slider("Vspeed", 0, false, gui_ef_get_param_simple(FX_EFFECT.SHAKE, PP_SHAKE_VSPEED), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.SHAKE, PP_SHAKE_VSPEED);}))
		
		// effect: SHOCKWAVES
		.AddElement(new __ppf_ui_menu("SHOCKWAVES", false, 4))
			.AddElement(new __ppf_ui_checkbox("Effect Enabled", 0, gui_ef_get_enabled(FX_EFFECT.SHOCKWAVES), function(checked) {return gui_ef_set_enabled(checked, FX_EFFECT.SHOCKWAVES);}))
			.AddElement(new __ppf_ui_slider("Amount", 0, false, 0.1, 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.SHOCKWAVES, PP_SHOCKWAVES_AMOUNT);}))
			.AddElement(new __ppf_ui_slider("Aberration", 0, false, 0.1, 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.SHOCKWAVES, PP_SHOCKWAVES_ABERRATION);}))
		.AddElement(new __ppf_ui_button("Prisma LUT", function() {
				gui_shockwaves_lut_type += 1;
				if (gui_shockwaves_lut_type >= array_length(gui_shockwaves_lut_list)) gui_shockwaves_lut_type = 0;
				gui_ef_set_param_simple(sprite_get_texture(gui_shockwaves_lut_list[gui_shockwaves_lut_type], 0), FX_EFFECT.SHOCKWAVES, PP_SHOCKWAVES_PRISMA_LUT_TEX);
			}))
		
		// effect: SWIRL
		.AddElement(new __ppf_ui_menu("SWIRL", false, 6))
			.AddElement(new __ppf_ui_checkbox("Effect Enabled", 0, gui_ef_get_enabled(FX_EFFECT.SWIRL), function(checked) {return gui_ef_set_enabled(checked, FX_EFFECT.SWIRL);}))
			.AddElement(new __ppf_ui_slider("Angle", 0, false, gui_ef_get_param_simple(FX_EFFECT.SWIRL, PP_SWIRL_ANGLE), -720, 720, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.SWIRL, PP_SWIRL_ANGLE);}))
			.AddElement(new __ppf_ui_slider("Radius", 0, false, gui_ef_get_param_simple(FX_EFFECT.SWIRL, PP_SWIRL_RADIUS), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.SWIRL, PP_SWIRL_RADIUS);}))
			.AddElement(new __ppf_ui_folder("Center", false, 2))
				.AddElement(new __ppf_ui_slider("Center X", 0, false, gui_ef_get_param_vec2_x(FX_EFFECT.SWIRL, PP_SWIRL_CENTER), 0, 1, true, function(output) {gui_ef_set_param_vec2_x(output, FX_EFFECT.SWIRL, PP_SWIRL_CENTER);}))
				.AddElement(new __ppf_ui_slider("Center Y", 0, false, gui_ef_get_param_vec2_y(FX_EFFECT.SWIRL, PP_SWIRL_CENTER), 0, 1, true, function(output) {gui_ef_set_param_vec2_y(output, FX_EFFECT.SWIRL, PP_SWIRL_CENTER);}))
		
		// effect: ZOOM
		.AddElement(new __ppf_ui_menu("ZOOM", false, 6))
			.AddElement(new __ppf_ui_checkbox("Effect Enabled", 0, gui_ef_get_enabled(FX_EFFECT.ZOOM), function(checked) {return gui_ef_set_enabled(checked, FX_EFFECT.ZOOM);}))
			.AddElement(new __ppf_ui_slider("Amount", 0, false, gui_ef_get_param_simple(FX_EFFECT.ZOOM, PP_ZOOM_AMOUNT), 0, 2, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.ZOOM, PP_ZOOM_AMOUNT);}))
			.AddElement(new __ppf_ui_slider("Range", 0, false, gui_ef_get_param_simple(FX_EFFECT.ZOOM, PP_ZOOM_RANGE), 1, 10, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.ZOOM, PP_ZOOM_RANGE);}))
			.AddElement(new __ppf_ui_folder("Focus", false, 2))
				.AddElement(new __ppf_ui_slider("Center X", 0, false, gui_ef_get_param_vec2_x(FX_EFFECT.ZOOM, PP_ZOOM_CENTER), 0, 1, true, function(output) {gui_ef_set_param_vec2_x(output, FX_EFFECT.ZOOM, PP_ZOOM_CENTER);}))
				.AddElement(new __ppf_ui_slider("Center Y", 0, false, gui_ef_get_param_vec2_y(FX_EFFECT.ZOOM, PP_ZOOM_CENTER), 0, 1, true, function(output) {gui_ef_set_param_vec2_y(output, FX_EFFECT.ZOOM, PP_ZOOM_CENTER);}));
		
		#endregion
		
		#region >> CATEGORY: ARTISTIC
		inspector_struct
		.AddElement(new __ppf_ui_category("Artistic", false, 109))
			
		// effect: VHS
		.AddElement(new __ppf_ui_menu("VHS", false, 16))
			.AddElement(new __ppf_ui_checkbox("Effect Enabled", 0, gui_ef_get_enabled(FX_EFFECT.VHS), function(checked) {return gui_ef_set_enabled(checked, FX_EFFECT.VHS);}))
			.AddElement(new __ppf_ui_slider("Chromatic Aberration", 0, false, gui_ef_get_param_simple(FX_EFFECT.VHS, PP_VHS_CHROMATIC_ABERRATION), 0, 10, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.VHS, PP_VHS_CHROMATIC_ABERRATION);}))
			.AddElement(new __ppf_ui_slider("Scan Aberration", 0, false, gui_ef_get_param_simple(FX_EFFECT.VHS, PP_VHS_SCAN_CHROMATIC_ABERRATION), 0, 10, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.VHS, PP_VHS_SCAN_CHROMATIC_ABERRATION);}))
			.AddElement(new __ppf_ui_slider("Grain Intensity", 0, false, gui_ef_get_param_simple(FX_EFFECT.VHS, PP_VHS_GRAIN_INTENSITY), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.VHS, PP_VHS_GRAIN_INTENSITY);}))
			.AddElement(new __ppf_ui_slider("Grain Height", 0, false, gui_ef_get_param_simple(FX_EFFECT.VHS, PP_VHS_GRAIN_HEIGHT), 1, 50, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.VHS, PP_VHS_GRAIN_HEIGHT);}))
			.AddElement(new __ppf_ui_slider("Grain Fade", 0, false, gui_ef_get_param_simple(FX_EFFECT.VHS, PP_VHS_GRAIN_FADE), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.VHS, PP_VHS_GRAIN_FADE);}))
			.AddElement(new __ppf_ui_slider("Grain Amount", 0, false, gui_ef_get_param_simple(FX_EFFECT.VHS, PP_VHS_GRAIN_AMOUNT), 1, 100, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.VHS, PP_VHS_GRAIN_AMOUNT);}))
			.AddElement(new __ppf_ui_slider("Grain Speed", 0, false, gui_ef_get_param_simple(FX_EFFECT.VHS, PP_VHS_GRAIN_SPEED), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.VHS, PP_VHS_GRAIN_SPEED);}))
			.AddElement(new __ppf_ui_slider("Grain Interval", 0, false, gui_ef_get_param_simple(FX_EFFECT.VHS, PP_VHS_GRAIN_INTERVAL), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.VHS, PP_VHS_GRAIN_INTERVAL);}))
			.AddElement(new __ppf_ui_slider("Scan Speed", 0, false, gui_ef_get_param_simple(FX_EFFECT.VHS, PP_VHS_SCAN_SPEED), 0, 5, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.VHS, PP_VHS_SCAN_SPEED);}))
			.AddElement(new __ppf_ui_slider("Scan Size", 0, false, gui_ef_get_param_simple(FX_EFFECT.VHS, PP_VHS_SCAN_SIZE), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.VHS, PP_VHS_SCAN_SIZE);}))
			.AddElement(new __ppf_ui_slider("Scan Offset", 0, false, gui_ef_get_param_simple(FX_EFFECT.VHS, PP_VHS_SCAN_OFFSET), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.VHS, PP_VHS_SCAN_OFFSET);}))
			.AddElement(new __ppf_ui_slider("HScan Offset", 0, false, gui_ef_get_param_simple(FX_EFFECT.VHS, PP_VHS_HSCAN_OFFSET), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.VHS, PP_VHS_HSCAN_OFFSET);}))
			.AddElement(new __ppf_ui_slider("Flickering Intensity", 0, false, gui_ef_get_param_simple(FX_EFFECT.VHS, PP_VHS_FLICKERING_INTENSITY), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.VHS, PP_VHS_FLICKERING_INTENSITY);}))
			.AddElement(new __ppf_ui_slider("Flickering Speed", 0, false, gui_ef_get_param_simple(FX_EFFECT.VHS, PP_VHS_FLICKERING_SPEED), 0, 10, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.VHS, PP_VHS_FLICKERING_SPEED);}))
			.AddElement(new __ppf_ui_slider("Wiggle Amplitude", 0, false, gui_ef_get_param_simple(FX_EFFECT.VHS, PP_VHS_WIGGLE_AMPLITUDE), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.VHS, PP_VHS_WIGGLE_AMPLITUDE);}))
			
		// effect: GLITCH
		.AddElement(new __ppf_ui_menu("GLITCH", false, 7))
			.AddElement(new __ppf_ui_checkbox("Effect Enabled", 0, gui_ef_get_enabled(FX_EFFECT.GLITCH), function(checked) {return gui_ef_set_enabled(checked, FX_EFFECT.GLITCH);}))
			.AddElement(new __ppf_ui_slider("Speed", 0, false, gui_ef_get_param_simple(FX_EFFECT.GLITCH, PP_GLITCH_SPEED), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.GLITCH, PP_GLITCH_SPEED);}))
			.AddElement(new __ppf_ui_slider("Block Size", 0, false, gui_ef_get_param_simple(FX_EFFECT.GLITCH, PP_GLITCH_BLOCK_SIZE), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.GLITCH, PP_GLITCH_BLOCK_SIZE);}))
			.AddElement(new __ppf_ui_slider("Interval", 0, false, gui_ef_get_param_simple(FX_EFFECT.GLITCH, PP_GLITCH_INTERVAL), 0.5, 0.999, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.GLITCH, PP_GLITCH_INTERVAL);}))
			.AddElement(new __ppf_ui_slider("Intensity", 0, false, gui_ef_get_param_simple(FX_EFFECT.GLITCH, PP_GLITCH_INTENSITY), -1, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.GLITCH, PP_GLITCH_INTENSITY);}))
			.AddElement(new __ppf_ui_slider("Peak Amplitude 1", 0, false, gui_ef_get_param_simple(FX_EFFECT.GLITCH, PP_GLITCH_AMPLITUDE1), -5, 5, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.GLITCH, PP_GLITCH_AMPLITUDE1);}))
			.AddElement(new __ppf_ui_slider("Peak Amplitude 2", 0, false, gui_ef_get_param_simple(FX_EFFECT.GLITCH, PP_GLITCH_AMPLITUDE2), -5, 5, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.GLITCH, PP_GLITCH_AMPLITUDE2);}))
		
		// effect: CINEMA BARS
		.AddElement(new __ppf_ui_menu("CINEMA BARS", false, 10))
			.AddElement(new __ppf_ui_checkbox("Effect Enabled", 0, gui_ef_get_enabled(FX_EFFECT.CINEMA_BARS), function(checked) {return gui_ef_set_enabled(checked, FX_EFFECT.CINEMA_BARS);}))
			.AddElement(new __ppf_ui_slider("Amount", 0, false, gui_ef_get_param_simple(FX_EFFECT.CINEMA_BARS, PP_CINEMA_BARS_AMOUNT), 0, 0.3, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.CINEMA_BARS, PP_CINEMA_BARS_AMOUNT);}))
			.AddElement(new __ppf_ui_slider("Intensity", 0, false, gui_ef_get_param_simple(FX_EFFECT.CINEMA_BARS, PP_CINEMA_BARS_INTENSITY), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.CINEMA_BARS, PP_CINEMA_BARS_INTENSITY);}))
				.AddElement(new __ppf_ui_folder("Color", false, 3))
					.AddElement(new __ppf_ui_slider("Red", 0, false, gui_ef_get_param_color_red(FX_EFFECT.CINEMA_BARS, PP_CINEMA_BARS_COLOR), 0, 255, true, function(output) {gui_ef_set_param_color_red(output, FX_EFFECT.CINEMA_BARS, PP_CINEMA_BARS_COLOR);}))
					.AddElement(new __ppf_ui_slider("Green", 0, false, gui_ef_get_param_color_green(FX_EFFECT.CINEMA_BARS, PP_CINEMA_BARS_COLOR), 0, 255, true, function(output) {gui_ef_set_param_color_green(output, FX_EFFECT.CINEMA_BARS, PP_CINEMA_BARS_COLOR);}))
					.AddElement(new __ppf_ui_slider("Blue", 0, false, gui_ef_get_param_color_blue(FX_EFFECT.CINEMA_BARS, PP_CINEMA_BARS_COLOR), 0, 255, true, function(output) {gui_ef_set_param_color_blue(output, FX_EFFECT.CINEMA_BARS, PP_CINEMA_BARS_COLOR);}))
			.AddElement(new __ppf_ui_checkbox("Vertical Enable", 0, gui_ef_get_param_simple(FX_EFFECT.CINEMA_BARS, PP_CINEMA_BARS_VERT_ENABLE), function(checked) {return gui_ef_set_param_enable(checked, FX_EFFECT.CINEMA_BARS, PP_CINEMA_BARS_VERT_ENABLE);}))
			.AddElement(new __ppf_ui_checkbox("Horizontal Enable", 0, gui_ef_get_param_simple(FX_EFFECT.CINEMA_BARS, PP_CINEMA_BARS_HOR_ENABLE), function(checked) {return gui_ef_set_param_enable(checked, FX_EFFECT.CINEMA_BARS, PP_CINEMA_BARS_HOR_ENABLE);}))
			.AddElement(new __ppf_ui_checkbox("Can Distort", 0, gui_ef_get_param_simple(FX_EFFECT.CINEMA_BARS, PP_CINEMA_BARS_CAN_DISTORT), function(checked) {return gui_ef_set_param_enable(checked, FX_EFFECT.CINEMA_BARS, PP_CINEMA_BARS_CAN_DISTORT);}))
		
		// effect: DITHERING
		.AddElement(new __ppf_ui_menu("DITHERING", false, 8))
			.AddElement(new __ppf_ui_checkbox("Effect Enabled", 0, gui_ef_get_enabled(FX_EFFECT.DITHERING), function(checked) {return gui_ef_set_enabled(checked, FX_EFFECT.DITHERING);}))
			.AddElement(new __ppf_ui_button("Mode", function() {
				gui_dithering_mode += 1;
				if (gui_dithering_mode > 3) gui_dithering_mode = 0;
				__inspected_class.SetEffectParameter(FX_EFFECT.DITHERING, PP_DITHERING_MODE, gui_dithering_mode);
			}))
			.AddElement(new __ppf_ui_slider("Intensity", 0, false, gui_ef_get_param_simple(FX_EFFECT.DITHERING, PP_DITHERING_INTENSITY), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.DITHERING, PP_DITHERING_INTENSITY);}))
			.AddElement(new __ppf_ui_slider("Bit Levels", 32, false, gui_ef_get_param_simple(FX_EFFECT.DITHERING, PP_DITHERING_BIT_LEVELS), 0, 32, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.DITHERING, PP_DITHERING_BIT_LEVELS);}))
			.AddElement(new __ppf_ui_slider("Contrast", 0, false, gui_ef_get_param_simple(FX_EFFECT.DITHERING, PP_DITHERING_CONTRAST), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.DITHERING, PP_DITHERING_CONTRAST);}))
			.AddElement(new __ppf_ui_slider("Threshold", 0, false, gui_ef_get_param_simple(FX_EFFECT.DITHERING, PP_DITHERING_THRESHOLD), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.DITHERING, PP_DITHERING_THRESHOLD);}))
			.AddElement(new __ppf_ui_slider("Scale", 4, false, gui_ef_get_param_simple(FX_EFFECT.DITHERING, PP_DITHERING_SCALE), 1, 4, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.DITHERING, PP_DITHERING_SCALE);}))
			.AddElement(new __ppf_ui_button("Bayer Matrix Texture", function() {
				gui_dithering_index += 1; if (gui_dithering_index >= array_length(gui_dithering_bayers)) gui_dithering_index = 0;
				gui_ef_set_param_simple(gui_dithering_bayers[gui_dithering_index][1], FX_EFFECT.DITHERING, PP_DITHERING_BAYER_SIZE);
				gui_ef_set_param_simple(sprite_get_texture(gui_dithering_bayers[gui_dithering_index][0], 0), FX_EFFECT.DITHERING, PP_DITHERING_BAYER_TEXTURE);
			}))
		
		// effect: NOISE GRAIN
		.AddElement(new __ppf_ui_menu("NOISE GRAIN", false, 7))
			.AddElement(new __ppf_ui_checkbox("Effect Enabled", 0, gui_ef_get_enabled(FX_EFFECT.NOISE_GRAIN), function(checked) {return gui_ef_set_enabled(checked, FX_EFFECT.NOISE_GRAIN);}))
			.AddElement(new __ppf_ui_slider("Intensity", 0, false, gui_ef_get_param_simple(FX_EFFECT.NOISE_GRAIN, PP_NOISEGRAIN_INTENSITY), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.NOISE_GRAIN, PP_NOISEGRAIN_INTENSITY);}))
			.AddElement(new __ppf_ui_slider("Luminosity", 0, false, gui_ef_get_param_simple(FX_EFFECT.NOISE_GRAIN, PP_NOISEGRAIN_LUMINOSITY), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.NOISE_GRAIN, PP_NOISEGRAIN_LUMINOSITY);}))
			.AddElement(new __ppf_ui_slider("Scale", 0, false, gui_ef_get_param_simple(FX_EFFECT.NOISE_GRAIN, PP_NOISEGRAIN_SCALE), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.NOISE_GRAIN, PP_NOISEGRAIN_SCALE);}))
			.AddElement(new __ppf_ui_slider("Speed", 0, false, gui_ef_get_param_simple(FX_EFFECT.NOISE_GRAIN, PP_NOISEGRAIN_SPEED), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.NOISE_GRAIN, PP_NOISEGRAIN_SPEED);}))
			.AddElement(new __ppf_ui_checkbox("Mix", 0, gui_ef_get_param_simple(FX_EFFECT.NOISE_GRAIN, PP_NOISEGRAIN_MIX), function(checked) {return gui_ef_set_param_enable(checked, FX_EFFECT.NOISE_GRAIN, PP_NOISEGRAIN_MIX);}))
			.AddElement(new __ppf_ui_button("Noise Texture", function() {
				gui_noisegrain_noise_type += 1;
				if (gui_noisegrain_noise_type >= array_length(gui_noisegrain_noise_tex_list)) gui_noisegrain_noise_type = 0;
				gui_ef_set_param_simple(sprite_get_texture(gui_noisegrain_noise_tex_list[gui_noisegrain_noise_type], 0), FX_EFFECT.NOISE_GRAIN, PP_NOISEGRAIN_NOISE_TEX);
			}))
		
		// effect: SCANLINES
		.AddElement(new __ppf_ui_menu("SCANLINES", false, 12))
			.AddElement(new __ppf_ui_checkbox("Effect Enabled", 0, gui_ef_get_enabled(FX_EFFECT.SCANLINES), function(checked) {return gui_ef_set_enabled(checked, FX_EFFECT.SCANLINES);}))
			.AddElement(new __ppf_ui_slider("Intensity", 0, false, gui_ef_get_param_simple(FX_EFFECT.SCANLINES, PP_SCANLINES_INTENSITY), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.SCANLINES, PP_SCANLINES_INTENSITY);}))
			.AddElement(new __ppf_ui_slider("Sharpness", 0, false, gui_ef_get_param_simple(FX_EFFECT.SCANLINES, PP_SCANLINES_SHARPNESS), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.SCANLINES, PP_SCANLINES_SHARPNESS);}))
			.AddElement(new __ppf_ui_slider("Speed", 0, false, gui_ef_get_param_simple(FX_EFFECT.SCANLINES, PP_SCANLINES_SPEED), 0, 5, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.SCANLINES, PP_SCANLINES_SPEED);}))
			.AddElement(new __ppf_ui_slider("Amount", 0, false, gui_ef_get_param_simple(FX_EFFECT.SCANLINES, PP_SCANLINES_AMOUNT), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.SCANLINES, PP_SCANLINES_AMOUNT);}))
				.AddElement(new __ppf_ui_folder("Color", false, 3))
					.AddElement(new __ppf_ui_slider("Red", 0, false, gui_ef_get_param_color_red(FX_EFFECT.SCANLINES, PP_SCANLINES_COLOR), 0, 255, true, function(output) {gui_ef_set_param_color_red(output, FX_EFFECT.SCANLINES, PP_SCANLINES_COLOR);}))
					.AddElement(new __ppf_ui_slider("Green", 0, false, gui_ef_get_param_color_green(FX_EFFECT.SCANLINES, PP_SCANLINES_COLOR), 0, 255, true, function(output) {gui_ef_set_param_color_green(output, FX_EFFECT.SCANLINES, PP_SCANLINES_COLOR);}))
					.AddElement(new __ppf_ui_slider("Blue", 0, false, gui_ef_get_param_color_blue(FX_EFFECT.SCANLINES, PP_SCANLINES_COLOR), 0, 255, true, function(output) {gui_ef_set_param_color_blue(output, FX_EFFECT.SCANLINES, PP_SCANLINES_COLOR);}))
			.AddElement(new __ppf_ui_slider("Mask Power", 0, false, gui_ef_get_param_simple(FX_EFFECT.SCANLINES, PP_SCANLINES_MASK_POWER), 0, 15, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.SCANLINES, PP_SCANLINES_MASK_POWER);}))
			.AddElement(new __ppf_ui_slider("Mask Scale", 0, false, gui_ef_get_param_simple(FX_EFFECT.SCANLINES, PP_SCANLINES_MASK_SCALE), 0, 3, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.SCANLINES, PP_SCANLINES_MASK_SCALE);}))
			.AddElement(new __ppf_ui_slider("Mask Smoothness", 0, false, gui_ef_get_param_simple(FX_EFFECT.SCANLINES, PP_SCANLINES_MASK_SMOOTHNESS), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.SCANLINES, PP_SCANLINES_MASK_SMOOTHNESS);}))
		
		// effect: SPEEDLINES
		.AddElement(new __ppf_ui_menu("SPEEDLINES", false, 16))
			.AddElement(new __ppf_ui_checkbox("Effect Enabled", 0, gui_ef_get_enabled(FX_EFFECT.SPEEDLINES), function(checked) {return gui_ef_set_enabled(checked, FX_EFFECT.SPEEDLINES);}))
			.AddElement(new __ppf_ui_slider("Scale", 0, false, gui_ef_get_param_simple(FX_EFFECT.SPEEDLINES, PP_SPEEDLINES_SCALE), 0, 20, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.SPEEDLINES, PP_SPEEDLINES_SCALE);}))
			.AddElement(new __ppf_ui_slider("Tiling", 0, false, gui_ef_get_param_simple(FX_EFFECT.SPEEDLINES, PP_SPEEDLINES_TILING), 0, 16, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.SPEEDLINES, PP_SPEEDLINES_TILING);}))
			.AddElement(new __ppf_ui_slider("Speed", 20, false, gui_ef_get_param_simple(FX_EFFECT.SPEEDLINES, PP_SPEEDLINES_SPEED), -10, 10, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.SPEEDLINES, PP_SPEEDLINES_SPEED);}))
			.AddElement(new __ppf_ui_slider("Rot Speed", 20, false, gui_ef_get_param_simple(FX_EFFECT.SPEEDLINES, PP_SPEEDLINES_ROT_SPEED), -10, 10, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.SPEEDLINES, PP_SPEEDLINES_ROT_SPEED);}))
			.AddElement(new __ppf_ui_slider("Contrast", 0, false, gui_ef_get_param_simple(FX_EFFECT.SPEEDLINES, PP_SPEEDLINES_CONTRAST), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.SPEEDLINES, PP_SPEEDLINES_CONTRAST);}))
			.AddElement(new __ppf_ui_slider("Power", 0, false, gui_ef_get_param_simple(FX_EFFECT.SPEEDLINES, PP_SPEEDLINES_POWER), 0, 4, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.SPEEDLINES, PP_SPEEDLINES_POWER);}))
			.AddElement(new __ppf_ui_slider("Remap", 0, false, gui_ef_get_param_simple(FX_EFFECT.SPEEDLINES, PP_SPEEDLINES_REMAP), 0, 0.99, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.SPEEDLINES, PP_SPEEDLINES_REMAP);}))
				.AddElement(new __ppf_ui_folder("Color", false, 3))
					.AddElement(new __ppf_ui_slider("Red", 0, false, gui_ef_get_param_color_red(FX_EFFECT.SPEEDLINES, PP_SCANLINES_COLOR), 0, 255, true, function(output) {gui_ef_set_param_color_red(output, FX_EFFECT.SPEEDLINES, PP_SCANLINES_COLOR);}))
					.AddElement(new __ppf_ui_slider("Green", 0, false, gui_ef_get_param_color_green(FX_EFFECT.SPEEDLINES, PP_SCANLINES_COLOR), 0, 255, true, function(output) {gui_ef_set_param_color_green(output, FX_EFFECT.SPEEDLINES, PP_SCANLINES_COLOR);}))
					.AddElement(new __ppf_ui_slider("Blue", 0, false, gui_ef_get_param_color_blue(FX_EFFECT.SPEEDLINES, PP_SCANLINES_COLOR), 0, 255, true, function(output) {gui_ef_set_param_color_blue(output, FX_EFFECT.SPEEDLINES, PP_SCANLINES_COLOR);}))
			.AddElement(new __ppf_ui_slider("Mask Power", 0, false, gui_ef_get_param_simple(FX_EFFECT.SPEEDLINES, PP_SPEEDLINES_MASK_POWER), 0, 15, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.SPEEDLINES, PP_SPEEDLINES_MASK_POWER);}))
			.AddElement(new __ppf_ui_slider("Mask Scale", 0, false, gui_ef_get_param_simple(FX_EFFECT.SPEEDLINES, PP_SPEEDLINES_MASK_SCALE), 0, 3, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.SPEEDLINES, PP_SPEEDLINES_MASK_SCALE);}))
			.AddElement(new __ppf_ui_slider("Mask Smoothness", 0, false, gui_ef_get_param_simple(FX_EFFECT.SPEEDLINES, PP_SPEEDLINES_MASK_SMOOTHNESS), 0, 2, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.SPEEDLINES, PP_SPEEDLINES_MASK_SMOOTHNESS);}))
			.AddElement(new __ppf_ui_button("Noise Texture", function() {
				gui_speedlines_noise_type += 1;
				if (gui_speedlines_noise_type >= array_length(gui_speedlines_noise_tex_list)) gui_speedlines_noise_type = 0;
				gui_ef_set_param_simple(sprite_get_texture(gui_speedlines_noise_tex_list[gui_speedlines_noise_type], 0), FX_EFFECT.SPEEDLINES, PP_SPEEDLINES_NOISE_TEX);
			}))
		
		// effect: FADE
		.AddElement(new __ppf_ui_menu("FADE", false, 6))
			.AddElement(new __ppf_ui_checkbox("Effect Enabled", 0, gui_ef_get_enabled(FX_EFFECT.FADE), function(checked) {return gui_ef_set_enabled(checked, FX_EFFECT.FADE);}))
			.AddElement(new __ppf_ui_slider("Amount", 0, false, gui_ef_get_param_simple(FX_EFFECT.FADE, PP_FADE_AMOUNT), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.FADE, PP_FADE_AMOUNT);}))
			.AddElement(new __ppf_ui_folder("Color", false, 3))
				.AddElement(new __ppf_ui_slider("Red", 0, false, gui_ef_get_param_color_red(FX_EFFECT.FADE, PP_FADE_COLOR), 0, 255, true, function(output) {gui_ef_set_param_color_red(output, FX_EFFECT.FADE, PP_FADE_COLOR);}))
				.AddElement(new __ppf_ui_slider("Green", 0, false, gui_ef_get_param_color_green(FX_EFFECT.FADE, PP_FADE_COLOR), 0, 255, true, function(output) {gui_ef_set_param_color_green(output, FX_EFFECT.FADE, PP_FADE_COLOR);}))
				.AddElement(new __ppf_ui_slider("Blue", 0, false, gui_ef_get_param_color_blue(FX_EFFECT.FADE, PP_FADE_COLOR), 0, 255, true, function(output) {gui_ef_set_param_color_blue(output, FX_EFFECT.FADE, PP_FADE_COLOR);}))
		
		// effect: NES FADE
		.AddElement(new __ppf_ui_menu("NES FADE", false, 3))
			.AddElement(new __ppf_ui_checkbox("Effect Enabled", 0, gui_ef_get_enabled(FX_EFFECT.NES_FADE), function(checked) {return gui_ef_set_enabled(checked, FX_EFFECT.NES_FADE);}))
			.AddElement(new __ppf_ui_slider("Amount", 0, false, gui_ef_get_param_simple(FX_EFFECT.NES_FADE, PP_NES_FADE_AMOUNT), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.NES_FADE, PP_NES_FADE_AMOUNT);}))
			.AddElement(new __ppf_ui_slider("Levels", 16, false, gui_ef_get_param_simple(FX_EFFECT.NES_FADE, PP_NES_FADE_LEVELS), 0, 16, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.NES_FADE, PP_NES_FADE_LEVELS);}))
		
		// effect: BORDER
		.AddElement(new __ppf_ui_menu("BORDER", false, 7))
			.AddElement(new __ppf_ui_checkbox("Effect Enabled", 0, gui_ef_get_enabled(FX_EFFECT.BORDER), function(checked) {return gui_ef_set_enabled(checked, FX_EFFECT.BORDER);}))
			.AddElement(new __ppf_ui_slider("Curvature", 0, false, gui_ef_get_param_simple(FX_EFFECT.BORDER, PP_BORDER_CURVATURE), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.BORDER, PP_BORDER_CURVATURE);}))
			.AddElement(new __ppf_ui_slider("Smooth", 0, false, gui_ef_get_param_simple(FX_EFFECT.BORDER, PP_BORDER_SMOOTH), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.BORDER, PP_BORDER_SMOOTH);}))
				.AddElement(new __ppf_ui_folder("Color", false, 3))
					.AddElement(new __ppf_ui_slider("Red", 0, false, gui_ef_get_param_color_red(FX_EFFECT.BORDER, PP_BORDER_COLOR), 0, 255, true, function(output) {gui_ef_set_param_color_red(output, FX_EFFECT.BORDER, PP_BORDER_COLOR);}))
					.AddElement(new __ppf_ui_slider("Green", 0, false, gui_ef_get_param_color_green(FX_EFFECT.BORDER, PP_BORDER_COLOR), 0, 255, true, function(output) {gui_ef_set_param_color_green(output, FX_EFFECT.BORDER, PP_BORDER_COLOR);}))
					.AddElement(new __ppf_ui_slider("Blue", 0, false, gui_ef_get_param_color_blue(FX_EFFECT.BORDER, PP_BORDER_COLOR), 0, 255, true, function(output) {gui_ef_set_param_color_blue(output, FX_EFFECT.BORDER, PP_BORDER_COLOR);}))
		
		// effect: TONE MAPPING
		.AddElement(new __ppf_ui_menu("TONE MAPPING", false, 6))
			.AddElement(new __ppf_ui_checkbox("Effect Enabled", 0, gui_ef_get_enabled(FX_EFFECT.TONE_MAPPING), function(checked) {return gui_ef_set_enabled(checked, FX_EFFECT.TONE_MAPPING);}))
			.AddElement(new __ppf_ui_folder("Type", false, 4))
				.AddElement(new __ppf_ui_button("ACES Film", function() {gui_ef_set_param_simple(0, FX_EFFECT.TONE_MAPPING, PP_TONE_MAPPING_MODE);}))
				.AddElement(new __ppf_ui_button("Uncharted 2", function() {gui_ef_set_param_simple(1, FX_EFFECT.TONE_MAPPING, PP_TONE_MAPPING_MODE);}))
				.AddElement(new __ppf_ui_button("Lottes", function() {gui_ef_set_param_simple(2, FX_EFFECT.TONE_MAPPING, PP_TONE_MAPPING_MODE);}))
				.AddElement(new __ppf_ui_button("Unreal 3", function() {gui_ef_set_param_simple(3, FX_EFFECT.TONE_MAPPING, PP_TONE_MAPPING_MODE);}))
		
		
			
		#endregion
		
		#region >> CATEGORY: IMAGE ENHANCEMENT
		inspector_struct
		.AddElement(new __ppf_ui_category("Enhancement & Others", false, 29))
		
		// effect: COMPARE
		.AddElement(new __ppf_ui_menu("COMPARE (DEBUG)", false, 4))
			.AddElement(new __ppf_ui_checkbox("Effect Enabled", 0, gui_ef_get_enabled(FX_EFFECT.COMPARE), function(checked) {return gui_ef_set_enabled(checked, FX_EFFECT.COMPARE);}))
			.AddElement(new __ppf_ui_checkbox("Side-By-Side", 0, gui_ef_get_param_simple(FX_EFFECT.COMPARE, PP_COMPARE_SIDE_BY_SIDE), function(checked) {return gui_ef_set_param_enable(checked, FX_EFFECT.COMPARE, PP_COMPARE_SIDE_BY_SIDE);}))
			.AddElement(new __ppf_ui_slider("X Offset", 0, false, gui_ef_get_param_simple(FX_EFFECT.COMPARE, PP_COMPARE_X_OFFSET), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.COMPARE, PP_COMPARE_X_OFFSET);}))
			.AddElement(new __ppf_ui_slider("Stack Index", array_length(__inspected_class.__stack_surface), false, gui_ef_get_param_simple(FX_EFFECT.COMPARE, PP_COMPARE_STACK_INDEX), 0, array_length(__inspected_class.__stack_surface), true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.COMPARE, PP_COMPARE_STACK_INDEX);}))
		
		// effect: FXAA
		.AddElement(new __ppf_ui_menu("FXAA", false, 2))
			.AddElement(new __ppf_ui_checkbox("Effect Enabled", 0, gui_ef_get_enabled(FX_EFFECT.FXAA), function(checked) {return gui_ef_set_enabled(checked, FX_EFFECT.FXAA);}))
			.AddElement(new __ppf_ui_slider("Strength", 0, false, gui_ef_get_param_simple(FX_EFFECT.FXAA, PP_FXAA_STRENGTH), 0, 8, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.FXAA, PP_FXAA_STRENGTH);}))
		
		// effect: HQ4x
		.AddElement(new __ppf_ui_menu("HQ4x", false, 4))
			.AddElement(new __ppf_ui_checkbox("Effect Enabled", 0, gui_ef_get_enabled(FX_EFFECT.HQ4X), function(checked) {return gui_ef_set_enabled(checked, FX_EFFECT.HQ4X);}))
			.AddElement(new __ppf_ui_slider("Smoothnes", 0, false, gui_ef_get_param_simple(FX_EFFECT.HQ4X, PP_HQ4X_SMOOTHNESS), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.HQ4X, PP_HQ4X_SMOOTHNESS);}))
			.AddElement(new __ppf_ui_slider("Sharpness", 0, false, gui_ef_get_param_simple(FX_EFFECT.HQ4X, PP_HQ4X_SHARPNESS), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.HQ4X, PP_HQ4X_SHARPNESS);}))
			.AddElement(new __ppf_ui_slider("Downscale", 8, false, gui_ef_get_param_simple(FX_EFFECT.HQ4X, PP_HQ4X_DOWNSCALE), 0, 8, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.HQ4X, PP_HQ4X_DOWNSCALE);}))
		
		// effect: COLOR BLINDNESS
		.AddElement(new __ppf_ui_menu("COLOR BLINDNESS CORRECTION", false, 2))
			.AddElement(new __ppf_ui_checkbox("Effect Enabled", 0, gui_ef_get_enabled(FX_EFFECT.COLOR_BLINDNESS), function(checked) {return gui_ef_set_enabled(checked, FX_EFFECT.COLOR_BLINDNESS);}))
			.AddElement(new __ppf_ui_button("Mode (Protanopia, Deutanopia, Tritanopia)", function() {
				gui_colorblind_cur_mode += 1;
				if (gui_colorblind_cur_mode > 2) gui_colorblind_cur_mode = 0;
				gui_ef_set_param_simple(gui_colorblind_cur_mode, FX_EFFECT.COLOR_BLINDNESS, PP_COLOR_BLINDNESS_MODE);
			}))
		
		// effect: TEXTURE OVERLAY
		.AddElement(new __ppf_ui_menu("TEXTURE OVERLAY", false, 12))
			.AddElement(new __ppf_ui_checkbox("Effect Enabled", 0, gui_ef_get_enabled(FX_EFFECT.TEXTURE_OVERLAY), function(checked) {return gui_ef_set_enabled(checked, FX_EFFECT.TEXTURE_OVERLAY);}))
			.AddElement(new __ppf_ui_slider("Intensity", 0, false, gui_ef_get_param_simple(FX_EFFECT.TEXTURE_OVERLAY, PP_TEXTURE_OVERLAY_INTENSITY), 0, 1, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.TEXTURE_OVERLAY, PP_TEXTURE_OVERLAY_INTENSITY);}))
			.AddElement(new __ppf_ui_slider("Scale", 0, false, gui_ef_get_param_simple(FX_EFFECT.TEXTURE_OVERLAY, PP_TEXTURE_OVERLAY_SCALE), -2, 2, true, function(output) {gui_ef_set_param_simple(output, FX_EFFECT.TEXTURE_OVERLAY, PP_TEXTURE_OVERLAY_SCALE);}))
			.AddElement(new __ppf_ui_checkbox("Can Distort", 0, gui_ef_get_param_simple(FX_EFFECT.TEXTURE_OVERLAY, PP_TEXTURE_OVERLAY_CAN_DISTORT), function(checked) {return gui_ef_set_param_enable(checked, FX_EFFECT.TEXTURE_OVERLAY, PP_TEXTURE_OVERLAY_CAN_DISTORT);}))
			.AddElement(new __ppf_ui_folder("Blend Modes", false, 6))
				.AddElement(new __ppf_ui_button("Default", function() {gui_ef_set_param_simple(0, FX_EFFECT.TEXTURE_OVERLAY, PP_TEXTURE_OVERLAY_BLENDMODE);}))
				.AddElement(new __ppf_ui_button("Add", function() {gui_ef_set_param_simple(1, FX_EFFECT.TEXTURE_OVERLAY, PP_TEXTURE_OVERLAY_BLENDMODE);}))
				.AddElement(new __ppf_ui_button("Subtract", function() {gui_ef_set_param_simple(2, FX_EFFECT.TEXTURE_OVERLAY, PP_TEXTURE_OVERLAY_BLENDMODE);}))
				.AddElement(new __ppf_ui_button("Multiply", function() {gui_ef_set_param_simple(3, FX_EFFECT.TEXTURE_OVERLAY, PP_TEXTURE_OVERLAY_BLENDMODE);}))
				.AddElement(new __ppf_ui_button("Divide", function() {gui_ef_set_param_simple(4, FX_EFFECT.TEXTURE_OVERLAY, PP_TEXTURE_OVERLAY_BLENDMODE);}))
				.AddElement(new __ppf_ui_button("Color Burn", function() {gui_ef_set_param_simple(5, FX_EFFECT.TEXTURE_OVERLAY, PP_TEXTURE_OVERLAY_BLENDMODE);}))
			.AddElement(new __ppf_ui_button("Texture", function() {
				var _file = get_open_filename("PNG Image|*.png", "*.png");
				if (_file != "") {
					if (sprite_exists(gui_textureoverlay_spritetex_id)) sprite_delete(gui_textureoverlay_spritetex_id);
					gui_textureoverlay_spritetex_id = sprite_add(_file, 0, 0, 0, 0, 0);
					gui_ef_set_param_simple(sprite_get_texture(gui_textureoverlay_spritetex_id, 0), FX_EFFECT.TEXTURE_OVERLAY, PP_TEXTURE_OVERLAY_TEXTURE);
				}
			}));
		
		
		#endregion
		
		#region >> CATEGORY: EXTERNAL EFFECTS
		// Add External Effects (if any)
		var _external_effects_len = array_length(global.__ppf_external_effects);
		if (_external_effects_len > 0) {
			// create a new category
			var _category = new __ppf_ui_category("External Effects", false, 0);
			inspector_struct.AddElement(_category);
			
			// add elements
			var _effect_struct = undefined;
			for (var i = 0; i < _external_effects_len; ++i) {
				_effect_struct = global.__ppf_external_effects[i];
				if (_effect_struct.GetEditorData != undefined) {
					_category.amount_opened += _effect_struct.GetEditorData(self);
				}
			}
		}
		#endregion
		
		// folc
		//inspector_struct.SetTabsFolding(false, 28, undefined, true);
		
		// callback [must have it]
		return inspector_struct;
		#endregion
	}
	
	static __PPFX_Profile = function() {
		#region UI
		// helper variables
		gui_preset_profiles = new __PPFX_PresetProfile();
		
		inspector_struct = new __PPF_UIInspector("PPFX_Profile")
			.AddElement(new __ppf_ui_menu("PROFILE | Post-Processing FX", true, 12))
				.AddElement(new __ppf_ui_text_ext("Info", 0, function(element) {
					var _width = element.parent.__panel_width-element.xx-element.parent.__element_xpadding;
					element.width = _width;
					var _text = "The profile is like a container, which contains the effects you want the system to render. They alone don't do anything, it's just a data structure.\nYou load them into the post-processing system. Each post-processing system can only have 1 profile loaded into it, at the same time (you can also merge profiles).";
					return _text;
				}))
				.AddElement(new __ppf_ui_separator())
				.AddElement(new __ppf_ui_text_ext("Name", 0, function(element) {
					var _width = element.parent.__panel_width-element.xx-element.parent.__element_xpadding;
					element.width = _width;
					var _text = $"Profile Name: {__inspected_class.__profile_name}";
					return _text;
				}))
			
			// Actions
			.AddElement(new __ppf_ui_folder("Actions", true, 5))
					.AddElement(new __ppf_ui_button("Load Default (Merge)", function() {
						__inspected_class.Load(gui_preset_profiles.GetDefault("Game"), true);
					}))
					
					.AddElement(new __ppf_ui_button("Load Default (Overwrite)", function() {
						__inspected_class.Load(gui_preset_profiles.GetDefault("Game"), false);
					}))
					
					.AddElement(new __ppf_ui_button("Export (only enabled effects)", function() {
						var _text = __inspected_class.Stringify(false, true);
						clipboard_set_text(_text);
					}))
					
					.AddElement(new __ppf_ui_button("Export (all effects)", function() {
						var _text = __inspected_class.Stringify(false, false);
						clipboard_set_text(_text);
					}))
					
					.AddElement(new __ppf_ui_button("Reset", function() {
						__inspected_class.Reset();
					}))
			
			// Effects
			.AddElement(new __ppf_ui_folder("Effects", false, 2))
				.AddElement(new __ppf_ui_text("Count", 0, function() {
					return $"Count: {array_length(__inspected_class.__effects_array)} | [enabled] (order) name";
				}))
				.AddElement(new __ppf_ui_method("Effects Array", 0, undefined,
					function(element) {
						// enable real time ui
						//inspector_struct.__bake();
						
						// draw item list
						var _array = __inspected_class.__effects_array, _rec = 0, _text = "", _text_height = 0, _effect = undefined,
						isize = array_length(_array), i = isize-1,
						_xx = element.xx,
						_yy = element.yy,
						_mx = element.parent.__input_m_x,
						_my = element.parent.__input_m_y,
						_height = 0,
						_mlp = element.parent.__input_m_left_pressed,
						_mlr = element.parent.__input_m_left_released;
						repeat(isize) {
							_rec = i / isize;
							_effect = _array[i];
							_text = $"[{_effect.settings.enabled ? "x" : " "}] ({_effect.stack_order}) {_effect.effect_name}" + "\n";
							_text_height = string_height(_text);
							
							// draw item
							draw_text(_xx, _yy, _text);
							
							_yy += _text_height + 4;
							_height += _text_height + 4;
							--i;
						}
						return _height + 16;
					}))
		
		
		// callback [must have it]
		return inspector_struct;
		#endregion
	}
	
	static __PPFX_LUTGenerator = function() {
		#region UI
		// ui variables
		gui_lut_strip_squares = 16;
		gui_lut_grid_squares = 8;
		gui_lut_haldgrid_squares = 8;
		gui_lut_1dcurve_size = 1024;
		
		// ui system
		inspector_struct = new __PPF_UIInspector("PPFX_LUTGenerator")
			.AddElement(new __ppf_ui_menu("LUT Generator | Post-Processing FX", true, 1))
			.AddElement(new __ppf_ui_text_ext("This class is capable of generating several types of LUT: Strip, Grid, Hald Grid and Curve.", 0, function(element) {
				var _width = element.parent.__panel_width-element.xx*2;
				element.width = _width;
				return element.text;
			}))
			.AddElement(new __ppf_ui_menu("PREVIEW", true, 2))
			.AddElement(new __ppf_ui_text("LUT Preview:", 0, function() {
				return $"LUT type: {__inspected_class.__lut_type}";
			}))
			.AddElement(new __ppf_ui_method("Preview", 0, undefined, function(element) {
				var _class = __inspected_class;
				var _height = 0;
				
				with(element) {
					var _exists = false;
					
					var _xscale = (parent.__panel_width-xx*3) / sprite_get_width(_class.__output) * 1;
					var _yscale = _xscale;
					
					if (_class.__export_as_sprite) {
						if (sprite_exists(_class.__output)) {
							var _spr_height = sprite_get_height(_class.__output);
							if (_spr_height <= 1) _yscale = 1;
							draw_sprite_ext(_class.__output, 0, xx+parent.__element_xpadding, yy, _xscale, _yscale, 0, c_white, alpha);
							_height = _yscale * _spr_height + 8;
							_exists = true;
						}
					} else {
						if (surface_exists(_class.__output)) {
							var _surf_height = surface_get_height(_class.__output);
							if (_surf_height <= 1) _yscale = 1;
							draw_surface_ext(_class.__output, xx+parent.__element_xpadding, yy, _xscale, _yscale, 0, c_white, alpha);
							_height = _yscale * _surf_height + 8;
							_exists = true;
						}
					}
					
					if (!_exists) {
						draw_sprite(__spr_ppf_debug_icon, 0, xx+parent.__panel_width/2-parent.__element_xpadding, yy+sprite_get_height(__spr_ppf_debug_icon)/2);
						_height = sprite_get_height(__spr_ppf_debug_icon) + 16;
					}
				}
				
				return _height;
			}))
			.AddElement(new __ppf_ui_menu("GENERATE", true, 14))
			.AddElement(new __ppf_ui_folder("Strip", false, 2))
				.AddElement(new __ppf_ui_slider("Squares", 4, false, gui_lut_strip_squares, 0, 64, false, function(output) {
					gui_lut_strip_squares = round(output);
				}))
				.AddElement(new __ppf_ui_button("Generate", function() {
					__inspected_class.GenerateStrip(gui_lut_strip_squares, true);
				}))
			
			
			.AddElement(new __ppf_ui_folder("Grid", false, 2))
				.AddElement(new __ppf_ui_slider("Squares", 4, false, gui_lut_grid_squares, 0, 16, false, function(output) {
					gui_lut_grid_squares = round(output);
				}))
				.AddElement(new __ppf_ui_button("Generate", function() {
					__inspected_class.GenerateGrid(gui_lut_grid_squares, true);
				}))
			
			.AddElement(new __ppf_ui_folder("Hald Grid", false, 2))
				.AddElement(new __ppf_ui_slider("Squares", 4, false, gui_lut_haldgrid_squares, 0, 16, false, function(output) {
					gui_lut_haldgrid_squares = round(output);
				}))
				.AddElement(new __ppf_ui_button("Generate", function() {
					__inspected_class.GenerateHaldGrid(gui_lut_haldgrid_squares, true);
				}))
			
			.AddElement(new __ppf_ui_folder("Curve", false, 2))
				.AddElement(new __ppf_ui_slider("Size", 64, false, gui_lut_1dcurve_size, 0, 4096, false, function(output) {
					gui_lut_1dcurve_size = round(output);
				}))
				.AddElement(new __ppf_ui_button("Generate", function() {
					__inspected_class.Generate1D(gui_lut_1dcurve_size, true);
				}))
			
			.AddElement(new __ppf_ui_folder("Cube (.cube)", false, 1))
				.AddElement(new __ppf_ui_button("Load from file", function() {
					var _file = get_open_filename("*.cube", "");
					if (_file != "") {
						__inspected_class.LoadCube(_file, true);
					}
				}))
			
			.AddElement(new __ppf_ui_menu("EXPORT", true, 1))
			.AddElement(new __ppf_ui_button("Export LUT (.png)", function() {
				var _file = get_save_filename("*.png", "lut_sprite");
				if (_file != "") {
					if (sprite_exists(__inspected_class.__output)) {
						sprite_save(__inspected_class.__output, 0, _file + ".png");
					}
				}
			}))
		// callback [must have it]
		return inspector_struct;
		#endregion
	}
}

#endregion

#region DEBUG UI

/// @func PPFX_DebugUI(class_instance)
/// @param {Struct} class_instance The system struct returned from a constructor/class. Let it blank/undefined if you want the Debug UI to search it for you, in the current object/context.
/// @param {Bool} right_side The UI will spawn in the right side.
/// @param {Real} width The initial UI width.
/// @param {Real} height The initial UI height.
function PPFX_DebugUI(class_instance=undefined, right_side=true, width=300, height=600) constructor {
	static __inspector_generator = new __PPFX_DebugInspectorGenerator();
	
	// visual
	__ui_right_side = right_side;
	__ui_x = __ui_right_side ? window_get_width()-width-40 : 20;
	__ui_y = 20;
	__ui_w = width;
	__ui_h = max(height, window_get_height()-40);
	__ui_is_resizing_w = false;
	__ui_is_resizing_w_old_pos = 0;
	__ui_is_resizing_h = false;
	__ui_is_moving = false;
	__ui_is_moving_old_mouse_x = 0;
	__ui_is_moving_old_mouse_y = 0;
	__ui_resize_w_margin = 32;
	__ui_resize_h_margin = 32;
	__ui_show_border = false;
	__ui_min_width = 300;
	__ui_min_height = 48;
	
	// core
	__inspector_array = [
		{
			name : "__NO_CLASS__",
			idd : __inspector_generator.__PPFX_ClassSelector,
		},
		{
			name : "PPFX_System",
			idd : __inspector_generator.__PPFX_System,
		},
		{
			name : "PPFX_Profile",
			idd : __inspector_generator.__PPFX_Profile,
		},
		{
			name : "PPFX_LUTGenerator",
			idd : __inspector_generator.__PPFX_LUTGenerator,
		},
	];
	__inspected_class = undefined;
	__inspected_class_object_name = "";
	__current_inspector_method = undefined;
	__current_inspector_struct = undefined;
	__inspector_index = -1;
	__add_items_post_func = -1;
	__ui_time = 0;
	__ui_padding = 0;
	__destroyed = false;
	__is_backing_home = false;
	
	__can_click = true; // prevents click throughs overlapping elements
	
	static __debug_func_start = function() {
		__debug_time = get_timer();
	}
	static __debug_func_end = function() {
		__debug_time = get_timer()-__debug_time;
		return $"{__debug_time/1000}ms";
	}
	
	SetClass(class_instance);
	
	#region Public Methods
	
	/// @desc Choose a new class to debug.
	/// @func SetClass()
	static SetClass = function(class_instance=undefined) {
		// reset class
		__inspected_class = undefined; // we are not debugging any class...
		__inspected_class_object_name = "";
		__inspector_index = 0; // the default inspector
		
		// try to find a new class
		if (!is_undefined(class_instance) && is_struct(class_instance)) {
			// set new class to inspect
			__inspected_class = class_instance;
			__inspected_class_object_name = instanceof(__inspected_class);
			
			// find predefined classes
			__inspector_index = -1;
			var i = 0, isize = array_length(__inspector_array);
			repeat(isize) {
				if (__inspector_array[i].name == __inspected_class_object_name) {
					__inspector_index = i;
					break;
				}
				++i;
			}
			// no predefined class found
			if (__inspector_index == -1) {
				__ppf_trace($"Debug: There is no debug UI for this class: {__inspected_class_object_name}...", 1);
				__inspector_index = 0;
			} else {
				__ppf_trace($"Debugging {__inspected_class_object_name} class", 3);
			}
		} else {
			// if no class found, set to default inspector
			__ppf_trace($"Debug: No debug inspector for this class ({class_instance}). Going to class selector...", 1);
			__inspector_index = 0;
		}
		
		// update UI, to create items based on the __inspector_index
		UpdateUI();
	}
	
	/// @func UpdateUI()
	static UpdateUI = function() {
		try {
			// bind ui function to self and call it
			__current_inspector_method = method(self, __inspector_array[__inspector_index].idd); // Bind inspector function to self
			__current_inspector_struct = __current_inspector_method();
			// create additional UI items (if any)
			if (__add_items_post_func != -1) __add_items_post_func(__current_inspector_struct);
			
			// > add Home button (always) <
			if (!is_undefined(__current_inspector_struct)) {
				__current_inspector_struct.AddElement(new __ppf_ui_method("HOME", 0, undefined, function(element) {
					var _mx = element.parent.__input_m_x,
						_my = element.parent.__input_m_y,
						_mrp = element.parent.__input_m_right_pressed,
						_mlp = element.parent.__input_m_left_pressed,
						_mlr = element.parent.__input_m_left_released;
					element.height = 8;
					
					var _x1 = element.xx,
						_y1 = element.yy,
						_x2 = element.xx+element.parent.__panel_width-element.xx,
						_y2 = element.yy+element.height;
					
					if (point_in_rectangle(_mx, _my, _x1, _y1, _x2, _y2)) {
						// left click
						if (_mlp) {
							__is_backing_home = true;
							draw_rectangle_color(_x1, _y1, _x2, _y2, c_orange, c_orange, c_orange, c_orange, false);
						}
						// drag ui
						if (_mrp) {
							__ui_is_moving = true;
						}
					}
					return element.height;
				}), 0);
			}
		} catch(exception) {
			__ppf_trace($"Failed to create inspector.\n{exception.message}\n{exception.stacktrace}", 1);
		}
	}
	
	/// @desc Get UI system struct. Useful to manually add items to the UI later.
	/// @func GetInspector()
	static GetInspector = function() {
		return __current_inspector_struct;
	}
	
	/// @desc Get current editing class struct.
	/// @func GetClass()
	static GetClass = function() {
		return __inspected_class;
	}
	
	/// @desc Get current editing class name.
	/// @func GetClassName()
	static GetClassName = function() {
		return __inspected_class_object_name;
	}
	
	/// @desc This function is called after the UI is created.
	/// @func AddItems()
	static AddItems = function(func) {
		__add_items_post_func = func;
		__add_items_post_func(__current_inspector_struct);
	}
	
	/// @desc Destroy debug UI.
	/// @func Destroy()
	static Destroy = function() {
		// destroy Inspector UI
		if (__current_inspector_struct != undefined) {
			__current_inspector_struct.Clean();
			__current_inspector_struct.Destroy();
		}
		__add_items_post_func = -1;
		__destroyed = true;
		__current_inspector_method = undefined;
		__current_inspector_struct = undefined;
		__inspected_class = undefined;
		__inspected_class_object_name = "";
	}
	
	/// @desc Define UI position and size.
	/// @func SetRectangle()
	static SetRectangle = function(xx=undefined, yy=undefined, width=undefined, height=undefined) {
		__ui_x = xx ?? __ui_x;
		__ui_y = yy ?? __ui_y;
		__ui_w = width ?? __ui_w;
		__ui_h = height ?? __ui_h;
	}
	
	/// @desc Draw debug UI, to debug Post-Processing FX.
	/// @func Draw(general_alpha, font)
	/// @param {real} general_alpha The drawing alpha.
	/// @param {real} font The font to use, for drawing texts.
	static Draw = function(general_alpha=1, font=__ppf_fnt_debug_ui) {
		// check if it's in a wrong event
		if (event_number != ev_draw_post && event_number != ev_gui && event_number != ev_gui_begin && event_number != ev_gui_end) {
			__ppf_trace("Debug UI can only be drawn in Post-Draw or GUI events.", 1);
			exit;
		}
		
		// input
		var _window_width = window_get_width();
		var _window_height = window_get_height();
		var _window_mouse_x = window_mouse_get_x();
		var _window_mouse_y = window_mouse_get_y();
		if (event_number == ev_gui || event_number == ev_gui_begin || event_number == ev_gui_end) {
			_window_width = display_get_gui_width();
			_window_height = display_get_gui_height();
			_window_mouse_x = device_mouse_x_to_gui(0);
			_window_mouse_y = device_mouse_y_to_gui(0);
		}
		
		#region Move
		if (__ui_is_moving) {
			// reposition
			__ui_x = _window_mouse_x - __ui_is_moving_old_mouse_x;
			__ui_y = _window_mouse_y - __ui_is_moving_old_mouse_y;
			// close (no moving)
			if (mouse_check_button_released(mb_right)) {
				__ui_is_moving = false;
			}
			// maximize
			if (mouse_check_button_released(mb_middle)) {
				__ui_x = (_window_mouse_x > _window_width/2) ? window_get_width()-__ui_w-40 : 20;
				__ui_y = 20;
				__ui_h = window_get_height()-40;
				__ui_is_moving = false;
			}
		} else {
			// old mouse coords
			__ui_is_moving_old_mouse_x = _window_mouse_x - __ui_x;
			__ui_is_moving_old_mouse_y = _window_mouse_y - __ui_y;
		}
		#endregion
		
		#region Resize UI
		var _pos_y = __ui_y+__ui_h,
			_hovering_hor = point_in_rectangle(_window_mouse_x, _window_mouse_y, __ui_x-__ui_resize_w_margin, __ui_y, __ui_x, __ui_y+__ui_h+__ui_resize_h_margin),
			_hovering_ver = point_in_rectangle(_window_mouse_x, _window_mouse_y, __ui_x-__ui_resize_w_margin, _pos_y, __ui_x+__ui_w, _pos_y+__ui_resize_h_margin);
		
		// drag
		if (mouse_check_button_pressed(mb_left)) {
			// width
			__ui_is_resizing_w_old_pos = __ui_x+__ui_w;
			if (_hovering_hor) {
				__ui_is_resizing_w = true;
			}
			// height
			if (_hovering_ver) {
				__ui_is_resizing_h = true;
			}
		}
		if (__ui_is_resizing_w) {
			__ui_x = _window_mouse_x+(__ui_resize_w_margin/2);
			__ui_w = abs(__ui_is_resizing_w_old_pos - __ui_x); // distance
			if (mouse_check_button_released(mb_left)) {
				__ui_is_resizing_w = false;
			}
		}
		if (__ui_is_resizing_h) {
			__ui_h = _window_mouse_y-(__ui_resize_h_margin/2) - __ui_y;
			if (mouse_check_button_released(mb_left)) {
				__ui_is_resizing_h = false;
			}
		}
		
		// keep ui inside window frame buffer
		if (_window_width > 0 && _window_height > 0) {
			__ui_x = clamp(__ui_x, 20, _window_width-__ui_w-40);
			__ui_y = clamp(__ui_y, 20, _window_height-__ui_h-20);
			__ui_w = max(__ui_w, __ui_min_width);
			__ui_h = max(__ui_h, __ui_min_height);
			__ui_w = min(__ui_w, _window_width-40);
			__ui_h = min(__ui_h, _window_height-40);
		}
		
		// enable border
		__ui_show_border = (_hovering_hor || _hovering_ver || __ui_is_resizing_w || __ui_is_resizing_h);
		#endregion
		
		// do not draw if destroyed or undefined UI struct
		if (__destroyed || __current_inspector_struct == undefined) exit;
		
		// time
		__ui_time += PPFX_CFG_SPEED;
		
		// draw ui items
		var _old_font = draw_get_font(),
			_old_color = draw_get_color(),
			_old_zwrite = gpu_get_zwriteenable(),
			_old_ztest = gpu_get_ztestenable(),
			_old_culling = gpu_get_cullmode();
		draw_set_font(font);
		draw_set_color(c_white);
		gpu_set_zwriteenable(false);
		gpu_set_ztestenable(false);
		gpu_set_cullmode(cull_noculling);
			__current_inspector_struct.Draw(
				__ui_x + __ui_padding,
				__ui_y + __ui_padding,
				__ui_x+__ui_w - __ui_padding,
				__ui_y+__ui_h - __ui_padding,
				__ui_time, general_alpha
			);
		gpu_set_zwriteenable(_old_zwrite);
		gpu_set_ztestenable(_old_ztest);
		gpu_set_cullmode(_old_culling);
		draw_set_font(_old_font);
		draw_set_color(_old_color);
		
		// border
		if (__ui_show_border) {
			draw_rectangle_color(
				__ui_x + __ui_padding,
				__ui_y + __ui_padding,
				__ui_x+__ui_w - __ui_padding,
				__ui_y+__ui_h - __ui_padding,
				c_white, c_white, c_white, c_white, true
			);
		}
		
		// reset debug ui (when needed)
		if (__is_backing_home) {
			SetClass(undefined);
			__is_backing_home = false;
		}
	}
	
	#endregion
}

#endregion

#region PRESET PROFILES

// DO NOT USE IT MANUALLY.
// It should only be used in the Debug UI, and is subject to change.
/// @ignore
function __PPFX_PresetProfile() constructor {
	static GetDefault = function(name) {
		var _effects = [
			new FX_ColorCurves(false),
			new FX_ChannelMixer(false),
			new FX_Rotation(false),
			new FX_Zoom(false),
			new FX_Shake(false),
			new FX_Panorama(false),
			new FX_LensDistortion(false),
			new FX_Pixelize(false),
			new FX_Swirl(false),
			new FX_DisplaceMap(false),
			new FX_Shockwaves(false),
			new FX_SineWave(false),
			new FX_Glitch(false),
			new FX_WhiteBalance(false),
			new FX_HQ4x(false),
			new FX_FXAA(false),
			new FX_SunShafts(false),
			new FX_Bloom(false),
			new FX_DepthOfField(false),
			new FX_SlowMotion(false),
			new FX_MotionBlur(false),
			new FX_RadialBlur(false),
			new FX_LUT(false),
			new FX_Exposure(false),
			new FX_Posterization(false),
			new FX_Brightness(false),
			new FX_Contrast(false),
			new FX_ShadowMidtoneHighlight(false),
			new FX_Saturation(false),
			new FX_HueShift(false),
			new FX_Colorize(false),
			new FX_ColorTint(false),
			new FX_InvertColors(false),
			new FX_TextureOverlay(false),
			new FX_LiftGammaGain(false),
			new FX_ToneMapping(false),
			new FX_PaletteSwap(false),
			new FX_KawaseBlur(false),
			new FX_GaussianBlur(false),
			new FX_VHS(false),
			new FX_ChromaticAberration(false),
			new FX_Mist(false),
			new FX_SpeedLines(false),
			new FX_Dithering(false),
			new FX_NoiseGrain(false),
			new FX_Vignette(false),
			new FX_ScanLines(false),
			new FX_NESFade(false),
			new FX_Fade(false),
			new FX_CinemaBars(false),
			new FX_ColorBlindness(false),
			new FX_Channels(false),
			new FX_Border(false),
			new FX_Compare(false)
		];
		var i = 0, isize = array_length(global.__ppf_external_effects);
		repeat(isize) {
			array_push(_effects, global.__ppf_external_effects[i]);
			++i;
		}
		return new PPFX_Profile(name, _effects);
	}
	
	static GetHorror1 = function(name) {
		return new PPFX_Profile(name, [
			new FX_VHS(true),
			new FX_Vignette(true, 0.5),
			new FX_Glitch(true),
		]);
	}
	
	static GetCRT1 = function(name) {
		return new PPFX_Profile(name, [
			new FX_VHS(true),
			new FX_LensDistortion(true, 0.5),
			new FX_ScanLines(true),
		]);
	}
}

#endregion
