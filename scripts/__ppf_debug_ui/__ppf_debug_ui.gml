
/*----------------------------------------------------------------------
	Simple UI System for Debugging
	Copyright (C) 2023 Mozart Junior (FoxyOfJungle). Kazan Games Ltd.
	Website: https://foxyofjungle.itch.io/ | Discord: @foxyofjungle	
----------------------------------------------------------------------*/

/// Feather ignore all

#region UI INSPECTOR
/// @ignore
function __PPF_UIInspector(name) constructor {
	// base
	__system_name = name;
	__ui_elements_array = []; // array of struct elements
	__ui_element_in_focus = undefined; // ui element struct
	__ui_element_in_focus_index = 0; // index from ui array
	__panel_x1 = 0;
	__panel_y1 = 0;
	__panel_x2 = 0;
	__panel_y2 = 0;
	__panel_width = 32; // not using 0 to prevent crash
	__panel_height = 32;
	__old_panel_width = 0;
	__old_panel_height = 0;
	__ui_move_y = 0;
	__ui_yoffset = 0;
	__ui_height = 30; // default height
	__surface = -1;
	__bake_time_base = 8;
	__bake_time = __bake_time_base;
	__destroyed = false;
	__in_focus = false;
	__timer = 0;
	
	// prefs
	__debug = false;
	__element_xpadding = 10;
	__element_ypadding = 0;
	__is_height_responsive = true;
	__is_folding_enabled = true;
	
	// input
	__input_cursor_x = 0; // raw mouse input
	__input_cursor_y = 0;
	__input_m_x = 0; // use this for elements
	__input_m_y = 0;
	__input_m_x_normalized = 0;
	__input_m_y_normalized = 0;
	__input_m_left = false;
	__input_m_right = false;
	__input_m_middle = false;
	__input_m_left_pressed = false;
	__input_m_left_released = false;
	__input_m_right_released = false;
	__input_m_middle_pressed = false;
	__input_m_right_pressed = false;
	
	// scrollbar
	__scroll_value = 0;
	__scroll_old_yoffset = 0;
	__scroll_output = 0;
	__scroll_area = 200;
	__scroll_speed = 100;
	__scroll_enable = true;
	__scroll_move_speed = 0.3;
	
	// methods
	#region Private Methods
	/// @ignore
	static __bake = function() {
		// Bake (renderize) UI again. Call it whenever you want to update the UI
		__bake_time = __bake_time_base;
	}
	
	#endregion
	
	#region Public Methods
	
	static Clean = function() {
		if (surface_exists(__surface)) surface_free(__surface);
	}
	
	static Destroy = function() {
		__ui_element_in_focus = undefined;
		__destroyed = true;
		Clean();
		var i = 0, isize = array_length(__ui_elements_array); {
			delete __ui_elements_array[i];
			++i;
		}
		array_resize(__ui_elements_array, 0);
	}
	
	static AddElement = function(element_struct, from_pos=-1) {
		element_struct.parent = self; // set element parent to self (ui __PPF_UIInspector, system/controller/renderer)
		element_struct.index = array_length(__ui_elements_array);
		if (element_struct.width <= 0) element_struct.width = __panel_width;
		if (element_struct.height <= 0) element_struct.height = 32;
		//show_debug_message($"{__system_name} | Added element: {element_struct.name}");
		
		if (from_pos == -1) {
			array_insert(__ui_elements_array, 0, element_struct);
		} else {
			array_insert(__ui_elements_array, array_length(__ui_elements_array) - from_pos, element_struct);
		}
		
		return self; // return __PPF_UIInspector object struct
	}
	
	static RemoveElement = function(from_pos, number=1) {
		array_delete(__ui_elements_array, array_length(__ui_elements_array)-1 - from_pos, number);
		__bake();
	}
	
	static RemoveAllElements = function() {
		//var isize = array_length(__ui_elements_array);
		//if (isize > 0) {
		//	for (var i = isize-1; i >= 0; --i) {
		//		delete __ui_elements_array[i];
		//	}
		//	array_resize(__ui_elements_array, 0);
		//}
	}
	
	static SetTabsFolding = function(is_opened, from=0, to=undefined, debug=false) {
		var _size = array_length(__ui_elements_array);
		for (var i = _size-1; i >= 0; --i) {
			if (i <= _size-from) {
				var _item = __ui_elements_array[i];
				if (_item.is_openable) {
					_item.opened = is_opened;
					//show_debug_message(i);
				}
				
			}
		}
		if (debug) show_debug_message(__ui_elements_array[_size-from].text);
		__scroll_value = 0;
		__scroll_old_yoffset = 0;
		__scroll_output = 0;
		__bake();
	}
	
	#endregion
	
	#region Render
	// Draw
	/// @desc Draw UI system.
	/// @func Draw(x1, y1, x2, y2, alpha)
	static Draw = function(x1, y1, x2, y2, timer, alpha) {
		if (__destroyed) exit;
		__panel_x1 = x1;
		__panel_y1 = y1;
		__panel_x2 = x2;
		__panel_y2 = y2;
		__panel_width = x2 - x1;
		__panel_height = y2 - y1;
		__timer = timer;
		
		// limit size
		__panel_width = max(__panel_width, 32);
		__panel_height = max(__panel_height, 32);
		
		 // get minimum panel height (from this container or ui height)
		if (__is_height_responsive) __panel_height = min(__panel_height, __ui_height);
		
		// limit x1 position
		__panel_x1 = min(__panel_x1, __panel_x2-__panel_width);
		
		// update surface container dinamically
		if (__old_panel_width != __panel_width || __old_panel_height != __panel_height) {
			if (surface_exists(__surface)) surface_free(__surface);
			__old_panel_width = __panel_width;
			__old_panel_height = __panel_height;
		}
		
		// background
		draw_set_color(c_black);
		draw_set_alpha(0.65*alpha);
		draw_rectangle(__panel_x1, __panel_y1, __panel_x2, __panel_y1+__panel_height, false);
		draw_set_color(c_white);
		draw_set_alpha(1);
		
		// Input
		__input_cursor_x = 0;
		__input_cursor_y = 0;
		__input_m_left = mouse_check_button(mb_left);
		__input_m_right = mouse_check_button(mb_right);
		__input_m_middle = mouse_check_button(mb_middle);
		__input_m_left_pressed = mouse_check_button_pressed(mb_left);
		__input_m_right_pressed = mouse_check_button_pressed(mb_right);
		__input_m_middle_pressed = mouse_check_button_pressed(mb_middle);
		__input_m_left_released = mouse_check_button_released(mb_left);
		__input_m_right_released = mouse_check_button_released(mb_right);
		
		if (event_number == ev_draw_post) {
			__input_cursor_x = window_mouse_get_x();
			__input_cursor_y = window_mouse_get_y();
		} else
		if (event_number == ev_gui || event_number == ev_gui_begin || event_number == ev_gui_end) {
			__input_cursor_x = device_mouse_x_to_gui(0);
			__input_cursor_y = device_mouse_y_to_gui(0);
		}
		
		__input_m_x_normalized = __ppf_linearstep(__panel_x1, __panel_x1+__panel_width, __input_cursor_x);
		__input_m_y_normalized = __ppf_linearstep(__panel_y1, __panel_y1+__panel_height, __input_cursor_y);
		__input_m_x = lerp(0, __panel_width, __input_m_x_normalized);
		__input_m_y = lerp(0, __panel_height, __input_m_y_normalized);
		
		// draw items
		if (!surface_exists(__surface)) {
			__surface = surface_create(__panel_width, __panel_height+1);
			__bake();
		}
		
		__in_focus = point_in_rectangle(__input_cursor_x, __input_cursor_y, __panel_x1, __panel_y1, __panel_x2, __panel_y2);
		if (__in_focus && (__input_m_left || __input_m_right || __input_m_middle)) {
			__bake();
		}
		__scroll_enable = true;
		//if keyboard_check_pressed(ord("H")) {
		//	__is_folding_enabled = !__is_folding_enabled;
		//}
		
		// Bake UI in a surface
		__bake_time = max(__bake_time-1, 0);
		if (__bake_time > 0) {
			surface_set_target(__surface);
				draw_clear_alpha(c_black, 0);
				draw_set_halign(fa_left);
				draw_set_valign(fa_top);
				
				var _elements_array = __ui_elements_array,
				_array_size = array_length(_elements_array),
				_xoffset_array = array_create(_array_size, 0),
				_xoffset = 0,
				_draw_item = 0,
				_element = undefined;
				
				// reset initial yoffset (height)
				__ui_height = 0;
				
				for (var i = _array_size-1; i >= 0; i-=1) {
					// get current element struct
					_element = _elements_array[i];
					//show_debug_message(_element.name);
					//if (string_lower(_element.name) != "bloom") {
					//	continue;
					//}
					
					// set offset
					_xoffset = _xoffset_array[i];
					
					// dont draw itens if closed
					if (_draw_item > 0) {
						_draw_item -= 1;
						continue;
					}
					
					// folding
					if (_element.is_openable) {
						if (__is_folding_enabled) {
							_draw_item = !real(_element.opened) * _element.amount_opened;
						}
						
						var j = i - _element.amount_opened;
						repeat(_element.amount_opened) {
							_xoffset_array[j] += __element_xpadding;
							++j;
						}
					}
					
					// update element
					_element.alpha = alpha;
					_element.xx = _xoffset;
					_element.yy = __ui_height + __ui_yoffset;
					// offset for columns
					//if (_element.column <= 0) {
					//} else {
					//	_element.xx = _xoffset + (_element.width * _element.column);
					//	_element.yy = __ui_height - (_element.height * _element.column) + __ui_yoffset;
					//}
					_element.can_render = (_element.yy > -_element.height && _element.yy < __panel_height+16);
					
					// call element draw func
					if (_element.Draw != undefined) _element.Draw();
					
					// [debug] item rectangle
					if (__debug) draw_rectangle(_element.xx, _element.yy, _element.xx+_element.width, _element.yy+_element.height-1, true);
					
					// increase ui height from element height
					__ui_height += _element.height + __element_ypadding;
				}
			surface_reset_target();
		}
		if (__debug) draw_circle(__panel_x1, __panel_y1+__ui_height+__ui_yoffset, 4, true);
		
		// draw surface
		gpu_push_state();
		gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
		if (surface_exists(__surface)) draw_surface(__surface, __panel_x1, __panel_y1);
		gpu_pop_state();
		
		// element in focus
		// reset focus
		if (__input_m_left_released) {
			__ui_element_in_focus = undefined;
		}
		if (__input_m_right_released && __in_focus) {
			__bake();
		}
		//draw_text(x2 + 16, __panel_y1, __ui_element_in_focus);
		
		#region Scrollbar
		__scroll_area = __ui_height;
		var _x1 = x2 + 16,
		_y1 = __panel_y1,
		_x2 = x2 + 16,
		_y2 = y2;
		
		// focus on scrollbar
		if (point_in_rectangle(__input_cursor_x, __input_cursor_y, _x1-8, _y1, _x2+8, _y2)) {
			if (__input_m_left) {
				if (__ui_element_in_focus == undefined) __ui_element_in_focus = self;
			}
		}
		// if focused
		if (__ui_element_in_focus == self) {
			__scroll_value = __ppf_linearstep(__panel_y1, __panel_y1+__panel_height, __input_cursor_y); // 0 ~ 1
		}
		if (__scroll_enable && __in_focus) __scroll_value += (mouse_wheel_down() - mouse_wheel_up()) * (100 / __scroll_area);
		__scroll_value = clamp(__scroll_value, 0, 1);
		
		// draw
		__scroll_output = -lerp(0, __scroll_area-__panel_height, __scroll_value);
		draw_set_color(c_white);
		draw_set_alpha(alpha);
		draw_sprite_stretched(__spr_ppf_pixel, 0, _x1, _y1, 1, __panel_height);
		draw_sprite(__ppf_spr_ui_control, 0, _x1, _y1+__panel_height*__scroll_value);
		draw_set_alpha(1);
		
		// move ui smoothly
		__ui_move_y = __scroll_output;
		__ui_yoffset = round(lerp(__ui_yoffset, __ui_move_y, __scroll_move_speed));
		
		// auto bake if scrolling
		if (__scroll_old_yoffset != __ui_yoffset) {
			__bake();
			__scroll_old_yoffset = __ui_yoffset;
		}
		#endregion
		
		// Border
		draw_set_color(c_white);
		if (__debug) draw_rectangle(__panel_x1, __panel_y1, __panel_x2, __panel_y2, true);
	}
	
	#endregion
}

#endregion

#region UI ELEMENTS

/// @ignore
function __ppf_ui_element() {
	is_openable = false;
	parent = undefined; // this is __PPF_UIInspector
	index = -1;
	can_render = true;
	name = "";
	xx = 0;
	yy = 0;
	width = 0;
	height = 32;
	alpha = 1;
	column = 0;
}

/// @ignore
function __ppf_ui_category(_title, _opened, _amount_opened=1) : __ppf_ui_element() constructor {
	is_openable = true;
	name = "category";
	text = _title;
	opened = _opened; // gap
	amount_opened = _amount_opened;
	text_width = string_width(text);
	text_height = string_height(text);
	height = 26;
	
	static Draw = function() {
		if (!can_render) exit;
		
		// select
		if (point_in_rectangle(parent.__input_m_x, parent.__input_m_y, xx, yy, xx+parent.__panel_width, yy+height-4)) {
			if (parent.__input_m_left_pressed) {
				opened = !opened;
				if (parent.__ui_element_in_focus == undefined) parent.__ui_element_in_focus = self;
			}
		}
		
		draw_set_color(c_white);
		draw_set_halign(fa_center);
		draw_set_alpha(alpha);
		var _width = parent.__panel_width;
		var _color = opened ? c_orange : c_lime;
		draw_set_color(_color);
		draw_sprite_stretched_ext(__spr_ppf_pixel, 0, xx+10, yy+text_height/2, (_width/2-text_width/2)-20, 1, _color, alpha);
		draw_sprite_stretched_ext(__spr_ppf_pixel, 0, (xx+_width/2+text_width/2)+10, yy+text_height/2, (_width/2-text_width/2)-20, 1, _color, alpha);
		draw_text(xx+_width/2, yy, text);
		draw_text(xx+16, yy+1, opened ? "v" : ">");
		draw_text(xx+_width-16, yy+1, opened ? "v" : "<");
		draw_set_alpha(1);
		draw_set_halign(fa_left);
		draw_set_color(c_white);
	}
}

/// @ignore
function __ppf_ui_menu(_title, _opened=true, _amount_opened=1) : __ppf_ui_element() constructor {
	is_openable = true;
	name = "menu";
	text = _title;
	opened = _opened; // gap
	amount_opened = _amount_opened;
	height = 40;
	
	static Draw = function() {
		if (!can_render) exit;
		
		// select
		if (point_in_rectangle(parent.__input_m_x, parent.__input_m_y, xx, yy, xx+parent.__panel_width, yy+height-8)) {
			if (parent.__input_m_left_pressed) {
				opened = !opened;
				if (parent.__ui_element_in_focus == undefined) parent.__ui_element_in_focus = self;
			}
		}
		draw_set_color(c_white);
		//draw_rectangle(xx, yy, xx+parent.__panel_width, yy+height, false);
		
		// draw
		draw_sprite_stretched_ext(__spr_ppf_pixel, 0, xx, yy, parent.__panel_width-xx, height-8, c_black, alpha);
		draw_set_valign(fa_middle);
		draw_set_color(opened ? c_orange : c_lime);
		draw_set_alpha(alpha);
		draw_text(xx+parent.__element_xpadding, yy+(height/2)-3, text);
		draw_set_valign(fa_top);
		draw_set_alpha(1);
	}
}

/// @ignore
function __ppf_ui_folder(_title, _opened, _amount_opened=1) : __ppf_ui_element() constructor {
	is_openable = true;
	name = "folder";
	text = _title;
	opened = _opened; // gap
	amount_opened = _amount_opened;
	height = 32;
	
	static Draw = function() {
		if (!can_render) exit;
		
		// select
		if (point_in_rectangle(parent.__input_m_x, parent.__input_m_y, xx, yy, xx+parent.__panel_width, yy+height-4)) {
			if (parent.__input_m_left_pressed) {
				opened = !opened;
				if (parent.__ui_element_in_focus == undefined) parent.__ui_element_in_focus = self;
			}
		}
		draw_set_color(c_white);
		//draw_rectangle(xx, yy, xx+parent.__panel_width, yy+height, false);
		
		// draw
		draw_sprite_stretched_ext(__spr_ppf_pixel, 0, xx, yy, parent.__panel_width, height-4, c_black, alpha*0.8);
		draw_set_valign(fa_middle);
		draw_set_color(c_orange);
		draw_set_alpha(alpha);
		draw_text(xx+parent.__element_xpadding, yy+(height/2)-2, (opened ? "v" : ">") + "   " + text);
		draw_set_valign(fa_top);
		draw_set_alpha(1);
	}
}

/// @ignore
function __ppf_ui_text(_title, _column=0, _callback=undefined) : __ppf_ui_element() constructor {
	name = "text";
	text = _title;
	height = 32;
	callback = _callback;
	column = _column;
	
	static Draw = function() {
		if (!can_render) exit;
		
		if (callback != undefined) text = callback(text);
		
		draw_set_color(c_white);
		draw_set_alpha(alpha);
		draw_text(xx, yy, text);
		draw_set_alpha(1);
	}
}

/// @ignore
function __ppf_ui_text_ext(_title, _column=0, _callback=undefined) : __ppf_ui_element() constructor {
	name = "text";
	text = _title;
	width = 100;
	height = 32;
	callback = _callback;
	column = _column;
	
	static Draw = function() {
		if (!can_render) exit;
		
		if (callback != undefined) text = callback(self);
		
		draw_set_color(c_white);
		draw_set_alpha(alpha);
		draw_text_ext(xx, yy, text, -1, width);
		height = string_height_ext(text, -1, width)+8;
		draw_set_alpha(1);
	}
}

/// @ignore
function __ppf_ui_method(_title, _column=0, _on_create=undefined, _on_draw=undefined) : __ppf_ui_element() constructor {
	name = "caller";
	text = _title;
	height = 32;
	draw_func = _on_draw;
	column = _column;
	
	if (_on_create != undefined) _on_create();
	
	static Draw = function() {
		if (!can_render) exit;
		
		if (draw_func != undefined) height = draw_func(self);
	}
}

/// @ignore
function __ppf_ui_checkbox(_title, _column=0, _checked=false, _callback=undefined) : __ppf_ui_element() constructor {
	name = "checkbox";
	text = _title;
	width = 120;
	height = 32;
	checked = _checked;
	callback = _callback;
	column = _column;
	sprite = __ppf_spr_ui_checkbox;
	sprite_w = sprite_get_width(sprite);
	sprite_h = sprite_get_height(sprite);
	
	static Draw = function() {
		if (!can_render) exit;
		
		// set focus
		if (point_in_rectangle(parent.__input_m_x, parent.__input_m_y, xx, yy, xx+sprite_w, yy+sprite_h)) {
			// press
			if (parent.__input_m_left_pressed) {
				if (parent.__ui_element_in_focus == undefined) parent.__ui_element_in_focus = self;
			}
			//release
			if (parent.__input_m_left_released) {
				if (callback != undefined) {
					checked = callback(checked);
				}
			}
		}
		// draw
		draw_set_color(c_white);
		draw_set_alpha(alpha);
		draw_sprite(sprite, checked ?? 0, xx, yy); // only set index if checked is not undefined
		draw_text(xx+sprite_w+8, yy, text);
		draw_set_alpha(1);
	}
}

/// @ignore
function __ppf_ui_button(_title, _callback=undefined) : __ppf_ui_element() constructor {
	name = "button";
	text = _title;
	height = 32;
	callback = _callback;
	sprite = __ppf_spr_ui_checkbox;
	sprite_w = sprite_get_width(sprite);
	sprite_h = sprite_get_height(sprite);
	
	static Draw = function() {
		if (!can_render) exit;
		
		// set focus
		if (point_in_rectangle(parent.__input_m_x, parent.__input_m_y, xx, yy, xx+sprite_w, yy+sprite_h)) {
			// press
			if (parent.__input_m_left_pressed) {
				if (parent.__ui_element_in_focus == undefined) parent.__ui_element_in_focus = self;
			}
			//release
			if (parent.__input_m_left_released) {
				if (callback != undefined) callback();
			}
		}
		// draw
		draw_set_color(c_white);
		draw_set_alpha(alpha);
		draw_sprite(sprite, 0, xx, yy);
		draw_text(xx+sprite_w+8, yy, text);
		draw_set_alpha(1);
	}
}

/// @ignore
function __ppf_ui_slider(_title, _subdivisions=0, _auto_update=false, _default_value=1, _range_min=0, _range_max=1, _can_autoupdate=true, _callback=undefined) : __ppf_ui_element() constructor {
	name = "slider";
	text = _title;
	width = 150;
	height = 40;
	callback = _callback;
	can_run_callback = false;
	can_autoupdate = _can_autoupdate;
	autoupdate = _auto_update;
	value = clamp(__ppf_relerp(_range_min, _range_max, _default_value, 0, 1), 0, 1);
	value_default = value;
	range_nmin = _range_min;
	range_nmax = _range_max;
	output = lerp(_range_min, _range_max, value);
	subdivisions = _subdivisions;
	
	static Draw = function() {
		if (!can_render) exit;
		can_run_callback = false;
		
		// auto adjust
		width = parent.__panel_width - xx - 64;
		
		// auto update
		if (autoupdate) {
			value = sin(parent.__timer) * 0.5 + 0.5;
			parent.__bake();
			can_run_callback = true;
		}
		
		// if focused
		if (parent.__ui_element_in_focus == self) {
			//value = median(0, 1, (parent.__input_m_x - xx) / width);
			value = clamp(__ppf_linearstep(xx, xx+width, parent.__input_m_x), 0, 1);
			can_run_callback = true;
		}
		
		// subdivide
		if (subdivisions > 0) value = floor(value * subdivisions) / subdivisions;
		
		// set focus
		if (point_in_rectangle(parent.__input_m_x, parent.__input_m_y, xx, yy+24-height/2, xx+width, yy+24+height/3)) {
			if (parent.__input_m_middle_pressed) {
				value = value_default;
				can_run_callback = true;
			}
			if (parent.__input_m_left_pressed) {
				if (parent.__ui_element_in_focus == undefined) parent.__ui_element_in_focus = self;
			}
			if (parent.__input_m_right_pressed) {
				if (can_autoupdate) autoupdate = !autoupdate;
			}
		}
		
		// output
		output = lerp(range_nmin, range_nmax, value);
		
		if (can_run_callback) {
			if (callback != undefined) callback(output);
		}
		
		// draw
		draw_set_color(c_white);
		draw_set_alpha(alpha);
		draw_sprite_stretched(__spr_ppf_pixel, 0, xx, yy+24, width, 1);
		draw_sprite(__ppf_spr_ui_control, 0, xx+width*value, yy+24);
		draw_text(xx, yy, text);
		draw_text(xx+string_width(text)+10, yy, "("+string(range_nmin)+"/"+string(range_nmax) + ") | " + string(output));
	}
}

/// @ignore
function __ppf_ui_separator(_color=make_color_rgb(60, 60, 60), _height=16) : __ppf_ui_element() constructor {
	name = "empty_space";
	height = _height;
	color = _color;
	
	static Draw = function() {
		draw_set_color(color);
		draw_set_alpha(alpha);
		draw_line(xx, yy, parent.__panel_width-xx, yy);
		draw_set_alpha(1);
	};
}

/// @ignore
function __ppf_ui_empty_space(_height=32) : __ppf_ui_element() constructor {
	name = "empty_space";
	height = _height;
	
	static Draw = undefined;
}

#endregion
