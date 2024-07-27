
/// Feather ignore all

/// @desc The profile is like a container, which contains the effects you want the system to render. They alone don't do anything, it's just a data structure.
/// You can create multiple profiles with different effects and then load them in real time.
///
/// The order you add the effects to the array doesn't matter. They already have their own order.
///
/// To load this profile to the post-processing system, use system_id.ProfileLoad(profile_id).
/// @param {String} name Profile name. It only serves as a cosmetic and nothing else.
/// @param {Array} effects_array Array with all effects structs. Each effect can be obtained from "new FX_*" constructors.
/// @returns {Struct} Profile struct.
function PPFX_Profile(name, effects_array) constructor {
	__ppf_trace($"Profile created. {__ppf_get_context()}", 3);
	__ppf_exception(!is_string(name), "Invalid profile name.");
	__ppf_exception(!is_array(effects_array), "Parameter is not an array containing effects.");
	
	__profile_name = name;
	__effects_array = effects_array;
	//__id = sha1_string_utf8(string(self) + string(random(10000))); // unused
	
	#region Public Methods
	/// @func GetName()
	/// @desc Get the name of the profile.
	/// @returns {String} Profile name.
	static GetName = function() {
		return __profile_name;
	}
	
	/// @func SetName(name)
	/// @desc Set the name of the profile.
	/// @param {String} name New profile name.
	/// @returns {Undefined}
	static SetName = function(name) {
		__ppf_exception(!is_string(name), "Invalid profile name.");
		__profile_name = name;
	}
	
	/// @func Stringify(round_numbers)
	/// @desc This function parses and exports the profile in GML, for easy use.
	/// @param {Bool} round_numbers Sets whether to round numbers (removing decimals).
	/// @param {Bool} enabled_only Defines if will export only enabled effects.
	/// @param {Struct} renderer Include PPFX_System() id to export effects from the system/renderer, instead of profile.
	/// @returns {string} Description
	static Stringify = function(round_numbers=false, enabled_only=false, renderer=undefined) {
		var _source = self;
		if (renderer != undefined && ppfx_system_exists(renderer)) {
			_source = renderer;
		}
		
		__ppf_trace($"Parsing \"{__profile_name}\" Profile. WARNING: The returned string will contain undefined textures.", 2);
		
		// methods
		static __parseEffect = function(effect_struct=undefined, constructor_name="", parameters_array=undefined, round_numb=false, delimiter=", ") {
			if (parameters_array == undefined) exit;
			var _effect_string = $"\tnew {constructor_name}(";
			var _variable_value = undefined,
				_variable_type = undefined,
				_parameters_len = array_length(parameters_array);
			
			// fill parameters
			for (var k = 0; k < _parameters_len; ++k) {
				_variable_value = parameters_array[k];
				_variable_type = typeof(_variable_value);
				
				// concat parameter
				// write string based on type
				switch(_variable_type) {
					case "bool":
						_effect_string += _variable_value ? "true" : "false";
						break;
					
					case "number":
						var _value = _variable_value;
						if (_variable_value < 0.0001) _value = "0"; else
						if (round_numb && _variable_value > 1) _value = string(round(_variable_value)); // round number (if needed)
						_effect_string += string(_value);
						break;
					
					case "ptr":
						_effect_string += "undefined";
						break;
					
					case "array":
						var _type = _variable_value[0];
						var _value = _variable_value[1];
						switch(_type) {
							// vec2
						    case "vec2":
								_effect_string += $"[{string(_value[0])}, {string(_value[1])}]";
								break;
							// vec3
						    case "vec3":
								_effect_string += $"[{string(_value[0])}, {string(_value[1])}, {string(_value[2])}]";
								break;
							// color
							case "color":
								var _color = make_color_rgb(_value[0]*255, _value[1]*255, _value[2]*255);
								if (_color == c_black) _effect_string += "c_black"; else
								if (_color == c_white) _effect_string += "c_white"; else
								if (_color == c_red) _effect_string += "c_red"; else
								if (_color == c_green) _effect_string += "c_green"; else
								if (_color == c_blue) _effect_string += "c_blue"; else
								if (_color == c_orange) _effect_string += "c_orange"; else
								if (_color == c_yellow) _effect_string += "c_yellow"; else
								if (_color == c_aqua) _effect_string += "c_aqua"; else
								if (_color == c_lime) _effect_string += "c_lime"; else
								if (_color == c_purple) _effect_string += "c_purple"; else
								if (_color == c_fuchsia) _effect_string += "c_fuchsia"; else
								_effect_string += $"make_color_rgb({string(round(_value[0]*255))}, {string(round(_value[1]*255))}, {string(round(_value[2]*255))})";
								break;
							// texture
							case "texture":
								_effect_string += "undefined";
								break;
						}
						break;
					
					default:
						_effect_string += string(_variable_value);
						break;
				}
				
				// add delimiter (comma)
				if (k != _parameters_len-1) _effect_string += delimiter;
			}
			
			// close parentheses
			_effect_string += ")";
			
			// order
			if (effect_struct != undefined) {
				if (effect_struct.order_was_changed) {
					_effect_string += $".SetOrder({effect_struct.stack_order})";
				}
			}
			
			// last comma
			return _effect_string + ",\n";
		}
		
		// init
		var _final_string = $"game_profile = new PPFX_Profile(\"{__profile_name}\", [\n";
		try {
			// loop effects
			var _array = _source.__effects_array;
			var _length = array_length(_array);
			for (var i = 0; i < _length; ++i) {
				var _effect_struct = _array[i];
				if (_effect_struct.settings.enabled || !enabled_only) {
					if (_effect_struct.ExportData != undefined) {
						var _data = _effect_struct.ExportData();
						_final_string += __parseEffect(_effect_struct, _data.name, _data.params, round_numbers);
					}
				}
			}
			// close bracket
			_final_string += "]);"
		}
		catch(error) {
			__ppf_trace($"Error parsing \"{__profile_name}\" profile.\n> " + error.longMessage, 1);
			return undefined;
		}
		show_debug_message(_final_string)
		return _final_string;
	}
	
	/// @ignore
	/// @desc Reset profile (remove all effects from it).
	static Reset = function() {
		array_resize(__effects_array, 0);
	}
	
	/// @ignore
	/// @desc Load/import a profile to this profile.
	static Load = function(profile_id, merge=false) {
		var _profile_effects_array = profile_id.__effects_array;
		if (merge) {
			// merge
			var i = 0, isize = array_length(_profile_effects_array),
				j = 0, jsize = array_length(__effects_array),
				_effect = undefined,
				_exists = false;
			
			repeat(isize) {
				_effect = _profile_effects_array[i];
				_exists = false;
				// check if effect already exists in this system
				j = 0; 
				repeat(jsize) {
					if (_effect.effect_name == __effects_array[j].effect_name) {
						_exists = true;
						break;
					}
					++j;
				}
				if (!_exists) {
					array_push(__effects_array, _effect);
				}
				++i;
			}
		} else {
			// copy and replace
			array_resize(__effects_array, 0);
			array_copy(__effects_array, 0, _profile_effects_array, 0, array_length(_profile_effects_array));
		}
	}
	
	#endregion
}
