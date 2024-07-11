// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
///@arg phase 0
///@arg follow 1
///@arg force 2
///@arg dir 3
///@arg friction 4
function scr_combat_force()
{
	var _phase = argument0
	switch (_phase)
	{
		case 0:
			with (instance_create_layer(0,0,"Instances",obj_combat_force))
			{
				follow = argument1;
				force = argument2;
				dir = argument3;
				fric = argument4;
			}
		break;
		
		case 1:///STEP
			if (instance_exists(follow) == false) { instance_destroy(); exit; }
			follow.x += lengthdir_x(force,dir);
			follow.y += lengthdir_y(force,dir);
			force = max(force - fric,0);
			if (force == 0) { instance_destroy(); }
		break;
	}
}