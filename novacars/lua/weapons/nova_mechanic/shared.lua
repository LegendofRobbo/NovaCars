SWEP.Category          = "Novacars"
SWEP.Instructions   = "Fix up vehicles for the morons who crashed them.  Can also install modifications on vehicles with right click."
SWEP.ViewModelFlip		= false
SWEP.ViewModel = "models/weapons/c_crowbar.mdl"
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"
SWEP.ViewModelFOV 		= 51
SWEP.BobScale 			= 2
SWEP.DrawCrosshair 			= false
SWEP.HoldType = "knife"
SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false
SWEP.UseHands = true
SWEP.Base = "wep_ck_base"

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

SWEP.Sequence			= 0

SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false

SWEP.CurrentCar = game.GetWorld()

if SERVER then 
	util.AddNetworkString( "CMSendFixingTimer" )
	util.AddNetworkString( "CMOpenModMenu" )
end

if CLIENT then
	CMCarFixDelay = CurTime()


	net.Receive( "CMSendFixingTimer", function()

		local delay = net.ReadUInt( 8 )
		local remaining = CurTime() + delay

		local DelayFrame = vgui.Create( "DFrame" )   
		DelayFrame:SetSize( 200, 50 )  
		DelayFrame:SetTitle( "" )
		DelayFrame:SetVisible( true )  
		DelayFrame:SetDraggable( false )  
		DelayFrame:ShowCloseButton( false ) 
		DelayFrame:SetBackgroundBlur( true )  
		DelayFrame:MakePopup()
		DelayFrame:Center()
		DelayFrame.Paint = function( self, w, h )
			local fraction = (remaining - CurTime()) / delay
			surface.SetDrawColor(0, 0, 0, 230)
			surface.DrawRect(0, 0, w, h)

			surface.SetDrawColor(0, 0, 110, 250)
			surface.DrawRect(10, h / 2, fraction * 180, 20)
			surface.SetDrawColor(0, 0, 130, 250)
			surface.DrawRect(10, h / 2, fraction * 180, 10)

			surface.SetDrawColor(0, 0, 0, 255)
			surface.DrawOutlinedRect(0, 0, w, h)
			surface.DrawOutlinedRect(10, h / 2, w - 20, 20)
			draw.DrawText( "Working on Vehicle...", "NovaTrebuchet", 100, 5, Color(250, 250, 250), TEXT_ALIGN_CENTER )
		end

		timer.Simple( delay, function()
			if DelayFrame and DelayFrame:IsValid() then
				DelayFrame:Remove()
			end
		end)

	end)

end


SWEP.ViewModelBoneMods = {
	["ValveBiped.Bip01_R_Hand"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
}

SWEP.VElements = {
	["asshole"] = { type = "Model", model = "models/props_c17/tools_wrench01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.367, 1.253, -4.791), angle = Angle(0, -42.037, -91.471), size = Vector(0.97, 0.97, 0.97), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

SWEP.WElements = {
	["asshole"] = { type = "Model", model = "models/props_c17/tools_wrench01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(2.848, 1.172, -2.82), angle = Angle(0, 0, -88.996), size = Vector(0.97, 0.97, 0.97), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

function SWEP:Deploy()

	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
	self.Weapon:SetNextPrimaryFire(CurTime() + 1)

	self.Weapon:SetHoldType("knife")

	return true
end

function SWEP:DrawHUD()
	if !LocalPlayer():IsValid() or !LocalPlayer():Alive() or LocalPlayer():InVehicle() then return end

	local tr = util.TraceLine ({
		start = LocalPlayer():GetShootPos(),
		endpos = LocalPlayer():GetShootPos() + LocalPlayer():GetAimVector() * 60,
		filter = LocalPlayer(),
		mask = MASK_SHOT
	})


	if !tr.Entity or !tr.Entity:IsValid() then return end
	local car = tr.Entity
	if car:GetClass() != "prop_vehicle_jeep" then return end
	draw.SimpleText( "Left Click: Fix Vehicle", "NovaTrebuchet", ScrW() / 2, (ScrH() / 2) - 40, Color(255,255,255), 1)
	draw.SimpleText( "Right Click: Install Vehicle Mods", "NovaTrebuchet", ScrW() / 2, (ScrH() / 2) - 26, Color(255,255,255), 1 )


end

local grad = Material( "gui/gradient" )
local upgrad = Material( "gui/gradient_up" )
local downgrad = Material( "gui/gradient_down" )

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

local function NOVA_OpenModMenu( car )
	if Nova_Modframe and Nova_Modframe:IsValid() or !car or !car:IsValid() or !car:IsVehicle() then return end
		Nova_Modframe = vgui.Create( "DFrame" )   
		Nova_Modframe:SetSize( 350, 500 )  
		Nova_Modframe:SetTitle( "" )
		Nova_Modframe:SetVisible( true )  
		Nova_Modframe:SetDraggable( true )  
		Nova_Modframe:ShowCloseButton( true ) 
		Nova_Modframe:MakePopup()
		Nova_Modframe:Center()
		local r = CMOD_Cars[car:GetVehicleClass()]
		local modz = car:CMGetInstalledMods()
		Nova_Modframe.Paint = function( s, w, h )
			DrawInlineBox( 0, 0, w, h, 20, Color(30, 30, 30), Color(20, 20, 20) )
			DrawInlineBox( 10, 50, w - 20, 200, 10, Color(40, 40, 40), Color(20, 20, 20) )
			DrawInlineBox( 10, 280, w - 20, 200, 10, Color(40, 40, 40), Color(20, 20, 20) )
			if r then
				draw.SimpleText( r.Name, "NovaTrebuchetMods", 15, 10, Color(255,255,255), 0)
				draw.SimpleText( "Available Mods", "NovaTrebuchetMods", 15, 30, Color(205,205,205), 0)
				draw.SimpleText( "Installed Mods ("..table.Count( modz ).."/"..NOVA_Config.MaxMods..")", "NovaTrebuchetMods", 15, 260, Color(205,205,205), 0)
			end
		end

		local basepanel = vgui.Create( "DScrollPanel", Nova_Modframe )
		basepanel:SetSize( 330, 200 )
		basepanel:SetPos( 10, 50 )

		local basepanel2 = vgui.Create( "DScrollPanel", Nova_Modframe )
		basepanel2:SetSize( 330, 200 )
		basepanel2:SetPos( 10, 280 )

		local spacer = 10
		for k, v in pairs( NOVA_Mods ) do
			if modz[k] then continue end
			local itempanel = vgui.Create( "DPanel", basepanel )
			itempanel:SetPos( 10, spacer )
			spacer = spacer + 37
			itempanel:SetSize( 310, 35 )
			itempanel.Paint = function( self, w, h )
				surface.SetDrawColor( Color(50,50,50) )
				surface.DrawRect( 0, 0, w, h )
				surface.SetDrawColor( Color(30,30,30) )
				surface.DrawOutlinedRect( 0, 0, w, h )
				local wenis = Color(205,205,205)
				if NOVA_Mods[k].Col then wenis = NOVA_Mods[k].Col end
				local crx, cry = draw.SimpleText( k, "NovaTrebuchetMods", 5, 3, wenis, 0)
				draw.SimpleText( NOVA_Mods[k].Desc, "NovaTrebuchetSmall", 5, 18, Color(155,155,155), 0)
				draw.SimpleText( "$"..NOVA_Mods[k].Cost, "NovaTrebuchetSmall", 10 + crx, 4, Color(15,155,15), 0)
			end

    		local BuyButton = vgui.Create("DButton", itempanel)
			BuyButton:SetSize( 60, 16 )
			BuyButton:SetPos( 245, 3 )
			BuyButton:SetTextColor(Color(255, 255, 255, 255))
			BuyButton:SetText( "Install")
			BuyButton.Paint = function( self, w, h )
				surface.SetDrawColor( Color(40,40,40) )
				surface.DrawRect( 0, 0, w, h )
				surface.SetDrawColor( Color(30,30,30) )
				surface.DrawOutlinedRect( 0, 0, w, h )
			end
			BuyButton.DoClick = function()
				LocalPlayer():ConCommand( "nova_installmod "..k )
				Nova_Modframe:Remove()
			end
		end

		spacer = 10
		for k, v in pairs( car:CMGetInstalledMods() ) do
			local itempanel = vgui.Create( "DPanel", basepanel2 )
			itempanel:SetPos( 10, spacer )
			spacer = spacer + 37
			itempanel:SetSize( 310, 35 )
			itempanel.Paint = function( self, w, h )
				surface.SetDrawColor( Color(50,50,50) )
				surface.DrawRect( 0, 0, w, h )
				surface.SetDrawColor( Color(30,30,30) )
				surface.DrawOutlinedRect( 0, 0, w, h )
				local wenis = Color(205,205,205)
				if NOVA_Mods[k].Col then wenis = NOVA_Mods[k].Col end
				local crx, cry = draw.SimpleText( k, "NovaTrebuchetMods", 5, 3, wenis, 0)
				draw.SimpleText( NOVA_Mods[k].Desc, "NovaTrebuchetSmall", 5, 18, Color(155,155,155), 0)
			end

    		local BuyButton = vgui.Create("DButton", itempanel)
			BuyButton:SetSize( 60, 16 )
			BuyButton:SetPos( 245, 3 )
			BuyButton:SetTextColor(Color(255, 255, 255, 255))
			BuyButton:SetText( "Remove")
			BuyButton.Paint = function( self, w, h )
				surface.SetDrawColor( Color(40,40,40) )
				surface.DrawRect( 0, 0, w, h )
				surface.SetDrawColor( Color(30,30,30) )
				surface.DrawOutlinedRect( 0, 0, w, h )
			end
			BuyButton.DoClick = function()
--				LocalPlayer():ConCommand( "nova_removemod "..k )
				net.Start( "NovaRemoveMod" )
				net.WriteString( k )
				net.SendToServer()
				Nova_Modframe:Remove()
			end
		end

end

net.Receive( "CMOpenModMenu", function() NOVA_OpenModMenu( net.ReadEntity() ) end)


function SWEP:SendUseDelay( d )
if !self:IsValid() or !self.Owner:IsValid() then return end
net.Start( "CMSendFixingTimer" )
net.WriteUInt( d, 8 )
net.Send(self.Owner)
end

local nxtsound = CurTime()
local nxtsound2 = CurTime()
local fixitsounds = {
	"vo/npc/male01/answer36.wav",
	"vo/npc/male01/answer25.wav",
	"vo/npc/male01/answer03.wav",
	"vo/npc/male01/busy02.wav",
	"vo/npc/male01/getgoingsoon.wav",
	"vo/npc/male01/gordead_ques16.wav",
	"vo/npc/male01/gordead_ques10.wav",
	"vo/npc/male01/yougotit02.wav",
}
local clangsounds = {
	"physics/metal/metal_box_impact_hard1.wav",
	"weapons/crowbar/crowbar_impact1.wav",
	"weapons/crowbar/crowbar_impact2.wav",
	"physics/metal/metal_solid_impact_hard5.wav",
	"physics/metal/sawblade_stick3.wav",
	"vehicles/v8/vehicle_impact_medium3.wav"
}

function SWEP:Think()
	if !SERVER or !IsFirstTimePredicted() or !self.FixingVehicle then return end
	if nxtsound <= CurTime() then
		sound.Play( table.Random( fixitsounds ), self.Owner:GetPos() ) 
--		self.Weapon:EmitSound( table.Random( fixitsounds ), 100, 100 )
		nxtsound = CurTime() + math.random( 2.5, 3.5 )
	end

	if nxtsound2 <= CurTime() then
		self.Owner:EmitSound( table.Random( clangsounds ), 80, math.random( 80, 105 ), 0.4 )
		nxtsound2 = CurTime() + math.random( 0.6, 1.2 )
	end

end

function SWEP:FixCar()
	local tr = util.TraceLine( {
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 60,
		filter = self.Owner
	} )

	if ( !IsValid( tr.Entity ) ) then 
		tr = util.TraceHull( {
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 60,
			filter = self.Owner,
			mins = Vector( -10, -10, -8 ),
			maxs = Vector( 10, 10, 8 )
		} )
	end

	if ( tr.Hit and tr.Entity:IsValid() and tr.Entity:IsVehicle() and SERVER ) then 
		local car = tr.Entity
--		if !car:CMIsDamaged() then DarkRP.notify(self.Owner, 1, 4, "This vehicle does not need repairs!" ) return end
		local canchange, nmsg = hook.Call( "NOVA_CanRepairVehicle", nil, self.Owner, car )
		if isbool(canchange) and !canchange then self.Owner:NCNotify( nmsg ) return end

		self:SendUseDelay( NOVA_Config.CarFixTime )
		self.FixingVehicle = true
		timer.Simple( NOVA_Config.CarFixTime, function() if self:IsValid() and self.Owner:IsValid() then self:FinishFixing() end end )
	end


end

function SWEP:FinishFixing()
	if !SERVER then return end
	local tr = util.TraceLine( {
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 60,
		filter = self.Owner
	} )

	if ( !IsValid( tr.Entity ) ) then 
		tr = util.TraceHull( {
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 60,
			filter = self.Owner,
			mins = Vector( -10, -10, -8 ),
			maxs = Vector( 10, 10, 8 )
		} )
	end

	self.FixingVehicle = false

	if ( tr.Hit and tr.Entity:IsValid() and tr.Entity:IsVehicle() ) then 
		local car = tr.Entity
		if !car:CMIsDamaged() then DarkRP.notify(self.Owner, 1, 4, "This vehicle does not need repairs!" ) return end
		car:CMFixVehicle()
	end

end


function SWEP:PrimaryAttack()

	self:FixCar()

	self.Weapon:SetNextPrimaryFire(CurTime() + 1)
	self.Weapon:SetNextSecondaryFire(CurTime() + 1)

end

function SWEP:SecondaryAttack()
	if CLIENT then return end
	if !NOVA_Config.EnableModdingSystem then DarkRP.notify(ply, 1, 4, "Vehicle modding is disabled on this server!" ) return end
	local tr = util.TraceLine ({
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 60,
		filter = self.Owner,
		mask = MASK_SHOT
	})
	local car
	if tr.Entity and tr.Entity:IsValid() and tr.Entity:GetClass() == "prop_vehicle_jeep" then 
		car = tr.Entity
	else
		return
	end

	self.Weapon:SetNextPrimaryFire(CurTime() + 1)
	self.Weapon:SetNextSecondaryFire(CurTime() + 1)

	if car:GetSaveTable().VehicleLocked then DarkRP.notify(self.Owner, 1, 4, "You cannot modify a locked vehicle!" ) return end
	if !car:CMIsEmptyVehicle() then DarkRP.notify(self.Owner, 1, 4, "You cannot modify an occupied vehicle!" ) return end
--	if car.DestroyedCar or car:WaterLevel() >= 2 then DarkRP.notify(self.Owner, 1, 4, "You cannot modify a destroyed vehicle!" ) return end

	car:CMNetworkStatsToTarget( self.Owner )
	net.Start( "CMOpenModMenu")
	net.WriteEntity( car )
	net.Send( self.Owner )

end




/********************************************************
	SWEP Construction Kit base code
		Created by Clavus
	Available for public use, thread at:
	   facepunch.com/threads/1032378
	   
	   
	DESCRIPTION:
		This script is meant for experienced scripters 
		that KNOW WHAT THEY ARE DOING. Don't come to me 
		with basic Lua questions.
		
		Just copy into your SWEP or SWEP base of choice
		and merge with your own code.
		
		The SWEP.VElements, SWEP.WElements and
		SWEP.ViewModelBoneMods tables are all optional
		and only have to be visible to the client.
********************************************************/

function SWEP:Initialize()

	// other initialize code goes here

	if CLIENT then
	
		// Create a new table for every weapon instance
		self.VElements = table.FullCopy( self.VElements )
		self.WElements = table.FullCopy( self.WElements )
		self.ViewModelBoneMods = table.FullCopy( self.ViewModelBoneMods )

		self:CreateModels(self.VElements) // create viewmodels
		self:CreateModels(self.WElements) // create worldmodels
		
		// init view model bone build function
		if IsValid(self.Owner) then
			local vm = self.Owner:GetViewModel()
			if IsValid(vm) then
				self:ResetBonePositions(vm)
				
				// Init viewmodel visibility
				if (self.ShowViewModel == nil or self.ShowViewModel) then
					vm:SetColor(Color(255,255,255,255))
				else
					// we set the alpha to 1 instead of 0 because else ViewModelDrawn stops being called
					vm:SetColor(Color(255,255,255,1))
					// ^ stopped working in GMod 13 because you have to do Entity:SetRenderMode(1) for translucency to kick in
					// however for some reason the view model resets to render mode 0 every frame so we just apply a debug material to prevent it from drawing
					vm:SetMaterial("Debug/hsv")			
				end
			end
		end
		
	end

end

function SWEP:Holster()
	
	if CLIENT and IsValid(self.Owner) then
		local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			self:ResetBonePositions(vm)
		end
	end
	
	return true
end

function SWEP:OnRemove()
	self:Holster()
end

if CLIENT then

	SWEP.vRenderOrder = nil
	function SWEP:ViewModelDrawn()
		
		local vm = self.Owner:GetViewModel()
		if !IsValid(vm) then return end
		
		if (!self.VElements) then return end
		
		self:UpdateBonePositions(vm)

		if (!self.vRenderOrder) then
			
			// we build a render order because sprites need to be drawn after models
			self.vRenderOrder = {}

			for k, v in pairs( self.VElements ) do
				if (v.type == "Model") then
					table.insert(self.vRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.vRenderOrder, k)
				end
			end
			
		end

		for k, name in ipairs( self.vRenderOrder ) do
		
			local v = self.VElements[name]
			if (!v) then self.vRenderOrder = nil break end
			if (v.hide) then continue end
			
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if (!v.bone) then continue end
			
			local pos, ang = self:GetBoneOrientation( self.VElements, v, vm )
			
			if (!pos) then continue end
			
			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )
				
				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end
				
				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end
				
				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
				
			elseif (v.type == "Sprite" and sprite) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif (v.type == "Quad" and v.draw_func) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()

			end
			
		end
		
	end

	SWEP.wRenderOrder = nil
	function SWEP:DrawWorldModel()
		
		if (self.ShowWorldModel == nil or self.ShowWorldModel) then
			self:DrawModel()
		end
		
		if (!self.WElements) then return end
		
		if (!self.wRenderOrder) then

			self.wRenderOrder = {}

			for k, v in pairs( self.WElements ) do
				if (v.type == "Model") then
					table.insert(self.wRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.wRenderOrder, k)
				end
			end

		end
		
		if (IsValid(self.Owner)) then
			bone_ent = self.Owner
		else
			// when the weapon is dropped
			bone_ent = self
		end
		
		for k, name in pairs( self.wRenderOrder ) do
		
			local v = self.WElements[name]
			if (!v) then self.wRenderOrder = nil break end
			if (v.hide) then continue end
			
			local pos, ang
			
			if (v.bone) then
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent )
			else
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent, "ValveBiped.Bip01_R_Hand" )
			end
			
			if (!pos) then continue end
			
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )
				
				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end
				
				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end
				
				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
				
			elseif (v.type == "Sprite" and sprite) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif (v.type == "Quad" and v.draw_func) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()

			end
			
		end
		
	end

	function SWEP:GetBoneOrientation( basetab, tab, ent, bone_override )
		
		local bone, pos, ang
		if (tab.rel and tab.rel != "") then
			
			local v = basetab[tab.rel]
			
			if (!v) then return end
			
			// Technically, if there exists an element with the same name as a bone
			// you can get in an infinite loop. Let's just hope nobody's that stupid.
			pos, ang = self:GetBoneOrientation( basetab, v, ent )
			
			if (!pos) then return end
			
			pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
		else
		
			bone = ent:LookupBone(bone_override or tab.bone)

			if (!bone) then return end
			
			pos, ang = Vector(0,0,0), Angle(0,0,0)
			local m = ent:GetBoneMatrix(bone)
			if (m) then
				pos, ang = m:GetTranslation(), m:GetAngles()
			end
			
			if (IsValid(self.Owner) and self.Owner:IsPlayer() and 
				ent == self.Owner:GetViewModel() and self.ViewModelFlip) then
				ang.r = -ang.r // Fixes mirrored models
			end
		
		end
		
		return pos, ang
	end

	function SWEP:CreateModels( tab )

		if (!tab) then return end

		// Create the clientside models here because Garry says we can't do it in the render hook
		for k, v in pairs( tab ) do
			if (v.type == "Model" and v.model and v.model != "" and (!IsValid(v.modelEnt) or v.createdModel != v.model) and 
					string.find(v.model, ".mdl") and file.Exists (v.model, "GAME") ) then
				
				v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
				if (IsValid(v.modelEnt)) then
					v.modelEnt:SetPos(self:GetPos())
					v.modelEnt:SetAngles(self:GetAngles())
					v.modelEnt:SetParent(self)
					v.modelEnt:SetNoDraw(true)
					v.createdModel = v.model
				else
					v.modelEnt = nil
				end
				
			elseif (v.type == "Sprite" and v.sprite and v.sprite != "" and (!v.spriteMaterial or v.createdSprite != v.sprite) 
				and file.Exists ("materials/"..v.sprite..".vmt", "GAME")) then
				
				local name = v.sprite.."-"
				local params = { ["$basetexture"] = v.sprite }
				// make sure we create a unique name based on the selected options
				local tocheck = { "nocull", "additive", "vertexalpha", "vertexcolor", "ignorez" }
				for i, j in pairs( tocheck ) do
					if (v[j]) then
						params["$"..j] = 1
						name = name.."1"
					else
						name = name.."0"
					end
				end

				v.createdSprite = v.sprite
				v.spriteMaterial = CreateMaterial(name,"UnlitGeneric",params)
				
			end
		end
		
	end
	
	local allbones
	local hasGarryFixedBoneScalingYet = false

	function SWEP:UpdateBonePositions(vm)
		
		if self.ViewModelBoneMods then
			
			if (!vm:GetBoneCount()) then return end
			
			// !! WORKAROUND !! //
			// We need to check all model names :/
			local loopthrough = self.ViewModelBoneMods
			if (!hasGarryFixedBoneScalingYet) then
				allbones = {}
				for i=0, vm:GetBoneCount() do
					local bonename = vm:GetBoneName(i)
					if (self.ViewModelBoneMods[bonename]) then 
						allbones[bonename] = self.ViewModelBoneMods[bonename]
					else
						allbones[bonename] = { 
							scale = Vector(1,1,1),
							pos = Vector(0,0,0),
							angle = Angle(0,0,0)
						}
					end
				end
				
				loopthrough = allbones
			end
			// !! ----------- !! //
			
			for k, v in pairs( loopthrough ) do
				local bone = vm:LookupBone(k)
				if (!bone) then continue end
				
				// !! WORKAROUND !! //
				local s = Vector(v.scale.x,v.scale.y,v.scale.z)
				local p = Vector(v.pos.x,v.pos.y,v.pos.z)
				local ms = Vector(1,1,1)
				if (!hasGarryFixedBoneScalingYet) then
					local cur = vm:GetBoneParent(bone)
					while(cur >= 0) do
						local pscale = loopthrough[vm:GetBoneName(cur)].scale
						ms = ms * pscale
						cur = vm:GetBoneParent(cur)
					end
				end
				
				s = s * ms
				// !! ----------- !! //
				
				if vm:GetManipulateBoneScale(bone) != s then
					vm:ManipulateBoneScale( bone, s )
				end
				if vm:GetManipulateBoneAngles(bone) != v.angle then
					vm:ManipulateBoneAngles( bone, v.angle )
				end
				if vm:GetManipulateBonePosition(bone) != p then
					vm:ManipulateBonePosition( bone, p )
				end
			end
		else
			self:ResetBonePositions(vm)
		end
		   
	end
	 
	function SWEP:ResetBonePositions(vm)
		
		if (!vm:GetBoneCount()) then return end
		for i=0, vm:GetBoneCount() do
			vm:ManipulateBoneScale( i, Vector(1, 1, 1) )
			vm:ManipulateBoneAngles( i, Angle(0, 0, 0) )
			vm:ManipulateBonePosition( i, Vector(0, 0, 0) )
		end
		
	end

	/**************************
		Global utility code
	**************************/

	// Fully copies the table, meaning all tables inside this table are copied too and so on (normal table.Copy copies only their reference).
	// Does not copy entities of course, only copies their reference.
	// WARNING: do not use on tables that contain themselves somewhere down the line or you'll get an infinite loop
	function table.FullCopy( tab )

		if (!tab) then return nil end
		
		local res = {}
		for k, v in pairs( tab ) do
			if (type(v) == "table") then
				res[k] = table.FullCopy(v) // recursion ho!
			elseif (type(v) == "Vector") then
				res[k] = Vector(v.x, v.y, v.z)
			elseif (type(v) == "Angle") then
				res[k] = Angle(v.p, v.y, v.r)
			else
				res[k] = v
			end
		end
		
		return res
		
	end
	
end

