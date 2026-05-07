SWEP.PrintName = "Herramienta de analisis"
SWEP.Slot      = 1
SWEP.HoldType = "pistol"
SWEP.ViewModelFOV = 70
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/c_toolgun.mdl"
SWEP.WorldModel = "models/weapons/w_toolgun.mdl"
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
    local trace = self.Owner:GetEyeTraceNoCursor()
    if IsValid(trace.Entity) and trace.Entity:GetClass() == "se_terminal" then
      local hp = players_spaceship.modules[trace.Entity.ModuleName].health
      self.Owner:ChatPrint("Salud del modulo: "..math.Round(hp))
    end
  end
end
