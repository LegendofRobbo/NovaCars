function EFFECT:Init(data)
	self.penis = data:GetOrigin()
	local randomizer = Vector( math.random(-5, 5), math.random(-5, 5), 0 )

	self.Emitter = ParticleEmitter( self.penis )
	if !self.Emitter then return end

			local beat = self.Emitter:Add("particle/smokesprites_000"..math.random(1,8), self.penis)
			if (beat) then
				beat:SetPos( self.penis + randomizer )
				beat:SetLifeTime(1)
				beat:SetDieTime(math.Rand( 1.5, 3))
				beat:SetStartAlpha(254)
				beat:SetEndAlpha(0)
				beat:SetStartSize(math.random(12,15))
				beat:SetEndSize(math.random(60,85))
				beat:SetCollide(false)
				beat:SetGravity(Vector(0,0,50))
				beat:SetRollDelta( math.random(-2,2) )
				beat:SetColor(45,40,40,math.random(4,30))
				beat:SetVelocity(Vector(math.random(-20, 20),math.random(-20, 20),math.random(20, 30) ))
			end

		self.Emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end