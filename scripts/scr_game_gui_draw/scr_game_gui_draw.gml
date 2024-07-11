// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function scr_game_gui_draw()
{
	with (obj_gui_skill_slot)
	{
		image_index = 0;
		if (position == ctl.player_skill_focus) { image_index = 1; }
		draw_self();
		switch (position)
		{
			case 0:
				draw_sprite(spr_skill1_icon,0,x,y);
			break;
			case 1:
				draw_sprite(spr_skill2_icon,0,x,y);
			break;
			case 2:
				draw_sprite(spr_skill3_icon,0,x,y);
			break;
		}
	}
}