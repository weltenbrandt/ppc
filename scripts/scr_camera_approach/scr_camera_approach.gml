// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function scr_camera_approach()
{
	// This script smoothly interpolates between the current value and the target value by a specified amount
	var current = argument0;
	var target = argument1;
	var amount = argument2;

	// Check if the current value is equal to the target value
	if (current == target) {
		return current; // If they are equal, no need for interpolation, return the current value
	} else {
		// Calculate the difference between the target value and the current value
		var diff = target - current;

		// Ensure the difference is within the specified amount
		if (abs(diff) <= amount) {
		    return target; // If the difference is within the amount, return the target value
		} else {
		    // Otherwise, interpolate towards the target value by the specified amount
		    return current + sign(diff) * amount;
		}
	}
}