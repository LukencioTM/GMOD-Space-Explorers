SWEP.PrintName = "Herramienta de reparacion"
SWEP.Slot      = 1
SWEP.HoldType = "melee"
SWEP.ViewModelFOV = 70
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/c_crowbar.mdl"
SWEP.WorldModel = "models/props_c17/tools_wrench01a.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = true
SWEP.UseHands = true

SWEP.Primary.ClipSize       = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic      = false
SWEP.Primary.Ammo           = "none"
SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.Automatic    = false
SWEP.Secondary.Ammo         = "none"


function SWEP:PrimaryAttack()
  if SERVER then

    local tr = util.TraceHull({
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + (self.Owner:GetAimVector() * 66),
			mins = self.Mins,
			maxs = self.Maxs,
			filter = self.Owner
    })

    local ent = tr.Entity

    if ent and ent:IsValid() and ent:GetClass() == "se_terminal" then
      local hp = players_spaceship.modules[ent.ModuleName].health
      if hp < 100 then
        ent:EmitSound("npc/dog/dog_servo"..math.random(7, 8)..".wav", 70, math.random(100, 105))
        players_spaceship.modules[ent.ModuleName].health = math.Clamp(hp + 5 * self.Owner:GetNWInt("repair_skills", 1), 0, 100)
        local effectdata = EffectData()
        effectdata:SetOrigin( ent:GetPos() + Vector(0, 0, 32))
        util.Effect( "StunstickImpact", effectdata )
      else
        self:EmitSound("weapons/melee/crowbar/crowbar_hit-"..math.random(4)..".ogg", 75, math.random(120, 125))
        players_spaceship.modules[ent.ModuleName].health = 100
      end
    end
    if ent:IsPlayer() and ent.race == "Robots" then
      ent:Heal(5)
    end
    self.Weapon:SetNextPrimaryFire(CurTime() + 0.75)
  end

	self.Weapon:TakePrimaryAmmo(1)
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )

	self.Owner:SetAnimation(PLAYER_ATTACK1)
end
