NOVA_Config = {}

NOVA_Config.Language = "EN" -- available languages: EN (english), FR (french), DE (german)
NOVA_Config.DebugLogger = false -- enable logging debug data to console? recommended you only turn this on if you are trying to squash bugs and turn it off again for everyday usage

-- system settings
NOVA_Config.EnableHealthSystem = true -- enable novacars vehicle health system? disabling this will disallow damage to the hull or tyres of vehicles but will still allow passengers to be shot unless you disable CanShootPassengers
NOVA_Config.EnableSeatSysten = true -- enable novacars passengers system?
NOVA_Config.EnableModdingSystem = true -- enable installing car mods with the mechanics wrench?
NOVA_Config.EnableLightingSystem = true -- enable headlights?
NOVA_Config.EnableELS = true -- enable emergency lights/sirens?
NOVA_Config.EnableHorns = true -- can people beep their car horns?

NOVA_Config.BetterVehicleNetworking = false -- will thoroughly network all vehicle stats to all players at the cost of somewhat higher server bandwidth usage (disabled = only network vehicle table to players that enter that vehicle)
NOVA_Config.AlwaysEnterDriverSeatFirst = true -- any player that enters an empty vehicle will always be placed in the drivers seat, can be slightly buggy if disabled

-- car health/damage related stuff
NOVA_Config.DefaultTyreHealth = 50
NOVA_Config.CanPopTyres = true -- will tyres pop if they take enough damage?
NOVA_Config.CrashDamage = true -- do vehicles get damaged when you crash them into things?
NOVA_Config.CrashDamageMultiplier = 1 -- higher numbers make cars super fragile to crashing, should make people drive responsibly
NOVA_Config.BulletDamageMultiplier = 1 -- how tough cars are against bullet damage (only affects damage dealt to the vehicles actual hull, does NOT affect damage dealt to passengers or tyres)
NOVA_Config.ExplosiveDamageMultiplier = 5 -- how tough cars are against explosives
NOVA_Config.ProtectParkedVehicles = false -- anti griefing measure to stop shitheads from slashing your tyres or blowing your car up while its parked and empty
NOVA_Config.CarsCanCrushPlayers = false -- will cars deal damage to players if you run them over? keep in mind that cdm is already discouraged by the fact that cars are damaged by running people over
NOVA_Config.CarFixTime = 10 -- how long does it take for a mechanic to fix a car?
NOVA_Config.CanEnterDestroyedVehicles = false -- if false vehicles will eject all passengers when destroyed and will not allow anybody to enter them until they are fixed
NOVA_Config.ExplodeWhenDestroyed = false -- do vehicles blow up when they reach 0 health? this does not actually destroy the vehicle but it will damage/kill passengers and nearby players

-- engine related stuff
NOVA_Config.EnableManualEngineStarting = true -- do you want players to be able to manually start/stop car engines

-- gun related stuff
NOVA_Config.DrivebyShooting = true -- if set to true passengers can use their weapons to fire out the window [NOTE: Not compatible with FAS2 weapons because of the way they are coded]
NOVA_Config.DrivebyShootingGunRange = 50 -- how close to the exterior of the vehicle do you need to be to be able to shoot out? increasing this number will widen the field of fire for each seat
NOVA_Config.CanShootPassengers = true -- can bullets penetrate into cars and kill the passengers? recommended that you have this on if you have driveby shooting enabled
NOVA_Config.CanShootOwnCar = false -- will you damage your own car if you shoot it while sitting inside it?
NOVA_Config.BulletPenetrationIndex = 45 -- how deeply/likely bullets are to penetrate into vehicles, setting this higher will make it easier to shoot and kill passengers

NOVA_Config.SpeedLimit = 50 -- is in MPH
NOVA_Config.AllowThirdPerson = true -- allow third person while driving?
NOVA_Config.RestrictVehiclePickup = false -- stops people from picking up cars with physgun, enable this at your own risk as it can possibly interfere with other addons

NOVA_Config.MaxSpikeStripInventory = 10 -- how many spike strips can a player hold in inventory at once?

-- a list of weapons that you aren't allowed to use in a car, either because they malfunction badly or are unrealistic/unbalanced
NOVA_Config.DrivebyShootingRestrict2Handed = false -- automatically restrict the player from using 2 handed weapons in a vehicle (this uses SWEP.HoldType for detection)
NOVA_Config.DrivebyShootingDefaultWeapon = "keys" -- the default weapon players are switched to upon choosing a new seat
NOVA_Config.DrivebyShootingWeaponBlacklist = {
	"weapon_crossbow",
	"weapon_crowbar",
	"weapon_rpg",
	"weapon_physcannon",
	"weapon_physgun",
	"weapon_stunstick",
	"weapon_bugbait",
	"arrest_stick",
	"unarrest_stick",
	"stunstick",
	"nova_mechanic",
	"door_ram",
	"gmod_tool",
	"m9k_damascus",
	"m9k_davy_crockett",
	"m9k_ex41",
	"m9k_m202",
	"m9k_m79gl",
	"m9k_matador",
	"m9k_milkormgl",
	"m9k_orbital_strike",
	"m9k_rpg7",
}

NOVA_Config.MaxMods = 4 -- how many mods can be installed on a car at once?


-- Credits to Jean Foret for improving the french translation
NOVA_Config.TranslateStrings = {
 
    -- server
    ["noheadlights"] = { ["EN"] = "This vehicle doesn't have headlights!", ["FR"] = "Ce véhicule n'a pas de sirènes !", ["DE"] = "Dieses Fahrzeug hat keine Scheinwerfer!" },
    ["doorslocked"] = { ["EN"] = "Sorry, the driver of this vehicle has locked the doors!", ["FR"] = "Le conducteur de ce véhicule a verrouillé les portes !", ["DE"] = "Sorry, der Fahrer dieses Fahrzeuges hat die Türen geschlossen!" },
    ["carfull"] = { ["EN"] = "Sorry, this vehicle is full!", ["FR"] = "Désolé, Ce véhicule est plein !", ["DE"] = "Sorry, dieses Fahrzeug ist voll!" },
    ["cardestroyed"] = { ["EN"] = "This vehicle is destroyed!", ["FR"] = "Ce véhicule est détruit !", ["DE"] = "Dieses Fahrzeug ist zerstört!" },
    ["badweapon"] = { ["EN"] = "You can't use that weapon in a car!", ["FR"] = "Vous ne pouvez pas utiliser cette arme dans une voiture !", ["DE"] = "Du darfst diese Waffe nicht im Fahrzeug benutzten!" },
    ["alarm1"] = { ["EN"] = "Somebody is breaking into your car!", ["FR"] = "Quelqu'un essaie de voler votre voiture !", ["DE"] = "Jemand bricht in deinem Fahrzeug ein!" },
    ["alarm2"] = { ["EN"] = " is breaking into your car!", ["FR"] =  " Vole votre voiture !", ["DE"] = " bricht in dein Fahrzeug ein!" },
    ["cartheft"] = { ["EN"] = "Car Theft", ["FR"] = "Vol de voiture", ["DE"] = "Autodiebstahl" },
    ["imdriving"] = { ["EN"] = "You are already the driver!", ["FR"] = "Vous êtes déjà le conducteur", ["DE"] = "Du bist bereits der Fahrer!" },
    ["seatoccupied"] = { ["EN"] = "That seat is occupied by ", ["FR"] = "Cette place est occupé par ", ["DE"] = "Dieser sitzt wird bereits verwendet von " },
    ["modsdisabled"] = { ["EN"] = "Vehicle modding is disabled on this server!", ["FR"] = "La modification des véhicules est désactivé !", ["DE"] = "Das Modifizieren der Fahrzeuge ist auf diesen Server Deaktiviert!" },
    ["fullamods"] = { ["EN"] = "This vehicle cannot hold any more mods!", ["FR"] = "Ce véhicule a déjà atteint son maximum de modification!", ["DE"] = "Dieses Fahrzeug hat das Limit an Modifikationen erreicht!" },
    ["modinstalled"] = { ["EN"] = "This vehicle already has this mod!", ["FR"] = "Ce véhicule a déjà cette modification !", ["DE"] = "Dieses Fahrzeug das bereits diese Modifikation!" },
    ["poorfag"] = { ["EN"] = "You cannot afford to install this mod!", ["FR"] = "Vous ne pouvez vous permettre d'acheter cette modification", ["DE"] = "Du kannst dir diese Modifikation nicht leisten!" },
    ["addedmod"] = { ["EN"] = "Successfully installed ", ["FR"] = "Modification de voiture installée ", ["DE"] = "Erfolgreich Installiert: " },
    ["thiscarsucks"] = { ["EN"] = "This vehicle doesn't have this mod!", ["FR"] = "Ce véhicule n'a pas encore cette modification!", ["DE"] = "Dieses Fahrzeug hat diese Modifikation nicht!" },
    ["rmv1"] = { ["EN"] = "Successfully removed ", ["FR"] = "Modification enlevé ", ["DE"] = "Erfolgreich Entfernt: " },
    ["rmv2"] = { ["EN"] = " and sold it to the wreckers for $", ["FR"] = " et vender ce véhicule au dépôt pour $", ["DE"] = " und verkauft für $" },
    ["cantkick"] = { ["EN"] = "This player cannot be kicked from their seat!", ["FR"] = "This player cannot be kicked from their seat!", ["DE"] = "This player cannot be kicked from their seat!" }, -- TRANSLATE LATER
    ["kickedsomecunt"] = { ["EN"] = "You kicked ", ["FR"] = "You kicked ", ["DE"] = "You kicked " },  -- TRANSLATE LATER
    ["kickedsomecunt2"] = { ["EN"] = " out of your car", ["FR"] = " out of your car", ["DE"] = " out of your car" },  -- TRANSLATE LATER
    ["gotkicked"] = { ["EN"] = "You were kicked out of the vehicle!", ["FR"] = "You were kicked out of the vehicle!", ["DE"] = "You were kicked out of the vehicle!" },  -- TRANSLATE LATER
    ["emptyseat"] = { ["EN"] = "That seat is empty!", ["FR"] = "That seat is empty!", ["DE"] = "That seat is empty!" },  -- TRANSLATE LATER

    --client
    ["speed"] = { ["EN"] = "Speed: ", ["FR"] = "Vitesse: ", ["DE"] = "Geschwindigkeit: " },
    ["health"] = { ["EN"] = "Integrity: ", ["FR"] = "Santé: ", ["DE"] = "Leben: " },
    ["ownedby"] = { ["EN"] = "Owned by: ", ["FR"] = "Propriétaire: ", ["DE"] = "Besitzer: " },
    ["vmods"] = { ["EN"] = "Vehicle Mods: ", ["FR"] = "Mods de véhicules: ", ["DE"] = "Modifikationen: " },
    ["locks"] = { ["EN"] = "Door Locks", ["FR"] = "Verrou", ["DE"] = "Tür Schloss" },
    ["scruise"] = { ["EN"] = "Safe Cruise", ["FR"] = "Vitesse de sécurité", ["DE"] = "Tempomat" },
    ["hlights"] = { ["EN"] = "Headlights", ["FR"] = "Phares", ["DE"] = "Scheinwerfer" },
    ["mousesteer"] = { ["EN"] = "Mouse Steering", ["FR"] = "Direction avec souris", ["DE"] = "Maus-Lenkung" },
    ["options"] = { ["EN"] = "Options", ["FR"] = "Options", ["DE"] = "Einstellungen" },

    --options menu
    ["fxr"] = { ["EN"] = "FX Render Distance", ["FR"] = "Effets rendent la distance", ["DE"] = "FX Render Entfernung" },
    ["fxd"] = { ["EN"] = "FX Render Density", ["FR"] = "Effets rendent la densité", ["DE"] = "FX Render Dichte" },
    ["rskids"] = { ["EN"] = "Render Skids?", ["FR"] = "Dérapage ?", ["DE"] = "Render Skids?" },
    ["skidd"] = { ["EN"] = "Skid Duration", ["FR"] = "Durée du dérapage", ["DE"] = "Skid Dauer" },
    ["wfx"] = { ["EN"] = "Wheel FX", ["FR"] = "Effets de la roue", ["DE"] = "Reifen FX" },
    ["dhd"] = { ["EN"] = "Dynamic Headlights", ["FR"] = "Phares dynamiques", ["DE"] = "Dynamische Scheinwerfer" },
    ["shd"] = { ["EN"] = "Show Driver", ["FR"] = "Voir le conducteur", ["DE"] = "Zeige Fahrer" },
    ["msp"] = { ["EN"] = "Metric Speed", ["FR"] = "Vitesse métrique", ["DE"] = "Metric Geschwindigkeit" },
    ["mss"] = { ["EN"] = "Mouse Driving Sensitivity", ["FR"] = "Sensibilité de la conduite avec souris", ["DE"] = "Maus-Lenkung Empfindlichkeit" },
    ["reset"] = { ["EN"] = "Reset all to Defaults", ["FR"] = "Réinitialiser les paramètres par défaut", ["DE"] = "Alles Zurücksetzen" },   
    ["idrive"] = { ["EN"] = "Immersive Driving Cam", ["FR"] = "Immersive Driving Cam", ["DE"] = "Immersive Fahr-Kamera" },  -- TRANSLATE LATER
    ["3dhud"] = { ["EN"] = "3D HUD", ["FR"] = "3D HUD", ["DE"] = "3D HUD" }, -- TRANSLATE LATER

 	-- mods
 	["nostank"] = { ["EN"] = "Provides a short speed boost (shift to activate)", ["FR"] = "Améliore la vitesse de votre voiture avec un peu de NITRO ( SHIFT pour utiliser )", ["DE"] = "Gibt einen Kurzen Schnelligkeit Boost (SCHIFT zum Aktivieren)" },  
 	["polycarb"] = { ["EN"] = "+20% Bullet resistance", ["FR"] = "+20% de résistance aux balles", ["DE"] = "+20% Kugeln Widerstand" },  
 	["chassis"] = { ["EN"] = "+25% Crash resistance", ["FR"] = "+25% de résistance aux crash", ["DE"] = "+25% Stoß Widerstand" }, 
  	["tyres"] = { ["EN"] = "3X Tyre health", ["FR"] = "3X Vie des pneus", ["DE"] = "3X Reifen Widerstand" },  
  	["bpglass"] = { ["EN"] = "Can't shoot in, can't shoot out either", ["FR"] = "Vitre par balle, résistance aux balles", ["DE"] = "Kann nicht mehr ins Auto geschossen werde, genauso wie nach drausen" }, 
  	["jacked"] = { ["EN"] = "Better offroad ability", ["FR"] = "Meilleure conduite (hors route)", ["DE"] = "Bessere Straßen Festigkeit" }, 
  	["modalarm1"] = { ["EN"] = "Alerts you when somebody is breaking into your car", ["FR"] = "Alarme anti-vol", ["DE"] = "Meldet sich bei dir wenn jemand in dein Fahrzeug einbricht" }, 
  	["modalarm2"] = { ["EN"] = "Alerts you and the police when somebody lockpicks your car", ["FR"] = "Alarme anti-vol qui vous appelera la police et vous en cas de vol", ["DE"] = "Meldet es der Polizei und dir wenn jemand in dein Fahrzeug einbricht" }, 
  	["boostjump"] = { ["EN"] = "Launch your vehicle up into the air (Left Alt to activate)", ["FR"] = "Launch your vehicle up into the air (shift to activate)", ["DE"] = "Bringen sie ihr Fahrzeug in die luft. (SCHIFT zum akivieren)" },   -- TRANSLATE LATER

  	--customcheck
  	["alarminstalled"] = { ["EN"] = "This vehicle already has an alarm system!", ["FR"] = "Ce véhicule est déjà équipé d'une alarme !", ["DE"] = "Dieses Fahrzeug hat bereits ein Alarmsystem!" },
  	["fatfuck"] = { ["EN"] = "This vehicle is too heavy to support nitrous! (Must be less than 3 tons)", ["FR"] = "Ce véhicule est trop lourd pour supporter du nitro !", ["DE"] = "Dieses Fahrzeug ist zu schwer um Nitro zu unterstützen! (Muss weniger als 3 Tonnen wiegen)" },
}


function NOVA_GetTranslatedString( str )
	local lang = NOVA_Config.Language or "EN"
	if NOVA_Config.TranslateStrings[str] and NOVA_Config.TranslateStrings[str][lang] then 
		return NOVA_Config.TranslateStrings[str][lang] 
	else
		return "Translation error: no translation found for "..str.." in language: "..lang
	end
end


NOVA_Mods = {
	["NOS Tank"] = {
		["Desc"] = NOVA_GetTranslatedString( "nostank" ),
		["Cost"] = 250,
		["Col"] = Color( 155, 155, 255 ),
		["CustomCheck"] = function( ply, car ) if (car:GetVehicleParams().body.massOverride / 1000) >= 3 then return false, NOVA_GetTranslatedString( "fatfuck" ) else return true end end,
	},
	["Polycarb Shell"] = {
		["Desc"] = NOVA_GetTranslatedString( "polycarb" ),
		["Cost"] = 300,
	},
	["Reinforced Chassis"] = {
		["Desc"] = NOVA_GetTranslatedString( "chassis" ),
		["Cost"] = 180,
	},
	["Bulletproof Tyres"] = {
		["Desc"] = NOVA_GetTranslatedString( "tyres" ),
		["Cost"] = 200,
	},
	["Bulletproof Glass"] = {
		["Desc"] = NOVA_GetTranslatedString( "bpglass" ),
		["Cost"] = 100,
	},
	["Jacked Suspension"] = {
		["Desc"] = NOVA_GetTranslatedString( "jacked" ),
		["Cost"] = 100,
	},

	["Alarm System Tier 1"] = {
		["Desc"] = NOVA_GetTranslatedString( "modalarm1" ),
		["Cost"] = 50,
		["Col"] = Color( 255, 255, 155 ),
		["CustomCheck"] = function( ply, car ) if car:CMGetInstalledMods()["Alarm System Tier 2"] then return false, NOVA_GetTranslatedString( "alarminstalled" ) else return true end end,
	},
	["Alarm System Tier 2"] = {
		["Desc"] = NOVA_GetTranslatedString( "modalarm2" ),
		["Cost"] = 350,
		["Col"] = Color( 255, 255, 155 ),
		["CustomCheck"] = function( ply, car ) if car:CMGetInstalledMods()["Alarm System Tier 1"] then return false, NOVA_GetTranslatedString( "alarminstalled" ) else return true end end,
	},

	["Boost Jump"] = {
		["Desc"] = NOVA_GetTranslatedString( "boostjump" ),
		["Cost"] = 400,
		["Col"] = Color( 155, 255, 155 ),
		["CustomCheck"] = function( ply, car ) if (car:GetVehicleParams().body.massOverride / 1000) >= 3 then return false, NOVA_GetTranslatedString( "fatfuck" ) else return true end end,
	},
-- test, ignore for now
/*
	["Car Bomb"] = {
		["Desc"] = "Trigger from Q menu to begin the countdown",
		["Cost"] = 300,
		["Col"] = Color( 255, 155, 155 ),
	},
	["Ignition Bomb"] = {
		["Desc"] = "Boobytrap this car to explode!",
		["Cost"] = 500,
		["Col"] = Color( 255, 105, 105 ),
	},
*/
}