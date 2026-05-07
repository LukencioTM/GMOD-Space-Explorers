net.Receive("se_choose_race", function()
  local races = net.ReadTable()

  local choose_race_frame = vgui.Create( "DFrame" )
  choose_race_frame:SetSize( table.Count(races) * 228, 250 )
  choose_race_frame:Center()
  choose_race_frame:SetTitle( "" )
  choose_race_frame:SetDraggable( true )
  choose_race_frame:MakePopup()
  choose_race_frame:ShowCloseButton( false )
  function choose_race_frame:Paint(w, h)
    draw.RoundedBox( 5, 0, 0, w, h, Color(50, 50, 50, 255) )
  end

  local layout = vgui.Create( "DTileLayout", choose_race_frame )
  layout:SetBaseSize( 32 ) -- Tile size
  layout:Dock( FILL )

  for k, v in pairs(races) do
    local base_panel = vgui.Create( "DPanel" )
    base_panel:SetPos( 10, 30 )
    base_panel:SetSize( 200, 200 )
    function base_panel:Paint(w, h)
      draw.RoundedBox( 5, 0, 0, w, h, Color(40, 40, 50, 255) )
    end

    local model_panel = vgui.Create( "DModelPanel", base_panel )
    model_panel:SetSize( 200, 160 )
    model_panel:Dock(TOP)
    model_panel:SetModel( v.models[1] )

    local choose = vgui.Create( "DButton", base_panel )
    choose:SetSize( 300, 40 )
    choose:Dock( TOP )
    choose:SetText( "" )
    choose.DoClick = function()
      choose_race_frame:Close()
      net.Start("se_race_choosen")
      net.WriteString(k)
      net.SendToServer()
    end
    function choose:Paint(w, h)
      if self.Hovered then
        draw.RoundedBox( 5, 0, 0, w, h, Color(40, 160, 40, 255) )
      else
        draw.RoundedBox( 5, 0, 0, w, h, Color(10, 120, 10, 255) )
      end
      draw.DrawText( v.name, "se_ScoreboardFont", w / 2, 10, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
    end
    layout:Add( base_panel )
  end
end)
