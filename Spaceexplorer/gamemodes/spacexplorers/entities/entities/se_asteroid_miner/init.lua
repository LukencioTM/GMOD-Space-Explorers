AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
  self:SetModel("models/props_combine/combine_teleportplatform.mdl")
  self:SetSolid(SOLID_BBOX)
  self:SetUseType(SIMPLE_USE)
end

function ENT:Use(acticator, caller)

end

function ENT:AttachAsteroid()
  self:SetNWBool("asteroid_attached", true)
  self.asteroid_attached = true
end
function ENT:DeattachAsteroid()
  self:SetNWBool("asteroid_attached", false)
  self.asteroid_attached = false
end
