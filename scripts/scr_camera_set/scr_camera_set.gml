// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function scr_camera_set()
{
	if (instance_exists(ctl.camera_target) == true)
	{
		// Camera follow script
		var _view_camera = view_camera[0];
		var _cam_wview = camera_get_view_width(_view_camera);
		var _cam_hview = camera_get_view_height(_view_camera);
		var _player_x = ctl.camera_target.x;
		var _player_y = ctl.camera_target.y;
		// Calculate camera target position
		var _target_x = clamp(_player_x - _cam_wview * 0.5, 0, room_width - _cam_wview);
		var _target_y = clamp(_player_y - _cam_hview * 0.5, 0, room_height - _cam_hview);
		camera_set_view_pos(view_camera[0], _target_x, _target_y)
	}
}