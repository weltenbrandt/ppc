// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
///@arg phase 0
///@arg owner 1
///@arg xx 2 
///@arg yy 3
///@arg dir 4
///@arg mspd 5
///@arg damage 6
///@arg radius 7
///@arg duration 8
function scr_combat_proj(_phase)
{
	switch (_phase)
	{
		case 0:///INIT
			with (instance_create_layer(argument[2],argument[3],"Instances",obj_combat_proj))
			{
				owner = argument[1];
				dir = argument[4];
				mspd = argument[5];
				damage = argument[6];
				radius = argument[7];
				duration = argument[8];
				destroy = false;
			}
		break;
		
		case 1:///STEP
			x += lengthdir_x(mspd,dir);
			y += lengthdir_y(mspd,dir);
			if (duration > 0)
			{
				image_alpha = min(image_alpha + 0.1, 1);
				if (scr_tool_col_circlecircle(x, y, radius, obj_player.x, obj_player.y, 5))
				{
				    var _block_dir = (ctl.player_dir + 360) mod 360;
				    var _dir_to_proj = (point_direction(obj_player.x, obj_player.y, x, y) + 360) mod 360;
				    var _block_radius = 90;
				    var _half_block_radius = _block_radius * 0.5;

				    if (ctl.player_block_timer == 0)
				    {
				        scr_combat_force(0, obj_player, 2, dir, ctl.player[id_player_data_friction]);
				    }
				    else
				    {
				        var min_block_angle = (_block_dir - _half_block_radius + 360) mod 360;
				        var max_block_angle = (_block_dir + _half_block_radius + 360) mod 360;
				        var is_blocking = false;

				        if (min_block_angle < max_block_angle)
				        {
				            is_blocking = (_dir_to_proj >= min_block_angle) && (_dir_to_proj <= max_block_angle);
				        }
				        else
				        {
				            is_blocking = (_dir_to_proj >= min_block_angle) || (_dir_to_proj <= max_block_angle);
				        }

				        if (is_blocking)
				        {
				            ///BLOCK
				        }
				        else
				        {
				            scr_combat_force(0, obj_player, 2, dir, ctl.player[id_player_data_friction]);
				        }
				    }
				    destroy = true;
				}

				duration--;
			}
			else
			{
				image_alpha=max(image_alpha-0.05,0);
				if (image_alpha == 0) { instance_destroy(); }
			}
			if (destroy == true)
			{
				audio_play_sound(snd_combat_proj_ex,10,false,0.3*ctl.config_sfx_vol);
				scr_gfx(0,x,y,spr_combat_proj_ex);
				instance_destroy();
			}
		break;
	}
}