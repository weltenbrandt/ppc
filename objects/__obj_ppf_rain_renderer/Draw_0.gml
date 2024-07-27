
// Feather ignore all

//draw_set_color(c_white);
//draw_sprite_tiled(spr_3d_sun_tex, 0, (cam_x+cam_w/2)*0.2, 0+current_time*0.1);

// recursive rain
if (!surface_exists(rain_surface_a)) {
	rain_surface_a = surface_create(width, height, global.__ppf_main_texture_format);
}
if (!surface_exists(rain_surface_b)) {
	rain_surface_b = surface_create(width, height, global.__ppf_main_texture_format);
}

surface_set_target(rain_surface_b);
	//camera_apply(view_camera[0]);
	draw_set_color(c_black);
	draw_set_alpha(fade_clear_amount);
	draw_rectangle(0, 0, width, height, false);
	draw_set_alpha(1);
	draw_set_color(c_white);
	gpu_push_state();
	gpu_set_tex_filter(true);
	gpu_set_blendmode_ext_sepalpha(bm_dest_color, bm_src_color, bm_one, bm_zero); //bm_src_color
	//gpu_set_blendmode_ext(bm_dest_color, bm_src_color);
	
	// draw rain drops
	// single drop
	draw_sprite(__spr_ppf_rain_normal, 1, random_range(0, width), random_range(0, height));
	
	// many drops
	rain_timer = max(rain_timer-1, 0);
	if (rain_timer == 0) {
		array_push(raindrop_list, {
			sprite : __spr_ppf_rain_normal,
			sprite_subimg : 0,
			xx : random_range(0, width),
			yy : 0,
			hmov_amplitude : random_range(0.2, 0.5),
			scale : random_range(0.25, 0.4),
			spd : random_range(1, 3),
			alpha : 1,
			fric : 1,
		});
		rain_timer = irandom_range(rain_timer_range1, rain_timer_range2);
	}
	var i = 0, isize = array_length(raindrop_list);
	repeat(isize) {
		var _reciprocal = i / isize;
		var _drop = raindrop_list[i];
		var t = current_time*0.001;
		_drop.xx += (sin(t + _drop.spd + sin(t*1.2) * _reciprocal) * _drop.hmov_amplitude) + random_range(-0.5, 0.5);
		_drop.yy += _drop.spd * _drop.fric;
		//_drop.fric = sin(t*0.5*_reciprocal) * 0.2+0.5;
		_drop.scale += random_range(-0.01, 0.01);
		_drop.scale = clamp(_drop.scale, 0.2, 0.8);
		_drop.alpha += choose(0, random_range(-0.02, 0.02))
		
		if (_drop.yy > height+32) {
			array_delete(raindrop_list, i, 1);
			i -= 1;
		}
		draw_sprite_ext(_drop.sprite, _drop.sprite_subimg, _drop.xx, _drop.yy, _drop.scale, _drop.scale, 0, c_white, _drop.alpha);
		++i;
	}
	
	gpu_pop_state();
	draw_set_color(c_white);
surface_reset_target();


// recursive apply
// use repeat(2) to more fps
rain_surface_swap = !rain_surface_swap;

var _surf1 = rain_surface_swap ? rain_surface_a : rain_surface_b;
var _surf2 = rain_surface_swap ? rain_surface_b : rain_surface_a;

surface_set_target(_surf1);
	draw_clear(make_color_rgb(128, 128, 255));
	//gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
	shader_set(__ppf_sh_ds_box4);
	shader_set_uniform_f(shader_get_uniform(__ppf_sh_ds_box4, "u_texel_size"), 1/width, 1/height);
	draw_surface(_surf2, 0, 0);
	//gpu_set_blendmode(bm_normal);
	shader_reset();
surface_reset_target();



var _ww = surface_get_width(_surf1);
var _hh = surface_get_height(_surf1);

if (!surface_exists(surf_final)) {
    surf_final = surface_create(_ww, _hh);
}
surface_set_target(surf_final);
	draw_clear(c_black);
	draw_set_alpha(1);
	draw_set_color(make_color_rgb(128, 128, 255));
	draw_rectangle(0, 0, _ww, _hh, false);
	gpu_set_colorwriteenable(true, true, true, false);
	draw_surface(_surf2, 0, 0);
	gpu_set_colorwriteenable(true, true, true, true);
surface_reset_target();

draw_surface(surf_final, 0, 0);
draw_set_color(c_white);
