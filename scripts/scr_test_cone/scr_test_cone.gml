// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
///@arg phase 0
///@arg xx 1
///@arg yy 2
///@arg dir 3
///@arg cone_wid 4
///@arg cone_len 5
function scr_test_cone(_phase)
{
	switch (_phase)
	{
		case 0:///INIT
			with (instance_create_layer(argument[1],argument[2],"Instances",obj_test_cone))
			{
				depth = 1000;
				dir = argument[3];
				cone_width = argument[4];
				cone_length = argument[5];
				alarm[0] = room_speed*0.5;
			}
		break;
		
		case 1:///DRAW
			// Calculate the vertices of the cone
			var x1 = x + lengthdir_x(cone_length, dir - cone_width / 2);
			var y1 = y + lengthdir_y(cone_length, dir - cone_width / 2);
			var x2 = x + lengthdir_x(cone_length, dir + cone_width / 2);
			var y2 = y + lengthdir_y(cone_length, dir + cone_width / 2);

			// Draw the cone
			draw_set_color(c_aqua);
			draw_set_alpha(0.1);
			draw_triangle(x, y, x1, y1, x2, y2, false);
			draw_line(x, y, x1, y1);
			draw_line(x, y, x2, y2);
			draw_line(x1, y1, x2, y2);
			draw_set_alpha(1);
		break;
	}
}