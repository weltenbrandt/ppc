// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
///@arg phase 0
///@arg xx 1
///@arg yy 2
///@arg sprite 3
function scr_gfx(_phase)
{
	switch (_phase)
	{
		case 0:///INIT
			with (instance_create_layer(argument[1],argument[2],"Instances",obj_gfx))
			{
				sprite_index = argument[3];
			}
		break;
		
		case 1:///STEP
			if (image_index >= image_number-1) { instance_destroy(); }
		break;
	}
}