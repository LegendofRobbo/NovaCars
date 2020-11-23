AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")


--Called when the SENT is spawned
function ENT:Initialize()
	self:SetModel( "models/novacars/spikestrip/spikestrip.mdl" )
 	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )
	self:SetTrigger( true )
	self.NxtThnk = CurTime() + 10
end

function ENT:Use( activator, caller )
end

function ENT:Think()
	if self.NxtThnk <= CurTime() then
		if !self:GetNWEntity( "NCOwner", game.GetWorld() ):IsValid() then self:Remove() end
		self.NxtThnk = CurTime() + 10
	end
end

function ENT:Touch( ent )
	if !ent:IsValid() or ent:GetClass() != "prop_vehicle_jeep" then return end
	local trc = self:GetTouchTrace()
	for i = 0, ent:GetWheelCount() - 1 do
		if ent:GetWheelContactPoint( i ):Distance( trc.HitPos ) < 25 then
			ent:ApplyTyreDamage( i, 99999 )
			break
		end
	end
end
