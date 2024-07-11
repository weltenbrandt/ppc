// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function scr_player_keyaction()
{
	if (key[id_key_shoulder_left] == true)
	{
		var _previous_focus = player_skill_focus;
		player_skill_focus = max(player_skill_focus-1,0);
		if (player_skill_focus != _previous_focus) { scr_sfx_play(ui[id_ui_sounds_cursor]); }
	}
	else if (key[id_key_shoulder_right] == true)
	{
		var _previous_focus = player_skill_focus;
		player_skill_focus = min(player_skill_focus+1,2);
		if (player_skill_focus != _previous_focus) { scr_sfx_play(ui[id_ui_sounds_cursor]); }
	}
}