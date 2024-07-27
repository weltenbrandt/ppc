
/*--------------------------------------------------------------------------------------------------
	Here you can modify some library behaviors.
	You don't need to call this script, it runs automatically.
	
	If you want to change the quality of Blurs (radial, motion...), Sunshafts and others, modify the
	"ITERATIONS" variable of each one in the pixel shader. Most effects don't need this.
	
	Some effects let you set the resolution. They have a parameter called "downscale", like
	Bloom and Depth of Field.
--------------------------------------------------------------------------------------------------*/

// Debug messages from Post-Processing FX
// 0 > Disabled.
// 1 > Error debug messages.
// 2 > Error debug messages + Warnings. (default)
// 3 > Error debug messages + Warnings + Create/Destroy systems + Load Profiles, etc.
#macro PPFX_CFG_TRACE_LEVEL 2

// Enable error checking of Post-Processing FX functions (disabling this will increase CPU-side performance)
#macro PPFX_CFG_ERROR_CHECKING_ENABLE true

// Enable hardware compatibility checking
#macro PPFX_CFG_HARDWARE_CHECKING true

// Time (in seconds) to reset the global PPFX timer (-1 for unlimited)
// useful for Mobile devices
#macro PPFX_CFG_TIMER -1 // 3600 seconds = 60 minutes (1 hour)

// Global effects speed ( 1/60 = 0.016 ) >> 60 is the game speed, in frames per second
#macro PPFX_CFG_SPEED 0.016

// HDR (High Dynamic Range) for Post-Processing FX rendering.
// This allows for better color depth, contrast and brightness (especially useful for the Bloom and Sunshafts/Godrays effect).
// Notes:
// - This may affect performance;
// - Not all GPUs support this feature;
// - You will probably need some system that facilitates the use of HDR (mostly for Bloom and Sunshafts). Check out https://foxyofjungle.itch.io/hdr-renderer-for-gamemaker
#macro PPFX_CFG_HDR_ENABLE true

// HDR textures format
#macro PPFX_CFG_HDR_TEX_FORMAT PPF_HDR_TEX_FORMAT.RGBA16

// Color Curves, curve file format
#macro PPFX_CFG_COLOR_CURVES_FORMAT ".crv"
