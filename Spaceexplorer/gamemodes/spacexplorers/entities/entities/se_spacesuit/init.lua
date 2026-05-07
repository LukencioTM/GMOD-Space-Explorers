AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
  self:SetModel("models/Combine_Super_Soldier.mdl")
  self:SetSolid(SOLID_BBOX)
  self:SetUseType(SIMPLE_USE)
end

function ENT:Use(activator, caller)
  if caller.race != "Robots" then
    if !caller.in_suit then
      caller:WearSuit(true)
    else
      caller:WearSuit(false)
    end
    caller.in_suit = !caller.in_suit
  end
end
