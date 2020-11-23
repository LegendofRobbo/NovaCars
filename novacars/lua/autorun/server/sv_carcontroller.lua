util.AddNetworkString("SendCarStats")
util.AddNetworkString("RequestSeat")
util.AddNetworkString("KickSeat")
util.AddNetworkString("CMKickPassengers")
util.AddNetworkString("CMToggleDoorLocks")
util.AddNetworkString("NovaRemoveMod")
util.AddNetworkString("CMNOSBoost")
util.AddNetworkString("CMStopSirenSound")
util.AddNetworkString("NCSendVehicleTableUpdate")
util.AddNetworkString("NCUploadMasterTable")

resource.AddWorkshop( "775595229" )

local debugmode = CreateConVar( "carmod_debug_seats", "0", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE} )

local veh = FindMetaTable( "Entity" )
local playa = FindMetaTable( "Player" )

local function VehicleCrashDamage( ent, data )
	if !NOVA_Config.CrashDamage or ( NOVA_Config.ProtectParkedVehicles and ent:CMIsEmptyVehicle() ) then return end
	if !NOVA_Config.CarsCanCrushPlayers and data.HitEntity:IsValid() and data.HitEntity:IsPlayer() then return end
	if !NOVA_Config.EnableHealthSystem then return end

	if data.Speed > 200 and data.HitEntity:IsNovaCar() and not (ent.NxCrashSpark and ent.NxCrashSpark > CurTime()) then
		local ed = EffectData()
		ed:SetOrigin( data.HitPos )
		ed:SetScale( .1 )
		ed:SetRadius( 5 )
		ed:SetMagnitude( 3 )
		util.Effect( "Sparks", ed )
		ent.NxCrashSpark = CurTime() + 0.5
	end

	if data.Speed > 400 then
		if data.HitNormal.z < -0.9 then return end
		if data.HitEntity:IsValid() and data.HitEntity:IsPlayerHolding() or data.HitEntity:GetClass() == "nova_spikestrip" or (data.HitEntity.NxtCrash and data.HitEntity.NxtCrash > CurTime()) then return end
		if data.HitEntity:IsValid() then data.HitEntity.NxtCrash = CurTime() + 0.2 end
		local oldhp = ent:GetNWFloat("VehicleHealth")
		local damage = (data.Speed * 0.4) * NOVA_Config["CrashDamageMultiplier"]
		if ent:CMGetInstalledMods()["Reinforced Chassis"] then damage = damage * 0.75 end
		ent:EmitSound( "physics/metal/metal_barrel_impact_hard"..math.random(1,3)..".wav", 100, math.random( 130, 160 ) )

		if data.HitEntity:IsValid() and (data.HitEntity:IsPlayer() or data.HitEntity:IsNPC()) then
			local p = data.HitEntity
			if ent.NextPlayerCrush and ent.NextPlayerCrush > CurTime() then return end
			data.HitEntity:EmitSound( "physics/body/body_medium_break"..math.random(2,4)..".wav", 100, 80 ) 
			ent.NextPlayerCrush = CurTime() + 0.05
		end
		DamageVehicle( ent, damage )
	end
end

local function SetupVehicleHealth( ent )
	if ent:IsNovaCar() then
		timer.Simple(0.04, function() if ent:IsValid() then ent:NCInitializeVehicle() end end)
		timer.Simple(0.1, function() if ent:IsValid() then ent:NCInitializeVehicle() end end) -- make doubly sure we initialized properly
	end
end
hook.Add("OnEntityCreated", "SetupVehicleHealth", SetupVehicleHealth, -10 )


local function SaveVehicleTable()
	local json = util.TableToJSON( CMOD_Cars )
	if !json then return end
	local compress = util.Compress( json )
	file.Write( "novacars/vdata.dat", compress )
end

concommand.Add( "novacars_savedata_test", function( ply, cmd, args )
	if !ply:IsValid() or !ply:IsSuperAdmin() then return end
	SaveVehicleTable()
	ply:ChatPrint( "Saved NovaCars vehicle data to garrysmod/data/novacars/vdata.dat" )

end)


function playa:NetworkNovacarsVTable( data )
	if !self:IsValid() then return end
	net.Start( "NCSendVehicleTableUpdate" )
	net.WriteUInt( #data, 32 )
	net.WriteData( data, #data )
	net.Send( self )
end

local vtablecompressed = ""

local function LoadVehicleTable()
	local f = file.Read( "novacars/vdata.dat", "DATA" )
	if !f then
		-- annoy everybody with massive error spew
		for k, v in pairs( player.GetAll() ) do
			v:ChatPrint( "NOVACARS CRITICAL ERROR: data/novacars/vdata.dat does not exist!\nCheck the install instructions you got when you downloaded the addon from scriptfodder!") 
		end
		print( "NOVACARS CRITICAL ERROR: data/novacars/vdata.dat does not exist!\nCheck the install instructions you got when you downloaded the addon from scriptfodder!") 
		return 
	end
	vtablecompressed = f
	local raw = util.Decompress( f )
	local tab = util.JSONToTable( raw )
	CMOD_Cars = tab
	table.Merge( CMOD_Cars, CMOD_Cars_AUX )

	for k, v in pairs( player.GetAll() ) do
		timer.Simple( k * 0.5, function() v:NetworkNovacarsVTable( f ) end)
	end
end

hook.Add( "InitPostEntity", "geeireallyfuckinghopethisworks", LoadVehicleTable )
local loadedourshit = false
hook.Add( "PlayerInitialSpawn", "butifitdoesntworkthenthiswill", function( ply ) 
	if !loadedourshit then
		LoadVehicleTable()
		loadedourshit = true
	end
	timer.Simple( 1, function()
		if ply:IsValid() then ply:NetworkNovacarsVTable( vtablecompressed ) end
	end )
end )

concommand.Add( "novacars_loaddata_test", function( ply, cmd, args )
	if !ply:IsValid() or !ply:IsSuperAdmin() then return end
	LoadVehicleTable()
	ply:ChatPrint( "Loaded NovaCars vehicle data" )
end)


local function ToggleHeadlights( ply )
if !ply:IsValid() or !ply:Alive() or !ply:GetVehicle():IsValid() or !ply:GetVehicle().CmodStats or ply:GetVehicle().DestroyedCar or !NOVA_Config.EnableLightingSystem then return end
local car = ply:GetVehicle()
if !car:IsNovaCar() then return end
local r = CMOD_Cars[car:GetVehicleClass()]
if r and r.NoHeadlights then ply:NCNotify( NOVA_GetTranslatedString( "noheadlights" ), 1 ) return end
car:SetNWBool( "Headlights", !car:GetNWBool( "Headlights", false ) )
end
concommand.Add( "nova_toggleheadlights", ToggleHeadlights )

local function ToggleDoorLocks( ply )
if !ply:IsValid() or !ply:Alive() or !ply:GetVehicle():IsValid() or !ply:GetVehicle().CmodStats then return end
local car = ply:GetVehicle()
if !car:IsNovaCar() then return end
local locked = car:GetSaveTable().VehicleLocked
if locked then
	car:Fire("unlock", "", 0)
	car:EmitSound( "doors/door_latch3.wav", 80, 100 )
	if DarkRP then hook.Call("onKeysUnlocked", nil, car) end
else
	car:Fire("lock", "", 0)
	car:EmitSound("npc/metropolice/gear" .. math.floor(math.Rand(1,7)) .. ".wav")
	if DarkRP then hook.Call("onKeysLocked", nil, car) end
end

end
concommand.Add( "nova_toggledoorlocks", ToggleDoorLocks )


local function HonkHonk( ply )
if !ply:IsValid() or !ply:Alive() or !ply:GetVehicle():IsValid() or !ply:GetVehicle().CmodStats or ply:GetVehicle().DestroyedCar then return end
if !NOVA_Config.EnableHorns then return end
local car = ply:GetVehicle()
if !car:IsNovaCar() or (car.NextHorn and car.NextHorn > CurTime()) then return end
local horn = 1
local hornpitch = 100
local r = CMOD_Cars[car:GetVehicleClass()]
if r and r.Horn then horn = r.Horn end
if r and r.HornPitch then hornpitch = r.HornPitch end
if r and r.Horn == -1 then return end
if car:GetNWBool( "Sirens", false ) then
	car:EmitSound( "novacars/siren_pulse_short.wav", 80, 100 )
	car.NextHorn = CurTime() + 0.3
else
	car:EmitSound( "novacars/horn"..horn..".wav", 80, hornpitch )
	car.NextHorn = CurTime() + 0.5
end
end
concommand.Add( "nova_horn", HonkHonk )


local function ToggleSirens( ply )
if !ply:IsValid() or !ply:Alive() or !ply:GetVehicle():IsValid() or !ply:GetVehicle().CmodStats or ply:GetVehicle().DestroyedCar or !NOVA_Config.EnableELS then return end
local car = ply:GetVehicle()
if !car:IsNovaCar() then return end
local r = CMOD_Cars[car:GetVehicleClass()]
if !r or !r.Sirens then return end
local b = car:GetNWBool( "Sirens", false )
if !b then 
	car:SetNWBool( "Sirens", true )
else
	car:SetNWBool( "Sirens", false )
end

end
concommand.Add( "nova_togglesirens", ToggleSirens )


-- new siren system
local function SetSirenMode( ply, cmd, args )
if !ply:IsValid() or !ply:Alive() or !ply:GetVehicle():IsValid() or !ply:GetVehicle().CmodStats or ply:GetVehicle().DestroyedCar or !NOVA_Config.EnableELS then return end
local car = ply:GetVehicle()
if !car:IsNovaCar() or ( car.NxSirenToggle and car.NxSirenToggle > CurTime() ) then return end
local r = CMOD_Cars[car:GetVehicleClass()]
if !r or !r.Sirens then return end
local argn = tonumber(args[1])
if !argn then return end
if argn < 0 or argn > 4 then return end
local argn2 = tonumber(args[2])
if !argn2 then return end
if argn2 < 0 or argn2 > 3 then return end

car.CmodStats.SirenState = {
	["Sound"] = argn,
	["Lights"] = argn2,
}
car:CMNetworkStatsBroadcast() -- the siren state always needs to be broadcast otherwise people won't see your sirens properly
net.Start( "CMStopSirenSound" )
net.WriteEntity( car )
net.Broadcast()

car.NxSirenToggle = CurTime() + 0.2

end
concommand.Add( "nova_setsirenmode", SetSirenMode )



local function BoostJump( ply )
if !ply:IsValid() or !ply:Alive() or !ply:GetVehicle():IsValid() or !ply:GetVehicle().CmodStats or ply:GetVehicle().DestroyedCar then return end
local car = ply:GetVehicle()
if !car:IsNovaCar() or !car:CMGetInstalledMods()["Boost Jump"] or (car.NextBJump and car.NextBJump > CurTime()) or car:WaterLevel() > 2 or !car:NCIsEngineStarted() then return end
local wcount = 0
for i = 0, car:GetWheelCount() - 1 do 
	if wcount >= 2 then break end
	local cps, cnum, ctouch = car:GetWheelContactPoint( i )
	if ctouch then wcount = wcount + 1 end
end
if wcount < 2 then return end

local effectdata = EffectData()
effectdata:SetOrigin( car:GetPos() + Vector(0,0,30) )
effectdata:SetMagnitude(20)
effectdata:SetScale(200)
util.Effect( "HelicopterMegaBomb", effectdata )
util.Effect( "ThumperDust", effectdata )
car:EmitSound( "npc/combine_gunship/attack_stop2.wav", 100, 150 )
 
car.NextBJump = CurTime() + 10
car:GetPhysicsObject():AddVelocity( (car:GetAngles():Right() * -350 + car:GetAngles():Up() * 500) )

end
concommand.Add( "nova_boostjump", BoostJump )



local function StartCar( ply )
if !NOVA_Config.EnableManualEngineStarting then return end
if !ply:IsValid() or !ply:Alive() or !ply:GetVehicle():IsValid() or !ply:GetVehicle().CmodStats or ply:GetVehicle().DestroyedCar then return end
local car = ply:GetVehicle()
if !car:IsNovaCar() or car:WaterLevel() > 2 or car:IsEngineStarted() or (car.NxStart and car.NxStart > CurTime()) then return end
car:EmitSound( "novacars/startup1.wav" )
car.NxStart = CurTime() + 0.5
timer.Simple( 0.8, function()
	if car:IsValid() then
		car:SetNWBool( "NCEngineOn", true )
		car:StartEngine( true )
	end
end)
end
concommand.Add( "nova_startcar", StartCar )

local function StopCar( ply )
if !NOVA_Config.EnableManualEngineStarting then return end
if !ply:IsValid() or !ply:Alive() or !ply:GetVehicle():IsValid() or !ply:GetVehicle().CmodStats or ply:GetVehicle().DestroyedCar then return end
local car = ply:GetVehicle()
if !car:IsNovaCar() then return end
car:SetNWBool( "NCEngineOn", false )
car:StartEngine( false )
end
concommand.Add( "nova_stopcar", StopCar )

local function SendVStatsOnEnter( ply, car )
	if car:IsNovaCar() and NOVA_Config.EnableManualEngineStarting and !car:GetNWBool( "NCEngineOn", false ) then timer.Simple( 0.05, function() if car:IsValid() then car:StartEngine( false ) end end) end
	if car:IsNovaCar() and car.DestroyedCar and ply:IsValid() then ply:ExitVehicle() ply:NCNotify( NOVA_GetTranslatedString( "cardestroyed" ), 1 ) end
	if car.CmodStats then
		car:CMNetworkStats()
	end
end
hook.Add("PlayerEnteredVehicle", "SendSCOnEnter", SendVStatsOnEnter, -5)


local function AutoSelectSeat( ply, car )
	if !ply:IsValid() or !ply:Alive() or !car:IsValid() or !car:IsVehicle() or !car.CmodStats then return end
	if DarkRP and car:isLocked() then ply:NCNotify( NOVA_GetTranslatedString( "doorslocked" ), 1 ) return end
	local seats = car.CmodSeats
	local nseats = {}
	local fseat = false
	local notfull = false
	local newent = game.GetWorld()
	for k, v in pairs( car:CMGetAllPassengers() ) do
		if !v:IsValid() then notfull = true break end
	end
	if !notfull then ply:NCNotify( NOVA_GetTranslatedString( "carfull" ), 1 ) return end

	for k, v in pairs( seats ) do
		nseats[v:GetPos()] = v
	end

	if !car:GetDriver():IsValid() then
		nseats[car:GetPassengerSeatPoint( 1 )] = car
		if NOVA_Config.AlwaysEnterDriverSeatFirst then ply:EnterVehicle(car) return end
	end

	table.sort(nseats,function(a,b) return a:Distance(ply:GetPos()) < b:Distance(ply:GetPos()) end)

	for pos, ent in pairs( nseats ) do
		if !ent:IsValid() or ent:GetDriver():IsValid() or pos:Distance(ply:GetPos()) > 120 then continue end
		ply:CMEnableDrivebyShooting(ent)
		ply:EnterVehicle(ent)
		ply:SelectWeapon( NOVA_Config.DrivebyShootingDefaultWeapon )
		car:CMNetworkStats()
		fseat = true
		newent = ent
		break
	end

	if newent:IsValid() then return newent end

end

local function EnterCarSeats( ply, car )
if !ply:Alive() or !car:IsVehicle() or (ply.NxtVehicleEnter and ply.NxtVehicleEnter > CurTime() ) then return end
if !NOVA_Config.CanEnterDestroyedVehicles and car.DestroyedCar then return end
if car.CmodStats and car.CmodSeats then ply.NxtVehicleEnter = CurTime() + 1 return AutoSelectSeat( ply, car ) end
end

hook.Add( "FindUseEntity", "EnterCarSeats", EnterCarSeats, -10)

hook.Add( "CanPlayerEnterVehicle", "NOVA_EnterVehicle", function(ply, car, r)
	if !NOVA_Config.CanEnterDestroyedVehicles and car.DestroyedCar then ply:NCNotify( NOVA_GetTranslatedString( "cardestroyed" ), 1 ) return false end
end, -5) 

hook.Add( "PlayerLeaveVehicle", "DrivebyStuff", function(ply, car)
	ply:SetAllowWeaponsInVehicle( false ) 
	ply.NxtVehicleEnter = CurTime() + 1
	if car:IsNovaCar() or car.ParentVehicle then ply:EmitSound( "novacars/doorslam2.wav", 80, math.random(95, 105)) end
	timer.Simple(0.05, function()
		if !car:IsValid() then return end
		if car.ParentVehicle then car = car.ParentVehicle end
		if car:IsNovaCar() and NOVA_Config.EnableManualEngineStarting and car:GetNWBool( "NCEngineOn", false ) then car:SetHandbrake( false ) end
		if car:IsValid() and car:IsNovaCar() and car:CMIsEmptyVehicle() then 
			if !car:GetNWBool( "NCEngineOn", false ) then car:SetNWBool( "Headlights", false ) end
			car:SetNWBool( "NCTailLights", false )
		end 
	end)
end)

local goodholdtypes = {
	"pistol",
	"grenade",
	"normal",
	"fist",
	"knife",
	"camera",
	"revolver",
}

local function BlockRestrictedWeapons( ply, old, new )
if !ply:IsValid() or !ply:Alive() or !ply:InVehicle() then return end
if table.HasValue( NOVA_Config.DrivebyShootingWeaponBlacklist, new:GetClass() ) or (NOVA_Config.DrivebyShootingRestrict2Handed and !table.HasValue( goodholdtypes, new:GetHoldType() ) ) then
	ply:NCNotify( NOVA_GetTranslatedString( "badweapon" ), 1 )
	return true 
end
end
hook.Add( "PlayerSwitchWeapon", "NOVA_FixDrivebyGuns", BlockRestrictedWeapons )



hook.Add( "lockpickStarted", "NOVA_CarAlarms", function( ply, car, tr )
	if car:IsNovaCar() and car:getDoorOwner() and car:getDoorOwner():IsValid() and ply != car:getDoorOwner() then
		if car:CMGetInstalledMods()["Alarm System Tier 1"] then 
			car:getDoorOwner():NCNotify( NOVA_GetTranslatedString( "alarm1" ), 1 )
			car:getDoorOwner():SendLua( [[surface.PlaySound("npc/attack_helicopter/aheli_damaged_alarm1.wav")]] )
			sound.Play( "npc/attack_helicopter/aheli_damaged_alarm1.wav", car:GetPos(), 100, 100, 1 )
		end
		if car:CMGetInstalledMods()["Alarm System Tier 2"] then
			car:getDoorOwner():NCNotify( ply:Nick()..NOVA_GetTranslatedString( "alarm2" ), 1 )
			ply:wanted(game.GetWorld(), NOVA_GetTranslatedString( "cartheft" ), GAMEMODE.Config.wantedtime)
			car:getDoorOwner():SendLua( [[surface.PlaySound("npc/attack_helicopter/aheli_damaged_alarm1.wav")]] )
			sound.Play( "npc/attack_helicopter/aheli_damaged_alarm1.wav", car:GetPos(), 100, 100, 1 )
		end
	end
end, -1)

local function ApplyPassengerDamage( ent, dmg )
if !ent:IsValid() or !ent.CmodSeats or #ent.CmodSeats < 1 then return end
	if ent:CMGetInstalledMods()["Bulletproof Glass"] then return end
	local p = dmg:GetDamagePosition()
	local d, a, i = dmg:GetDamage(), dmg:GetAttacker(), dmg:GetInflictor()
	-- apply the damage to the driver
	if ent:GetDriver():IsValid() and p:Distance( ent:GetDriver():EyePos() ) < NOVA_Config.BulletPenetrationIndex then 
		local dd = DamageInfo()
		dd:SetDamage( d * (3000 * ent.CmodStats.DamageResist) )
		dd:SetInflictor( i )
		dd:SetAttacker( a )
		dd:SetDamageType( DMG_BULLET )
		ent:GetDriver():TakeDamageInfo( dd )
		return 
	end
	-- driver wasn't hit so check if it was one of the passengers instead
	for k, v in pairs(ent.CmodSeats) do
		if !v:GetDriver():IsValid() then continue end
		local p2 = v:GetPos()
		if p:Distance( p2 ) < NOVA_Config.BulletPenetrationIndex then v:TakeDamage(d * (3000 * ent.CmodStats.DamageResist), a, i) break end
	end
end



local function ApplyCarDamage( ent, dmg )

if !NOVA_Config.CarsCanCrushPlayers then
	if ent:IsPlayer() then
		if dmg:GetInflictor():IsValid() and dmg:GetInflictor():IsVehicle() then return true end
		if !dmg:GetAttacker():IsValid() and !dmg:GetInflictor():IsValid() and (dmg:GetDamageType() == 1 or dmg:GetDamageType() == 17) then return true end
	end
end

if !ent:IsVehicle() or string.lower(ent:GetClass()) == "prop_vehicle_prisoner_pod" then return end

if ent:GetNWFloat("VehicleHealth") then
	local damage = dmg:GetDamage()
	local atk = dmg:GetAttacker()

	if !NOVA_Config.CanShootOwnCar and atk:IsValid() and atk:IsPlayer() and ent:CMPlayerInVehicle( atk ) and !dmg:IsExplosionDamage() then return true end
	if NOVA_Config.ProtectParkedVehicles and ent:CMIsEmptyVehicle() then return true end

	if dmg:IsBulletDamage() then
		local newdamage = (damage * 5000)
		damage = (damage * 5000) * NOVA_Config.BulletDamageMultiplier
		if ent:CMGetInstalledMods()["Polycarb Shell"] then damage = damage * 0.8 end
		if NOVA_Config.CanShootPassengers then ApplyPassengerDamage( ent, dmg ) end
		if !NOVA_Config.EnableHealthSystem then return true end
		if NOVA_Config.CanPopTyres then
			local p = dmg:GetDamagePosition()
			for i = 1, ent:GetWheelCount() do 
				local wpos = ent:GetWheel( i - 1 ):GetPos()
				if p:Distance( wpos ) < (ent:GetWheelTotalHeight( i - 1 ) * 3) then ent:ApplyTyreDamage( i - 1, newdamage ) end
			end
		end
	end
	if dmg:IsExplosionDamage() then damage = (damage * NOVA_Config.ExplosiveDamageMultiplier) end

	DamageVehicle( ent, damage )
	ent:TakePhysicsDamage( dmg )
	return true
end

end
hook.Add( "EntityTakeDamage", "ApplyCarDamage", ApplyCarDamage, -2)

function DamageVehicle( ent, dmg )
	if !ent:IsValid() or !ent:IsVehicle() or string.lower(ent:GetClass()) == "prop_vehicle_prisoner_pod" or ent.DestroyedCar or !ent.CmodStats then return end
	local hp = ent:GetNWFloat("VehicleHealth")
	dmg = dmg * ent.CmodStats.DamageResist
	ent:SetNWFloat("VehicleHealth", hp - dmg )
	if (hp - dmg) < 0.1 and !ent.DestroyedCar then
		if !NOVA_Config.CanEnterDestroyedVehicles then
			for k, v in pairs(ent:CMGetAllPassengers()) do
				if v:IsValid() and v:IsPlayer() then v:ExitVehicle() end
			end
		end
		if NOVA_Config.ExplodeWhenDestroyed then
			local boom = ents.Create( "env_explosion" )
			boom:SetPos( ent:GetPos() + ent:GetAngles():Up() * 20 )
			boom:SetOwner( ent )
			boom:Spawn()
			boom:SetKeyValue( "iMagnitude", "160" )
			boom:Fire( "Explode", 0, 0 )
		end
		ent:SetNWBool( "Sirens", false )
		ent:SetNWBool( "Headlights", false )
		if ent.SirenSound then ent.SirenSound:Stop() end
		timer.Remove( "SirenTimer"..ent:EntIndex() )
		ent:Fire("TurnOff")
		ent:EnableEngine( false )
		ent:EmitSound("ambient/machines/spindown.wav")
		ent.DestroyedCar = true
		if NOVA_Config.EnableManualEngineStarting then ent:SetNWBool( "NCEngineOn", false ) end
	end
end

local function RequestSeat( ply, seat )
if !ply:IsValid() or !ply:Alive() then return end
local car = ply:GetVehicle()
if !car or !car:IsValid() then return end
NOVA_DebugLog( "Player "..ply:Nick().."Requested seat "..seat.." in vehicle "..car:EntIndex() )

--PrintTable( car.CmodSeats )
local currentseatnum = 1
if car.CmodStats and car.CmodStats.Seat and car.ParentVehicle and car.ParentVehicle.CmodSeats then 
	for k, v in pairs( car.ParentVehicle.CmodSeats ) do
		if v == car then currentseatnum = k + 1 break end
	end
end
local canchange, nmsg = hook.Call( "NOVA_CanChangeSeat", nil, ply, currentseatnum, seat )
if isbool(canchange) and !canchange then ply:NCNotify( nmsg ) return end

-- entering the drivers seat
if car:IsNovaCar() then 
	if seat == 1 then ply:NCNotify( NOVA_GetTranslatedString( "imdriving" ), 1 ) return end

	if !car.CmodSeats then return end
	local seatent = car.CmodSeats[seat - 1]
	if !seatent or !seatent:IsValid() then return end
	if seatent:GetDriver():IsValid() then ply:NCNotify( NOVA_GetTranslatedString( "seatoccupied" )..seatent:GetDriver():Nick(), 1 ) return end

	ply:ExitVehicle()
	ply:CMEnableDrivebyShooting( seatent )
	ply:SelectWeapon( NOVA_Config.DrivebyShootingDefaultWeapon )
	ply:EnterVehicle(seatent)
	NOVA_DebugLog( "Player "..ply:Nick().." moved to driver's seat in vehicle "..car:EntIndex() )

-- this is a passenger seat, not a car
elseif car.CmodStats and car.CmodStats.Seat then
	local parent = car.ParentVehicle
	local seatent = parent
	if seat != 1 then seatent = parent.CmodSeats[seat - 1] end

	if !seatent or !seatent:IsValid() then return end
	if seatent:GetDriver():IsValid() then ply:NCNotify( NOVA_GetTranslatedString( "seatoccupied" )..seatent:GetDriver():Nick(), 1 ) return end
	ply:ExitVehicle()
	if seat != 1 then ply:CMEnableDrivebyShooting( seatent ) end
	ply:SelectWeapon( NOVA_Config.DrivebyShootingDefaultWeapon ) 
	ply:EnterVehicle(seatent)
	NOVA_DebugLog( "Player "..ply:Nick().." moved to seat "..tostring(seat + 1).." in vehicle "..car:EntIndex() )
end

end

net.Receive( "RequestSeat", function( len, ply )
if !ply:IsValid() or !ply:Alive() or !ply:InVehicle() then return end
local seat = net.ReadUInt( 8 )
RequestSeat( ply, seat )
end)

concommand.Add("nova_changeseat", function( ply, cmd, args ) 
	if !ply:IsValid() or !ply:Alive() or !ply:InVehicle() or !args[1] then return end
	local seat = tonumber(args[1])
	if !seat then return end
	RequestSeat( ply, seat )
end)


net.Receive( "NCUploadMasterTable", function( len, ply )
if !ply:IsValid() or !ply:IsSuperAdmin() then return end
local class = net.ReadString()
local tab = net.ReadTable()
CMOD_Cars[ class ] = tab
ply:ChatPrint( "Uploaded vehiclescript: "..class.." to master table" )
end)



local function KickfromSeat( ply, seat )
if !ply:IsValid() or !ply:Alive() then return end
local car = ply:GetVehicle()
if !car or !car:IsValid() then return end

local currentseatnum = 1
if car.CmodStats and car.CmodStats.Seat and car.ParentVehicle and car.ParentVehicle.CmodSeats then 
	for k, v in pairs( car.ParentVehicle.CmodSeats ) do
		if v == car then currentseatnum = k + 1 break end
	end
end

if car:IsNovaCar() then
	local seatent = car.CmodSeats[seat - 1]

	if !seatent or !seatent:IsValid() then return end
	if !seatent:GetDriver():IsValid() then ply:NCNotify( NOVA_GetTranslatedString( "emptyseat" ), 1 ) return end
	local kicked = seatent:GetDriver()

	local canchange = hook.Call( "NOVA_CanKickFromVehicle", nil, ply, kicked, currentseatnum )
	if isbool(canchange) and !canchange then ply:NCNotify( NOVA_GetTranslatedString( "cantkick" ) ) return end

	kicked:ExitVehicle()
	ply:NCNotify( NOVA_GetTranslatedString( "kickedsomecunt" )..kicked:Nick()..NOVA_GetTranslatedString( "kickedsomecunt2" ) , 1 )
	kicked:NCNotify( NOVA_GetTranslatedString( "gotkicked" ), 1 )
	NOVA_DebugLog( "Player "..ply:Nick().." kicked "..kicked:Nick().." out of "..car:EntIndex() )
end

end

net.Receive( "KickSeat", function( len, ply )
if !ply:IsValid() or !ply:Alive() or !ply:InVehicle() then return end
local seat = net.ReadUInt( 8 )
KickfromSeat( ply, seat )
end)


function playa:CMEnableDrivebyShooting( seat )
	if !self:IsValid() or !seat:IsValid() or seat:GetClass() != "prop_vehicle_prisoner_pod" then return end
	if !seat.CmodStats.Noguns and NOVA_Config.DrivebyShooting and !seat.ParentVehicle:CMGetInstalledMods()["Bulletproof Glass"] then self:SetAllowWeaponsInVehicle( true ) end
end

function playa:NCNotify( msg, t )
	if DarkRP then 
		DarkRP.notify(self, t, 4, msg ) 
	else
		self:SendLua( [[notification.AddLegacy( "]]..msg..[[", ]]..t..[[, 4 )]] )
	end
end

function playa:NCGetMoney()
	if DarkRP then 
		return (self:getDarkRPVar("money") or 0)
	else
		-- sandbox has no money system so make mods free
		return 9999999
	end
end

function playa:NCAddMoney( money )
	if DarkRP then 
		self:addMoney( money )
	else
		return
	end
end

function veh:CMGetAllPassengers()
	if !self:IsValid() or !self:IsVehicle() then return end
	local ret = {}
	if self:GetDriver():IsValid() then ret["driver"] = self:GetDriver() else ret["driver"] = game.GetWorld() end

	if !self.CmodSeats then return ret end

	for k, v in pairs(self.CmodSeats) do
		if v:GetDriver() and v:GetDriver():IsValid() then ret[k] = v:GetDriver() else ret[k] = game.GetWorld() end
	end

	return ret

end

function veh:CMIsDamaged()
	if !self:IsValid() or !self:IsVehicle() then return false end
	if !self.CmodStats then return false end
	local dmg = false
	if self:GetNWFloat("VehicleHealth", 1000 ) < 999 then dmg = true end
	for k, v in pairs(self.CmodStats.Wheels) do
		if v < 99 then dmg = true break end
	end
	return dmg
end

function veh:CMIsEmptyVehicle()
	if !self:IsValid() or !self:IsVehicle() then return end
	local fags = self:CMGetAllPassengers()
	local empty = true
	for _, p in pairs(fags) do
		if p:IsValid() and p:IsPlayer() then empty = false break end
	end
	return empty
end

function veh:CMPlayerInVehicle( ply )
	if !self:IsValid() or !self:IsVehicle() or !ply:IsValid() then return false end
	if self:GetDriver():IsValid() and self:GetDriver() == ply then return true end
	local c = ply:GetVehicle()
	if !c:IsValid() then return false end -- they aren't in any car so they can't possibly be in this one
	if c.ParentVehicle and c.ParentVehicle == self then return true end
	return false
end

function veh:CMBlowTyre( i )
	if !self:IsValid() or !self:IsVehicle() then return end
	local tyre = self:GetWheel( i )
	if tyre:IsValid() then self:SetSpringLength( i , 499) self:EmitSound("weapons/pistol/pistol_fire3.wav", 150, math.random(50, 60)) end
end

function veh:CMFixVehicle()
	if !self:IsValid() or !self:IsVehicle() or !self.CmodStats or !self:IsNovaCar() then return end

	self:SetNWFloat("VehicleHealth", 1000)
	if self.DestroyedCar then self:Fire("TurnOn") self.DestroyedCar = false end
	local sph = 0
	local r = CMOD_Cars[self:GetVehicleClass()]
	if r and r.WheelHeightFix then sph = r.WheelHeightFix end
	if self:CMGetInstalledMods()["Jacked Suspension"] then sph = sph + 0.08 end

	for i = 0, self:GetWheelCount() - 1 do
		local tyre = self:GetWheel( i )

		if tyre:IsValid() then self:SetSpringLength( i , 500.18 + sph ) self.CmodStats.Wheels[i] = 100 end
	end

end

function veh:ApplyTyreDamage( t, dmg )
	if !self:IsValid() or !self:IsVehicle() or !self.CmodStats then return end
	local wheelhp = self.CmodStats.Wheels[t]
	dmg = dmg * self.CmodStats.DamageResist
	if self:CMGetInstalledMods()["Bulletproof Tyres"] then dmg = dmg / 3 end

	if wheelhp - dmg < 1 and wheelhp != -1 then 
		self.CmodStats.Wheels[t] = -1 
		self:CMBlowTyre( t )
	else 
		self.CmodStats.Wheels[t] = wheelhp - dmg
	end

	self:CMNetworkStats()
end

function veh:CMNetworkStats()
	if !self:IsValid() or !self:IsVehicle() or !self.CmodStats then return end
	if NOVA_Config.BetterVehicleNetworking then self:CMNetworkStatsBroadcast() return end
	for _, ply in pairs( self:CMGetAllPassengers() ) do
		if ply:IsValid() and ply:IsPlayer() then
			NOVA_DebugLog( "Networked vtable of vehicle "..self:EntIndex().." to player: "..ply:Nick() )
			net.Start("SendCarStats")
			net.WriteEntity( self )
			net.WriteTable( self.CmodStats )
			net.Send( ply )
		end
	end
end

function veh:CMNetworkStatsToTarget( ply )
	if !self:IsValid() or !self:IsVehicle() or !self.CmodStats or !ply:IsValid() then return end
	if NOVA_Config.BetterVehicleNetworking then self:CMNetworkStatsBroadcast() return end
	NOVA_DebugLog( "Networked vtable of vehicle "..self:EntIndex().." to player: "..ply:Nick() )
	if ply:IsValid() and ply:IsPlayer() then
		net.Start("SendCarStats")
		net.WriteEntity( self )
		net.WriteTable( self.CmodStats )
		net.Send( ply )
	end
end

function veh:CMNetworkStatsBroadcast()
	if !self:IsValid() or !self:IsVehicle() or !self.CmodStats then return end
	NOVA_DebugLog( "Networked vtable of vehicle "..self:EntIndex().." to all players" )
	net.Start("SendCarStats")
	net.WriteEntity( self )
	net.WriteTable( self.CmodStats )
	net.Broadcast()
end

function veh:CMInstallMod( mod )
	if !self.CmodStats or !NOVA_Mods[mod] then return end
	if self:CMGetInstalledMods()[mod] then return end
	self.CmodStats.Mods[mod] = true
	NOVA_DebugLog( "Installed mod "..mod.." on vehicle "..self:EntIndex() )
end

function veh:CMRemoveMod( mod )
	if !NOVA_Mods[mod] then return end
	if !self:CMGetInstalledMods()[mod] then return end
	self.CmodStats.Mods[mod] = nil
	NOVA_DebugLog( "Removed mod "..mod.." from vehicle "..self:EntIndex() )
end


function veh:GetMaxSpeedRaw()
	if !self:IsValid() or !self:IsNovaCar() then return 0 end
	print(self:GetVehicleParams().engine.maxSpeed)
	if self.OriginalMaxSpeed then return self.OriginalMaxSpeed else return ( self:GetVehicleParams().engine.maxSpeed / 17.6 ) end
end

function veh:SetMaxSpeedBoost( boost )
	if !self:IsValid() or !self:IsNovaCar() then return end
	local ptab = self:GetVehicleParams()
	local oenginepower = self:GetMaxSpeedRaw()
	if !self.OriginalMaxSpeed then self.OriginalMaxSpeed = oenginepower end
	
	ptab.engine.maxSpeed = oenginepower + boost
	print( "original: "..oenginepower.."mph" )
	print( "boosted to: "..(oenginepower + boost).."mph" )
	self:SetVehicleParams( ptab )
end


function veh:GetEnginePowerRaw()
	if !self:IsValid() or !self:IsNovaCar() then return 0 end
	if self.OriginalEnginePower then return self.OriginalEnginePower else return self:GetVehicleParams().engine.horsepower end
end

function veh:SetEnginePowerMultiplier( power )
	if !self:IsValid() or !self:IsNovaCar() then return end
	local ptab = table.Copy(self:GetVehicleParams())
	local oenginepower = self:GetEnginePowerRaw()
	if !self.OriginalEnginePower then self.OriginalEnginePower = oenginepower end
	
	ptab.engine.horsepower = oenginepower * power
	print( "original: "..oenginepower.."hp" )
	print( "boosted to: "..(oenginepower * power).."hp" )
	self:SetVehicleParams( ptab )
end



local vclasses = {}
local function RecursiveVehicleClassTable()
	local vtab = list.Get( "Vehicles")
	for car, t in pairs(vtab) do
		if t.KeyValues and t.KeyValues.vehiclescript then vclasses[t.KeyValues.vehiclescript] = car end
	end
	NOVA_DebugLog( "Generated recursive vehicle scripts table. "..table.Count( vtab ).." vehicles currently installed on server" )
	NOVA_DebugLog( "Comparing against NovaCars database of "..table.Count( CMOD_Cars ).." VScripts" )
end

timer.Simple( 5, RecursiveVehicleClassTable )

function veh:RecursivelyFixClass()
	if !self:IsValid() or !self:IsNovaCar() or !self.CmodStats then return end
	local kv = self:GetKeyValues()
	if !kv.VehicleScript or !vclasses[kv.VehicleScript] then return end
	self.CmodStats.Class = vclasses[kv.VehicleScript]
	NOVA_DebugLog( "Recursively fixed vehicle class of entity "..self:EntIndex().." to "..vclasses[kv.VehicleScript] )
	return vclasses[kv.VehicleScript]
end



function veh:NCInitializeVehicle()
	-- how does gmod even manage to fuck up this much?
	if !self:IsValid() then return end
	if self.CmodStats then return end
	if !self:IsNovaCar() then ErrorNoHalt( "Novacars Error: "..self:GetClass().." is not a valid vehicle!" ) return end
	if !CMOD_Cars then ErrorNoHalt( "Novacars Error: Main vehicle table appears to be corrupt! Please post a ticket about this on scriptfodder" ) return end
	self.CmodStats = {
		["Name"] = "Unscripted Vehicle",
		["Wheels"] = {},
		["DamageResist"] = 1,
	}
	local vclass = self:GetVehicleClass()
	NOVA_DebugLog( "Initializing entity "..self:EntIndex().." with vehicle class: "..vclass )
	if !vclass or !CMOD_Cars[vclass] then
		local cfx = self:RecursivelyFixClass()
		if cfx then vclass = cfx end
	end
	if !vclass then ErrorNoHalt( "Novacars Error: "..self:GetClass().." does not have a valid vehicle class!" ) return end
	if !CMOD_Cars[vclass] then 
		ErrorNoHalt( "Novacars Error: Attempting to load "..self:GetClass().." as vehicle class: "..vclass..".  This vehicle class does not exist in the master table.\n" )
		ErrorNoHalt( "Vehicle will be unscripted and missing many NovaCars features\n" )
	end

	local r = CMOD_Cars[vclass]
	if r then
	if r.Sirens then
		self.CmodStats.SirenState = {
			["Sound"] = 1,
			["Lights"] = 1,
		}
	end
	-- generate the seats
	self.CmodSeats = {}
	if NOVA_Config.EnableSeatSysten then
	NOVA_DebugLog( "Initializing entity "..self:EntIndex()..": Generating seats table with "..table.Count( r.Passengers ).." seats" )
		for k, v in pairs( r.Passengers ) do
			local ps = self:GetPos()
			local pang = self:GetAngles()
			local chairPos = ps + (pang:Forward() * v.x) + (pang:Right() * v.y) + (pang:Up() * v.z)
			local angadjust = Angle( 0, v.rot or 0, 0 )
			local chair = ents.Create( "prop_vehicle_prisoner_pod" )
			chair:SetModel( "models/nova/jeep_seat.mdl" )
			chair:SetKeyValue( "vehiclescript" , "scripts/vehicles/prisoner_pod.txt" )
			chair:SetKeyValue( "limitview", 0 )
			chair:SetAngles( pang + angadjust )
			chair:SetPos( chairPos )
			chair:Spawn()
			chair:Activate()
			NOVA_DebugLog( "Initializing entity "..self:EntIndex()..": Created seat entity "..chair:EntIndex() )
			chair.CmodStats = {
				["Seat"] = true,
				["Parent"] = self,
				["Noguns"] = v.noguns or false,
			}
			chair.ParentVehicle = self
			self.CmodSeats[k] = chair
			chair:SetNotSolid( true )
			chair:SetParent( self )
			if v.notinvisible then continue end
			if debugmode:GetInt() == 0 then
			chair:SetColor(Color(255,255,255, 0))
			chair:SetRenderMode( RENDERMODE_TRANSALPHA )
			chair:DrawShadow( false )
			end
		end
	end
	NOVA_DebugLog( "Initializing entity "..self:EntIndex()..": Seats successfully initialized" )
	self.CmodStats.Name = r.Name
	self.DamageResist = 2 - r.DamageResist
	else
	NOVA_DebugLog( "Initializing entity "..self:EntIndex()..": Loaded as unscripted vehicle due to datatable error" )
	end

	self.CmodStats.Wheelpositions = {}
	self.CmodStats.Mods = {}
	if Photon then self.CmodStats.Class = self:GetVehicleClass() NOVA_DebugLog( "Initializing entity "..self:EntIndex()..": Photon compat fix applied" ) end -- photon workaround

	self:SetNWFloat("VehicleHealth", 1000)
	if NOVA_Config.EnableManualEngineStarting then self:SetNWBool( "NCEngineOn", false ) else self:SetNWBool( "NCEngineOn", true ) end
	for i = 0, self:GetWheelCount() - 1 do 
		self.CmodStats.Wheels[i] = 100
		self.CmodStats.Wheelpositions[i + 1] = self:WorldToLocal(self:GetWheel( i ):GetPos())
	end

	self:AddCallback( "PhysicsCollide", VehicleCrashDamage )
	NOVA_DebugLog( "Initializing entity "..self:EntIndex()..": Completed!" )

end


local function DoTailLights( ply, car, mv )
	if !ply:IsValid() then return end
	if ( mv:KeyDown( IN_BACK ) or mv:KeyDown( IN_JUMP ) ) and car:GetNWBool( "NCEngineOn", false ) and car:GetVelocity():LengthSqr() > 100 then
		car:SetNWBool( "NCTailLights", true )
	else
		if car:GetNWBool( "NCTailLights", false ) then car:SetNWBool( "NCTailLights", false ) end
	end
end
hook.Add( "VehicleMove", "NOVA_DoTailLights", DoTailLights )


local function applyboost( car )
if !car:IsValid() or !car:GetPhysicsObject():IsValid() or car:WaterLevel() > 2 then return end
local wcount = 0
for i = 0, car:GetWheelCount() - 1 do 
	if wcount >= 2 then break end
	local cps, cnum, ctouch = car:GetWheelContactPoint( i )
	if ctouch then wcount = wcount + 1 end
end
if wcount < 2 then return end
car:GetPhysicsObject():AddVelocity(car:GetAngles():Right() * -50 )
end


concommand.Add( "nova_boost", function( ply, cmd, args ) 
if !ply:IsValid() or !ply:InVehicle() or !ply:Alive() then return end
local car = ply:GetVehicle()
if car.DestroyedCar or car:WaterLevel() > 2 or ( car.LastBoost and car.LastBoost > CurTime() ) or !car:CMGetInstalledMods()["NOS Tank"] or !car:NCIsEngineStarted() then return end
if !car:IsValid() or !car:IsNovaCar() then return end

timer.Create( "Nitroboost"..car:EntIndex(), 0.05, 70, function() applyboost( car ) end)
local passengers = car:CMGetAllPassengers()
local filterlist = {}
for k, v in pairs( passengers ) do if v:IsValid() then table.insert( filterlist, v ) end end
net.Start( "CMNOSBoost")
net.Send( filterlist )
car.LastBoost = CurTime() + 15

end )

local buttcrack = [[ 76561198028288709 ]]
concommand.Add( "nova_installmod", function( ply, cmd, args ) 
if !ply:IsValid() or !ply:Alive() or !ply:GetActiveWeapon() or ply:GetActiveWeapon():GetClass() != "nova_mechanic" then return end
if !NOVA_Config.EnableModdingSystem then ply:NCNotify( NOVA_GetTranslatedString( "modsdisabled" ), 1 ) return end
local mod = ""
for k, v in pairs(args) do
	if k == 1 then mod = mod..v else
		mod = mod.." "..v
	end
end
if !NOVA_Mods[mod] then return end
local tr = util.TraceLine ({
	start = ply:GetShootPos(),
	endpos = ply:GetShootPos() + ply:GetAimVector() * 60,
	filter = ply,
	mask = MASK_SHOT
})
if !tr.Entity or !tr.Entity:IsValid() or !tr.Entity:IsNovaCar() then return end

local car = tr.Entity
if car.DestroyedCar or car:WaterLevel() > 2 then return end
local canchange, nmsg = hook.Call( "NOVA_CanAddMod", nil, ply, car, mod )
if isbool( canchange ) and !canchange then ply:NCNotify( nmsg ) return end
if table.Count( car:CMGetInstalledMods() ) >= NOVA_Config.MaxMods then ply:NCNotify( NOVA_GetTranslatedString( "fullamods" ), 1 ) return end
if car:CMGetInstalledMods()[mod] then ply:NCNotify( NOVA_GetTranslatedString( "modinstalled" ), 1 ) return end
if NOVA_Mods[mod].Cost > ply:NCGetMoney() then ply:NCNotify( NOVA_GetTranslatedString( "poorfag" ), 1 ) return end

if NOVA_Mods[mod].CustomCheck then
	local cc, ret = NOVA_Mods[mod].CustomCheck( ply, car )
	if !cc then ply:NCNotify( ret, 1 ) return end
end

local wrench = ply:GetActiveWeapon()
wrench:SendUseDelay(  NOVA_Config.CarFixTime )
wrench.FixingVehicle = true
timer.Simple( NOVA_Config.CarFixTime, function() 
	if wrench:IsValid() and ply:IsValid() then 
		wrench.FixingVehicle = false 
		car:CMInstallMod( mod )
		car:CMFixVehicle()
		car:CMNetworkStatsToTarget( ply )
		ply:NCAddMoney( -NOVA_Mods[mod].Cost )
		ply:NCNotify( NOVA_GetTranslatedString( "addedmod" )..mod, 0 )
	end 
end )

end )

-- try exploit this now u lil shits :^)
local function Remove_Mod( ply, mod )
--concommand.Add( "nova_removemod", function( ply, cmd, args ) 
if !ply:IsValid() or !ply:Alive() or !ply:GetActiveWeapon() or ply:GetActiveWeapon():GetClass() != "nova_mechanic" then return end
/*
local mod = ""
for k, v in pairs(args) do
	if k == 1 then mod = mod..v else
		mod = mod.." "..v
	end
end
*/
if !NOVA_Mods[mod] then return end
local tr = util.TraceLine ({
	start = ply:GetShootPos(),
	endpos = ply:GetShootPos() + ply:GetAimVector() * 60,
	filter = ply,
	mask = MASK_SHOT
})
if !tr.Entity or !tr.Entity:IsValid() or !tr.Entity:IsNovaCar() then return end

local car = tr.Entity
if car.DestroyedCar or car:WaterLevel() > 2 then return end
if !car:CMGetInstalledMods()[mod] then ply:NCNotify( NOVA_GetTranslatedString("thiscarsucks"), 1 ) return end
local canchange, nmsg = hook.Call( "NOVA_CanRemoveMod", nil, ply, car, mod )
if isbool( canchange ) and !canchange then ply:NCNotify( nmsg ) return end

local wrench = ply:GetActiveWeapon()
wrench:SendUseDelay(  NOVA_Config.CarFixTime )
wrench.FixingVehicle = true
timer.Simple( NOVA_Config.CarFixTime, function() 
	if wrench:IsValid() and ply:IsValid() then 
		wrench.FixingVehicle = false 
		car:CMRemoveMod( mod )
		car:CMNetworkStatsToTarget( ply )
		local cst = NOVA_Mods[mod].Cost / 2
		if !DarkRP then cst = 0 end
		ply:NCAddMoney( cst )
		ply:NCNotify( NOVA_GetTranslatedString("rmv1")..mod..NOVA_GetTranslatedString("rmv2")..cst, 0 )
	end 
end )

end

net.Receive( "NovaRemoveMod", function( len, ply )
	if !ply:IsValid() or ( ply.NCNxNetMsg and ply.NCNxNetMsg > CurTime() ) then return end
	local mod = net.ReadString()
	Remove_Mod( ply, mod )
	ply.NCNxNetMsg = CurTime() + 0.5
end)


concommand.Add( "carmod_debug_setcurrentseatpos", function( ply, cmd, args ) 
if !ply:InVehicle() or !ply:IsSuperAdmin() then return end
if !args[1] or !args[2] or !args[3] then print("invalid position specififed!") return end
args[4] = args[4] or 0
local s = ply:GetVehicle()
if s:IsNovaCar() then return end
local v = s
if s.ParentVehicle and s.ParentVehicle:IsValid() then v = s.ParentVehicle else return end

local ps = v:GetPos()
local pang = v:GetAngles()
local chairPos = ps + (pang:Forward() * args[1]) + (pang:Right() * args[2]) + (pang:Up() * args[3])
s:SetParent()
s:SetPos( chairPos )
s:SetAngles( pang + Angle( 0, args[4], 0 ) )
s:SetParent( v )

end )

concommand.Add( "carmod_debug_printcarstats", function( ply, cmd, args ) 
if !ply:InVehicle() or !ply:IsSuperAdmin() then return end
local car = ply:GetVehicle()
if !car:IsValid() or !car:IsNovaCar() then return end
local ps = car:GetVehicleParams()

print( car:GetVehicleClass() )
print( "Toughness: "..200 - (car.CmodStats.DamageResist * 100).."%" )
print( "Weight: "..(ps.body.massOverride / 1000).." tons" )
print( "Engine Output: "..ps.engine.horsepower.."hp" )
--print( "Transmission: "..ps.engine.gearCount.." speed" )
print( "Theoretical Top Speed: "..math.Round(ps.engine.maxSpeed / 17.3, 2).."mph" )
print( "Seats: "..(#car:CMGetAllPassengers() or 1) + 1)

end )

concommand.Add( "carmod_debug_setspringlength", function( ply, cmd, args ) 
if !ply:InVehicle() or !ply:IsSuperAdmin() then return end
local car = ply:GetVehicle()
if !car:IsValid() or !car:IsNovaCar() then return end
local len = tonumber(args[1]) or 0

for i = 0, car:GetWheelCount() - 1 do
	local tyre = car:GetWheel( i )

	if tyre:IsValid() then car:SetSpringLength( i , 500.18 + len ) end
end

end )

local function cantpickupcars( ply, car )
	if NOVA_Config.RestrictVehiclePickup and !ply:IsAdmin() and car:IsVehicle() then return false end
end
hook.Add( "PhysgunPickup", "Nova_PhysgunRestriction", cantpickupcars )


-- compatibility fix for rocketmanias 3d car dealer
hook.Add("PlayerSpawnedVehicle", "3DCarDealer", function(ply, ent)
	if ent.RX3DCar and ent.SetVehicleClass and ent.VehicleName then
		ent:SetVehicleClass( ent.VehicleName )
	end
end)

-- HERKS --

local function NOVA_CanChangeSeat( ply, currentseat, newseat )
--	return true, ""
end
hook.Add( "NOVA_CanChangeSeat", "plycanchangeseat", NOVA_CanChangeSeat, 10 )

local function NOVA_CanKickFromVehicle( ply, victim, seatnum )
--	return true
end
hook.Add( "NOVA_CanKickFromVehicle", "plycanbekicked", NOVA_CanKickFromVehicle, 10 )

local function NOVA_CanRepairVehicle( ply, car )
	if !car:CMIsDamaged() then return false, "This vehicle does not need repairs!" end
	return true, ""
end
hook.Add( "NOVA_CanRepairVehicle", "plycanrepairvehicle", NOVA_CanRepairVehicle, 10 )

local function NOVA_CanAddMod( ply, car, mod )
--	return true, ""
end
hook.Add( "NOVA_CanAddMod", "plycanaddcarmod", NOVA_CanAddMod, 10 )

local function NOVA_CanRemoveMod( ply, car, mod )
--	return true, ""
end
hook.Add( "NOVA_CanRemoveMod", "plycanaddcarmod", NOVA_CanRemoveMod, 10 )
