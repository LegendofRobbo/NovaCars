local veh = FindMetaTable( "Entity" )

function NOVA_DebugLog( str )
	if !NOVA_Config.DebugLogger then return end
	if SERVER then MsgN( "[NC_SV]: "..str ) end
	if CLIENT then MsgN( "[NC_CL]: "..str ) end
end

function veh:GetCMSpeed()
if !self:IsValid() or !self:IsVehicle() then return end
return math.floor( self:GetVelocity():Length() / 17.3 )
end

function veh:GetCMSpeedMetric()
if !self:IsValid() or !self:IsVehicle() then return end
return math.floor( (self:GetVelocity():Length() / 17.3) * 1.60934 )
end

function veh:GetCMSpeedAccurate()
if !self:IsValid() or !self:IsVehicle() then return end
return self:GetVelocity():Length() / 17.3
end

function veh:IsNovaCar()
	return self:GetClass() == "prop_vehicle_jeep" or false
end

function veh:NCIsEngineStarted()
	if !self:IsValid() or !self:IsVehicle() or !self:IsNovaCar() then return end
	return self:GetNWBool( "NCEngineOn", false )
end

function veh:CMGetInstalledMods()
	if SERVER then 
		if !self.CmodStats then return {} end
		return self.CmodStats.Mods or {}
	else
		if !self.CS_Stats then return {} end
		return self.CS_Stats.Mods or {}
	end
end
-- makes safe cruise more reliable but also makes it run serverside which isn't desirable
/*
local function SafeCruiseLogic( ply, cmd )
	if !ply:Alive() or !ply:InVehicle() then return end
	local car = ply:GetVehicle()
	local stats = {}
	local safecruise = false

	local carangle = (-cmd:GetViewAngles().y) + 90
	if carangle > 180 then carangle = -carangle end
	local carangle2 = math.Clamp( carangle, -90, 90)
	cmd:SetSideMove( carangle2 * 5 )

	if !car.CmodStats or !car.CmodStats.SafeCruise then return end
	if car:GetCMSpeed() > (CMOD_Config["SpeedLimit"] - 1.5) then cmd:SetForwardMove( -100 ) end

end

hook.Add( "StartCommand", "safecruise_logic", SafeCruiseLogic)
*/

-- move their bullets 50 units outwards from their gun, should allow players to fire out of windows they are sitting next to without letting them shoot through the hood/rear of their car
local function DrivebyBulletMods( e, bul )
	if !e:IsValid() or !e:IsPlayer() then return end
	if !e:InVehicle() then return end
	local src = bul.Src
	local dir = bul.Dir

	bul.Src = src + dir * (NOVA_Config.DrivebyShootingGunRange or 1)
	return true
end

hook.Add( "EntityFireBullets", "DrivebyBulletMods", DrivebyBulletMods )

local function FixStupidWeaponBases( ply, owep, nwep )
	if nwep.Base and nwep.Base == "cw_base" then
		nwep.NearWallEnabled = false
	end
end
hook.Add( "PlayerSwitchWeapon", "Nova_FixStupidWeaponBases", FixStupidWeaponBases, -10 )







if SERVER then 
util.AddNetworkString("ShowBadHooks")
concommand.Add("nova_debug_grab_hooks", function( ply, cmd, args)
	local hks = args[1]
	local tab = {}
	if !hks or hks == "" then 
		for k, v in pairs( hook.GetTable() ) do
			tab[k] = table.Count( v ).." hooks"
		end
		net.Start( "ShowBadHooks" )
		net.WriteString( "All Server Hooks" )
		net.WriteTable( tab )
		net.Send( ply )
		return
	end

	for k, v in pairs( hook.GetTable()[hks] ) do
		tab[k] = debug.getinfo(v).source
	end

	net.Start( "ShowBadHooks" )
	net.WriteString( hks )
	net.WriteTable( tab )
	net.Send( ply )

end)

end

if CLIENT then
	net.Receive( "ShowBadHooks", function() 
		local nm = net.ReadString()
		local tb = net.ReadTable()
		print( "==== "..nm.." ====" )
		PrintTable( tb )
	end )
end