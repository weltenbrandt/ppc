// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function scr_player_get_hvspeed_dir()
{
	with (ctl)
	{
		if (player[id_player_data_hsp] < 0 && player[id_player_data_vsp] < 0) { return 135; }
		else if (player[id_player_data_hsp] > 0 && player[id_player_data_vsp] < 0) { return 45; }
		else if (player[id_player_data_hsp] < 0 && player[id_player_data_vsp] > 0) { return 225; }
		else if (player[id_player_data_hsp] > 0 && player[id_player_data_vsp] > 0) { return 315; }
		else if (player[id_player_data_hsp] < 0) { return 180; }
		else if (player[id_player_data_hsp] > 0) { return 0; }
		else if (player[id_player_data_vsp] < 0) { return 90; }
		else if ( player[id_player_data_vsp] > 0) { return 270; }
		else { return -1 }	
	}
}