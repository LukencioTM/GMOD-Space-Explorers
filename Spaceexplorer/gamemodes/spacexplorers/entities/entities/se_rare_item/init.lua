AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local se_item_models = {
  "models/props_c17/pulleywheels_small01.mdl",
  "models/Combine_Helicopter/helicopter_bomb01.mdl",
  "models/props_junk/PlasticCrate01a.mdl",
  "models/props_combine/breenglobe.mdl",
  "models/props_junk/MetalBucket01a.mdl",
  "models/props_c17/pulleywheels_large01.mdl",
  "models/props_combine/breenbust.mdl",
  "models/props_junk/Shoe001a.mdl",
  "models/props_vehicles/carparts_muffler01a.mdl"
}

function ENT:Initialize()
  local model = table.Random(se_item_models)
  self:SetModel(model)
  self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	phys:Wake()
  self:SetUseType(SIMPLE_USE)
end

function ENT:Use(acticator, caller)
  local credits = math.random(2, 12)
  players_spaceship.credits = players_spaceship.credits + credits
  caller:ChatPrint("+"..credits.." creditos")
  self:EmitSound("items/itempickup.wav")
  self:EmitSound("items/itempickup.wav")
  self:EmitSound("items/itempickup.wav")
  self:Remove()
end
