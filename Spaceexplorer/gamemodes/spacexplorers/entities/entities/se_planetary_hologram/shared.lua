ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.PrintName = "Holograba planetario"
ENT.Category = "VenceAddons"
ENT.Author = "VenceAddons"
ENT.Spawnable = true
ENT.AdminOnly = false

function ENT:SetupDataTables()
  self:NetworkVar("Bool", 0, "HologramActive")
  self:NetworkVar("Bool", 1, "Station")
  self:NetworkVar("Bool", 2, "Infected")
  self:NetworkVar("String", 0, "PlanetKey")
  self:NetworkVar("String", 1, "PlanetName")
end
