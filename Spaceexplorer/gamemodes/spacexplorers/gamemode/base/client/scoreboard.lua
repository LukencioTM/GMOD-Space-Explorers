local se_universe = Material( "se_materials/universe.png" )
local se_spaceship_icon = Material( "se_materials/spaceship_icon.png" )
se_current_star_map = se_current_star_map or nil

local se_scoreboard_languages = {
	Espanol = "es",
	English = "eng",
	Russian = "rus"
}

local se_star_type_names = {
	Unknow = "Desconocido",
	Shop = "Tienda",
	Station = "Estacion",
	Exit = "Salida",
	Mission = "Mision"
}

local se_skill_names = {
	Repairing = "Reparacion",
	Health = "Salud",
	Speed = "Velocidad"
}

local se_race_names = {
	Humans = "Humanos",
	Robots = "Robots",
	Zoltans = "Zoltans"
}

local function se_close_star_map(show_scoreboard)
	if IsValid(se_map_browser) then
		se_map_browser:Remove()
	end

	if show_scoreboard and IsValid(se_scoreboard) then
		se_scoreboard:Show()
	end
end

local function se_draw_menu_button(button, w, h, text, base_color, hover_color)
	if button.Hovered then
		draw.RoundedBox( 5, 0, 0, w, h, hover_color )
	else
		draw.RoundedBox( 5, 0, 0, w, h, base_color )
	end
	draw.DrawText( text, "se_ScoreboardFont", w / 2, 12, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
end

function se_draw_star_map(stars, w, h, draw_labels, offset_x, offset_y)
	if !stars or !stars.stars then return end
	offset_x = offset_x or 0
	offset_y = offset_y or 0

	surface.SetDrawColor( 255, 255, 255, 100 )
	surface.SetMaterial( se_universe	)
	surface.DrawTexturedRect( offset_x, offset_y, w, h )

	for k, star in pairs(stars.stars) do
		local start_pos = { offset_x + 20 + (w - 50) * (star.pos[1] / 100), offset_y + 20 + (h - 70) * (star.pos[2] / 100)}
		if stars.player_pos == k then
			local c = math.cos( math.rad( (CurTime() % 360) * 10 ) )
			local s = math.sin( math.rad( (CurTime() % 360) * 10 ) )
			local newx = 30 * s - 30 * c + 15
			local newy = 30 * c + 30 * s + 15
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial( se_spaceship_icon	)
			surface.DrawTexturedRectRotated( start_pos[1] + newx, start_pos[2] + newy, 30, 32, (CurTime() % 360) * 10 - 120 )
		end
		for _, v in pairs(star.connects_to) do
			if stars.stars[v] then
				local end_pos = { offset_x + 20 + (w - 50) * (stars.stars[v].pos[1] / 100), offset_y + 20 + (h - 70) * (stars.stars[v].pos[2] / 100)}
				surface.SetDrawColor( 255, 255, 255, 255 )
				surface.DrawLine( start_pos[1] + 16, start_pos[2] + 16, end_pos[1] + 16, end_pos[2] + 16)
			end
		end
	end

	for k, star in pairs(stars.stars) do
		local pos = { offset_x + 20 + (w - 50) * (star.pos[1] / 100), offset_y + 20 + (h - 70) * (star.pos[2] / 100)}
		if draw_labels then
			local label_text = se_star_type_names[star.type] or star.type
			if star.explored and star.saved_system_name then
				label_text = star.saved_system_name
			end
			draw.SimpleText( label_text, "se_map_font", pos[1], pos[2] - 15, Color(255, 255, 255), TEXT_ALIGN_LEFT )
		end
		drawCircle(16 + pos[1], 16 + pos[2], 16, 4, Color(255, 255, 255))
		if stars.player_pos == k then
			drawCircle(16 + pos[1], 16 + pos[2], 12.8, 4, Color(40, 80, 40))
		elseif stars.star_choosed == k then
			drawCircle(16 + pos[1], 16 + pos[2], 12.8, 4, Color(80, 80, 40))
		elseif star.type == "Exit" then
			drawCircle(16 + pos[1], 16 + pos[2], 12.8, 4, Color(80, 40, 40))
		elseif star.type == "Mission" then
			drawCircle(16 + pos[1], 16 + pos[2], 12.8, 4, Color(80, 40, 80))
		elseif star.explored then
			drawCircle(16 + pos[1], 16 + pos[2], 12.8, 4, Color(40, 40, 80))
		else
			drawCircle(16 + pos[1], 16 + pos[2], 12.8, 4, Color(40, 40, 40))
		end
	end
end

local function se_open_save_game_panel()
	local frame = vgui.Create( "DFrame" )
	frame:SetSize( 420, 180 )
	frame:Center()
	frame:SetTitle( "Guardar partida" )
	frame:SetDraggable( true )
	frame:MakePopup()
	function frame:Paint(w, h)
		draw.RoundedBox( 5, 0, 0, w, h, Color(50, 50, 50, 250) )
	end

	local label = vgui.Create( "DLabel", frame )
	label:SetText( "Nombre del guardado" )
	label:SetFont( "se_ScoreboardFont" )
	label:SetColor( Color(255, 255, 255) )
	label:Dock( TOP )
	label:DockMargin( 12, 8, 12, 4 )
	label:SetTall( 30 )

	local entry = vgui.Create( "DTextEntry", frame )
	entry:Dock( TOP )
	entry:DockMargin( 12, 0, 12, 10 )
	entry:SetTall( 32 )
	entry:SetText( os.date("Partida %Y-%m-%d %H-%M") )
	entry:SelectAllText()

	local save_button = vgui.Create( "DButton", frame )
	save_button:SetText( "" )
	save_button:Dock( TOP )
	save_button:DockMargin( 12, 0, 12, 0 )
	save_button:SetTall( 44 )
	function save_button:Paint(w, h)
		se_draw_menu_button(self, w, h, "Guardar", Color(10, 120, 10, 255), Color(40, 160, 40, 255))
	end
	function save_button:DoClick()
		net.Start("se_save_game")
		net.WriteString(entry:GetValue())
		net.SendToServer()
		frame:Close()
	end
end

local function se_open_load_game_panel(saves)
	local frame = vgui.Create( "DFrame" )
	frame:SetSize( 620, 420 )
	frame:Center()
	frame:SetTitle( "Cargar partida" )
	frame:SetDraggable( true )
	frame:MakePopup()
	function frame:Paint(w, h)
		draw.RoundedBox( 5, 0, 0, w, h, Color(50, 50, 50, 250) )
	end

	local selected_save = nil

	local list = vgui.Create( "DScrollPanel", frame )
	list:Dock( FILL )
	list:DockMargin( 10, 10, 10, 10 )

	if table.Count(saves or {}) == 0 then
		local empty = vgui.Create( "DLabel", list )
		empty:Dock( TOP )
		empty:SetTall( 40 )
		empty:SetContentAlignment( 5 )
		empty:SetFont( "se_ScoreboardFont" )
		empty:SetColor( Color(255, 255, 255) )
		empty:SetText( "No hay partidas guardadas" )
	end

	for _, save in ipairs(saves or {}) do
		local save_button = vgui.Create( "DButton", list )
		save_button:SetText( "" )
		save_button:SetTall( 58 )
		save_button:Dock( TOP )
		save_button:DockMargin( 0, 0, 0, 8 )

		function save_button:Paint(w, h)
			local base_color = selected_save == save.id and Color(40, 80, 120, 255) or Color(30, 30, 30, 255)
			local hover_color = selected_save == save.id and Color(60, 110, 160, 255) or Color(80, 80, 80, 255)
			if self.Hovered then
				draw.RoundedBox( 5, 0, 0, w, h, hover_color )
			else
				draw.RoundedBox( 5, 0, 0, w, h, base_color )
			end
			draw.DrawText( save.name or save.id, "se_ScoreboardFont", 10, 6, Color(255, 255, 255), TEXT_ALIGN_LEFT )
			draw.DrawText( "Sistema: "..(save.system_name or "?").." | Fuel: "..(save.fuel or 0).." | HP: "..math.Round(save.health or 0).." | Creditos: "..(save.credits or 0), "TerminalFont", 10, 32, Color(220, 220, 220), TEXT_ALIGN_LEFT )
		end

		function save_button:DoClick()
			selected_save = save.id
		end
	end

	local bottom_panel = vgui.Create("DPanel", frame)
	bottom_panel:Dock( BOTTOM )
	bottom_panel:DockMargin( 10, 0, 10, 10 )
	bottom_panel:SetTall( 48 )
	bottom_panel.Paint = function() end

	local load_button = vgui.Create( "DButton", bottom_panel )
	load_button:SetText( "" )
	load_button:Dock( LEFT )
	load_button:SetWide( 290 )
	function load_button:Paint(w, h)
		se_draw_menu_button(self, w, h, "CARGAR", Color(10, 120, 10, 255), Color(40, 160, 40, 255))
	end
	function load_button:DoClick()
		if !selected_save then return end
		net.Start("se_load_game")
		net.WriteString(selected_save)
		net.SendToServer()
		frame:Close()
	end

	local delete_button = vgui.Create( "DButton", bottom_panel )
	delete_button:SetText( "" )
	delete_button:Dock( RIGHT )
	delete_button:SetWide( 290 )
	function delete_button:Paint(w, h)
		se_draw_menu_button(self, w, h, "BORRAR", Color(120, 10, 10, 255), Color(160, 40, 40, 255))
	end
	function delete_button:DoClick()
		if !selected_save then return end
		Derma_Query("Estas seguro que quieres borrar " .. selected_save .. "?", "Confirmar Borrado",
			"SI", function()
				net.Start("se_delete_save_game")
				net.WriteString(selected_save)
				net.SendToServer()
				frame:Close()
			end,
			"NO", function() end
		)
	end
end

function se_open_star_map(stars)
	if IsValid(se_scoreboard) then
		se_scoreboard:Hide()
	end

	se_map_browser = vgui.Create( "DPanel" )
	se_map_browser:SetSize( 800, 600 )
	se_map_browser:Center()
	se_map_browser:MakePopup()

	function se_map_browser:Paint(w, h)
    draw.RoundedBox( 5, 0, 0, w, h, Color(50, 50, 50, 230) )
  end

	se_map_browser_map = vgui.Create( "DPanel", se_map_browser )
	se_map_browser_map:SetSize( 800, 520 )
	se_map_browser_map:Dock(TOP)

	function se_map_browser_map:Paint(w, h)
		se_draw_star_map(stars, w, h, false)
  end

	for k, star in pairs(stars.stars) do
		local pos = { 20 + 750 * (star.pos[1] / 100), 20 + 450 * (star.pos[2] / 100)}
		local DLabel = vgui.Create( "DLabel", se_map_browser_map )
		DLabel:SetPos( pos[1], pos[2] - 15 )
		DLabel:SetColor( Color(255, 255, 255) )
		local label_text = se_star_type_names[star.type] or star.type
		if star.explored and star.saved_system_name then
			label_text = star.saved_system_name
		end
		DLabel:SetText( label_text )
		DLabel:SetFont("se_map_font")

		local se_map_browser_star = vgui.Create( "DButton", se_map_browser_map )
		se_map_browser_star:SetText("")
		se_map_browser_star:SetSize(33, 33)
		se_map_browser_star:SetPos(pos[1], pos[2])
		function se_map_browser_star:OnMousePressed()
			if table.HasValue(star.connects_to, stars.player_pos) then
				surface.PlaySound("buttons/button15.wav")
				stars.star_choosed = k
				net.Start("se_choose_star")
				net.WriteInt(k, 8)
				net.SendToServer()
			else
				surface.PlaySound("buttons/button10.wav")
			end
		end
		function se_map_browser_star:Paint(w, h)
			drawCircle(w / 2, h / 2, w / 2, 4, Color(255, 255, 255))
			if stars.player_pos == k then
				drawCircle(w / 2, h / 2, w / 2 * 0.8, 4, Color(40, 80, 40))
			elseif stars.star_choosed == k then
				drawCircle(w / 2, h / 2, w / 2 * 0.8, 4, Color(80, 80, 40))
			elseif star.type == "Exit" then
				drawCircle(w / 2, h / 2, w / 2 * 0.8, 4, Color(80, 40, 40))
			elseif star.type == "Mission" then
				drawCircle(w / 2, h / 2, w / 2 * 0.8, 4, Color(80, 40, 80))
			elseif star.explored then
				drawCircle(w / 2, h / 2, w / 2 * 0.8, 4, Color(40, 40, 80))
			else
				drawCircle(w / 2, h / 2, w / 2 * 0.8, 4, Color(40, 40, 40))
			end
		end
	end

	local se_map_browser_close = vgui.Create( "DButton", se_map_browser )
	se_map_browser_close:SetText("")
	se_map_browser_close:SetSize(350, 60)
	se_map_browser_close:DockMargin( 10, 10, 10, 10 )
	se_map_browser_close:Dock(LEFT)
	function se_map_browser_close:OnMousePressed()
		se_close_star_map(true)
	end
	function se_map_browser_close:Paint(w, h)
		if self.Hovered then
			draw.RoundedBox( 5, 0, 0, w, h, Color(40, 160, 40, 255) )
		else
			draw.RoundedBox( 5, 0, 0, w, h, Color(10, 120, 10, 255) )
		end
		draw.DrawText( "Cerrar", "se_ScoreboardFont", w / 2, 20, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
	end

	local se_map_browser_jump_to_next_sec = vgui.Create( "DButton", se_map_browser )
	se_map_browser_jump_to_next_sec:SetText("")
	se_map_browser_jump_to_next_sec:SetSize(350, 60)
	se_map_browser_jump_to_next_sec:DockMargin( 10, 10, 10, 10 )
	se_map_browser_jump_to_next_sec:Dock(RIGHT)
	function se_map_browser_jump_to_next_sec:OnMousePressed()
		if stars.stars[stars.player_pos].type == "Exit" then
			net.Start("se_jump_to_next_sector")
			net.SendToServer()
			se_close_star_map(true)
		end
	end
	function se_map_browser_jump_to_next_sec:Paint(w, h)
		local color = 0.5
		if stars.stars[stars.player_pos].type == "Exit" then
			color = 1.0
		end
		if self.Hovered and stars.stars[stars.player_pos].type == "Exit" then
			draw.RoundedBox( 5, 0, 0, w, h, Color(40 * color, 40 * color, 160 * color, 255) )
		else
			draw.RoundedBox( 5, 0, 0, w, h, Color(10 * color, 10 * color, 120 * color, 255) )
		end
		draw.DrawText( "Saltar al siguiente sector", "se_ScoreboardFont", w / 2, 20, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
	end

end

function se_open_scoreboard(skills, stars)
  se_scoreboard = vgui.Create( "DFrame" )
  se_scoreboard:SetSize( 800, 600 )
  se_scoreboard:Center()
	se_scoreboard:SetTitle("")
  se_scoreboard:MakePopup()
  function se_scoreboard:Paint(w, h)

  end

  local se_scoreboard_main = vgui.Create( "DPanel", se_scoreboard )
  se_scoreboard_main:SetSize(400, 600)
  se_scoreboard_main:Dock(LEFT)
  function se_scoreboard_main:Paint(w, h)
    draw.RoundedBox( 5, 0, 0, w, h, Color(50, 50, 50, 250) )
  end

	local se_scoreboard_open_map = vgui.Create( "DButton", se_scoreboard_main )
	se_scoreboard_open_map:SetText("")
	se_scoreboard_open_map:SetSize(350, 60)
	se_scoreboard_open_map:DockMargin( 10, 10, 10, 0 )
	se_scoreboard_open_map:Dock(TOP)
	function se_scoreboard_open_map:OnMousePressed()
		se_open_star_map(stars)
	end
	function se_scoreboard_open_map:Paint(w, h)
		if self.Hovered then
			draw.RoundedBox( 5, 0, 0, w, h, Color(40, 160, 40, 255) )
		else
			draw.RoundedBox( 5, 0, 0, w, h, Color(10, 120, 10, 255) )
		end
		draw.DrawText( "Abrir mapa", "se_ScoreboardFont", w / 2, 20, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
	end

  local DLabel = vgui.Create( "DLabel", se_scoreboard_main )
  DLabel:SetSize(400, 50)
  DLabel:Dock(TOP)
  DLabel:SetContentAlignment(5)
  DLabel:SetText( LocalPlayer():GetNWInt("se_talent_points", 0).." puntos de talento disponibles" )
  DLabel:SetFont("se_ScoreboardFont")
  DLabel:SetColor(Color(255, 255, 255))

  for k, v in pairs(skills) do
    local se_scoreboard_skill_button = vgui.Create( "DButton", se_scoreboard_main )
    se_scoreboard_skill_button:SetText("")
    se_scoreboard_skill_button:SetSize(350, 40)
    se_scoreboard_skill_button:DockMargin( 10, 10, 10, 0 )
    se_scoreboard_skill_button:Dock(TOP)
    function se_scoreboard_skill_button:OnMousePressed()
      if LocalPlayer():GetNWInt("se_talent_points", 0) > 0 and v.level < v.max and !LocalPlayer():GetNWBool("SE_InSuit", false) then
				surface.PlaySound("buttons/button15.wav")
        v.level = v.level + 1
        DLabel:SetText( (LocalPlayer():GetNWInt("se_talent_points", 0) - 1).." puntos de talento disponibles" )
        net.Start("se_skill_update")
        net.WriteString(k)
        net.SendToServer()
			else
				surface.PlaySound("buttons/button10.wav")
      end
    end
    function se_scoreboard_skill_button:Paint(w, h)
      if self.Hovered then
        draw.RoundedBox( 5, 0, 0, w, h, Color(80, 80, 80, 255) )
      else
        draw.RoundedBox( 5, 0, 0, w, h, Color(30, 30, 30, 255) )
      end
      draw.DrawText( se_skill_names[k] or k, "se_ScoreboardFont", 5, 10, Color( 255, 255, 255, 255 ) )
      for k=1,v.max do
        if v.level >= k then
					draw.RoundedBox( 20, 150 + k * 25, 10, 20, 20, Color( 200, 200, 200, 255 ) )
        else
					draw.RoundedBox( 20, 150 + k * 25, 10, 20, 20, Color( 80, 80, 80, 255 ) )
        end
      end
    end
  end

	local language_combo_box = vgui.Create( "DComboBox", se_scoreboard_main )
	language_combo_box:SetPos( 5, 5 )
	language_combo_box:SetSize( 100, 40 )
	language_combo_box:SetValue( "Idioma" )
	for k, v in pairs(se_scoreboard_languages) do
		language_combo_box:AddChoice( k, v )
	end
	language_combo_box:DockMargin( 10, 10, 10, 0 )
	language_combo_box:Dock(TOP)
	language_combo_box:SetFont("se_ScoreboardFont")
	language_combo_box:SetTextColor(Color(255, 255, 255))
	language_combo_box.OnSelect = function( panel, index, value )
		net.Start("se_change_lang")
		net.WriteString(se_scoreboard_languages[value])
		net.SendToServer()
	end
	function language_combo_box:Paint(w, h)
		if self.Hovered then
			draw.RoundedBox( 5, 0, 0, w, h, Color(80, 80, 80, 255) )
		else
			draw.RoundedBox( 5, 0, 0, w, h, Color(30, 30, 30, 255) )
		end
	end

	local se_scoreboard_load_game = vgui.Create( "DButton", se_scoreboard_main )
	se_scoreboard_load_game:SetText("")
	se_scoreboard_load_game:SetSize(350, 60)
	se_scoreboard_load_game:DockMargin( 10, 10, 10, 0 )
	se_scoreboard_load_game:Dock(TOP)
	function se_scoreboard_load_game:OnMousePressed()
		net.Start("se_request_save_list")
		net.SendToServer()
	end
	function se_scoreboard_load_game:Paint(w, h)
		if self.Hovered then
			draw.RoundedBox( 5, 0, 0, w, h, Color(40, 160, 40, 255) )
		else
			draw.RoundedBox( 5, 0, 0, w, h, Color(10, 120, 10, 255) )
		end
		draw.DrawText( "Cargar partida", "se_ScoreboardFont", w / 2, 20, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
	end

	local se_scoreboard_save_game = vgui.Create( "DButton", se_scoreboard_main )
	se_scoreboard_save_game:SetText("")
	se_scoreboard_save_game:SetSize(350, 60)
	se_scoreboard_save_game:DockMargin( 10, 10, 10, 0 )
	se_scoreboard_save_game:Dock(TOP)
	function se_scoreboard_save_game:OnMousePressed()
		se_open_save_game_panel()
	end
	function se_scoreboard_save_game:Paint(w, h)
		if self.Hovered then
			draw.RoundedBox( 5, 0, 0, w, h, Color(40, 40, 80, 255) )
		else
			draw.RoundedBox( 5, 0, 0, w, h, Color(80, 80, 130, 255) )
		end
		draw.DrawText( "Guardar partida", "se_ScoreboardFont", w / 2, 20, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
	end

  local se_scoreboard_players = vgui.Create( "DPanel", se_scoreboard )
  se_scoreboard_players:SetSize(350, 600)
  se_scoreboard_players:Dock(RIGHT)
  function se_scoreboard_players:Paint(w, h)
    draw.RoundedBox( 5, 0, 0, w, h, Color(50, 50, 50, 250) )
  end

	local se_scoreboard_players_scroller = vgui.Create( "DHorizontalScroller", se_scoreboard_players )
  se_scoreboard_players_scroller:Dock(FILL)
  function se_scoreboard_players_scroller:Paint(w, h)

  end

  for k, v in pairs(player.GetAll()) do
    local se_scoreboard_player_btn = vgui.Create( "DButton", se_scoreboard_players_scroller )
    local race_name = v:GetNWString("se_race", "Humans")
    se_scoreboard_player_btn:SetText(v:Name()..": "..(se_race_names[race_name] or race_name))
    se_scoreboard_player_btn:SetSize(350, 40)
    se_scoreboard_player_btn:DockMargin( 10, 10, 10, 0 )
    se_scoreboard_player_btn:Dock(TOP)
		se_scoreboard_player_btn:SetFont("se_ScoreboardFont")
		se_scoreboard_player_btn:SetTextColor(Color(255, 255, 255))
		se_scoreboard_player_btn:SetContentAlignment( 7 )
    function se_scoreboard_player_btn:Paint(w, h)
      if self.Hovered then
        draw.RoundedBox( 5, 0, 0, w, h, Color(80, 80, 80, 255) )
      else
        draw.RoundedBox( 5, 0, 0, w, h, Color(30, 30, 30, 255) )
      end
    end
		-- There we init buttons for captain
		if LocalPlayer():GetNWBool("se_is_сaptain", false) and v != LocalPlayer() then
			-- Change size of the button
			se_scoreboard_player_btn:SetSize(350, 90)
			-- Create button for making player a captain
			local se_make_captain = vgui.Create( "DButton", se_scoreboard_player_btn )
			se_make_captain:SetText("Hacer capitan")
			se_make_captain:SetSize(100, 30)
			se_make_captain:DockMargin( 5, 5, 5, 5 )
			se_make_captain:Dock(BOTTOM)
			se_make_captain:SetFont("se_ScoreboardFont")
			se_make_captain:SetTextColor(Color(255, 255, 255))
			function se_make_captain:Paint(w, h)
				if self.Hovered then
					draw.RoundedBox( 5, 0, 0, w, h, Color(120, 120, 180, 255) )
				else
					draw.RoundedBox( 5, 0, 0, w, h, Color(80, 80, 120, 255) )
				end
			end
			-- When we click we send netmsg
			function se_make_captain:OnMousePressed()
				net.Start("se_make_captain")
				net.WriteEntity(v)
				net.SendToServer()
				se_scoreboard:Remove()
			end
			-- Shopping enabled checkbox
			local shopping_enabled = vgui.Create( "DCheckBox", se_scoreboard_player_btn )
			shopping_enabled:SetPos(10, 30)
			shopping_enabled:SetValue( v:GetNWBool("se_shopping_enabled", false) )
			function shopping_enabled:OnChange( bVal )
				net.Start("se_enable_shopping")
				net.WriteEntity(v)
				net.WriteBool(bVal)
				net.SendToServer()
			end
			-- Label to checkbox
			local DLabel = vgui.Create( "DLabel", se_scoreboard_player_btn )
			DLabel:SetSize(200, 50)
			DLabel:SetPos(30, 10)
			DLabel:SetText( "Permitir compras" )
			DLabel:SetFont("se_ScoreboardFont")
			DLabel:SetColor(Color(255, 255, 255))
		end
  end
end

function GM:ScoreboardShow()
  net.Start("se_open_scoreboard")
  net.SendToServer()
end

net.Receive("se_open_scoreboard", function()
  local skills = net.ReadTable()
	local stars = net.ReadTable()
	se_current_star_map = stars
  se_open_scoreboard(skills, stars)
end)

net.Receive("se_update_star_map", function()
	se_current_star_map = net.ReadTable()
end)

net.Receive("se_send_save_list", function()
	local saves = net.ReadTable()
	se_open_load_game_panel(saves)
end)

net.Receive("se_save_game_result", function()
	local success = net.ReadBool()
	local message = net.ReadString()

	if success then
		chat.AddText(Color(80, 220, 100), "[Guardado] ", Color(255, 255, 255), message)
	else
		chat.AddText(Color(220, 80, 80), "[Guardado] ", Color(255, 255, 255), message)
	end
end)

function GM:ScoreboardHide()
	if IsValid(se_scoreboard) then
		se_scoreboard:Remove()
	end
	if IsValid(se_map_browser) then
		se_map_browser:Remove()
	end
end
