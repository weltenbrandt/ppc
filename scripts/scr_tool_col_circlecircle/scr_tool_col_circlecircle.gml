// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
///@arg circle1_x 0
///@arg circle1_y 1
///@arg circle1_radius 2
///@arg circle2_x 3
///@arg circle2_y 4
///@arg circle2_radius 5
function scr_tool_col_circlecircle(x1, y1, r1, x2, y2, r2) 
{
    var dx = x2 - x1;
    var dy = y2 - y1;
    var distance = sqrt(dx * dx + dy * dy);
    return distance < (r1 + r2);
}