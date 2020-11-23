AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel( "models/props_c17/SuitCase_Passenger_Physics.mdl" )
 	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )

	local PhysAwake = self:GetPhysicsObject()
	if ( PhysAwake:IsValid() ) then
		PhysAwake:Wake()
	end 
end

function ENT:Use( ply, caller )
	if !ply:IsValid() or !ply:Alive() then return end
	local strips = ply:GetNWInt( "NCSpikeStrips", 0 )
	ply:SetNWInt( "NCSpikeStrips", math.Clamp( strips + 1, 0, NOVA_Config.MaxSpikeStripInventory ) )
	self:EmitSound( "items/itempickup.wav" )
	self:Remove()
end

function ENT:Think()
end

function ENT:Touch( ent )
end
