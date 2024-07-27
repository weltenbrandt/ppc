// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function scr_combat_anticluster()
{
	var a, xoff, yoff, om, mm, mag, _scale, _other;
	_scale = 1;
	om = _scale;
	mm = _scale;
	mag = om * om + mm * mm;
	om /= mag;
	mm /= mag;
	with (obj_enemy)
	{
	    _other = instance_place(x, y, obj_enemy);
	    if (_other != noone && _other != id)
	    {
			a = point_direction(x, y, _other.x, _other.y);
			xoff = lengthdir_x(1, a);
			yoff = lengthdir_y(1, a);
	        while (place_meeting(x, y, _other))
	        {
	            x -= xoff * om;
	            y -= yoff * om;
	            _other.x += xoff * mm;
	            _other.y += yoff * mm;
	            // = clamp(x, obj_enemy_limit.bbox_left, obj_enemy_limit.bbox_right);
	            //y = clamp(y, obj_enemy_limit.bbox_top, obj_enemy_limit.bbox_bottom);
	        }
	    }
	}
}