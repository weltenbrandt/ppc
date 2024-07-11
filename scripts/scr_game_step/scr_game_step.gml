// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function scr_game_step()
{
	if (game_timer mod 120 == 0)
	{
		var _random_dir = irandom(359);
		var _xx = obj_player.x + lengthdir_x(180,_random_dir);
		var _yy = obj_player.y + lengthdir_y(180,_random_dir);
		var _dir = point_direction(_xx,_yy,obj_player.x,obj_player.y);
		scr_combat_proj(0,obj_player,_xx,_yy,_dir,2,10,6,room_speed*5);
	}
}