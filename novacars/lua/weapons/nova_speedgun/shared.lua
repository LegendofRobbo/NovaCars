SWEP.Category          = "Novacars"
SWEP.Instructions   = "Left click to check a car's speed"
SWEP.ViewModelFlip		= false
SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"
SWEP.ViewModelFOV 		= 51
SWEP.BobScale 			= 0.5
SWEP.DrawCrosshair 			= false
SWEP.HoldType = "pistol"
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

SWEP.Pistol				= true
SWEP.Rifle				= false
SWEP.Shotgun			= false
SWEP.Sniper				= false

SWEP.RunArmOffset 		= Vector (0, 0, 0)
SWEP.RunArmAngle	 		= Vector (0, 0, 0)

SWEP.Sequence			= 0

SWEP.ShowViewModel = false
SWEP.ShowWorldModel = false
SWEP.ViewModelBoneMods = {}

SWEP.VElements = {
	["cam"] = { type = "Model", model = "models/novacars/speedgun.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(1.335, 1.343, -4.797), angle = Angle(0, -92.247, 180), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

SWEP.WElements = {
	["cam"] = { type = "Model", model = "models/novacars/speedgun.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(1.172, 1.039, -4.743), angle = Angle(180, 90, 0), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}


if SERVER then 
	util.AddNetworkString( "CMSendSpeedgunPulse" )
end

function SWEP:Deploy()

	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
	self.Weapon:SetNextPrimaryFire(CurTime() + 1)

	self.Weapon:SetHoldType(self.HoldType)

	return true
end

local ring = Material( "particle/particle_ring_sharp" )
local scansize = 0
local scanalpha = 0
local lastcar = "ERROR"
local lastspeed = 0
local txalpha = 0

net.Receive( "CMSendSpeedgunPulse", function() 
	scansize = 0
	scanalpha = 150
	txalpha = 100
	surface.PlaySound( "buttons/combine_button5.wav" )
	lastcar = net.ReadString()
	lastspeed = net.ReadFloat()
end )

function SWEP:DrawHUD()
	if !LocalPlayer():IsValid() or !LocalPlayer():Alive() then return end
	local x, y = ScrW() / 2, ScrH() / 2

		surface.SetDrawColor( Color(155,255,155, 100 ) )
		surface.SetMaterial( ring )
		surface.DrawTexturedRect( x - 30, y - 30, 60, 60 )

		if scanalpha > 0 then
			surface.SetDrawColor( Color(155,255,155, scanalpha ) )
			scansize = scansize + 2
			scanalpha = scanalpha - 4
			surface.DrawTexturedRect( x - scansize, y - scansize, scansize * 2, scansize * 2 )

		end

		if txalpha > 0 then
			txalpha = txalpha - 0.25
			draw.SimpleText( lastcar, "NovaTrebuchetMods", x + 60, y, Color(155,255,155, txalpha ), 0)
			draw.SimpleText( "SPD: "..lastspeed.." / "..NOVA_Config["SpeedLimit"].."MPH", "NovaTrebuchetMods", x + 60, y + 20, Color(155,255,155, txalpha ), 0)
		end

		surface.SetDrawColor( Color(155,255,155, 50 ) )
		surface.DrawLine( x - 29, y, x + 29, y )
		surface.DrawLine( x - 50, y - 50, x - 50, y - 20 )
		surface.DrawLine( x - 50, y - 50, x - 20, y - 50 )
		surface.DrawLine( x + 50, y - 50, x + 50, y - 20 )
		surface.DrawLine( x + 50, y - 50, x + 20, y - 50 )

		surface.DrawLine( x - 50, y + 50, x - 50, y + 20 )
		surface.DrawLine( x - 50, y + 50, x - 20, y + 50 )
		surface.DrawLine( x + 50, y + 50, x + 50, y + 20 )
		surface.DrawLine( x + 50, y + 50, x + 20, y + 50 )

		local tr = util.TraceLine ({
			start = LocalPlayer():GetShootPos(),
			endpos = LocalPlayer():GetShootPos() + LocalPlayer():GetAimVector() * 99999,
			filter = LocalPlayer(),
			mask = MASK_SHOT
		})

		local dst = math.floor(tr.HitPos:Distance( LocalPlayer():GetShootPos() ) * 0.0254 )
		if dst > 100 or !tr.Hit or tr.HitSky then return end
		draw.SimpleText( "RNG: "..dst.."m", "NovaTrebuchetMods", x + 60, y + 40, Color(155,255,155, 100 ), 0)
		if tr.Hit and tr.Entity and tr.Entity:GetClass() == "prop_vehicle_jeep" then 
			draw.SimpleText( "SCN", "NovaTrebuchetMods", x + 60, y - 53, Color(155,255,155, 100 ), 0)
			if dst <= 10 then draw.SimpleText( "ADVSCN", "NovaTrebuchetMods", x + 60, y - 35, Color(155,255,155, 100 ), 0) end
		end

end


function SWEP:Think()
end


function SWEP:PrimaryAttack()

	if SERVER then

		local f = {self.Owner}
		if self.Owner:GetVehicle():IsValid() then f = {self.Owner, self.Owner:GetVehicle()} end
		if self.Owner:GetVehicle().ParentVehicle and self.Owner:GetVehicle().ParentVehicle:IsValid() then table.insert( f, self.Owner:GetVehicle().ParentVehicle ) end
		local tr = util.TraceLine ({
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 3950,
			filter = f,
			mask = MASK_SHOT
		})

		if tr.Hit and !tr.HitSky and tr.Entity:IsValid() and tr.Entity:GetClass() == "prop_vehicle_jeep" then
			net.Start( "CMSendSpeedgunPulse" )
			local sn = tr.Entity:GetVehicleClass()
			if CMOD_Cars[sn] then sn = CMOD_Cars[sn].Name
				elseif list.Get( "Vehicles" )[ sn ] then sn = list.Get( "Vehicles" )[ sn ].Name 
			end
			if tr.Entity:GetDriver():IsValid() and !tr.Entity:GetDriver():isCP() and tr.Entity:GetCMSpeed() > (NOVA_Config["SpeedLimit"] + 2) then tr.Entity:GetDriver():wanted(self.Owner, "Speeding", GAMEMODE.Config.wantedtime) end
			net.WriteString( sn )
			net.WriteFloat( tr.Entity:GetCMSpeed() )
			net.Send( self.Owner )
		end
	end
	self.Weapon:SetNextPrimaryFire(CurTime() + 0.6)
	self.Weapon:SetNextSecondaryFire(CurTime() + 0.6)

end



function SWEP:SecondaryAttack()
end
