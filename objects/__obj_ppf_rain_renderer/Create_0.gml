
// EXPERIMENTAL !!!

width = 0;
height = 0;
rain_surface_a = -1;
rain_surface_b = -1;
rain_surface_swap = false;

fade_clear_amount = 0.01;

rain_timer = 5;
rain_timer_range1 = 10;
rain_timer_range2 = 60;

raindrop_list = []; // array with structs


surf_final = -1;
// 266 | 256 / 14641 (bm_src_color, bm_src_color, bm_src_color, bm_zero);
// 750 | 740 / 14641 (bm_src_color, bm_src_color, bm_dest_alpha, bm_zero);
//TESTT = 750;
//TESTT1 = 0;
//TESTT2 = 0;
//var _angle = (current_time*0.5) % 360;
//draw_sprite(__spr_ppf_rain_normal, 0, mouse_x+lengthdir_x(20, _angle), mouse_y+lengthdir_y(20, _angle));
//gpu_set_blendmode_ext(bm_dest_color, bm_src_color);
