AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local SE_TERMINAL_SCREEN_POS = Vector(0, -15, 50)
local SE_TERMINAL_SCREEN_ANG = Angle(0, 90, 45)
local SE_TERMINAL_SCREEN_SCALE = 0.05
local SE_PILOT_BUTTONS = {
  {command = "__console", x = 14, y = 52, w = 356, h = 488},
  {command = "jump", x = 390, y = 82, w = 190, h = 58},
  {command = "ship_health", x = 390, y = 152, w = 190, h = 58},
  {command = "ship_shields", x = 390, y = 222, w = 190, h = 58},
  {command = "fuel", x = 390, y = 292, w = 190, h = 58},
  {command = "help", x = 390, y = 362, w = 190, h = 58},
  {command = "clear", x = 390, y = 432, w = 190, h = 58}
}
local SE_HYPERDRIVE_BUTTONS = {
  {command = "__console", x = 14, y = 52, w = 356, h = 488},
  {command = "charge", x = 390, y = 112, w = 190, h = 66},
  {command = "get_charge", x = 390, y = 198, w = 190, h = 58},
  {command = "help", x = 390, y = 276, w = 190, h = 58},
  {command = "clear", x = 390, y = 354, w = 190, h = 58}
}
local SE_TELEPORT_BUTTONS = {
  {command = "__console", x = 14, y = 52, w = 356, h = 488},
  {command = "teleport", x = 390, y = 112, w = 190, h = 66},
  {command = "planet_info", x = 390, y = 198, w = 190, h = 58},
  {command = "help", x = 390, y = 276, w = 190, h = 58},
  {command = "clear", x = 390, y = 354, w = 190, h = 58}
}
local SE_COMMUNICATION_BUTTONS = {
  {command = "__console", x = 14, y = 52, w = 356, h = 488},
  {command = "answer 1", x = 390, y = 82, w = 190, h = 58},
  {command = "answer 2", x = 390, y = 152, w = 190, h = 58},
  {command = "answer 3", x = 390, y = 222, w = 190, h = 58},
  {command = "credits", x = 390, y = 302, w = 190, h = 50},
  {command = "help", x = 390, y = 366, w = 190, h = 50},
  {command = "clear", x = 390, y = 430, w = 190, h = 50}
}
local SE_WEAPONS_BUTTONS = {
  {command = "__console", x = 230, y = 52, w = 356, h = 488},
  {command = "enemy_modules", x = 14, y = 82, w = 190, h = 58},
  {command = "enemy_health", x = 14, y = 152, w = 190, h = 58},
  {command = "enemy_shields", x = 14, y = 222, w = 190, h = 58},
  {command = "weapons", x = 14, y = 302, w = 190, h = 50},
  {command = "help", x = 14, y = 366, w = 190, h = 50},
  {command = "clear", x = 14, y = 430, w = 190, h = 50},

  {command = "shoot 1 Weapons", x = 600, y = 82, w = 190, h = 58},
  {command = "shoot 2 Weapons", x = 600, y = 152, w = 190, h = 58},
  {command = "shoot 3 Weapons", x = 600, y = 222, w = 190, h = 58}
}
local SE_MINING_BUTTONS = {
  {command = "__console", x = 14, y = 52, w = 356, h = 488},
  {command = "asteroids", x = 390, y = 82, w = 190, h = 58},
  {command = "grab 1", x = 390, y = 152, w = 190, h = 58},
  {command = "mine", x = 390, y = 222, w = 190, h = 58},
  {command = "resources", x = 390, y = 292, w = 190, h = 58},
  {command = "miner_level", x = 390, y = 362, w = 190, h = 58},
  {command = "clear", x = 390, y = 432, w = 190, h = 58}
}

local function se_open_terminal_type(ent, ply)
  ply:SetNWEntity("ActiveTerminal", ent)
  net.Start("se_terminal_start_type")
  net.WriteEntity(ent)
  net.Send(ply)
end

local function se_can_use_terminal(ent, ply)
  return IsValid(ent) and IsValid(ply) and ply:Alive() and ply:GetPos():Distance(ent:GetPos()) <= 300
end

local function se_get_terminal_button_command(ent, ply, module_name, buttons)
  if ent.ModuleName != module_name then return nil end
  if !se_can_use_terminal(ent, ply) then return nil end

  local origin = ent:LocalToWorld(SE_TERMINAL_SCREEN_POS)
  local ang = SE_TERMINAL_SCREEN_ANG + ent:GetAngles()
  local hit_pos = util.IntersectRayWithPlane(ply:EyePos(), ply:GetAimVector(), origin, ang:Up())
  if !hit_pos then return nil end
  if hit_pos:DistToSqr(origin) > 120000 then return nil end

  local local_pos = WorldToLocal(hit_pos, Angle(), origin, ang)
  local x = local_pos.x / SE_TERMINAL_SCREEN_SCALE
  local y = -local_pos.y / SE_TERMINAL_SCREEN_SCALE

  for _, button in ipairs(buttons) do
    if x >= button.x and x <= button.x + button.w and y >= button.y and y <= button.y + button.h then
      return button.command
    end
  end

  return nil
end

function ENT:Initialize()
  self:SetModel("models/props_combine/combine_interface001.mdl")
  self:SetSolid(SOLID_VPHYSICS)
  self:SetUseType(SIMPLE_USE)
end

function ENT:Think()
  local hp = (players_spaceship.modules[self.ModuleName].health or 100) * 2
  self:SetColor(Color(255, 255 - (200 - hp), 255 - (200 - hp)))
end

function ENT:OnTakeDamage(damage)
  local hp = players_spaceship.modules[self.ModuleName].health
  if hp < 1 then
    local effectdata = EffectData()
    effectdata:SetOrigin( self:GetPos() )
    util.Effect( "HelicopterMegaBomb", effectdata )

    self:Ignite(30, 300)
  end
  if hp > 0 then
    players_spaceship.modules[self.ModuleName].health = hp - (damage:GetDamage() / 5)
  else
    players_spaceship.modules[self.ModuleName].health = 0
  end	

end

function ENT:Use(activator, caller)
  if !IsValid(caller) then return end

  if self.ModuleName == "Pilot" then
    local command = se_get_terminal_button_command(self, caller, "Pilot", SE_PILOT_BUTTONS)
    if command and command != "__console" then
      self:PrintLn(caller:Name() .. ":/ " .. command)
      se_terminal_read_line(self, command, caller)
    else
      se_open_terminal_type(self, caller)
    end
    return
  end

  if self.ModuleName == "HyperDrive" then
    local command = se_get_terminal_button_command(self, caller, "HyperDrive", SE_HYPERDRIVE_BUTTONS)
    if command and command != "__console" then
      self:PrintLn(caller:Name() .. ":/ " .. command)
      se_terminal_read_line(self, command, caller)
    else
      se_open_terminal_type(self, caller)
    end
    return
  end

  if self.ModuleName == "Teleport" then
    local command = se_get_terminal_button_command(self, caller, "Teleport", SE_TELEPORT_BUTTONS)
    if command and command != "__console" then
      self:PrintLn(caller:Name() .. ":/ " .. command)
      se_terminal_read_line(self, command, caller)
    else
      se_open_terminal_type(self, caller)
    end
    return
  end

  if self.ModuleName == "Communication" then
    local command = se_get_terminal_button_command(self, caller, "Communication", SE_COMMUNICATION_BUTTONS)
    if command and command != "__console" then
      self:PrintLn(caller:Name() .. ":/ " .. command)
      se_terminal_read_line(self, command, caller)
    else
      se_open_terminal_type(self, caller)
    end
    return
  end

  if self.ModuleName == "Weapons" then
    local command = se_get_terminal_button_command(self, caller, "Weapons", SE_WEAPONS_BUTTONS)
    if command and command != "__console" then
      self:PrintLn(caller:Name() .. ":/ " .. command)
      se_terminal_read_line(self, command, caller)
    elseif command == "__console" then
      se_open_terminal_type(self, caller)
    end
    return
  end

  if self.ModuleName == "AsteroidMining" then
    local command = se_get_terminal_button_command(self, caller, "AsteroidMining", SE_MINING_BUTTONS)
    if command and command != "__console" then
      self:PrintLn(caller:Name() .. ":/ " .. command)
      se_terminal_read_line(self, command, caller)
    elseif command == "__console" then
      se_open_terminal_type(self, caller)
    end
    return
  end

  se_open_terminal_type(self, caller)
end

function ENT:PrintLn(line)
  net.Start("se_terminal_println")
  net.WriteEntity(self)
  net.WriteString(line)
  net.Broadcast()
end

function ENT:ClearLines()
  net.Start("se_terminal_clear")
  net.WriteEntity(self)
  net.Broadcast()
end

function ENT:ChangeLine(line, index)
  net.Start("se_terminal_changeline")
  net.WriteEntity(self)
  net.WriteString(line)
  net.WriteInt(index, 32)
  net.Broadcast()
end

function ENT:Print(line)
  net.Start("se_terminal_print")
  net.WriteEntity(self)
  net.WriteString(line)
  net.Broadcast()
end

function ENT:ChangeUI(name, ply)
  net.Start("se_change_module_ui")
  net.WriteInt(self:EntIndex(), 32)
  net.WriteString(name)
  net.Send(ply)
end
