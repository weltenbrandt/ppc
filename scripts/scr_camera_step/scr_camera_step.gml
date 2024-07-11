// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function scr_camera_step()
{
	var _view_camera = view_camera[0];
	var _cam_wview = camera_get_view_width(_view_camera);
	var _cam_hview = camera_get_view_height(_view_camera);
	var _cam_xview = camera_get_view_x(_view_camera);
	var _cam_yview = camera_get_view_y(_view_camera);
	if (camera_active == true)
	{
		if (instance_exists(camera_target))
		{
			// Camera follow script
			var _cam_left_bound = _cam_wview * 0.5; // Define left boundary
			var _cam_right_bound = room_width - (_cam_wview * 0.5); // Define right boundary
			var _cam_top_bound = _cam_hview * 0.5; // Define top boundary
			var _cam_bottom_bound = room_height - (_cam_hview * 0.5); // Define bottom boundary

			var _player_x = camera_target.x;
			var _player_y = camera_target.y;

			// Calculate camera target position
			var _target_x = clamp(_player_x - _cam_wview * 0.5, 0, room_width - _cam_wview);
			var _target_y = clamp(_player_y - _cam_hview * 0.5, 0, room_height - _cam_hview);
			
			// Smoothly move the camera towards the target position
			var _cam_speed = (point_distance(_cam_xview, _cam_yview, _target_x, _target_y) / camera_follow_factor);
			
			_cam_xview = scr_camera_approach(_cam_xview, _target_x, _cam_speed);
			_cam_yview = scr_camera_approach(_cam_yview, _target_y, _cam_speed);
		}

		/*// Calculate the difference in zoom levels
		var _diff = camera_zoom_value - camera_zoom_targetvalue;
		var _speed = 0;
		// Apply zoom only if there's a difference
		if (_diff != 0) 
		{
			// Calculate new camera width and height based on zoom factor
			var new_cam_wview = camera_width * camera_zoom_value;
			var new_cam_hview = camera_height * camera_zoom_value;
	
			// Calculate the difference in width and height
			var dx = new_cam_wview - _cam_wview;
			var dy = new_cam_hview - _cam_hview;

			// Update camera position to maintain centering effect
			_cam_xview -= dx / 2;
			_cam_yview -= dy / 2;
				
			// Update camera zoom value and view size
			//camera_zoom_value -= _speed;
			if (camera_zoom_value >= camera_zoom_targetvalue)
			{
				_speed = max(abs(_diff) / 40,0.005);
				camera_zoom_value = max(camera_zoom_value-_speed,camera_zoom_targetvalue);
			}
			else
			{
				_speed = max(abs(_diff) / 40,0.005);
				camera_zoom_value = min(camera_zoom_value+_speed,camera_zoom_targetvalue);
			}
			//camera_zoom_value -= _speed;
			camera_set_view_size(_view_camera, new_cam_wview, new_cam_hview);
		}
		// Update camera view position*/
		camera_set_view_pos(_view_camera, _cam_xview, _cam_yview);
	}
		
		/*
		var _target_x = 0;
		var _target_y = 0;
		if (combat_shake_timer > 0)
		{
			combat_shake_timer--;
			// Generate random shake values
			combat_shake_x = random_range(-combat_shake_intensity*1, combat_shake_intensity*1);
			combat_shake_y = random_range(-combat_shake_intensity*1, combat_shake_intensity*1);
			combat_shake_x += lengthdir_x(combat_shake_intensity*0.5,combat_shake_direction); //random_range(-combat_shake_intensity, combat_shake_intensity);
			combat_shake_y += lengthdir_y(combat_shake_intensity*0.5,combat_shake_direction);///random_range(-combat_shake_intensity, combat_shake_intensity);
			// Calculate camera target position (maintain current position during shake)
			_target_x = _cam_xview + combat_shake_x;
			_target_y = _cam_yview + combat_shake_y;
		}
		else
		{
			// Reset shake values when the shake finishes
			combat_shake_x = 0;
			combat_shake_y = 0;
			_target_x = 0;
			_target_y = 0;
		}
		// Smoothly move the camera towards the target position
		var _cam_speed = (point_distance(_cam_xview,_cam_yview,_target_x,_target_y)/50);
		_cam_xview = scr_camera_approach(_cam_xview, _target_x, _cam_speed);
		_cam_yview = scr_camera_approach(_cam_yview, _target_y, _cam_speed);

		camera_set_view_pos(_view_camera, _cam_xview, _cam_yview);
		
		*/
}