// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
///@arg xx 0
///@arg yy 1
///@arg dir 2
///@arg cone_wid 3
///@arg cone_len 4
function scr_player_attack(_xx,_yy,_dir,_cone_width,_cone_lenght)
{
	scr_test_cone(0,_xx,_yy,_dir,_cone_width,_cone_lenght);
	with (obj_combat_proj) 
	{
	    if (scr_tool_col_conecircle(_xx, _yy, _dir, _cone_width, _cone_lenght, x, y, 6) == true) 
		{
			if (duration > 0)
			{
				dir = _dir;
				mspd*=2;
			}
	    }
	}
}