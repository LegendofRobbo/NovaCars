surface.CreateFont( "NovaTrebuchet", {
	font = "Trebuchet",
	size = 14,
	weight = 350,
} )

surface.CreateFont( "NovaTrebuchetSmall", {
	font = "Trebuchet",
	size = 13,
	weight = 350,
} )

surface.CreateFont( "NovaTrebuchetMods", {
	font = "Trebuchet",
	size = 14,
	weight = 600,
} )

local nova_safecruise = CreateClientConVar( "nova_safecruise", "0", true )
local nova_mousedrive = CreateClientConVar( "nova_mouse_assisted_driving", "0", true )
local nova_metricspeed = CreateClientConVar( "nova_metric_speedometer", "0", true )
local nova_showdriver = CreateClientConVar( "nova_show_driver_body", "1", true )
local nova_wheelfx = CreateClientConVar( "nova_config_wheel_effects", "1", true )

local nova_fxdistance = CreateClientConVar( "nova_config_fxrenderdistance", "2000", true )
local nova_fxdensity = CreateClientConVar( "nova_config_fxrenderdensity", "150", true )
local nova_doskids = CreateClientConVar( "nova_config_renderskids", "1", true )
local nova_skidduration = CreateClientConVar( "nova_config_skid_duration", "10", true )
local nova_dynamicheadlights = CreateClientConVar( "nova_config_dynamicheadlights", "1", true )
local nova_mousedrivesens = CreateClientConVar( "nova_config_mousedrive_sensitivity", "100", true )
local nova_immersivedriving = CreateClientConVar( "nova_config_immersive_driving_camera", "1", true )
local nova_3dhud = CreateClientConVar( "nova_config_3d_hud", "1", true )

local nova_bind_horn = CreateClientConVar( "nova_keybinds_horn", "107", true )
local nova_bind_siren = CreateClientConVar( "nova_keybinds_siren", "108", true )
local nova_bind_nos = CreateClientConVar( "nova_keybinds_nos", "79", true )
local nova_bind_engine = CreateClientConVar( "nova_keybinds_engine", "28", true )
local nova_bind_jump = CreateClientConVar( "nova_keybinds_jump", "81", true )
local nova_bind_headlights = CreateClientConVar( "nova_keybinds_headlights", "16", true )

local grad = Material( "gui/gradient" )
local upgrad = Material( "gui/gradient_up" )
local downgrad = Material( "gui/gradient_down" )
local dude = Material( "icon16/user.png" )
local dude2 = Material( "icon16/user_red.png" )
local ring = Material( "particle/particle_ring_sharp" )
local ring2 = Material( "particle/particle_ring_wave_additive" )
local arrow = Material( "trails/laser" )
local roundmat = Material( "particle/particle_sphere" )

local function DrawOffsetTexturedRect( x, y, w, h, rot, x0, y0 )

	local c = math.cos( math.rad( rot ) )
	local s = math.sin( math.rad( rot ) )

	local newx = y0 * s - x0 * c
	local newy = y0 * c + x0 * s

	surface.DrawTexturedRectRotated( x + newx, y + newy, w, h, rot )

end

local nxboost = CurTime()
local nxcommand = CurTime()
local Bnxboost = true
local function SafeCruiseLogic( ply, cmd )
	if !ply:Alive() or !ply:InVehicle() then return end
	local car = ply:GetVehicle()
	if car:GetClass() != "prop_vehicle_jeep" then return end
	local stats = {}

	if nxcommand <= CurTime() and !vgui.GetKeyboardFocus() then -- make sure we don't fire off random commands when typing in the chatbox, using menus etc
		local khn = nova_bind_horn:GetInt()
		if input.IsKeyDown( khn ) or input.IsMouseDown( khn ) then RunConsoleCommand( "nova_horn" ) nxcommand = CurTime() + 0.5 end
		khn = nova_bind_siren:GetInt()
		if input.IsKeyDown( khn ) or input.IsMouseDown( khn ) then RunConsoleCommand( "nova_togglesirens" ) nxcommand = CurTime() + 0.5 end
		khn = nova_bind_engine:GetInt()
		if input.IsKeyDown( khn ) or input.IsMouseDown( khn ) then RunConsoleCommand( "nova_startcar" ) nxcommand = CurTime() + 0.5 end
		khn = nova_bind_nos:GetInt()
		if input.IsKeyDown( khn ) or input.IsMouseDown( khn ) then RunConsoleCommand( "nova_boost" ) nxcommand = CurTime() + 0.5 end
		khn = nova_bind_jump:GetInt()
		if input.IsKeyDown( khn ) or input.IsMouseDown( khn ) then RunConsoleCommand( "nova_boostjump" ) nxcommand = CurTime() + 0.5 end
		khn = nova_bind_headlights:GetInt()
		if input.IsKeyDown( khn ) or input.IsMouseDown( khn ) then RunConsoleCommand( "nova_toggleheadlights" ) nxcommand = CurTime() + 0.5 end
	end

	if nova_mousedrive:GetInt() != 0 and !input.IsKeyDown(KEY_LALT) then
		local carangle = (-cmd:GetViewAngles().y) + 90
		if carangle > 180 then carangle = -carangle end
		carangle = carangle * (nova_mousedrivesens:GetInt() / 100)
		local carangle2 = math.Clamp( carangle, -90, 90)
		cmd:SetSideMove( carangle2 * 5 )
	end

	if nova_safecruise:GetInt() != 0 then
		if car:GetCMSpeed() > (NOVA_Config["SpeedLimit"] - 1.5) then cmd:SetForwardMove( -100 ) end
	end

	if input.IsKeyDown( KEY_LSHIFT ) and nxboost <= CurTime() and Bnxboost then
		RunConsoleCommand( "nova_boost" )
		nxboost = CurTime() + 2
		Bnxboost = false
	elseif !input.IsKeyDown( KEY_LSHIFT ) then
		Bnxboost = true
	end

end
hook.Add( "StartCommand", "safecruise_logic", SafeCruiseLogic)

/*
local nxsiren = CurTime()
hook.Add( "KeyPress", "NOVA_Sirens", function( ply, key )
	
	if !ply:IsValid() or !ply:Alive() or !ply:GetVehicle():IsValid() or ply:GetVehicle():GetClass() != "prop_vehicle_jeep" then return end
	if nxsiren <= CurTime() and key == IN_ATTACK2 then
		RunConsoleCommand( "nova_togglesirens" )
		nxsiren = CurTime() + 0.5
	end
	-- this is getting disgusting pretty quickly, bind system needs to be done soon

	print( key )
	local hornkey = nova_bind_horn:GetInt()
	if key == hornkey then RunConsoleCommand( "nova_horn" ) end


	if key == IN_ATTACK then
		RunConsoleCommand( "nova_horn" )
	elseif key == IN_WALK then
		RunConsoleCommand( "nova_boostjump" )
	elseif key == IN_RELOAD and !ply:GetVehicle():GetNWBool( "NCEngineOn", false ) then
		RunConsoleCommand( "nova_startcar" )
	end

	
end, -3 )
*/


local nospunch = 0
local function NovaScreenspace()
if !LocalPlayer():InVehicle() or !LocalPlayer():Alive() then nospunch = 0 return end
if nospunch > 0 then
	local tab = {
	[ "$pp_colour_addr" ] = 0,
	[ "$pp_colour_addg" ] = 0,
	[ "$pp_colour_addb" ] = nospunch * 0.001,
	[ "$pp_colour_brightness" ] = 0,
	[ "$pp_colour_contrast" ] = 1,
	[ "$pp_colour_colour" ] = 1,
	[ "$pp_colour_mulr" ] = 0,
	[ "$pp_colour_mulg" ] = 0,
	[ "$pp_colour_mulb" ] = 0
	}
	DrawColorModify( tab )
	DrawMaterialOverlay( "effects/strider_pinch_dudv", nospunch * 0.0001 )
	DrawMaterialOverlay( "effects/tp_eyefx/tpeye3", 0.1 )
	nospunch = math.Clamp( nospunch - 2.5, 0, 500 )
end
end
hook.Add( "RenderScreenspaceEffects", "NovaScreenspace", NovaScreenspace )

local nostimer = CurTime()
net.Receive( "CMNOSBoost", function() 
	surface.PlaySound( "novacars/nitro3.wav" ) 
	nospunch = 500
	nostimer = CurTime() + 15
end)

local function viewangledifference( Ang )
--		local eyes = LocalPlayer():EyeAngles() + Ang
		local eyes = LocalPlayer():GetAimVector():Angle()
--		if LocalPlayer():InVehicle() and LocalPlayer():GetVehicle():GetThirdPersonMode() then eyes = eyes + LocalPlayer():GetVehicle():GetAngles() end
        local DiffX = math.abs( math.NormalizeAngle( eyes.p - Ang.p ) )
        local DiffY = math.abs( math.NormalizeAngle( (eyes.y + 90) - Ang.y ) )
        return (DiffX + DiffY) * 1.6
end

local function viewangledifferenceSide( Ang )
		local eyes = LocalPlayer():EyeAngles() + Ang
        local DiffX = math.NormalizeAngle( eyes.p - Ang.p )
        local DiffY = math.NormalizeAngle( (eyes.y + 90) - Ang.y )
        return (DiffX + DiffY) * 1.6
end



local function DoVehicleHud( x, y, car, bg )

local kph = car:GetCMSpeed()
--if car:GetThirdPersonMode() then x = ScrW() / 2 + 50 y = ScrH() - 100 end
local bind = input.GetKeyName( nova_bind_engine:GetInt() )

if !car:GetNWBool( "NCEngineOn", false ) and car:GetNWFloat("VehicleHealth", 0 ) >= 1 then 
	draw.SimpleText( "Press "..bind.." to start engine", "NovaTrebuchet", x + 5, y + 22, Color(255,255,255, 255), TEXT_ALIGN_CENTER, 0 )
	return 
end

if bg then
surface.SetDrawColor(Color(50, 0, 0, 150))
surface.DrawRect( x - 6, y, 120, 45 )
surface.SetMaterial( grad )
surface.DrawTexturedRect( x + 114, y, 20, 45 )
end

surface.SetDrawColor(Color(55, 0, 0, 255))
surface.SetMaterial( ring )
surface.DrawTexturedRect( x - 100, y - 25, 100, 100 )
surface.SetDrawColor(Color(155, 0, 0, 255))
surface.DrawTexturedRect( x - 55, y + 20, 10, 10 )
surface.SetMaterial( ring2 )
surface.DrawTexturedRect( x - 100, y - 25, 100, 100 )

surface.SetDrawColor(Color(255, 0, 0, 255))
surface.SetMaterial( arrow )
DrawOffsetTexturedRect( x - 50, y + 25, 15, 38, ((-car:GetCMSpeedAccurate()) * 3) - 5, 0, 25 )

surface.SetDrawColor(Color(250, 150, 0, 255))

DrawOffsetTexturedRect( x - 50, y + 25, 15, 38, ((-NOVA_Config["SpeedLimit"]) * 3) - 5, 0, 25 )

if kph > NOVA_Config["SpeedLimit"] then draw.SimpleTextOutlined( "EXCEEDING SPEED LIMIT", "NovaTrebuchet", x + 5, y - 15, Color(255,55,55, 255), TEXT_ALIGN_LEFT, 0, 1, Color(50,0,0) ) end
if nova_safecruise:GetInt() != 0 then draw.SimpleText( "Safe Cruise Mode", "NovaTrebuchet", x + 5, y + 40, Color(55,55,255, 255), TEXT_ALIGN_LEFT, 0 ) end
local sptxt = NOVA_GetTranslatedString( "speed" )..kph.."mph"
if nova_metricspeed:GetInt() != 0 then sptxt = NOVA_GetTranslatedString( "speed" )..car:GetCMSpeedMetric().."kph" end
draw.SimpleText( sptxt, "NovaTrebuchet", x + 5, y + 5, Color(255,255,255, 255), TEXT_ALIGN_LEFT, 0 )
local hp = math.Round(car:GetNWFloat("VehicleHealth", 0) / 10)
if hp > 0 then
	draw.SimpleText( NOVA_GetTranslatedString( "health" )..hp.."%", "NovaTrebuchet", x + 5, y + 22, Color(200 - (hp * 2),(hp * 2.5),0, 255), TEXT_ALIGN_LEFT, 0 )
else
	draw.SimpleText( "ENGINE DESTROYED", "NovaTrebuchet", x + 5, y + 22, Color(255,0,0, 255), TEXT_ALIGN_LEFT, 0 )
end
if car:CMGetInstalledMods()["NOS Tank"] then
	surface.SetDrawColor(Color(55, 55, 255, 255))
	local nosclamp = math.Clamp(nostimer - CurTime(), 0, 10 )
	DrawOffsetTexturedRect( x - 50, y + 25, 15, 38, 180 - (nosclamp * -18), 0, 25 )
	if nosclamp <= 0.01 then draw.SimpleText( "BOOST", "NovaTrebuchet", x - 50, y - 40, Color(50,50,255, 255), TEXT_ALIGN_LEFT, 0 ) end
end

end



local function CarControllerHudTest()
if nova_3dhud:GetInt() != 1 then return end
local ply = LocalPlayer()
if !ply:Alive() or !ply:InVehicle() then return end
local car = ply:GetVehicle()
if !car:IsValid() or !car.CS_Stats or car.CS_Stats.Seat then return end

local kph = car:GetCMSpeed()
local dashpos = ( ply:EyePos() + ply:GetAngles():Up() * -4 + ply:GetAngles():Forward() * 14)
local rscale = 0.025

if car:GetThirdPersonMode() then
	local vang = viewangledifferenceSide( car:GetAngles() )
	if not (vang < -120 or vang > 150) then return end
	if vang > 0 then
		dashpos = car:GetPos() + car:GetAngles():Up() * 50 + car:GetAngles():Forward() * -90
	else
		dashpos = car:GetPos() + car:GetAngles():Up() * 50 + car:GetAngles():Forward() * 90
	end
	rscale = 0.3
end

--	print("GAY")
--	for i = 1, car:GetBoneCount() do
--		print( i.." || "..car:GetBoneName( i ) )
--	end

local carang = car:GetAngles()
carang:RotateAroundAxis( carang:Right(), 90)
carang:RotateAroundAxis( carang:Forward(), 90)
carang:RotateAroundAxis( carang:Up(), 270)
cam.Start3D2D( dashpos, carang, rscale )
/*
if !car:GetNWBool( "NCEngineOn", false ) and car:GetNWFloat("VehicleHealth", 0 ) >= 1 then 
	draw.SimpleTextOutlined( "Press R to start engine", "NovaTrebuchet", 5, 22, Color(255,255,255, 255), TEXT_ALIGN_CENTER, 0, 2, Color(0,0,0) )
	cam.End3D2D()
	return 
end
*/

DoVehicleHud( 0, 0, car )

cam.End3D2D()

end
hook.Add( "PreDrawEffects", "NCHudTest", CarControllerHudTest )

/*

*/
local function CarControllerHud()
local ply = LocalPlayer()

if ply:Alive() and ply:IsValid() and !ply:InVehicle() then
	local tr = util.TraceLine ({
		start = LocalPlayer():GetShootPos(),
		endpos = LocalPlayer():GetShootPos() + LocalPlayer():GetAimVector() * 100,
		filter = LocalPlayer(),
		mask = MASK_SHOT
	})
	if !tr.Entity or !tr.Entity:IsValid() then return end
	if tr.Entity:GetClass() == "nova_spikestrip" then
		local owner = tr.Entity:GetNWEntity( "NCOwner", game.GetWorld() )
		draw.SimpleText( "Spike Strip", "NovaTrebuchet", ScrW() / 2, (ScrH() / 2) + 10, Color(255,255,255, 150), 1 )
		if owner:IsValid() then
			draw.SimpleText( "Placed by: "..owner:Nick(), "NovaTrebuchet", ScrW() / 2, (ScrH() / 2) + 26, Color(255,255,255, 150), 1 )
		end
	end
end

if !ply:Alive() or !ply:InVehicle() then return end

local car = ply:GetVehicle()

if !car.CS_Stats then return end
if car.CS_Stats.Seat then
	if NOVA_Config.DrivebyShooting and !car.CS_Stats.Noguns then
		local vtr = util.TraceLine( { start = EyePos() + (EyeAngles():Forward() * (NOVA_Config.DrivebyShootingGunRange or 1)), endpos = EyePos() + (EyeAngles():Forward() * 250) } )
		if vtr.Hit and vtr.Entity and vtr.Entity:GetClass() == "prop_vehicle_jeep" then 
			surface.SetDrawColor(Color(255, 0, 0, 55))
			local wps, hps = ScrW() / 2, ScrH() / 2
			surface.SetMaterial( ring2 )
			surface.DrawTexturedRect( wps - 10, hps - 10, 20, 20 )
			draw.SimpleText( "Blocked!", "NovaTrebuchet", wps + 15, hps - 7, Color(255,55,55, 35), TEXT_ALIGN_LEFT, 0 )
		end
	end
	return 
end
/*
if input.IsKeyDown( KEY_SPACE ) and input.IsKeyDown( KEY_W ) then
	local spin = Angle(0,0,math.tan(CurTime() * 10) * 360)
	car:ManipulateBoneAngles(car:LookupBone( "WHEEL_RL" ), spin)
	car:ManipulateBoneAngles(car:LookupBone( "WHEEL_RR" ), spin)
end
*/
if nova_3dhud:GetInt() == 1 then return end

local dashpos = ( ply:EyePos() + ply:GetAngles():Up() * -10 + ply:GetAngles():Forward() * 35):ToScreen()
if car:GetThirdPersonMode() then dashpos.x = ScrW() / 2 + 50 dashpos.y = ScrH() - 100 end

DoVehicleHud( dashpos.x, dashpos.y, car, true )

end
hook.Add( "HUDPaint", "carcontroller_hud", CarControllerHud)

local function DrawDoubleTexturedRect( x, y, w, h )
surface.SetMaterial( downgrad )
surface.DrawTexturedRect( x, y, w, h / 1.5 )
surface.SetMaterial( upgrad )
surface.DrawTexturedRect( x, (y + h) - h / 1.5, w, h / 1.5 )
end

local function DrawInlineBox( x, y, w, h, out, c1, c2 )
		surface.SetDrawColor( c1 )
		surface.DrawRect( x, y, w, h )
		surface.SetDrawColor( c2 )
		surface.SetMaterial( downgrad )
		surface.DrawTexturedRect( x, y, w, out )
		surface.SetMaterial( upgrad )
		surface.DrawTexturedRect( x, y + h - out, w, out )
		surface.SetMaterial( grad )
		surface.DrawTexturedRect( x, y, out, h )
		surface.DrawTexturedRectRotated( x + w - (out / 2), y + h / 2, out, h, 180 )
end

local function genericpaintbutton( c, w, h )
 --   surface.SetDrawColor( c )
 	surface.SetDrawColor( Color(0,0,0) )
    surface.DrawRect( 0, 0, w, h )
    surface.SetMaterial( downgrad )
 	surface.SetDrawColor( Color(50,50,50) )
	surface.DrawTexturedRect( 0, 0, w, h )
    surface.SetDrawColor( Color(c.r / 2, c.g / 2, c.b / 2, 255) )
    surface.DrawOutlinedRect( 0, 0, w, h )
end

local function genericbutton( x, y, bw, bh, col, txt, func )
local TButton = vgui.Create( "DButton", CC_Vmenu )
	TButton:SetPos( x, y )
	TButton:SetText( txt )
	TButton:SetTextColor( Color(255, 255, 255, 255) )
	TButton:SetSize( bw, bh )
	TButton.Paint = function( self, w, h )
		genericpaintbutton( col, w, h )
	end
	TButton.DoClick = func
end

local function genericroundbutton( x, y, bw, bh, tx, f, num )

local sbg = vgui.Create( "DPanel", CC_Vmenu )
--sbg:SetParent( parent )
sbg:SetPos( x, y )
sbg:SetSize( bw, bh )
sbg.txt = tx
local car = LocalPlayer():GetVehicle()
if car and car:IsValid() and car.CS_Stats and car.CS_Stats.SirenState then
	sbg.func = car.CS_Stats.SirenState[f]
else
	return
end
sbg.num = num

sbg.Paint = function( self, w, h )
    surface.SetDrawColor( 10, 10, 10, 255 )
    surface.DrawRect(0, 0, w, h )
    surface.SetDrawColor( 40, 40, 40, 255 )
    surface.SetMaterial( downgrad )
    surface.DrawTexturedRect(0, 0, w, h - 3 )
	draw.SimpleText( self.txt, "NovaTrebuchetSmall", 5, h - 18, Color( 205, 205, 205, 50 ))
end


local TButton = vgui.Create( "DButton", sbg )
	TButton:SetPos( 3, 3 )
	TButton:SetText( "" )
	TButton:SetTextColor( Color(255, 255, 255, 255) )
	TButton:SetSize( 25, 25 )
	TButton.Paint = function( self, w, h )
		local c = Color( 255, 0, 0 )
		local car = LocalPlayer():GetVehicle()
		local dynf = 0
		if car and car:IsValid() and car.CS_Stats and car.CS_Stats.SirenState then
			dynf = car.CS_Stats.SirenState[f]
		end
		if dynf == sbg.num then c = Color( 0, 255, 0 ) end
		surface.SetMaterial( roundmat )
		surface.SetDrawColor( c )
		surface.DrawTexturedRect( 0, 0, w, h )
		surface.SetDrawColor( Color(c.r, c.g, c.b, 150) )
		surface.SetMaterial( ring2 )
		surface.DrawTexturedRect( 0, 0, w, h )
	end
	function TButton:DoClick()
		if f == "Sound" then
			RunConsoleCommand( "nova_setsirenmode", sbg.num, car.CS_Stats.SirenState.Lights )
		else
			RunConsoleCommand( "nova_setsirenmode", car.CS_Stats.SirenState.Sound, sbg.num )
		end
	end
end

local kmat = Material( "icon16/key.png" )
local function CreateVehicleMenu()
	if CC_Vmenu and CC_Vmenu:IsValid() then return end
	if !LocalPlayer():GetVehicle():IsValid() or !LocalPlayer():GetVehicle().CS_Stats then return end

	local car = LocalPlayer():GetVehicle()
	local r = car.CS_Stats
	if r.Seat and r.Parent and r.Parent:IsValid() then car = r.Parent r = r.Parent.CS_Stats end
	if !r then return end
	local r2 = CMOD_Cars[car:GetVehicleClass()]
	if !r2 then r2 = CMOD_Cars[car.CS_Stats.Class] end -- workaround for photon fucking with vehicle classnames
	local hp = math.Clamp(car:GetNWFloat("VehicleHealth", 0) / 10, 0, 255)
	
	CC_Vmenu = vgui.Create("DFrame")
	if r2 and r2.Sirens then
		CC_Vmenu:SetSize(400,405)
	else
		CC_Vmenu:SetSize(400,330)
	end
	CC_Vmenu:SetTitle("")
	CC_Vmenu:Center()
	CC_Vmenu:MakePopup()
	CC_Vmenu:ShowCloseButton( false )

	CC_Vmenu.Paint = function( panel, w, h )
		local hullcolor = ( Color(20, 120, 20, 150) )
		local hullcolor2 = ( Color(10, 60, 10, 150) )


		local ecolor = Color( 255 - (hp * 2.5), hp * 2.5 , 10, 150 )
		if hp < 0.1 then ecolor = Color( 50, 50, 50 ) end
		-- the actual window

		DrawInlineBox( 0, 0, w, h, 20, Color(30, 30, 30), Color(20, 20, 20) )
		DrawInlineBox( 160, 135, 225, 180, 10, Color(40, 40, 40), Color(20, 20, 20) )

		draw.SimpleText("NovaCars - Created by LegendofRobbo", "NovaTrebuchetSmall", 5, 5, Color( 205, 205, 205, 10 ))

		local n = "Nobody"
		if DarkRP and car:getDoorOwner() and car:getDoorOwner():IsValid() then n = car:getDoorOwner():Nick() end
		draw.SimpleText(NOVA_GetTranslatedString( "ownedby" )..n, "NovaTrebuchetSmall", 160, 45, Color( 205, 205, 205, 50 ))

		draw.SimpleText(NOVA_GetTranslatedString( "vmods" ), "NovaTrebuchetMods", 165, 118, Color( 205, 205, 205, 100 ))

		local it = 0
		for k, v in pairs( car:CMGetInstalledMods() ) do
			surface.SetDrawColor(Color(50,50,50))
			surface.DrawRect( 170, 145 + (it*22), 205, 20 )
			surface.SetDrawColor(Color(20,20,20))
			surface.DrawOutlinedRect( 170, 145 + (it*22), 205, 20 )
			draw.SimpleText(k, "NovaTrebuchetMods", 272, 148 + (it*22), Color( 205, 205, 205 ), 1)
			it = it + 1
		end


		draw.RoundedBox( 10, 20, 20, 135, 260, Color(0,0,0) )

		if r2 and r2.Sirens then
			surface.SetDrawColor( Color( 50, 50, 50 ) )
			surface.DrawOutlinedRect( 25, 325, w - 45, 60 )
		end

		-- hull outer
		surface.SetDrawColor(hullcolor)
		surface.DrawOutlinedRect( 25, 25, 125, 250 )

		-- engine
		surface.SetDrawColor(ecolor)
		DrawDoubleTexturedRect( 60, 35, 55, 55 )
		surface.SetDrawColor(hullcolor)
		surface.DrawOutlinedRect( 60, 35, 55, 55 )
		if hp < 0.1 then draw.SimpleText("DESTROYED", "NovaTrebuchet", 52, 55, Color( 255, 0, 0 )) end

		-- wheels
		local wwpos = {
			[1] = {26, 45, 20, 40},
			[2] = {129, 45, 20, 40},
			[3] = {26, 210, 20, 40}, 
			[4] = {129, 210, 20, 40},
			}
		for k, v in pairs(r.Wheels) do
			if v > 0 then surface.SetDrawColor(Color(200 - (v * 2), v * 1.5, 0, 100)) else surface.SetDrawColor(Color( 20, 20, 20) ) end
			
			DrawDoubleTexturedRect( wwpos[k+1][1], wwpos[k+1][2], wwpos[k+1][3], wwpos[k+1][4] )
		end

		surface.SetDrawColor(hullcolor)
		surface.DrawOutlinedRect( 26, 45, 20, 40 )
		surface.DrawOutlinedRect( 26, 210, 20, 40 )
		surface.DrawOutlinedRect( 129, 45, 20, 40 )
		surface.DrawOutlinedRect( 129, 210, 20, 40 )



		-- detail shit
		surface.SetDrawColor(hullcolor2)
		surface.DrawOutlinedRect( 35, 95, 105, 25 )

		draw.SimpleText(r.Name, "Trebuchet24", 160, 20, Color( 255, 255, 255 ))

	end

	local xit = vgui.Create( "DButton", CC_Vmenu )
	xit:SetText( "" )
	xit:SetPos( CC_Vmenu:GetWide() - 25, 5 )
	xit:SetSize( 20, 15 )
	xit.DoClick = function()
		gui.EnableScreenClicker( false )
		CC_Vmenu:Remove()
	end
	xit.Paint = function( self, w, h )
		surface.SetDrawColor( Color( 50, 50, 50 ) )
		surface.DrawOutlinedRect( 0, 0, w, h )
		draw.SimpleText( "X", "Trebuchet18", w / 2, 8, Color(255,255,255), 1, 1 )
	end



	if LocalPlayer():GetVehicle():GetClass() == "prop_vehicle_jeep" then
		genericbutton( 160, 65, 110, 20, Color(55, 155, 55, 55), NOVA_GetTranslatedString( "scruise" ), function() 
			if nova_safecruise:GetInt() != 0 then 
				RunConsoleCommand("nova_safecruise", "0") 
			else
				RunConsoleCommand("nova_safecruise", "1") 
			end 
		end )

		if r2 and r2.Sirens then
			genericroundbutton( 35, 330, 30, 50, "Wail", "Sound", 1 )
			genericroundbutton( 70, 330, 30, 50, "High", "Sound", 2 )
			genericroundbutton( 105, 330, 30, 50, "Pulse", "Sound", 3 )
			genericroundbutton( 140, 330, 30, 50, "HiLo", "Sound", 4 )
			genericroundbutton( 175, 330, 30, 50, "Mute", "Sound", 0 )
			genericroundbutton( 270, 330, 30, 50, "WAVE", "Lights", 1 )
			genericroundbutton( 305, 330, 30, 50, "FLSH", "Lights", 2 )
			genericroundbutton( 340, 330, 30, 50, "STRB", "Lights", 3 )
		end

		if NOVA_Config.EnableManualEngineStarting and hp > 0.1 then
			local TButton = vgui.Create( "DButton", CC_Vmenu )
			TButton:SetPos( 80, 55 )
			TButton:SetText( "" )
			TButton:SetSize( 16, 16 )
			TButton.Paint = function( self, w, h )
				if !LocalPlayer():GetVehicle():GetNWBool( "NCEngineOn", false ) then
					surface.SetDrawColor(Color(255,255,255))
				else
					surface.SetDrawColor(Color(55,55,55))
				end
				surface.SetMaterial( kmat )
				surface.DrawTexturedRect( 0, 0, w, h )
			end
			TButton.DoClick = function() 
				if LocalPlayer():GetVehicle():GetNWBool( "NCEngineOn", false ) then
					RunConsoleCommand("nova_stopcar")
				else
					RunConsoleCommand("nova_startcar")
				end
			end
		end

		genericbutton( 275, 65, 110, 20, Color(155, 155, 55, 55), NOVA_GetTranslatedString( "hlights" ), function() RunConsoleCommand("nova_toggleheadlights") end  )
		genericbutton( 160, 90, 110, 20, Color(255, 155, 55, 55), NOVA_GetTranslatedString( "locks" ), function() RunConsoleCommand("nova_toggledoorlocks") end  )
		genericbutton( 275, 90, 110, 20, Color(55, 55, 155, 55), NOVA_GetTranslatedString( "mousesteer" ), function() 
			if nova_mousedrive:GetInt() != 0 then 
				RunConsoleCommand("nova_mouse_assisted_driving", "0") 
			else
				RunConsoleCommand("nova_mouse_assisted_driving", "1") 
			end 
		end )
	end

	genericbutton( 25, 285, 125, 30, Color(155, 155, 155, 55), NOVA_GetTranslatedString( "options" ), function() RunConsoleCommand( "nova_client_settings" ) end  )

	if not r2 then return end

	-- driver seat request buttons
	local TButton = vgui.Create( "DButton", CC_Vmenu )
	TButton:SetPos( 50, 125 )
	TButton:SetText( "D" )
	TButton:SetSize( 25, 25 )

	TButton.Paint = function( self, w, h )
	surface.SetDrawColor(Color(55, 55, 55, 255))
	surface.DrawOutlinedRect( 0, 0, w, h )
	surface.SetDrawColor(Color(155, 155, 155, 255))
	surface.DrawOutlinedRect( 1, 1, w - 2, h - 2 )
	end

	TButton.DoClick = function() 
			net.Start("RequestSeat")
			net.WriteUInt( 1, 8 )
			net.SendToServer()
	end

	-- seat request buttons
	for k, v in pairs( r2.Passengers ) do

		local vert = math.Round( (k - 1) / 2 )
		local TButton = vgui.Create( "DButton", CC_Vmenu )
		local xpos = 100
		if k % 2 == 0 then xpos = 50 end
		TButton:SetPos( xpos, 125 + (vert * 30) )
		TButton:SetText( k )
		TButton:SetSize( 25, 25 )

		TButton.Paint = function( self, w, h )
		surface.SetDrawColor(Color(55, 55, 55, 255))
		surface.DrawOutlinedRect( 0, 0, w, h )
		surface.SetDrawColor(Color(155, 155, 155, 255))
		surface.DrawOutlinedRect( 1, 1, w - 2, h - 2 )
		end

		TButton.DoClick = function() 
			net.Start("RequestSeat")
			net.WriteUInt( k + 1, 8 )
			net.SendToServer()
		end

		if LocalPlayer():GetVehicle():IsNovaCar() then

			local TButton = vgui.Create( "DButton", CC_Vmenu )
			local xpos = 130
			local tx = ">"
			if k % 2 == 0 then xpos = 30 tx = "<" end
			TButton:SetPos( xpos, 125 + (vert * 30) )
			TButton:SetText( tx )
			TButton:SetTextColor( Color(155, 0, 0 ) )
			TButton:SetSize( 15, 25 )

			TButton.Paint = function( self, w, h )
				surface.SetDrawColor(Color(55, 5, 5, 255))
				surface.DrawOutlinedRect( 0, 0, w, h )
--				surface.SetDrawColor(Color(155, 155, 155, 255))
--				surface.DrawOutlinedRect( 1, 1, w - 2, h - 2 )
			end

			TButton.DoClick = function() 
				net.Start("KickSeat")
				net.WriteUInt( k + 1, 8 )
				net.SendToServer()
			end

		end

	end

end
concommand.Add("nova_carmenu", CreateVehicleMenu)

local function GenericMakeSlider( parent, x, y, length, text, min, max, var, tt )
if !parent:IsValid() then return end

local sbg = vgui.Create( "DPanel" )
sbg:SetParent( parent )
sbg:SetPos( x, y )
sbg:SetSize( length, 25 )

sbg.Paint = function( self, w, h )
    surface.SetDrawColor( 60, 60, 60, 255 )
    surface.DrawRect(0, 0, w, h )
    surface.SetDrawColor( 100, 100, 100, 255 )
    surface.SetMaterial( downgrad )
    surface.DrawTexturedRect(0, 0, w, h - 3 )
end

local NumSlider = vgui.Create( "DNumSlider", sbg )
NumSlider:SetPos( 10,-5 )
NumSlider:SetWide( length - 10 )
NumSlider:SetText( text )
NumSlider:SetMin( min )
NumSlider:SetMax( max )
NumSlider:SetConVar( var )
NumSlider:SetDecimals( 0 )
NumSlider:SetTooltip( tt )

end

local function GenericMakeBinder( x, y, txt, cccode, ccrun )

	local sbg = vgui.Create( "DPanel", CC_SettingsMenu )
	sbg:SetPos( x, y )
	sbg:SetSize( CC_SettingsMenu:GetWide() - 40, 25 )

	sbg.Paint = function( self, w, h )
    	surface.SetDrawColor( 60, 60, 60, 255 )
    	surface.DrawRect(0, 0, w, h )
    	surface.SetDrawColor( 100, 100, 100, 255 )
    	surface.SetMaterial( downgrad )
    	surface.DrawTexturedRect(0, 0, w, h - 3 )
	end

	local tx = vgui.Create( "DLabel", sbg )
	tx:SetText( txt )
	tx:SizeToContents()
	tx:SetPos( 5, 5 )

	local binder = vgui.Create( "DBinder", sbg )
	binder:SetSize( 100, 20 )
	binder:SetPos( sbg:GetWide() - 105, 2 )
	binder:SetSelected( cccode:GetInt() )

	function binder:SetSelectedNumber( num )
		self.m_iSelectedNumber = num
		RunConsoleCommand( ccrun, tostring(num) )
	end
end

local function CreateSettingsMenu()
	if CC_SettingsMenu and CC_SettingsMenu:IsValid() then return end
	
	CC_SettingsMenu = vgui.Create("DFrame")
	CC_SettingsMenu:SetSize(400,550)
	CC_SettingsMenu:SetTitle("")
	CC_SettingsMenu:Center()
	CC_SettingsMenu:MakePopup()
	CC_SettingsMenu:ShowCloseButton( true )

	CC_SettingsMenu.Paint = function( panel, w, h )
		DrawInlineBox( 0, 0, w, h, 20, Color(30, 30, 30), Color(20, 20, 20) )
		draw.SimpleText("NovaCars - Created by LegendofRobbo", "NovaTrebuchetSmall", 5, 5, Color( 205, 205, 205, 10 ))
	end

	GenericMakeSlider( CC_SettingsMenu, 20, 30, 360, NOVA_GetTranslatedString("fxr"), 0, 5000, "nova_config_fxrenderdistance", "The maximum distance at which effects (engine smoke, wheel effects, skids etc) render at" )
	GenericMakeSlider( CC_SettingsMenu, 20, 60, 360, NOVA_GetTranslatedString("fxd"), 0, 200, "nova_config_fxrenderdensity", "Controls particle density, skid resolution etc.  Recommended value: 150" )
	GenericMakeSlider( CC_SettingsMenu, 20, 100, 175, NOVA_GetTranslatedString("rskids"), 0, 1, "nova_config_renderskids", "Do we want to render skids on the road? turning this off can save a lot of performance" )
	GenericMakeSlider( CC_SettingsMenu, 205, 100, 175, NOVA_GetTranslatedString("skidd"), 1, 30, "nova_config_skid_duration", "How long do skids last?" )
	GenericMakeSlider( CC_SettingsMenu, 20, 130, 175, NOVA_GetTranslatedString("wfx"), 0, 1, "nova_config_wheel_effects", "Do we want to render skids on the road? turning this off can save a lot of performance" )
	GenericMakeSlider( CC_SettingsMenu, 20, 160, 360, NOVA_GetTranslatedString("dhd"), 0, 1, "nova_config_dynamicheadlights", "Render dynamic headlight cone?" )

	GenericMakeSlider( CC_SettingsMenu, 20, 200, 175, NOVA_GetTranslatedString("shd"), 0, 1, "nova_show_driver_body", "Show your playermodel when driving a car" )
	GenericMakeSlider( CC_SettingsMenu, 205, 200, 175, NOVA_GetTranslatedString("msp"), 0, 1, "nova_metric_speedometer", "Show speed in kph instead of mph" )
	GenericMakeSlider( CC_SettingsMenu, 20, 230, 360, NOVA_GetTranslatedString("mss"), 50, 250, "nova_config_mousedrive_sensitivity", "How far do you have to move the mouse left or right to steer?" )
	GenericMakeSlider( CC_SettingsMenu, 20, 260, 360, NOVA_GetTranslatedString("idrive"), 0, 1, "nova_config_immersive_driving_camera", "How far do you have to move the mouse left or right to steer?" )
	GenericMakeSlider( CC_SettingsMenu, 20, 290, 360, NOVA_GetTranslatedString("3dhud"), 0, 1, "nova_config_3d_hud", "Should the hud be drawn in a 3d context or not?" )

	GenericMakeBinder( 20, 330, "Vehicle Horn", nova_bind_horn, "nova_keybinds_horn" )
	GenericMakeBinder( 20, 360, "Toggle Sirens", nova_bind_siren, "nova_keybinds_siren" )
	GenericMakeBinder( 20, 390, "Use Nitrous Boost", nova_bind_nos, "nova_keybinds_nos" )
	GenericMakeBinder( 20, 420, "Start Engine", nova_bind_engine, "nova_keybinds_engine" )
	GenericMakeBinder( 20, 450, "Boost Jump", nova_bind_jump, "nova_keybinds_jump" )
	GenericMakeBinder( 20, 480, "Headlights", nova_bind_headlights, "nova_keybinds_headlights" )

	local TButton = vgui.Create( "DButton", CC_SettingsMenu )
	TButton:SetPos( 20, CC_SettingsMenu:GetTall() - 30 )
	TButton:SetText( NOVA_GetTranslatedString("reset") )
	TButton:SetTextColor( Color(255, 255, 255, 255) )
	TButton:SetSize( 360, 25 )
	TButton.Paint = function( self, w, h )
		genericpaintbutton( Color(155,155,155), w, h )
	end
	TButton.DoClick = function() 
		RunConsoleCommand( "nova_show_driver_body", "1" )
		RunConsoleCommand( "nova_config_wheel_effects", "1" )
		RunConsoleCommand( "nova_config_fxrenderdistance", "2000" )
		RunConsoleCommand( "nova_config_fxrenderdensity", "150" )
		RunConsoleCommand( "nova_config_renderskids", "1" )
		RunConsoleCommand( "nova_config_skid_duration", "10" )
		RunConsoleCommand( "nova_config_dynamicheadlights", "1" )
		RunConsoleCommand( "nova_config_mousedrive_sensitivity", "100" )
	end

end
concommand.Add("nova_client_settings", CreateSettingsMenu)


hook.Add( "PrePlayerDraw", "NCFixVehicleFP", function( p )
	if p != LocalPlayer() or !p:IsValid() or !p:Alive() or nova_showdriver:GetInt() != 1 or !p:GetVehicle():IsValid() or !p:GetVehicle():IsNovaCar() then return end
    local normal = -p:GetUp()
    local pos = p:EyePos() - Vector( 0, 0, 6 )
    local distance = normal:Dot(pos)
 
    p:SetRenderClipPlaneEnabled(true)
    p:SetRenderClipPlane(normal, distance)
   	p:SetRenderClipPlaneEnabled(false)
    return false
end)

-- this is mostly c+p from gmods base gamemode
local eyepoz = Vector(0,0,0)
local addvel = Vector(0,0,0)
local rollang = 0
local bumppunch = Vector(0,0,0)
local bumppunchtarget = Vector(0,0,0)

local function DoCarCamera( car, ply, view )
	if !ply:IsValid() or !car:IsValid() or car:GetClass() != "prop_vehicle_jeep" then return end
	if ( !car:GetThirdPersonMode() or !NOVA_Config.AllowThirdPerson ) then 
		if nova_showdriver:GetInt() == 1 then view.drawviewer = true end
		eyepoz = view.origin
		if nova_immersivedriving:GetInt() == 1 then
			rollang = math.Clamp( Lerp( FrameTime() * 1.5, rollang, car:GetVelocity():Dot(car:GetAngles():Forward()) ), -8, 8 )
			addvel = LerpVector( FrameTime() * 10, addvel, -car:GetVelocity() / 120 )
			addvel = Vector( math.Clamp(addvel.x, -2, 2 ), math.Clamp(addvel.y, -2, 2 ), math.Clamp(addvel.z, -2, 2 ) )
			view.angles.r = view.angles.r + (rollang / 10)

			/*
			if car:GetVelocity():Length() > 400 then
				local sped = car:GetVelocity():Length()
				if math.random( 0, 100 ) < (sped / 100) and ( bumppunchtarget.x + bumppunchtarget.y + bumppunchtarget.z ) == 0 then
					bumppunchtarget = Vector( math.Rand( -0.2, 0.2), math.Rand( -0.2, 0.2), math.Rand( -0.2, 0.2) )
				end
				bumppunch = LerpVector( FrameTime() * 15, bumppunch, bumppunchtarget )
				if bumppunch:Distance(bumppunchtarget) < 0.1 then bumppunchtarget = Vector(0,0,0) end
			end
			*/

			view.origin = view.origin + addvel
		end

		return view 
	end

	local mn, mx = car:GetRenderBounds()
	local radius = ( mn - mx ):Length()
	local radius = radius + radius * car:GetCameraDistance()

	local TargetOrigin = view.origin + ( view.angles:Forward() * -radius )
	local WallOffset = 4

	local tr = util.TraceHull( {
		start = view.origin,
		endpos = TargetOrigin,
		filter = function( e )
			local c = e:GetClass()
			return !c:StartWith( "prop_physics" ) &&!c:StartWith( "prop_dynamic" ) && !c:StartWith( "prop_ragdoll" ) && !e:IsVehicle() && !c:StartWith( "gmod_" )
		end,
		mins = Vector( -WallOffset, -WallOffset, -WallOffset ),
		maxs = Vector( WallOffset, WallOffset, WallOffset ),
	} )

	view.origin = tr.HitPos
	view.drawviewer = true

	--
	-- If the trace hit something, put the camera there.
	--
	if ( tr.Hit && !tr.StartSolid) then
		view.origin = view.origin + tr.HitNormal * WallOffset
	end

	eyepoz = view.origin
	return view

end
hook.Add( "CalcVehicleView", "Nova_CarCamera", DoCarCamera )




local function updatelight( l, car )
	if nova_dynamicheadlights:GetInt() != 1 then return end
	local r = CMOD_Cars[car:GetVehicleClass()]
	if !r and car.CS_Stats then r = CMOD_Cars[car.CS_Stats.Class] end
	local foffset = -90 -- instead of storing a seperate value for headlights forward offset lets just do this the smart way and grab it from the position of the headlight sprites
	if r and r.Headlights then foffset = -(r.Headlights[1].y + 5) end
	l:SetPos( car:GetPos() + car:GetAngles():Right() * foffset + car:GetAngles():Up() * 40 )
	l:SetAngles( car:GetAngles() + Angle( 0, 90, 0) )
	l:SetFOV( 110 )
	l:SetBrightness( 2 )
	l:SetEnableShadows( false )
	l:SetFarZ( 1400 )
	l:SetTexture( "effects/flashlight001" )
	l:SetColor( Color(255, 255, 235) )
	l:Update()
end

local function angledifference( a1, a2 )
       local DiffY = math.abs( math.NormalizeAngle( (a1.y + 90) - a2.y ) )
	return DiffY
end

local function numberinrage( num, lower, upper )
	return num >= lower and num <= upper
end



local skiddies = {}

local function addskidchunk( id, pos )
	if pos:Distance( LocalPlayer():GetPos() ) > nova_fxdistance:GetInt() or nova_doskids:GetInt() != 1 then return end -- dont even bother wasting cpu cycles on skids that are too far away to see
	if !skiddies[id] then
		skiddies[id] = { {p = pos, t = CurTime() + nova_skidduration:GetInt()} }
	else
		table.insert( skiddies[id], { p = pos, t = CurTime() + nova_skidduration:GetInt() } )
	end
end 

local function iterateskids()
	for id, tab in pairs( skiddies ) do
		for k, v in pairs( tab ) do
			if v.t and v.t <= CurTime() then table.remove( tab, k ) end
			if #tab <= 0 then skiddies[id] = nil end
		end
	end
end

local nxtsmok = CurTime()
local skidid = 0
local function carsmoke()
	if nxtsmok > CurTime() then return end
	local cars = ents.FindByClass("prop_vehicle_jeep")
	for k, v in pairs( cars ) do
		if v:GetPos():Distance( LocalPlayer():GetPos()) > nova_fxdistance:GetInt() or v:WaterLevel() >= 2 then continue end
		if v:GetNWBool( "Sirens", false ) then
			if !v.CS_Stats or !v.CS_Stats.SirenState then continue end
			local wav = v.CS_Stats.SirenState.Sound
			-- really facepunch? what a shitty system
			if !v.SirenSoundsTable then v.SirenSoundsTable = {
					[1] = CreateSound( v, "novacars/siren1.wav" ),
					[2] = CreateSound( v, "novacars/siren2.wav" ),
					[3] = CreateSound( v, "novacars/siren3.wav" ),
					[4] = CreateSound( v, "novacars/siren4.wav" ),
					[5] = CreateSound( v, "novacars/siren_pulse.wav" ),
				}
			end
			if !v.SirenSound or ( v.SirenSound and !v.SirenSound:IsPlaying() ) then
				if v.SirenSoundsTable[wav] then
					v.SirenSound = v.SirenSoundsTable[wav]
					v.SirenSound:SetSoundLevel( 85 )
					v.SirenSound:Play()
				else
					if v.SirenSound then v.SirenSound:Stop() end
				end
			end

		else
			if v.SirenSound and v.SirenSound:IsPlaying() then v.SirenSound:Stop() end
		end


		if v:GetNWFloat("VehicleHealth", 1000) <= 0 then
			local efx = EffectData()
			efx:SetEntity( v )
			util.Effect( "nova_enginesmoke_destroyed", efx )
		elseif v:GetNWFloat("VehicleHealth", 1000) < 250 then
			local efx = EffectData()
			efx:SetEntity( v )
			util.Effect( "nova_enginesmoke_oil", efx )
		elseif v:GetNWFloat("VehicleHealth", 1000) < 500 then
			local efx = EffectData()
			efx:SetEntity( v )
			util.Effect( "nova_enginesmoke_radiator", efx )
		end

		local skidsound = false
		local wang = 0
		if v.CS_Stats and v.CS_Stats.Wheelpositions and nova_wheelfx:GetInt() == 1 and v.tyreheat then
			for idx, w in pairs( v.CS_Stats.Wheelpositions ) do
				local poz = v:LocalToWorld( w )
				local tr = util.TraceLine( {start = poz, endpos = poz + Vector(0,0,-50), mask = MASK_SOLID_BRUSHONLY} )
				local vlen = v:GetVelocity():Length()
				if !tr.Hit then continue end
				if (tr.MatType == 68 or tr.MatType == 78 or tr.MatType == 85) and vlen > 400 then 
					if !skidsound then -- don't spam sounds from all 4 wheels, it sounds horrible
						if v.tyreheat > 0 then 
							sound.Play( "novacars/drive_gravel.wav", poz, 80, math.random(105,125), math.Rand(0.65, 0.8) )
						else
							sound.Play( "novacars/drive_gravel.wav", poz, 70, math.random(85,105), math.Rand(0.35, 0.45) )
						end
						skidsound = true
					end	
					local efx = EffectData()
					efx:SetOrigin( poz - Vector(0,0,20) )
					util.Effect( "nova_wheel_dust", efx )
				end
				local slideangle = angledifference( v:GetVelocity():Angle(), v:GetAngles() )
				if ( (input.IsKeyDown( KEY_SPACE ) and LocalPlayer():GetVehicle() == v) or (!numberinrage( slideangle, 165, 195 ) and slideangle >= 15) ) and vlen > 400 then
					v.tyreheat = math.Clamp((v.tyreheat or 0) + 20, 0, 100)
				else
					v.tyreheat = math.Clamp((v.tyreheat or 0) - 5, 0, 100)
				end

				if v.tyreheat > 0 and vlen > 200 and ( tr.MatType == 67 or tr.MatType == 77 ) then
					skidid = skidid or math.random( 0, 99999 )
					local efx = EffectData()
					efx:SetOrigin( poz - Vector(0,0,20) )
					util.Effect( "nova_wheel_skidz", efx )
					addskidchunk( v:EntIndex()..idx..skidid, tr.HitPos + Vector(0,0,1) )
					if !skidsound then -- don't spam sounds from all 4 wheels, it sounds horrible
						sound.Play( "novacars/skidz_short.wav", poz, 75, math.random(85,105), 0.25 )
						skidsound = true
					end	
				elseif skidid then 
					v.tyreheat = math.Clamp((v.tyreheat or 0) - 5, 0, 200) 
					skidid = nil 
				end
			end
		end


	end
	nxtsmok = CurTime() + math.Clamp(0.2 - (nova_fxdensity:GetInt() * 0.001), 0.01, 0.2)
end
hook.Add( "Tick", "Nova_CarSmoke", carsmoke)


hook.Add( "EntityRemoved", "NovaFixSirenSounds", function( car ) 
	if !car:IsValid() or car:GetClass() != "prop_vehicle_jeep" then return end
	if car.SirenSound then car.SirenSound:Stop() end
end)

local function clearlight( c )
	if c:IsValid() and c:GetClass() == "prop_vehicle_jeep" then
		if c.Headlightent and c.Headlightent:IsValid() then c.Headlightent:Remove() c.Headlightent = nil end
	end
end

local glowmat, inner, outer = Material( "particle/particle_glow_04_additive" ), Color( 255, 255, 255, 255 ), Color( 255, 255, 255, 55 )
local cuck = Material( "sprites/animglow02" )
local function doheadlights()
	local cars = ents.FindByClass("prop_vehicle_jeep")
	if !CMOD_Cars then return end
	for k, v in pairs( cars ) do
		local r = CMOD_Cars[v:GetVehicleClass()]
		if !r then continue end
		if v:GetPos():Distance(LocalPlayer():GetPos()) > nova_fxdistance:GetInt() then clearlight( v ) continue end
		if v:GetNWBool( "Headlights", false ) then
			if !v.Headlightent and nova_dynamicheadlights:GetInt() == 1 then v.Headlightent = ProjectedTexture() end
			updatelight( v.Headlightent, v )
			-- headlights
			if r and r.Headlights then
				cam.Start3D()
				cam.IgnoreZ( true )
					for _, l in pairs( r.Headlights ) do
						local pz = v:LocalToWorld( l )

						local anglediff = viewangledifference( v:GetAngles() )
						if anglediff > 205 then continue end -- save ourselves a few pointless calculations here

						local filtertab = { LocalPlayer(), v }
						local mycar = LocalPlayer():GetVehicle()
						local r2 = mycar.CS_Stats
						if !r2 then return end
						if LocalPlayer():InVehicle() then 
							table.insert( filtertab, LocalPlayer():GetVehicle() )
							if r2.Seat and r2.Parent and r2.Parent:IsValid() then table.insert( filtertab, r2.Parent ) end
						end

						local viztrace = util.TraceLine( {start = EyePos(), endpos = pz, filter = filtertab, mask = MASK_SHOT } )
						if viztrace.Hit then continue end
						render.SetMaterial( glowmat )
						local c1 = Color( 255,255,255, math.Clamp(255 - anglediff * 2.5, 0, 255) )
						local c2 = Color( 255,255,255, math.Clamp(155 - anglediff * 4, 0, 155) )
						render.DrawSprite( pz, 35, 35, c1 )
						render.DrawSprite( pz, 90, 5, c2 )
						render.DrawSprite( pz, 60, 60, c2 )

						if anglediff < 160 then
							render.DrawQuadEasy( pz + v:GetAngles():Right() * 2, v:GetAngles():Right() * -1, 13, 13, c1, 0 )
						end
					end
				cam.IgnoreZ( false )
				cam.End3D()
			end

		else
			clearlight( v )
		end

		-- tail lights
		if r and r.TailLights and (v:GetNWBool( "NCTailLights", false ) or v:GetNWBool( "Headlights", false )) then
			cam.Start3D()
			cam.IgnoreZ( true )
				for _, l in pairs( r.TailLights ) do

					local pz = v:LocalToWorld( l )

					local filtertab = { LocalPlayer(), v }
					local mycar = LocalPlayer():GetVehicle()
					local r2 = mycar.CS_Stats
					if !r2 then return end
					if LocalPlayer():InVehicle() then 
						table.insert( filtertab, LocalPlayer():GetVehicle() )
						if r2.Seat and r2.Parent and r2.Parent:IsValid() then table.insert( filtertab, r2.Parent ) end
					end

					local viztrace = util.TraceLine( {start = EyePos(), endpos = pz, filter = filtertab, mask = MASK_SHOT } )
					if viztrace.Hit then continue end
					render.SetMaterial( glowmat )
					local anglediff = viewangledifference( v:GetAngles() )
					if anglediff < 105 then continue end
					local c1 = Color( 255,5,5, math.Clamp(-190 + (anglediff * 0.55) ^ 1.1, 0, 255) )
					local c2 = Color( 255,5,5, math.Clamp(-190 + (anglediff * 0.45) ^ 1.1, 0, 255) )
					if v:GetNWBool( "NCTailLights", false ) then
						render.DrawSprite( pz, 30, 30, c1 )
						render.DrawSprite( pz, 50, 5, c2 )
						render.DrawSprite( pz, 80, 80, Color(255,5,5, c2.a / 2) )
					else
						render.DrawSprite( pz, 20, 15, c1 )
						render.DrawSprite( pz, 40, 5, c2 )
					end
					if anglediff > 160 then
						render.DrawQuadEasy( pz + v:GetAngles():Right() * -2, v:GetAngles():Right() * 1, 13, 13, c1, 0 )
					end
				end
			cam.IgnoreZ( false )
			cam.End3D()
		end


		-- police sirens
--		local sirenmode = 1
		local yellow = false
		if v:GetNWBool( "Sirens", false ) then
			local sirenmode = v.CS_Stats.SirenState.Lights
			cam.Start3D()
			cam.IgnoreZ( true )
			if r and r.Sirens then
				for it, l in pairs( r.Sirens ) do

					local flashspeed = 20
					if sirenmode == 2 then it = it * 0.4 elseif sirenmode == 3 then it = it % 2 end
					local sinwave = math.sin( math.abs( SysTime() * flashspeed ) + it )
					local coswave = -math.cos( math.abs( SysTime() * flashspeed ) + it )
					local pz = v:LocalToWorld( l )
					pz = pz + v:GetAngles():Up() * 2

					local filtertab = { LocalPlayer() }
					local mycar = LocalPlayer():GetVehicle()
					local r2 = mycar.CS_Stats
					if !r2 then return end
					if LocalPlayer():InVehicle() and v != mycar then 
						table.insert( filtertab, LocalPlayer():GetVehicle() )
						if r2.Seat and r2.Parent and r2.Parent:IsValid() then table.insert( filtertab, r2.Parent ) end
					end

					local viztrace = util.TraceLine( {start = EyePos(), endpos = pz, filter = filtertab, mask = MASK_SHOT } )
					if viztrace.Hit then continue end

					render.SetMaterial( glowmat )
					local c1 = Color( math.Round(sinwave) * 255,0,math.Round(coswave) * 255, 255 )
					if yellow then c1 = Color( 255,155,0, math.Round(sinwave) * 255 ) end
					render.DrawSprite( pz, 28, 22, c1 )
					render.DrawSprite( pz, 70, 5, c1 )
					if c1.r > 200 or ( yellow and c1.a >= 250 ) then
						render.DrawSprite( pz, 98, 98, Color( 255, 5, 5, math.min( 30, c1.a ) ) )
					end
					if c1.b > 200 and !yellow then
						render.DrawSprite( pz, 98, 98, Color( 5, 5, 255, 30 ) )
					end
				end
			end
			cam.IgnoreZ( false )
			cam.End3D()
		end

	end

end
hook.Add( "PreDrawHUD", "UpdateHeadlights", doheadlights, -1 )

local skidmat = Material( "novacars/skiddies" )
local function RenderSkidChunk( p1, p2, h, c )
	if p1:Distance( LocalPlayer():GetPos() ) > nova_fxdistance:GetInt() or p2:Distance( LocalPlayer():GetPos() ) > nova_fxdistance:GetInt() then return end
	local ang = (p1 - p2):Angle()
	render.SetMaterial( skidmat )
	render.DrawQuad( p1 - ang:Right() * -5, p2 - ang:Right() * -5, p2 - ang:Right() * 5, p1 - ang:Right() * 5, c )
end

hook.Add( "PostDrawOpaqueRenderables", "Nova_RenderSkids", function()
	if nova_doskids:GetInt() != 1 then return end
	cam.Start3D()
--	if !skiddies or #skiddies <= 0 then cam.End3D() return end

	for id, tab in pairs( skiddies ) do
		local opos = Vector(0,0,0)
		for k, v in pairs( tab ) do
			if k == 1 then opos = v.p end
			RenderSkidChunk( v.p, opos, 0, Color(0,0,0, 200) )
			opos = v.p

			if v.t and v.t <= CurTime() then table.remove( tab, k ) end
			if #tab <= 0 then skiddies[id] = nil end
		end
	end


	cam.End3D()
end )


hook.Add( "EntityRemoved", "fixheadlightglitch", function( e ) if e:IsVehicle() then clearlight( e ) end end, -5)


hook.Add( "OnSpawnMenuOpen", "dix", function()
	if !LocalPlayer():InVehicle() then return end
	CreateVehicleMenu()
	return false
end )

hook.Add( "OnSpawnMenuClose", "dix2", function()
	if CC_Vmenu then CC_Vmenu:Remove() end
end )

net.Receive( "SendCarStats", function() 
local car = net.ReadEntity()
local stats = net.ReadTable()
if !car:IsValid() then return end
car.CS_Stats = stats
end )

net.Receive( "CMStopSirenSound", function() 
local car = net.ReadEntity()
if car.SirenSound and car.SirenSound:IsPlaying() then car.SirenSound:Stop() end
end )

net.Receive( "NCSendVehicleTableUpdate", function()
	local len = net.ReadUInt( 32 )
	local data = net.ReadData( len )
	if !data then chat.AddText( Color(255,0,0), "Novacars: Error decompressing vehicle table! Recieved nil or malformed data from server!" ) return end
	local raw = util.Decompress( data )
	if !raw then chat.AddText( Color(255,0,0), "Novacars: Error decompressing vehicle table! Recieved nil or malformed data from server!" ) return end
	CMOD_Cars = util.JSONToTable( raw )
end )