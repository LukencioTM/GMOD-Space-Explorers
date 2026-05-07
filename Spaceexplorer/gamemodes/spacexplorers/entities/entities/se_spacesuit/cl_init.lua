include("shared.lua")

function ENT:Draw()
    self:DrawModel()

    local text = "Traje espacial"
    surface.SetFont( "se_NPCFont" )
    local width, _ = surface.GetTextSize( text )

    cam.Start3D2D(self:GetPos() + Vector(0, -10, 60), Angle(0, 0, 90), 0.15)
      draw.SimpleText(text, "se_NPCFont", -width / 2, 0, Color(200, 200, 200, 255), 0, 0, TEXT_ALIGN_CENTER);
    cam.End3D2D()
end
