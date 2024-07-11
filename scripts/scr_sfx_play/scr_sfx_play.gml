// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
///@arg sound_array
function scr_sfx_play(argument0)
{
	var _sound_array = argument0;
	var _sounds = _sound_array[0];
	var _vol = _sound_array[1];
	audio_play_sound(_sounds[irandom(array_length(_sounds)-1)],10,false,_vol*ctl.config_sfx_vol,0,random_range(0.8,1.2));
}