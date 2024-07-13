// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
///@arg phase
function scr_player_proj(_phase)
{
	switch (_phase)
	{
		case 0:///INIT
			var _xx = obj_player.x + lengthdir_x(4,argument[1]);
			var _yy = obj_player.y + lengthdir_y(4,argument[1]);
			with (instance_create_layer(_xx,_yy,"Instances",obj_player_proj))
			{
				range = 96;
				mspd = 4;
				dir = argument[1];
				radius = 4;
				alarm[0] = round(range/mspd);
				image_alpha = 0;
			}
		break;
		
		case 1: ///STEP
			image_alpha = min(image_alpha+0.1,1);
			x += lengthdir_x(mspd,dir);
			y += lengthdir_y(mspd,dir);
			with (obj_combat_proj)
			{
				if (scr_tool_col_circlecircle(other.x,other.y,other.radius,x,y,radius) == true)
				{
					instance_destroy(other);
					destroy = true;
					break;
				}
			}
			if (alarm[0] == -1)
			{
				image_alpha-=0.2;
				if (image_alpha <= 0) { instance_destroy(); }
			}
		break;
	}
}