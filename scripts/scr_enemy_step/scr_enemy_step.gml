// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function scr_enemy_step()
{
	with (obj_enemy)
	{
		var _dir = point_direction(x, y, obj_player.x, obj_player.y);
		var _dis = point_distance(x, y, obj_player.x, obj_player.y);
		if (_dis > 32)
		{
			x += lengthdir_x(1,_dir);
			y += lengthdir_y(1,_dir);
		}
		if (_dir <= 90 && _dir >= 0 || _dir >= 270 && _dir <= 360)
		{
			image_xscale = 1;
		}
		else
		{
			image_xscale = -1;
		}
	}
	
	if (game_timer mod 2 == 0)
	{
		scr_combat_anticluster();
	}
}