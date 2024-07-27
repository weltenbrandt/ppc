
/// @ignore
global.__ppf_shader_textures = {
	pixel_texture : sprite_get_texture(__spr_ppf_pixel, 0),
	noise_point : sprite_get_texture(__spr_ppf_noise_point, 0),
	noise_perlin : sprite_get_texture(__spr_ppf_noise_perlin, 0),
	noise_simplex : sprite_get_texture(__spr_ppf_noise_simplex, 0),
	default_normal : sprite_get_texture(__spr_ppf_normal, 0),
	default_palette : sprite_get_texture(__spr_ppf_pal_default, 0),
	default_lut : sprite_get_texture(__spr_ppf_lut_grid_default, 0),
	default_dirt_lens : sprite_get_texture(__spr_ppf_dirt_lens, 0),
	default_overlay_tex : sprite_get_texture(__spr_ppf_blood, 0),
	default_chromaber_prisma_lut : sprite_get_texture(__spr_ppf_prism_lut_rb, 0),
	default_shockwaves_prisma_lut : sprite_get_texture(__spr_ppf_prism_lut_cp, 0),
	bayer_16x16 : sprite_get_texture(__spr_ppf_bayer16x16, 0),
	bayer_8x8 : sprite_get_texture(__spr_ppf_bayer8x8, 0),
	bayer_4x4 : sprite_get_texture(__spr_ppf_bayer4x4, 0),
	bayer_2x2 : sprite_get_texture(__spr_ppf_bayer2x2, 0),
}

#macro __PPF_ST global.__ppf_shader_textures
