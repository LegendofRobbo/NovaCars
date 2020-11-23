SWEP.Category          = "Novacars"
SWEP.Instructions   = "Its a debug tool fam"
SWEP.ViewModelFlip		= false
SWEP.ViewModel			= "models/weapons/c_toolgun.mdl"
SWEP.WorldModel			= "models/weapons/w_toolgun.mdl"
SWEP.ViewModelFOV 		= 51
SWEP.BobScale 			= 2
SWEP.DrawCrosshair 			= false
SWEP.HoldType = "knife"
SWEP.Spawnable			= true
SWEP.AdminOnly		= true
SWEP.UseHands = true

SWEP.Primary.Recoil		= 5
SWEP.Primary.Damage		= 0
SWEP.Primary.NumShots		= 0
SWEP.Primary.Cone			= 0.075
SWEP.Primary.Delay 		= 1.5

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= 0
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= ""

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

SWEP.ShellEffect			= "none"
SWEP.ShellDelay			= 0

SWEP.Pistol				= true
SWEP.Rifle				= false
SWEP.Shotgun			= false
SWEP.Sniper				= false

SWEP.RunArmOffset 		= Vector (0, 0, 0)
SWEP.RunArmAngle	 		= Vector (0, 0, 0)

SWEP.Sequence			= 0

SWEP.HitDistance = 55

SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false

local CommittedCars = {}

local ctable = {
	["Class"] = "nil",
	["Name"] = "Test Car",
	["Passengers"] = {},
	["DamageResist"] = 1,
	["Headlights"] = {},
	["EnginePos"] = Vector( 0, 78.55, 59.43 ),
	["WheelHeightFix"] = 0,
}

if SERVER then util.AddNetworkString("PeanusWeanus") end

function SWEP:Deploy()

	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
	self.Weapon:SetNextPrimaryFire(CurTime() + 1)

	self.Weapon:SetHoldType("normal")

	return true
end


function SWEP:Think()
end

local wf = Material( "models/wireframe" )
function SWEP:DrawHUD()

	local tr = util.TraceLine ({
		start = LocalPlayer():GetShootPos(),
		endpos = LocalPlayer():GetShootPos() + LocalPlayer():GetAimVector() * 4096,
		filter = LocalPlayer(),
		mask = MASK_SHOT
	})

	local screenpos = tr.HitPos:ToScreen()
	local x = screenpos.x
	local y = screenpos.y
	
	surface.SetDrawColor(255, 255, 255, 155)
	surface.DrawRect(x-1, y-1, 2, 2)

	if !tr.Entity or !tr.Entity:IsValid() then return end
	local car = tr.Entity
	if car:GetClass() != "prop_vehicle_jeep" then return end
	local r = CMOD_Cars[car:GetVehicleClass()]
	if ctable.Class == car:GetVehicleClass() then r = ctable end
	if !r then draw.SimpleText( "Unscripted Car - No data available", "DermaDefault", x + 15, y - 10 ) return end
	draw.SimpleText( r.Name, "DermaDefault", x + 15, y - 10 )
	draw.SimpleText( "Toughness: "..(r.DamageResist * 100).."%", "DermaDefault", x + 15, y + 2, Color( 255, 255, 155 ) )
	draw.SimpleText( "Right Click: Set Headlight Positions", "DermaDefault", x + 15, y + 14, Color( 205, 205, 255, 150 ) )
	draw.SimpleText( "E + Right Click: Set Engine Position", "DermaDefault", x + 15, y + 26, Color( 205, 205, 255, 150 ) )
	draw.SimpleText( "E + Left Click: Set Taillight Position", "DermaDefault", x + 15, y + 38, Color( 205, 205, 255, 150 ) )
	draw.SimpleText( "R: Open Menu", "DermaDefault", x + 15, y + 50, Color( 205, 205, 255, 150 ) )
	draw.SimpleText( "Left Click: Select Vehicle", "DermaDefault", x + 15, y + 62, Color( 205, 205, 255, 150 ) )

	local pang = car:GetAngles()


	surface.SetDrawColor(255, 255, 55, 155)
	if r.Headlights then
		for _, l in pairs( r.Headlights ) do
			local pz = car:LocalToWorld( l ):ToScreen()
			surface.DrawRect(pz.x-3, pz.y-3, 6, 6)
		end
	end

	surface.SetDrawColor(255, 55, 55, 155)
	if r.TailLights then
		for _, l in pairs( r.TailLights ) do
			local pz = car:LocalToWorld( l ):ToScreen()
			surface.DrawRect(pz.x-3, pz.y-3, 6, 6)
		end
	end
	
	if r.EnginePos then
		local ep = car:LocalToWorld( r.EnginePos )
		local pz = ep:ToScreen()
		surface.SetDrawColor(55, 255, 55, 155)
		surface.DrawRect(pz.x-4, pz.y-4, 8, 8)
		surface.SetDrawColor(255, 255, 255, 155)
		surface.DrawRect(pz.x-1, pz.y-1, 2, 2)
		draw.SimpleText( "Engine", "DermaDefault", pz.x + 10, pz.y - 5 )
		cam.Start3D()
--			render.SetMaterial( wf )
			render.DrawWireframeBox( ep + pang:Up() * -10, pang, Vector(-10,-15,-10), Vector(10,15,10), Color(0,255,0), false )
		cam.End3D()

	end

	if r.Passengers then
		for sn, s in pairs( r.Passengers ) do
			local v = Vector( s.x, s.y, s.z )
			local pz = car:GetPos() + (pang:Forward() * v.x) + (pang:Right() * v.y) + (pang:Up() * v.z)
			local pz2 = pz:ToScreen()
			local pz3 = (pz + pang:Right() * -3 + pang:Up() * 37):ToScreen()
--			local pz = car:LocalToWorld( v ):ToScreen()

			surface.SetDrawColor(55, 155, 255, 155)
			surface.DrawRect(pz3.x-3, pz3.y-3, 6, 6)
			surface.SetDrawColor(255, 255, 255, 155)
			surface.DrawRect(pz3.x-1, pz3.y-1, 2, 2)
			draw.SimpleText( sn, "DermaDefault", pz3.x + 10, pz3.y - 5 )
			cam.Start3D()
				render.SetMaterial( wf )
			 	render.DrawQuadEasy( pz + pang:Up() * 10 + pang:Right() * -5, Vector(0,0,1), 18, 10, Color(55,155,255), pang.y )
			 	render.DrawQuadEasy( pz + pang:Up() * 20 + pang:Right() * 4, -pang:Right() + Vector(0,0,0.2), 10, 20, Color(55,155,255), pang.p )
			 	render.DrawQuadEasy( pz + pang:Up() * 20 + pang:Right() * 4, pang:Right() + Vector(0,0,-0.2), 10, 20, Color(55,155,255), pang.p )
			cam.End3D()

		end

	end



end


function SWEP:SetSpringLength( len )
if CLIENT then return end
local ply = self.Owner
if !ply:IsValid() or !ply:IsSuperAdmin() then return end

local tr = util.TraceLine ({
	start = ply:GetShootPos(),
	endpos = ply:GetShootPos() + ply:GetAimVector() * 5000,
	filter = ply,
	mask = MASK_SHOT
})
if !tr.Entity or !tr.Entity:IsValid() or tr.Entity:GetClass() != "prop_vehicle_jeep" then return end
local car = tr.Entity

for i = 0, car:GetWheelCount() - 1 do
	local tyre = car:GetWheel( i )
	if tyre:IsValid() then car:SetSpringLength( i , 500.18 + len ) end
end

end

if SERVER then
net.Receive( "PeanusWeanus", function( l, ply )
if !ply:IsValid() or !ply:IsSuperAdmin() then return end 
local len = net.ReadFloat()
local wep = ply:GetActiveWeapon()
if wep:GetClass() == "cm_debug_tool" then
	wep:SetSpringLength( len / 100 )
end
end )
end



function SWEP:PrimaryAttack()


if CLIENT and IsFirstTimePredicted() then
	local tr = util.TraceLine ({
		start = LocalPlayer():GetShootPos(),
		endpos = LocalPlayer():GetShootPos() + LocalPlayer():GetAimVector() * 4096,
		filter = LocalPlayer(),
		mask = MASK_SHOT
	})


	if !tr.Entity or !tr.Entity:IsValid() then return end
	local car = tr.Entity
	if !car:IsVehicle() then chat.AddText( "You need to be looking at a vehicle for this to work!" ) return end
	local p = tr.HitPos
	local p1 = car:WorldToLocal( p )
	if input.IsKeyDown( KEY_E ) then
		ctable.EnginePos = Vector( 0, math.Round(p1.y + 3, 2), math.Round(p1.z, 2) )
		chat.AddText( "Set engine position!" )
	else
		ctable.Headlights = { Vector( math.Round(p1.x, 2), math.Round(p1.y + 3, 2), math.Round(p1.z, 2) ), Vector( -math.Round(p1.x, 2), math.Round(p1.y + 3, 2), math.Round(p1.z, 2) )}
		chat.AddText( "Set headlight positions!" )
	end
end

	self.Weapon:SetNextPrimaryFire(CurTime() + 0.1)
	self.Weapon:SetNextSecondaryFire(CurTime() + 0.1)

end

local seatvals = {
	["n"] = 1, 
	["h"] = 0, 
	["z"] = 0, 
	["f"] = 0, 
	["fs"] = 0,
	["side"] = false,
}


function SWEP:SecondaryAttack()
	if CLIENT and IsFirstTimePredicted() then
	local tr = util.TraceLine ({
		start = LocalPlayer():GetShootPos(),
		endpos = LocalPlayer():GetShootPos() + LocalPlayer():GetAimVector() * 4096,
		filter = LocalPlayer(),
		mask = MASK_SHOT
	})

	if !tr.Entity or !tr.Entity:IsValid() then return end
	local car = tr.Entity
	if !car:IsVehicle() then chat.AddText( "You need to be looking at a vehicle for this to work!" ) return end
	ctable.Passengers = {}
	if CMOD_Cars[car:GetVehicleClass()] then
		local tba = CMOD_Cars[car:GetVehicleClass()]

		if input.IsKeyDown( KEY_E ) then
			tba = CMOD_Cars[car:GetVehicleClass()]
--			print( TabStr( tba, "FAGGOT", true ) )
			local p = tr.HitPos
			local p1 = car:WorldToLocal( p )
			tba.TailLights = { Vector( math.Round(p1.x, 2), math.Round(p1.y - 3, 2), math.Round(p1.z, 2) ), Vector( -math.Round(p1.x, 2), math.Round(p1.y - 3, 2), math.Round(p1.z, 2) )}
--			chat.AddText( "Added tail lights to "..car:GetVehicleClass() )
			net.Start( "NCUploadMasterTable" )
			net.WriteString( car:GetVehicleClass() )
			net.WriteTable( tba )
			net.SendToServer()
--			local siqstr = '		["TailLights"] = { Vector( '..math.Round(p1.x, 2)..', '..math.Round(p1.y - 3, 2)..', '..math.Round(p1.z, 2)..' ), Vector( '..-math.Round(p1.x, 2)..', '..math.Round(p1.y - 3, 2)..', '..math.Round(p1.z, 2)..' ) },'
--			file.Write( "novacars/"..car:GetVehicleClass()..".txt", siqstr )


			return
		end


		if tba.Passengers and #tba.Passengers > 0 then
			seatvals["n"] = #tba.Passengers
			seatvals["h"] = tba.Passengers[1].x
			seatvals["f"] = tba.Passengers[1].y
			seatvals["z"] = tba.Passengers[1].z
			seatvals["side"] = false
			if tba.Passengers[2] then seatvals["fs"] = -(tba.Passengers[1].y - tba.Passengers[2].y) else seatvals["fs"] = 0 end
		end
		ctable = table.Copy( CMOD_Cars[car:GetVehicleClass()] ) 
		if tba.WheelHeightFix then ctable.WheelHeightFix = tba.WheelHeightFix else ctable.WheelHeightFix = 0 end
		ctable.Class = car:GetVehicleClass()
		chat.AddText( "Adjusting vehicle class: "..car:GetVehicleClass() ) 
		return 
	end

	ctable.Class = car:GetVehicleClass()
	seatvals = {["n"] = 1, ["h"] = 0, ["z"] = 0, ["f"] = 0, ["fs"] = 0,["side"] = false,}
	local tb = list.Get( "Vehicles" )[ car:GetVehicleClass() ]
	if tb then ctable.Name = tb.Name end
	seatvals["n"] = 1
	seatvals["h"] = 18
	seatvals["f"] = 0
	seatvals["z"] = 18
	seatvals["fs"] = 40
	chat.AddText( "Working on vehicle class: "..car:GetVehicleClass() )
	end

	self.Weapon:SetNextPrimaryFire(CurTime() + 1)
	self.Weapon:SetNextSecondaryFire(CurTime() + 1)

end

local function calcseats()
	ctable.Passengers = {}
--	if seatvals["n"] < 1 then ctable.Passengers = {} return end
	for i = 1, seatvals["n"] do
--		local sidemod = seatvals["side"] and 1 or -1
		local modulo = -1
		if i % 2 != 0 then modulo = 1 end
		if seatvals["side"] then modulo = -modulo end
		local fmodulo = math.floor(i/2)
		ctable.Passengers[i] = {x = seatvals["h"] * modulo, y = seatvals["f"] + (seatvals["fs"] * fmodulo), z = seatvals["z"]}
	end
end

local function eznumwang( x, y, vl )
		local ez = vgui.Create( "DNumberWang", Hframe ) 
		ez:SetValue( seatvals[vl] )
		ez:SetSize( 80, 20 )
		ez:SetPos( x, y )
		ez:SetMax( 5000 )
		ez:SetMin( -5000 )
		ez.OnValueChanged = function( val )
			seatvals[vl] = val:GetValue()
			calcseats()
		end
end

local function eznumslider( y, vl, txt, min, max, round )
	local sbg = vgui.Create( "DPanel", Hframe )
	sbg:SetPos( 10, y )
	sbg:SetSize( Hframe:GetWide() - 20, 22 )

	sbg.Paint = function( self, w, h )
    	surface.SetDrawColor( 80, 80, 80, 255 )
    	surface.DrawRect(0, 0, w, h )
	end

	local ez = vgui.Create( "DNumSlider", sbg )
	if round then ez.round = true end
	ez:SetSize( sbg:GetWide() - 10, 20 )
	ez:SetPos( 5, 0 )
	ez:SetText( txt )
	ez:SetMinMax( min, max )
	ez:SetDecimals( 3 )
	ez:SetValue( seatvals[vl] )
	ez.OnValueChanged = function( val )
		if val.round then seatvals[vl] = math.Round(val:GetValue()) else seatvals[vl] = val:GetValue() end
		calcseats()
	end
end

local function OpenToolMenu()
	if Hframe and Hframe:IsValid() then return end
		Hframe = vgui.Create( "DFrame" )   
		Hframe:SetSize( 250, 340 )  
		Hframe:SetTitle( "" )
		Hframe:SetVisible( true )  
		Hframe:SetDraggable( true )  
		Hframe:ShowCloseButton( true ) 
		Hframe:MakePopup()
		Hframe:Center()
		Hframe.Paint = function( self, w, h ) 
		surface.SetDrawColor(25, 25, 25, 255)
		surface.DrawRect(0, 0, w, h)
		draw.SimpleText( "Name: ", "DermaDefault", 10, 25 )
		draw.SimpleText( "DR%: ", "DermaDefault", 10, 52 )
--		draw.SimpleText( "Seat Num: ", "DermaDefault", 10, 80 )
--		draw.SimpleText( "Seat H Offset: ", "DermaDefault", 10, 105 )
--		draw.SimpleText( "Seat Z Offset: ", "DermaDefault", 10, 130 )
--		draw.SimpleText( "Seat Forward Offset: ", "DermaDefault", 10, 155 )
--		draw.SimpleText( "Seat Forward Spacing: ", "DermaDefault", 10, 180 )
		draw.SimpleText( "Right Hand Drive?", "DermaDefault", 10, 230 )
--		draw.SimpleText( "Wheel Height Fix:", "DermaDefault", 10, 253 )
		end

		local nametx = vgui.Create( "DTextEntry", Hframe )
		nametx:SetPos( 45, 22 )
		nametx:SetSize( 190, 20 )
		nametx:SetText( ctable.Name )
		nametx.OnEnter = function( self )
			chat.AddText( "Set Vehicle name to: "..self:GetValue() )
			ctable.Name = self:GetValue()
		end

		local tuff = vgui.Create( "DNumberWang", Hframe ) 
		tuff:SetValue( ctable.DamageResist * 100 )
		tuff:SetSize( 80, 20 )
		tuff:SetPos( 45, 50 )
		tuff:SetMax( 5000 )
		tuff.OnValueChanged = function( val )
			ctable.DamageResist = val:GetValue() / 100
		end


		eznumslider( 75, "n", "Number of Seats", 0, 20, true )
		eznumslider( 100, "h", "Seat Width", 0, 1000, false )
		eznumslider( 125, "z", "Seat Height", -100, 1000, false )
		eznumslider( 150, "f", "Seat Placement", -500, 500, false )
		eznumslider( 175, "fs", "Seat Spacing", 0, 500, false )
--		eznumwang( 65, 78, "n" )
--		eznumwang( 85, 102, "h" )
--		eznumwang( 85, 128, "z" )
--		eznumwang( 115, 153, "f" )
--		eznumwang( 120, 178, "fs" )

/*
		local anal = vgui.Create( "DButton", Hframe )
		anal:SetPos( 10, 200 )
		anal:SetSize( 120, 20 )
		anal:SetText( "Calculate Seat Positions" )
		anal.DoClick = function()
			calcseats()
		end
*/

		local CB = vgui.Create( "DCheckBox", Hframe )
		CB:SetPos( 100, 230 )
		CB:SetValue( 0 )
		CB.OnChange = function( b )
			seatvals["side"] = b:GetChecked()
		end
/*
		local faget = vgui.Create( "DNumberWang", Hframe ) 
		faget:SetValue( ctable.WheelHeightFix * 100 )
		faget:SetSize( 80, 20 )
		faget:SetPos( 100, 250 )
		faget:SetMin( -500 )
		faget:SetMax( 500 )
		faget.OnValueChanged = function( val )
			ctable.WheelHeightFix = val:GetValue() / 100
			net.Start( "PeanusWeanus" )
			net.WriteFloat( val:GetValue() )
			net.SendToServer()
		end
*/

		local sbg = vgui.Create( "DPanel", Hframe )
		sbg:SetPos( 10, 250 )
		sbg:SetSize( Hframe:GetWide() - 20, 22 )

		sbg.Paint = function( self, w, h )
    		surface.SetDrawColor( 80, 80, 80, 255 )
    		surface.DrawRect(0, 0, w, h )
		end

		local ez = vgui.Create( "DNumSlider", sbg )
		ez:SetSize( sbg:GetWide() - 10, 20 )
		ez:SetPos( 5, 0 )
		ez:SetText( "Wheel Height" )
		ez:SetMinMax( -200, 200 )
		ez:SetDecimals( 3 )
		ez:SetValue( ctable.WheelHeightFix )
		ez.OnValueChanged = function( val )
			ctable.WheelHeightFix = math.Round(val:GetValue() / 100, 3)
			net.Start( "PeanusWeanus" )
			net.WriteFloat( val:GetValue() )
			net.SendToServer()
		end

		local anotherstupidname = vgui.Create( "DButton", Hframe )
		anotherstupidname:SetPos( 10, 300 )
		anotherstupidname:SetSize( 90, 20 )
		anotherstupidname:SetText( "Commit to Table" )
		anotherstupidname.DoClick = function()
		local str = [[
	["]]..ctable.Class..[["] = {
		["Name"] = "]]..ctable.Name..[[",
		["Passengers"] = {]].."\n"
		for k, v in pairs( ctable.Passengers ) do
			str = str..[[			[]]..k..[[] = { x = ]]..math.Round(v.x, 2)..[[, y = ]]..math.Round(v.y, 2)..[[, z = ]]..math.Round(v.z, 2)..[[},]].."\n"
		end
		str = str..[[		},
		["DamageResist"] = ]]..ctable.DamageResist..[[,
		["Headlights"] = {]].."\n"
		for k, v in pairs( ctable.Headlights ) do
			str = str..[[			[]]..k..[[] = Vector( ]]..math.Round(v.x, 2)..[[, ]]..math.Round(v.y, 2)..[[, ]]..math.Round(v.z, 2)..[[ ),]].."\n"
		end
		str = str..[[		},
		["EnginePos"] = Vector( ]]..math.Round(ctable.EnginePos.x, 2)..[[, ]]..math.Round(ctable.EnginePos.y, 2)..[[, ]]..math.Round(ctable.EnginePos.z, 2)..[[ ),
		["WheelHeightFix"] = ]]..ctable.WheelHeightFix..[[,
	},]]
		CommittedCars[ctable.Class] = str
		chat.AddText( "Committed vehicle class: "..ctable.Class.." to table" )
		end

		local anal = vgui.Create( "DButton", Hframe )
		anal:SetPos( 10, 275 )
		anal:SetSize( 90, 20 )
		anal:SetText( "Print to Console" )
		anal.DoClick = function()
		local str = [[
	["]]..ctable.Class..[["] = {
		["Name"] = "]]..ctable.Name..[[",
		["Passengers"] = {]].."\n"
		for k, v in pairs( ctable.Passengers ) do
			str = str..[[			[]]..k..[[] = { x = ]]..math.Round(v.x, 2)..[[, y = ]]..math.Round(v.y, 2)..[[, z = ]]..math.Round(v.z, 2)..[[},]].."\n"
		end
		str = str..[[		},
		["DamageResist"] = ]]..ctable.DamageResist..[[,
		["Headlights"] = {]].."\n"
		for k, v in pairs( ctable.Headlights ) do
			str = str..[[			[]]..k..[[] = Vector( ]]..math.Round(v.x, 2)..[[, ]]..math.Round(v.y, 2)..[[, ]]..math.Round(v.z, 2)..[[ ),]].."\n"
		end
		str = str..[[		},
		["EnginePos"] = Vector( ]]..math.Round(ctable.EnginePos.x, 2)..[[, ]]..math.Round(ctable.EnginePos.y, 2)..[[, ]]..math.Round(ctable.EnginePos.z, 2)..[[ ),
		["WheelHeightFix"] = ]]..ctable.WheelHeightFix..[[,
	},]]
		MsgN( str )
		end

		local anal2 = vgui.Create( "DButton", Hframe )
		anal2:SetPos( 105, 300 )
		anal2:SetSize( 90, 20 )
		anal2:SetText( "Print Cars Table" )
		anal2.DoClick = function()
			for k, v in pairs( CommittedCars ) do
				MsgN( v )
			end
		end

		local anal3 = vgui.Create( "DButton", Hframe )
		anal3:SetPos( 105, 275 )
		anal3:SetSize( 90, 20 )
		anal3:SetText( "Wipe Cars Table" )
		anal3.DoClick = function()
			CommittedCars = {}
			chat.AddText( "Wiped vehicle table" )
		end

end

local nxrld = CurTime()
function SWEP:Reload()
	if CLIENT and nxrld <= CurTime() then
	OpenToolMenu()
	nxrld = CurTime() + 0.5
	end
end