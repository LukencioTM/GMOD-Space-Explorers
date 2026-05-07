AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

util.AddNetworkString("se_hologram_interact")

local function se_planet_key_from_current()
  if !se_is_planet or !istable(se_curret_planet) then return nil end

  for key, planet in pairs(se_planet_positions or {}) do
    if planet == se_curret_planet then
      return key
    end
  end

  return nil
end

function ENT:Initialize()
  self:SetModel("models/hunter/blocks/cube2x2x05.mdl")
  self:SetSolid(SOLID_VPHYSICS)
  self:SetMoveType(MOVETYPE_VPHYSICS)
  self:PhysicsInit(SOLID_VPHYSICS)
  self:SetUseType(SIMPLE_USE)

  local phys = self:GetPhysicsObject()
  if IsValid(phys) then
    phys:Wake()
  end

  self:SetHologramActive(false)
  self:SetStation(false)
  self:SetInfected(false)
  self:SetPlanetKey("")
  self:SetPlanetName("Sin destino")
  self.NextHologramUpdate = 0
end

function ENT:Think()
  if self.NextHologramUpdate > CurTime() then return end
  self.NextHologramUpdate = CurTime() + 0.5

  local key = se_planet_key_from_current()
  local active = key != nil
  local planet = active and se_curret_planet or nil

  self:SetHologramActive(active)
  self:SetPlanetKey(key or "")
  self:SetPlanetName(active and (planet.name or "Destino desconocido") or "Sin destino")
  self:SetStation(key == "Station" or key == "LostStation")
  self:SetInfected(key == "LostStation")

  self:NextThink(CurTime() + 5)
  return true
end

function ENT:Use(activator, caller)
  if IsValid(activator) and activator:IsPlayer() and self:GetHologramActive() then
    net.Start("se_hologram_interact")
    net.WriteEntity(self)
    net.Send(activator)
  end
end
