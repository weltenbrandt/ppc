// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function scr_camera_init()
{
	camera_firstset = false;
	camera_width = 320;
	camera_height = 180;
	camera_zoom_value = 1;
	camera_zoom_targetvalue = 1;
	camera_active = true;
	camera_target = obj_player;
	camera_follow_factor = 15;
}