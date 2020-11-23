SWEP.Category          = "Novacars"
SWEP.Instructions   = "Left click to deploy spike strips, Right click to collect them."
SWEP.ViewModelFlip		= false
SWEP.ViewModel = "models/weapons/c_crowbar.mdl"
SWEP.WorldModel = "models/weapons/w_package.mdl"
SWEP.ViewModelFOV 		= 51
SWEP.BobScale 			= 2
SWEP.DrawCrosshair 			= false
SWEP.HoldType = "normal"
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
SWEP.Primary.DefaultClip	= -1
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

if SERVER then 
	util.AddNetworkString( "CMSendFixingTimer" )
	util.AddNetworkString( "CMOpenModMenu" )
end


SWEP.ViewModelBoneMods = {
	["ValveBiped.Bip01_R_Hand"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
}

SWEP.VElements = {
	["asshole"] = { type = "Model", model = "models/props_c17/tools_wrench01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.367, 1.253, -4.791), angle = Angle(0, -42.037, -91.471), size = Vector(0.97, 0.97, 0.97), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}


SWEP.WElements = {
--	["asshole"] = { type = "Model", model = "models/props_c17/tools_wrench01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(2.848, 1.172, -2.82), angle = Angle(0, 0, -88.996), size = Vector(0.97, 0.97, 0.97), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}


function SWEP:Deploy()

	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
	self.Weapon:SetNextPrimaryFire(CurTime() + 1)

	self.Weapon:SetHoldType("normal")

	return true
end

function SWEP:DrawHUD()
	if !LocalPlayer():IsValid() or !LocalPlayer():Alive() or LocalPlayer():InVehicle() then return end

	local tr = util.TraceLine ({
		start = LocalPlayer():GetShootPos(),
		endpos = LocalPlayer():GetShootPos() + LocalPlayer():GetAimVector() * 100,
		filter = LocalPlayer(),
		mask = MASK_SHOT
	})

	draw.SimpleText( "Spike Strips: "..LocalPlayer():GetNWInt( "NCSpikeStrips", 0 ), "NovaTrebuchet", ScrW() - 200, ScrH() - 200, Color(255,255,255), 1 )
	if !tr.Entity or !tr.Entity:IsValid() then return end
	if tr.Entity:GetClass() == "nova_spikestrip" then
--		draw.SimpleText( "Left Click: Fix Vehicle", "NovaTrebuchet", ScrW() / 2, (ScrH() / 2) - 40, Color(255,255,255), 1)
		draw.SimpleText( "Right Click: Collect Spike Strip", "NovaTrebuchet", ScrW() / 2, (ScrH() / 2) - 26, Color(255,255,255), 1 )
	end

end

hook.Add( "PlayerSpawn", "NCFixDeadPeople", function( ply ) 
	ply:SetNWInt( "NCSpikeStrips", 0 )
end)

-- c+p from neobasewars
function SWEP:BetterCheckObstructed( pos )
	local trsize = 50
	local tr = util.TraceHull( {
	start = pos + Vector( 0, 0, trsize ),
	endpos = pos + Vector( 0, 0, trsize / 2 ),
	mins = Vector( -(trsize / 2), -(trsize / 2), -(trsize / 2) ),
	maxs = Vector( (trsize / 2), (trsize / 2), (trsize / 2) ),
	mask = MASK_ALL,
	} )

	return !tr.Hit
end

function SWEP:Think()

	if CLIENT then
		local pmodel = "models/novacars/spikestrip/spikestrip.mdl"

		if !self.Ghost or !self.Ghost:IsValid() then
			self.Ghost = ents.CreateClientProp(pmodel)
			self.Ghost:SetOwner(LocalPlayer())
			self.Ghost:SetRenderMode(RENDERMODE_TRANSALPHA)
			self.Ghost:SetModel(pmodel)
		end

		if !self.Ghost:IsValid() then return end

		local tr = {}
		tr.start = self.Owner:GetShootPos()
		tr.endpos = self.Owner:GetShootPos() + 100 * self.Owner:GetAimVector()
		tr.filter = {self.Ghost, self.Owner}
		local trace = util.TraceLine(tr)

		if trace.Hit and trace.HitNormal.z > 0.95 and LocalPlayer():GetNWInt( "NCSpikeStrips", 0 ) > 0 then

		local ang = Angle(0,0,0)
		ang.yaw = 90 + self.Owner:GetAngles().y
		ang.roll = 0
		ang.pitch = 0
		local vec = trace.HitPos
		local maxs = self.Ghost:OBBMaxs()
		local mins = self.Ghost:OBBMins()
		local height = maxs.Z - mins.Z
		vec.Z = vec.Z

		self.Ghost:SetPos(vec + trace.HitNormal)

		self.Ghost:SetAngles(ang)
		local a = 100
		self.Ghost:SetColor(Color(255, 255, 255, a))
		if !self:BetterCheckObstructed( vec + trace.HitNormal ) then self.Ghost:SetColor(Color(255, 0, 0, a)) end
		else
			if self.Ghost:IsValid() then self.Ghost:SetColor(Color(255, 255, 255, 0)) end
		end
	end
end


function SWEP:PrimaryAttack()
	if !self.Owner:IsValid() or self.Owner:GetNWInt( "NCSpikeStrips", 0 ) < 1 then return end
	if SERVER then
		local ammo = self.Owner:GetNWInt( "NCSpikeStrips", 0 )
		if ammo < 1 then return end
		local tr = {}
		tr.start = self.Owner:GetShootPos()
		tr.endpos = self.Owner:GetShootPos() + 100 * self.Owner:GetAimVector()
		tr.filter = {self.Owner}
		local trace = util.TraceLine(tr)
		if trace.Hit and trace.HitNormal.z > 0.95 then
			if !self:BetterCheckObstructed( trace.HitPos + trace.HitNormal ) then return end
			local ss = ents.Create( "nova_spikestrip" )
			ss:SetPos( trace.HitPos )
			ss:SetAngles( Angle( 0,90 + self.Owner:GetAngles().y,0 ) )
			ss:Spawn()
			ss:EmitSound( "npc/roller/blade_cut.wav" )
			ss:SetNWEntity( "NCOwner", self.Owner )
			self.Owner:SetNWInt( "NCSpikeStrips", ammo - 1 )
		end
	end

	self.Weapon:SetNextPrimaryFire(CurTime() + 1)
	self.Weapon:SetNextSecondaryFire(CurTime() + 1)
end

function SWEP:SecondaryAttack()
	if SERVER then
		local tr = {}
		tr.start = self.Owner:GetShootPos()
		tr.endpos = self.Owner:GetShootPos() + 100 * self.Owner:GetAimVector()
		tr.filter = {self.Owner}
		local trace = util.TraceLine(tr)
	
		if trace.Entity and trace.Entity:IsValid() and trace.Entity:GetClass() == "nova_spikestrip" then
			trace.Entity:EmitSound( "npc/roller/blade_in.wav", 80, 70 )
			trace.Entity:Remove()
			local ammo = self.Owner:GetNWInt( "NCSpikeStrips", 0 )
			self.Owner:SetNWInt( "NCSpikeStrips", math.Clamp( ammo + 1, 0, NOVA_Config.MaxSpikeStripInventory ) )
		end
	end

	self.Weapon:SetNextPrimaryFire(CurTime() + 1)
	self.Weapon:SetNextSecondaryFire(CurTime() + 1)
end


if CLIENT then
function SWEP:OnRemove()
	if IsValid(self.Ghost) then
		self.Ghost:Remove()
	end
end

function SWEP:Holster()
	if IsValid(self.Ghost) then
		self.Ghost:Remove()
	end
end

end