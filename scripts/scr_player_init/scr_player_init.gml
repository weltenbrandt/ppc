// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function scr_player_init()
{
	#macro id_player_data_spr_idle_down 0
	#macro id_player_data_spr_idle_downleft 1
	#macro id_player_data_spr_idle_downright 2
	#macro id_player_data_spr_idle_left 3
	#macro id_player_data_spr_idle_right 4
	#macro id_player_data_spr_idle_up 5
	#macro id_player_data_spr_idle_upleft 6
	#macro id_player_data_spr_idle_upright 7
	
	#macro id_player_data_spr_walk_down 8
	#macro id_player_data_spr_walk_downleft 9
	#macro id_player_data_spr_walk_downright 10
	#macro id_player_data_spr_walk_left 11
	#macro id_player_data_spr_walk_right 12
	#macro id_player_data_spr_walk_up 13
	#macro id_player_data_spr_walk_upleft 14
	#macro id_player_data_spr_walk_upright 15
	
	#macro id_player_data_spr_run_down 16
	#macro id_player_data_spr_run_downleft 17
	#macro id_player_data_spr_run_downright 18
	#macro id_player_data_spr_run_left 19
	#macro id_player_data_spr_run_right 20
	#macro id_player_data_spr_run_up 21
	#macro id_player_data_spr_run_upleft 22
	#macro id_player_data_spr_run_upright 23
	
	#macro id_player_data_spr_runstop_down 24
	#macro id_player_data_spr_runstop_downleft 25
	#macro id_player_data_spr_runstop_downright 26
	#macro id_player_data_spr_runstop_left 27
	#macro id_player_data_spr_runstop_right 28
	#macro id_player_data_spr_runstop_up 29
	#macro id_player_data_spr_runstop_upleft 30
	#macro id_player_data_spr_runstop_upright 31
	
	#macro id_player_data_spr_roll_down 32
	#macro id_player_data_spr_roll_downleft 33
	#macro id_player_data_spr_roll_downright 34
	#macro id_player_data_spr_roll_left 35
	#macro id_player_data_spr_roll_right 36
	#macro id_player_data_spr_roll_up 37
	#macro id_player_data_spr_roll_upleft 38
	#macro id_player_data_spr_roll_upright 39
	
	#macro id_player_data_spr_attack1_down 40
	#macro id_player_data_spr_attack1_downleft 41
	#macro id_player_data_spr_attack1_downright 42
	#macro id_player_data_spr_attack1_left 43
	#macro id_player_data_spr_attack1_right 44
	#macro id_player_data_spr_attack1_up 45
	#macro id_player_data_spr_attack1_upleft 46
	#macro id_player_data_spr_attack1_upright 47
	
	#macro id_player_data_spr_attack2_down 48
	#macro id_player_data_spr_attack2_downleft 49
	#macro id_player_data_spr_attack2_downright 50
	#macro id_player_data_spr_attack2_left 51
	#macro id_player_data_spr_attack2_right 52
	#macro id_player_data_spr_attack2_up 53
	#macro id_player_data_spr_attack2_upleft 54
	#macro id_player_data_spr_attack2_upright 55
	
	#macro id_player_data_mspd 56
	#macro id_player_data_acel 57
	#macro id_player_data_friction 58
	#macro id_player_data_hsp 59
	#macro id_player_data_vsp 60
	#macro id_player_data_dir 61
	#macro id_player_data_roll_duration 62
	
	#macro id_player_data_attack_punish 63
	
	#macro id_player_data_attack1_duration 64
	#macro id_player_data_attack1_combothreshold_min 65
	#macro id_player_data_attack1_combothreshold_max 66
	#macro id_player_data_attack1_hitframe 67
	
	#macro id_player_data_attack2_duration 68
	#macro id_player_data_attack2_combothreshold_min 69
	#macro id_player_data_attack2_combothreshold_max 70
	#macro id_player_data_attack2_hitframe 71
	
	#macro id_player_data_snds_step 72
	#macro id_player_data_snds_attack1 73
	#macro id_player_data_snds_attack2 74
	#macro id_player_data_snds_roll 75
	#macro id_player_data_snds_runstop 76
	
	#macro id_player_data_runstop_timer 77
	
	player[id_player_data_spr_idle_down] = spr_player_idle_down;
	player[id_player_data_spr_idle_downleft] = spr_player_idle_downleft;
	player[id_player_data_spr_idle_downright] = spr_player_idle_downright;
	player[id_player_data_spr_idle_left] = spr_player_idle_left;
	player[id_player_data_spr_idle_right] = spr_player_idle_right;
	player[id_player_data_spr_idle_up] = spr_player_idle_up;
	player[id_player_data_spr_idle_upleft] = spr_player_idle_upleft;
	player[id_player_data_spr_idle_upright] = spr_player_idle_upright;
	
	player[id_player_data_spr_walk_down] = spr_player_walk_down;
	player[id_player_data_spr_walk_downleft] = spr_player_walk_downleft;
	player[id_player_data_spr_walk_downright] = spr_player_walk_downright;
	player[id_player_data_spr_walk_left] = spr_player_walk_left;
	player[id_player_data_spr_walk_right] = spr_player_walk_right;
	player[id_player_data_spr_walk_up] = spr_player_walk_up;
	player[id_player_data_spr_walk_upleft] = spr_player_walk_upleft;
	player[id_player_data_spr_walk_upright] = spr_player_walk_upright;
	
	player[id_player_data_spr_run_down] = spr_player_run_down;
	player[id_player_data_spr_run_downleft] = spr_player_run_downleft;
	player[id_player_data_spr_run_downright] = spr_player_run_downright;
	player[id_player_data_spr_run_left] = spr_player_run_left;
	player[id_player_data_spr_run_right] = spr_player_run_right;
	player[id_player_data_spr_run_up] = spr_player_run_up;
	player[id_player_data_spr_run_upleft] = spr_player_run_upleft;
	player[id_player_data_spr_run_upright] = spr_player_run_upright;
	
	player[id_player_data_spr_runstop_down] = spr_player_runstop_down;
	player[id_player_data_spr_runstop_downleft] = spr_player_runstop_downleft;
	player[id_player_data_spr_runstop_downright] = spr_player_runstop_downright;
	player[id_player_data_spr_runstop_left] = spr_player_runstop_left;
	player[id_player_data_spr_runstop_right] = spr_player_runstop_right;
	player[id_player_data_spr_runstop_up] = spr_player_runstop_up;
	player[id_player_data_spr_runstop_upleft] = spr_player_runstop_upleft;
	player[id_player_data_spr_runstop_upright] = spr_player_runstop_upright;
	
	player[id_player_data_spr_roll_down] = spr_player_roll_down;
	player[id_player_data_spr_roll_downleft] = spr_player_roll_downleft;
	player[id_player_data_spr_roll_downright] = spr_player_roll_downright;
	player[id_player_data_spr_roll_left] = spr_player_roll_left;
	player[id_player_data_spr_roll_right] = spr_player_roll_right;
	player[id_player_data_spr_roll_up] = spr_player_roll_up;
	player[id_player_data_spr_roll_upleft] = spr_player_roll_upleft;
	player[id_player_data_spr_roll_upright] = spr_player_roll_upright;
	
	player[id_player_data_spr_attack1_down] = spr_player_attack1_down;
	player[id_player_data_spr_attack1_downleft] = spr_player_attack1_downleft;
	player[id_player_data_spr_attack1_downright] = spr_player_attack1_downright;
	player[id_player_data_spr_attack1_left] = spr_player_attack1_left;
	player[id_player_data_spr_attack1_right] = spr_player_attack1_right;
	player[id_player_data_spr_attack1_up] = spr_player_attack1_up;
	player[id_player_data_spr_attack1_upleft] = spr_player_attack1_upleft;
	player[id_player_data_spr_attack1_upright] = spr_player_attack1_upright;
	
	player[id_player_data_spr_attack2_down] = spr_player_attack2_down;
	player[id_player_data_spr_attack2_downleft] = spr_player_attack2_downleft;
	player[id_player_data_spr_attack2_downright] = spr_player_attack2_downright;
	player[id_player_data_spr_attack2_left] = spr_player_attack2_left;
	player[id_player_data_spr_attack2_right] = spr_player_attack2_right;
	player[id_player_data_spr_attack2_up] = spr_player_attack2_up;
	player[id_player_data_spr_attack2_upleft] = spr_player_attack2_upleft;
	player[id_player_data_spr_attack2_upright] = spr_player_attack2_upright;
	
	player[id_player_data_snds_step] = [[snd_step_1,snd_step_2,snd_step_3,snd_step_4,snd_step_5,snd_step_6,snd_step_7,snd_step_8,snd_step_9,snd_step_10],0.2];
	player[id_player_data_snds_attack1] = [[snd_attack_1],1.0];
	player[id_player_data_snds_attack2] = [[snd_attack_2],1.0];
	player[id_player_data_snds_roll] = [[snd_roll],0.5];
	player[id_player_data_snds_runstop] = [[snd_runstop_1,snd_runstop_2,snd_runstop_3,snd_runstop_4,snd_runstop_5,snd_runstop_6,snd_runstop_7,snd_runstop_8],0.4];
	
	player[id_player_data_mspd] = 2;
	player[id_player_data_acel] = 0.35;
	player[id_player_data_friction] = 0.1;
	player[id_player_data_hsp] = 0;
	player[id_player_data_vsp] = 0;
	player[id_player_data_dir] = 0;
	player[id_player_data_roll_duration] = 30;
	
	player[id_player_data_attack1_duration] = 20;
	player[id_player_data_attack1_combothreshold_min] = 0.6;
	player[id_player_data_attack1_combothreshold_max] = 0.95;
	player[id_player_data_attack1_hitframe] = 5;
	
	player[id_player_data_attack2_duration] = 20;
	player[id_player_data_attack2_combothreshold_min] = 0.6;
	player[id_player_data_attack2_combothreshold_max] = 0.95;
	player[id_player_data_attack2_hitframe] = 5;
	
	player[id_player_data_attack_punish] = 12;
	player[id_player_data_runstop_timer] = 24;
	
	player_attack_timer = 0;
	player_attack_performing = 0;
	player_attack_punish_timer = 0;
	player_attack_hit = false;
	
	player_roll_timer = 0;
	
	player_runstop_timer = 0;
	
	player_state = "idle";
	player_facedir = "down";
	
	player_previous_movestate = 0;
	
	player_skill_focus = 0;
	player_mspd = player[id_player_data_mspd];
}