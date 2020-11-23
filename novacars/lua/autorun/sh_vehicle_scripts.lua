CMOD_Cars = CMOD_Cars or {}
CMOD_Cars_AUX = CMOD_Cars_AUX or {}
local t = CMOD_Cars_AUX -- lets give this another shot at making doubly sure that your custom cars don't get deleted when the master table loads
/*
//////// THIS IS FOR ADDING YOUR OWN CUSTOM CARS /////////
DO NOT OVERWRITE THIS FILE WHEN YOU UPDATE NOVACARS FROM SCRIPTFODDER OR YOU WILL LOSE YOUR CUSTOM VEHICLE SCRIPTS

/// EXAMPLE VEHICLE ///
t["bmwm3gtrtdm"] = {
	["Name"] = "BMW M3 GTR",
	["Passengers"] = { 
		[1] = { x = 17, y = 3, z = 16},
		[2] = { x = -17, y = 43, z = 18},
		[3] = { x = 17, y = 43, z = 18},
	},
	["DamageResist"] = 1,
	["Headlights"] = { Vector( 26.53, 98.06, 31.51 ), Vector( -26.53, 98.06, 31.51 ) },
	["TailLights"] = { Vector( 26.19, -104.95, 39.23 ), Vector( -26.19, -104.95, 39.23 ) },
	["EnginePos"] = Vector( 0, 72.1, 42.3 ),
}
*/


t["GTA4 Bobcat"] = {
	["Name"] = "GTA4 Bobcat",
	["Passengers"] = {
		[1] = { x = 20.27, y = -2.5, z = 29},
	},
	["DamageResist"] = 1.1,
	["Headlights"] = {
		[1] = Vector( 34.17, 116.94, 44.93 ),
		[2] = Vector( -34.17, 116.94, 44.93 ),
	},
	["EnginePos"] = Vector( 0, 74.01, 58.82 ),
	["WheelHeightFix"] = 0.077,
}

t["ram3500_tow"] = {
	["Name"] = "Dodge Ram 3500 Tow",
	["Passengers"] = {},
	["DamageResist"] = 1,
	["Headlights"] = {
--		[1] = { pos = Vector( 36.36, 128.63, 50 ), pair = true, col = Color( 255, 255, 245 ), size = 35, depth = 1.3},
	},
	["TailLights"] = {
--		[1] = { pos = Vector( 34.8, -151, 42.16 ), pair = true, col = Color( 255, 5, 5 ), size = 35, depth = 2 },
	},
	["EnginePos"] = Vector( 0, 108.35, 65.65 ),
	["WheelHeightFix"] = 0.097,
}
/*
t["supratdm"] = {
	["DamageResist"] = 0.95,
	["EnginePos"] = Vector( 0, 66.5938, 41.375 ), 
	["WheelHeightFix"] = -0.03,
	["Headlights"] = { 
		[1] = Vector( -24.0937, 100, 30),
		[2] = Vector( 24.0938, 100, 30 ),
	 },

	["Passengers"] = { 
		[1] = { ["y"] = 14, ["x"] = -17, ["z"] = 12,  },
		[2] = { ["y"] = 45, ["x"] = 17, ["z"] = 12,  },
		[3] = { ["y"] = 45, ["x"] = -17, ["z"] = 12,  },
	 },

	["Name"] = "Toyota Supra",
	["TailLights"] = { 
		[1] = Vector( 23.7813, -102.75, 40.375 ),
		[2] = Vector( -23.7812, -102.75, 40.375 ),
	 },

}
*/