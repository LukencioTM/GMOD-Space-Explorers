AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local se_npc_models = {
  "models/mossman.mdl",
  "models/alyx.mdl",
  "models/Barney.mdl",
  "models/Eli.mdl",
  "models/gman_high.mdl",
  "models/Kleiner.mdl",
  "models/monk.mdl",
  "models/odessa.mdl",
  "models/vortigaunt.mdl",
  "models/Combine_Soldier.mdl",
  "models/Humans/Group03m/male_02.mdl",
  "models/Humans/Group01/Female_04.mdl",
  "models/Humans/Group01/male_03.mdl",
}

local se_shop_types = {
  "Guns",
  "Fractions",
  "Ship Weapons",
  "Ship Service",
  "Ship Upgrades",
  "Mining Equipment"
}

local se_shop_type_names = {
  Guns = "Armas",
  Fractions = "Facciones",
  ["Ship Weapons"] = "Armas de nave",
  ["Ship Service"] = "Servicio de nave",
  ["Ship Upgrades"] = "Mejoras de nave",
  ["Mining Equipment"] = "Equipo de mineria"
}

function ENT:Initialize()
  local model = table.Random(se_npc_models)
  self:SetModel(model)
  self:SetSolid(SOLID_BBOX)
  self:SetHullType( HULL_HUMAN )
  self:SetHullSizeNormal( )
  self:SetNPCState( NPC_STATE_SCRIPT )
  self:CapabilitiesAdd( CAP_ANIMATEDFACE and CAP_TURN_HEAD)
  self:DropToFloor()
  self:SetUseType(SIMPLE_USE)
  self:SetMaxYawSpeed( 90 )

  self.items = {}

  local shop_type = table.Random(se_shop_types)
  if shop_type == "Guns" then
    se_npc_gen_gun_shop(self)
  end
  if shop_type == "Ship Weapons" then
    se_npc_gen_weapons_shop(self)
  end
  if shop_type == "Ship Service" then
    se_npc_ship_service(self)
  end
  if shop_type == "Ship Upgrades" then
    se_npc_ship_upgrades(self)
  end
  if shop_type == "Mining Equipment" then
    se_npc_mining_equipment(self)
  end
  self.shop_type = shop_type
  self:SetNWString("se_shopnpc_shop_name", se_shop_type_names[shop_type] or shop_type)
end

function ENT:AddItem(name, price, fn, fn_args, close)
  if close == nil then close = false end
  local item = {
    Name = name,
    Price = price,
    Fn = fn,
    Args = fn_args,
    Close = close
  }
  table.insert(self.items, item)
end

function ENT:AcceptInput( name, activator, caller )
  local items = {}
  for k, v in pairs(self.items) do
    items[k] = {
      Name = v.Name,
      Price = v.Price,
      Close = v.Close,
    }
  end
  if IsValid(caller) and caller:IsPlayer() and name == "Use" then
    if self.shop_type != "Fractions" then
      net.Start("se_open_npc_shop")
      net.WriteEntity(self)
      net.WriteTable(items)
      net.WriteInt(players_spaceship.credits, 32)
      net.Send(caller)
    else
      net.Start("se_open_fractions_npc")
      net.WriteTable(se_fractions)
      net.Send(caller)
    end
  end
end
