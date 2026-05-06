net.Receive("se_game_losed", function()
  local time_left = CurTime() + 30
  local info_table = net.ReadTable()
  local jumps = info_table.jumps
  local sectors = info_table.sectors
  local explored = info_table.explored
  local se_game_lose_frame = vgui.Create( "DFrame" )
  se_game_lose_frame:SetSize( 500, 300 )
  se_game_lose_frame:Center()
  se_game_lose_frame:SetTitle( "" )
  se_game_lose_frame:SetDraggable( true )
  se_game_lose_frame:MakePopup()
  se_game_lose_frame:ShowCloseButton( false )
  function se_game_lose_frame:Paint(w, h)
    draw.RoundedBox( 5, 0, 0, w, h, Color(50, 50, 50, 255) )
  end

  local game_losed_label = vgui.Create( "DLabel", se_game_lose_frame )
  game_losed_label:SetSize(400, 50)
  game_losed_label:Dock(TOP)
  game_losed_label:SetContentAlignment(5)
  game_losed_label:SetText( "Tu nave fue destruida" )
  game_losed_label:SetFont("se_ScoreboardFont")
  game_losed_label:SetColor(Color(255, 255, 255))

  local jumps_amount = vgui.Create( "DLabel", se_game_lose_frame )
  jumps_amount:SetSize(400, 30)
  jumps_amount:Dock(TOP)
  jumps_amount:SetContentAlignment(5)
  jumps_amount:SetText( "Realizaste "..jumps.." saltos" )
  jumps_amount:SetFont("se_ScoreboardFont")
  jumps_amount:SetColor(Color(255, 255, 255))

  local explores_amount = vgui.Create( "DLabel", se_game_lose_frame )
  explores_amount:SetSize(400, 30)
  explores_amount:Dock(TOP)
  explores_amount:SetContentAlignment(5)
  explores_amount:SetText( "Exploraste "..explored.." sistemas" )
  explores_amount:SetFont("se_ScoreboardFont")
  explores_amount:SetColor(Color(255, 255, 255))

  local sec_explores_amount = vgui.Create( "DLabel", se_game_lose_frame )
  sec_explores_amount:SetSize(400, 30)
  sec_explores_amount:Dock(TOP)
  sec_explores_amount:SetContentAlignment(5)
  sec_explores_amount:SetText( "Exploraste "..sectors.." sectores" )
  sec_explores_amount:SetFont("se_ScoreboardFont")
  sec_explores_amount:SetColor(Color(255, 255, 255))

  local time_left_label = vgui.Create( "DLabel", se_game_lose_frame )
  time_left_label:SetSize(400, 50)
  time_left_label:Dock(TOP)
  time_left_label:SetContentAlignment(5)
  time_left_label:SetText( "" )
  time_left_label:SetFont("se_ScoreboardFont")
  time_left_label:SetColor(Color(255, 255, 255))
  function time_left_label:Think()
    time_left_label:SetText( "Quedan "..math.Round((time_left - CurTime())).." segundos" )
  end


end)
