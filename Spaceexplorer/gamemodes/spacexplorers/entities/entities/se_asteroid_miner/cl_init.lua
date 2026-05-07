include("shared.lua")

function ENT:Draw()
    self:DrawModel()
    if self:GetNWBool("asteroid_attached", false) then
      if !self.asteroid_model then
        self.asteroid_model = ClientsideModel( "models/props_wasteland/rockgranite03b.mdl")
        self.asteroid_model:SetPos(Vector(-1090,-1230,100))
        self.asteroid_model:SetNoDraw(true)
      end
      local asteroid_mat = Matrix()
      asteroid_mat:SetAngles(Angle(-RealTime() * 2, RealTime() * 3, RealTime() * 4))
      self.asteroid_model:EnableMatrix( "RenderMultiply", asteroid_mat )
      self.asteroid_model:DrawModel()
      if self:GetNWBool("se_asteroid_emit_particles", false) then
        if CurTime() > (self.particle_cooldown or 0) then
          self.particle_cooldown = CurTime() + 0.2
          local effectdata = EffectData()
          effectdata:SetOrigin( Vector(-1090,-1230,100) )
          util.Effect( "StunstickImpact", effectdata )
        end
      end
    end
end
