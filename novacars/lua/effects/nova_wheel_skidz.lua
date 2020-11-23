-- chuck some siq skidz lad
function EFFECT:Init(data)
	self.penis = data:GetOrigin()
	local randomizer = Vector( math.random(-3, 3), math.random(-3, 3), 0 )

	self.Emitter = ParticleEmitter( self.penis )
	if !self.Emitter then return end

			local beat = self.Emitter:Add("particle/smokesprites_000"..math.random(1,8), self.penis)
			if (beat) then
				beat:SetPos( self.penis + randomizer )
				beat:SetLifeTime(1)
				beat:SetDieTime(math.Rand( 2, 3 ))
				beat:SetStartAlpha(254)
				beat:SetEndAlpha(0)
				beat:SetStartSize(math.random(1,2))
				beat:SetEndSize(math.random(50,60))
				beat:SetCollide(false)
				beat:SetGravity(Vector(0,0,30))
				beat:SetRollDelta( math.random(-1,1) )
				beat:SetColor(205,205,205,math.random(20,30))
				beat:SetVelocity(Vector(math.random(-20, 20),math.random(-20, 20),math.random(20, 30) ))
			end

		self.Emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end