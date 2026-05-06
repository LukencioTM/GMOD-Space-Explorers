se_players_ship_pos = {
  pos = Vector(),
  ang = Angle()
}

se_enemy_ship_state = {
  health = 0,
  shields = 0,
  modules = {}
}

se_player_spaceship_state = {
  health = 0,
  shields = 0,
  oxygen = 0,
  drive_charge = 0,
  modules = {},
  weapons = {},
  max_hp = 100,
  max_sh = 100,
}

se_curret_planet_info = {
  name = "",
  desk = "",
  air = false,
  planet_key = "",
  is_station = false,
  infected = false,
  hostile = false
}

se_disembark_countdown_end = 0
se_disembark_fade_start = 0
se_disembark_fade_text = ""
se_comm_state = {
  active = false,
  name = "Sin senal",
  text = "No hay transmision activa.",
  enemy = false,
  options = {}
}

net.Receive("se_event_simple", function()
  local event = net.ReadInt(8)
  -- Drive Charge
  if event == 1 then
    local sound = CreateSound(LocalPlayer(), "ambient/energy/force_field_loop1.wav")
    sound:PlayEx(0.25, 100)
    timer.Simple(10, function()
      sound:FadeOut(1)
    end)
  end
  -- Jump
  if event == 2 then
    local sound = CreateSound(LocalPlayer(), "ambient/machines/teleport3.wav")
    sound:PlayEx(0.5, 100)
  end
  -- Hit into players ship
  if event == 3 then
    util.ScreenShake( Vector( 0, 0, 0 ), 10, 10, 1, 5000 )
  end
  -- Hit into shields
  if event == 4 then
    local sound = CreateSound(LocalPlayer(), "ambient/explosions/exp" .. math.random(1, 4) .. ".wav")
    sound:PlayEx(0.5, 100)
  end
  -- Shoot
  if event == 5 then
    local sound = CreateSound(LocalPlayer(), "weapons/ar2/fire1.wav")
    sound:PlayEx(0.5, 100)
  end
  -- Enemy ship
  if event == 6 then
    local sound = CreateSound(LocalPlayer(), "ambient/alarms/alarm_citizen_loop1.wav")
    sound:PlayEx(0.25, 100)
    timer.Simple(10, function()
      sound:FadeOut(1)
    end)
  end
end)

net.Receive("se_wear_suit", function()
  local wear = net.ReadBool()
  if wear then
    surface.PlaySound("doors/door_metal_gate_move2.wav")
    LocalPlayer().suit_sound = CreateSound(LocalPlayer(), "ambient/atmosphere/undercity_loop1.wav")
    LocalPlayer().suit_sound:PlayEx(0.25, 100)
  else
    if LocalPlayer().suit_sound then
      LocalPlayer().suit_sound:FadeOut(1)
    end
  end
end)

net.Receive("se_open_pilot_camera", function()
  se_camera_enabled = net.ReadBool()
  if se_camera_enabled and IsValid(TextEntry) then
    TextEntry:Remove()
  end
end)

net.Receive("se_update_ship_pos", function()
  local pos = -net.ReadVector()
  se_players_ship_pos.pos = pos
end)

net.Receive("se_update_ship_angle", function()
  local ang = net.ReadAngle()
  se_players_ship_pos.ang = ang
end)

net.Receive("se_update_enemy_state", function()
  se_enemy_ship_state = net.ReadTable()
end)

net.Receive("se_send_ship_state", function()
  se_player_spaceship_state = net.ReadTable()
end)

net.Receive("se_send_planet_info", function()
  se_curret_planet_info = net.ReadTable()
end)

net.Receive("se_disembark_countdown", function()
  se_disembark_countdown_end = net.ReadFloat()
end)

net.Receive("se_disembark_fade", function()
  se_disembark_fade_text = net.ReadString()
  se_disembark_fade_start = CurTime()
  se_disembark_countdown_end = 0
end)

net.Receive("se_update_comm_state", function()
  se_comm_state = net.ReadTable()
end)

hook.Add("HUDPaint", "SE_DisembarkOverlay", function()
  if se_disembark_countdown_end > CurTime() then
    local remaining = math.ceil(se_disembark_countdown_end - CurTime())
    draw.SimpleText("DESEMBARCO", "se_ScoreboardFont", ScrW() / 2, 72, Color(235, 255, 255, 255), TEXT_ALIGN_CENTER)
    draw.SimpleText(tostring(remaining), "se_ScoreboardFont", ScrW() / 2, 102, Color(120, 230, 255, 255), TEXT_ALIGN_CENTER)
  end

  if se_disembark_fade_start > 0 then
    local elapsed = CurTime() - se_disembark_fade_start
    if elapsed > 4 then
      se_disembark_fade_start = 0
      return
    end

    local fade_in = math.Clamp(elapsed / 1.4, 0, 1)
    local fade_out = math.Clamp((4 - elapsed) / 1.3, 0, 1)
    local alpha = 255 * math.min(fade_in, fade_out)
    surface.SetDrawColor(0, 0, 0, alpha)
    surface.DrawRect(0, 0, ScrW(), ScrH())
    draw.SimpleText(se_disembark_fade_text, "se_ScoreboardFont", ScrW() / 2, ScrH() / 2 - 24, Color(235, 255, 255, alpha), TEXT_ALIGN_CENTER)
  end
end)
