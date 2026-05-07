local meta = FindMetaTable( "Player" )

-- Just sends netmsg with info about the races.
function meta:ChooseRace()
  net.Start("se_choose_race")
  net.WriteTable(races)
  net.Send(self)
end

-- Wears spacesuit, used by se_spacesuit entity
function meta:WearSuit(wear)
  self:SetNWBool("SE_InSuit", wear)
  if wear then
    -- We write past speed values to bring them back after you wear suit off
    self.suit_walk_speed_prev = self:GetWalkSpeed()
    self.suit_run_speed_prev = self:GetRunSpeed()
    self.suit_prev_model = self:GetModel()
    self:SetModel("models/player/combine_super_soldier.mdl")
    self:SetWalkSpeed(self:GetWalkSpeed() / 1.3)
    self:SetRunSpeed(self:GetRunSpeed() / 1.3)
    self:AllowFlashlight( true )
  else
    -- Check if we have those values
    if self.suit_walk_speed_prev then
      -- Bring old values
      self:SetWalkSpeed(self.suit_walk_speed_prev)
      self:SetRunSpeed(self.suit_run_speed_prev)
      self:SetModel(self.suit_prev_model)
      self:AllowFlashlight( false )
    end
  end
  net.Start("se_wear_suit")
  net.WriteBool(wear)
  net.Send(self)
end

-- Heals player, with additional sound for robots
function meta:Heal(hp)
  local hp = self:Health()
  if hp < self:GetMaxHealth() then
    if self.race == "Robots" then
      self:EmitSound("npc/dog/dog_servo"..math.random(7, 8)..".wav", 70, math.random(100, 105))
      local effectdata = EffectData()
      effectdata:SetOrigin( self:GetPos() + Vector(0, 0, 32))
      util.Effect( "StunstickImpact", effectdata )
    end
    self:SetHealth(hp + 5)
  else
    self:SetHealth(self:GetMaxHealth())
  end
end

-- Gives talent point which can be used for upgrades
function meta:GiveTalentPoints(amount)
  self:SetNWInt("se_talent_points", self:GetNWInt("se_talent_points", 0) + amount)
end

-- Old function from middle of development. Allows you to control spaceship(Flying)
function meta:StartFlying(turnon)
  net.Start("se_open_pilot_camera")
  net.WriteBool( turnon )
  net.Send(self)
  self:Freeze( turnon )
  self.InShip = turnon
end

-- Setup skills
function meta:SetupSkills()
  self.skills = {
    Repairing = {
      level = 0,
      max = 5
    },
    Health = {
      level = 0,
      max = 5
    },
    Speed = {
      level = 0,
      max = 5
    },
  }
end
