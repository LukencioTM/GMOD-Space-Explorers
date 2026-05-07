net.Receive("se_open_fractions_npc", function()
  local fractions = net.ReadTable()
  local current_fraction = fractions.Player_Fraction
  if current_fraction == "None" then
    current_fraction = "Sin faccion"
  elseif fractions.Fractions[current_fraction] then
    current_fraction = fractions.Fractions[current_fraction].Name
  end

  local se_shop_main = vgui.Create( "DFrame" )
  se_shop_main:SetSize(600, 600)
  se_shop_main:Center()
  se_shop_main:SetDraggable( true )
  se_shop_main:MakePopup()
  se_shop_main:SetTitle( "Facciones" )
  function se_shop_main:Paint(w, h)
    draw.RoundedBox( 5, 0, 0, w, h, Color(50, 50, 50, 250) )
  end

  local DLabel = vgui.Create( "DLabel", se_shop_main )
  DLabel:SetSize(400, 50)
  DLabel:Dock(TOP)
  DLabel:SetContentAlignment(5)
  DLabel:SetText( current_fraction )
  DLabel:SetFont("se_ScoreboardFont")
  DLabel:SetColor(Color(255, 255, 255))

  if fractions.Player_Fraction == "None" then
    for k, fraction in pairs(fractions.Fractions) do
      local se_fraction_panel = vgui.Create( "DPanel", se_shop_main )
      se_fraction_panel:SetText("")
      se_fraction_panel:SetSize(350, 120)
      se_fraction_panel:DockMargin( 10, 10, 10, 0 )
      se_fraction_panel:Dock(TOP)
      function se_fraction_panel:Paint(w, h)
        draw.RoundedBox( 5, 0, 0, w, h, Color(60, 60, 60, 255) )
      end

      local se_fraction_button = vgui.Create( "DButton", se_fraction_panel )
      se_fraction_button:SetText("")
      se_fraction_button:SetSize(350, 40)
      se_fraction_button:Dock(TOP)
      function se_fraction_button:Paint(w, h)
        if self.Hovered then
          draw.RoundedBox( 5, 0, 0, w, h, Color(80, 80, 80, 255) )
        else
          draw.RoundedBox( 5, 0, 0, w, h, Color(30, 30, 30, 255) )
        end
        draw.DrawText( "Unirse a "..fraction.Name.." / 150 creditos", "se_ScoreboardFont", w / 2, 10, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
      end
      function se_fraction_button:OnMousePressed()
        net.Start("se_change_fraction")
        net.WriteString(k)
        net.SendToServer()
        se_shop_main:Close()
      end

      local se_fraction_desc = vgui.Create( "DLabel", se_fraction_panel )
      se_fraction_desc:SetSize(350, 80)
      se_fraction_desc:Dock(TOP)
      se_fraction_desc:SetText( fraction.Desc )
      se_fraction_desc:SetTextColor( Color(255, 255, 255) )
      se_fraction_desc:SetFont( "TerminalFont" )
      se_fraction_desc:SetAutoStretchVertical( true )
      se_fraction_desc:SetWrap(true)
    end
  else
    if !fractions.Mission then
      local se_fraction_take_mission = vgui.Create( "DButton", se_shop_main )
      se_fraction_take_mission:SetText("")
      se_fraction_take_mission:SetSize(350, 40)
      se_fraction_take_mission:DockMargin( 10, 10, 10, 10 )
      se_fraction_take_mission:Dock(TOP)
      function se_fraction_take_mission:Paint(w, h)
        if self.Hovered then
          draw.RoundedBox( 5, 0, 0, w, h, Color(40, 80, 40, 255) )
        else
          draw.RoundedBox( 5, 0, 0, w, h, Color(30, 70, 30, 255) )
        end
        draw.DrawText( "Tomar mision", "se_ScoreboardFont", w / 2, 10, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
      end
      function se_fraction_take_mission:OnMousePressed()
        net.Start("se_take_mission")
        net.SendToServer()
        se_fraction_take_mission:Remove()
        local Missions = vgui.Create( "DLabel", se_shop_main )
        Missions:SetSize(400, 50)
        Missions:Dock(TOP)
        Missions:SetContentAlignment(5)
        Missions:SetText( "Sin misiones" )
        Missions:SetFont("se_ScoreboardFont")
        Missions:SetColor(Color(255, 255, 255))
      end
    else
      local Missions = vgui.Create( "DLabel", se_shop_main )
      Missions:SetSize(400, 50)
      Missions:Dock(TOP)
      Missions:SetContentAlignment(5)
      Missions:SetText( "Sin misiones" )
      Missions:SetFont("se_ScoreboardFont")
      Missions:SetColor(Color(255, 255, 255))
    end
    local se_fraction_leave = vgui.Create( "DButton", se_shop_main )
    se_fraction_leave:SetText("")
    se_fraction_leave:SetSize(350, 40)
    se_fraction_leave:DockMargin( 10, 10, 10, 10 )
    se_fraction_leave:Dock(BOTTOM)
    function se_fraction_leave:Paint(w, h)
      if self.Hovered then
        draw.RoundedBox( 5, 0, 0, w, h, Color(80, 80, 80, 255) )
      else
        draw.RoundedBox( 5, 0, 0, w, h, Color(30, 30, 30, 255) )
      end
      draw.DrawText( "Abandonar faccion", "se_ScoreboardFont", w / 2, 10, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
    end
    function se_fraction_leave:OnMousePressed()
      net.Start("se_change_fraction")
      net.WriteString("None")
      net.SendToServer()
      se_shop_main:Close()
    end
  end
end)
