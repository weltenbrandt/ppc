// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
///@arg circle1_x 0
///@arg circle1_y 1
///@arg circle1_radius 2
///@arg circle2_x 3
///@arg circle2_y 4
///@arg circle2_radius 5
/// @function cone_circle_collision(origin_x, origin_y, angle, cone_width, cone_length, circle_x, circle_y, circle_radius)
/// @description Checks if a circle is within an attack cone
/// @param origin_x, origin_y - Center coordinates of the cone's origin
/// @param angle - Direction the cone is facing (in degrees)
/// @param cone_width - Width of the cone (in degrees)
/// @param cone_length - Length of the cone
/// @param circle_x, circle_y - Center coordinates of the circle
/// @param circle_radius - Radius of the circle
/// @returns boolean - True if the circle is within the cone, else false
function scr_tool_col_conecircle(origin_x, origin_y, angle, cone_width, cone_length, circle_x, circle_y, circle_radius) 
{
   // Vector from the cone's origin to the circle's center
    var dx = circle_x - origin_x;
    var dy = circle_y - origin_y;

    // Distance from the cone's origin to the circle's center
    var _distance = point_distance(origin_x, origin_y, circle_x, circle_y);

    // Check if the circle is within the cone's length
    if (_distance > cone_length + circle_radius) {
        return false;
    }

    // Angle between the cone's direction and the vector to the circle's center
    var _vector_angle = point_direction(origin_x, origin_y, circle_x, circle_y);
    
    // Normalize the angle difference to the range [-180, 180]
    var _angle_difference = angle_difference(angle, _vector_angle);

    // Check if the circle is within the cone's width
    if (abs(_angle_difference) <= cone_width / 2) {
        return true;
    }

    return false;
}