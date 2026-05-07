include("shared.lua")

function ENT:Initialize( )
  self.AutomaticFrameAdvance = true
end

function ENT:Draw()
  self.Entity:DrawModel()
  local angle = LocalPlayer():EyeAngles()
	angle:RotateAroundAxis( angle:Forward(), 90 )
	angle:RotateAroundAxis( angle:Right(), 90 )

  local text = self:GetNWString("se_shopnpc_shop_name", "Error")
  surface.SetFont( "se_NPCFont" )
  local width, _ = surface.GetTextSize( text )

  cam.Start3D2D(self:GetPos() + Vector(0, 0, 80), angle, 0.15)
    draw.SimpleText(text, "se_NPCFont", -width / 2, 0, Color(200, 200, 200, 255), 0, 0, TEXT_ALIGN_CENTER);
  cam.End3D2D()
end
