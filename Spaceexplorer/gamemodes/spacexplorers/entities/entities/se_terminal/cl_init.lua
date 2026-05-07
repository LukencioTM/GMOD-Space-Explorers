include("shared.lua")

local SE_TERMINAL_SCREEN_POS = Vector(0, -15, 50)
local SE_TERMINAL_SCREEN_ANG = Angle(0, 90, 45)
local SE_TERMINAL_SCREEN_SCALE = 0.05
local SE_PILOT_BUTTONS = {
  {label = "SALTO", command = "jump", x = 390, y = 82, w = 190, h = 58},
  {label = "ESTADO", command = "ship_health", x = 390, y = 152, w = 190, h = 58},
  {label = "ESCUDOS", command = "ship_shields", x = 390, y = 222, w = 190, h = 58},
  {label = "FUEL", command = "fuel", x = 390, y = 292, w = 190, h = 58},
  {label = "AYUDA", command = "help", x = 390, y = 362, w = 190, h = 58},
  {label = "LIMPIAR", command = "clear", x = 390, y = 432, w = 190, h = 58}
}
local SE_HYPERDRIVE_BUTTONS = {
  {label = "CARGAR", command = "charge", x = 390, y = 112, w = 190, h = 66},
  {label = "CARGA", command = "get_charge", x = 390, y = 198, w = 190, h = 58},
  {label = "AYUDA", command = "help", x = 390, y = 276, w = 190, h = 58},
  {label = "LIMPIAR", command = "clear", x = 390, y = 354, w = 190, h = 58}
}
local SE_TELEPORT_BUTTONS = {
  {label = "DESEMBARCAR", command = "teleport", x = 390, y = 112, w = 190, h = 66},
  {label = "DESTINO", command = "planet_info", x = 390, y = 198, w = 190, h = 58},
  {label = "AYUDA", command = "help", x = 390, y = 276, w = 190, h = 58},
  {label = "LIMPIAR", command = "clear", x = 390, y = 354, w = 190, h = 58}
}
local SE_COMMUNICATION_BUTTONS = {
  {label = "RESP. 1", command = "answer 1", x = 390, y = 82, w = 190, h = 58},
  {label = "RESP. 2", command = "answer 2", x = 390, y = 152, w = 190, h = 58},
  {label = "RESP. 3", command = "answer 3", x = 390, y = 222, w = 190, h = 58},
  {label = "CREDITOS", command = "credits", x = 390, y = 302, w = 190, h = 50},
  {label = "AYUDA", command = "help", x = 390, y = 366, w = 190, h = 50},
  {label = "LIMPIAR", command = "clear", x = 390, y = 430, w = 190, h = 50}
}
local SE_WEAPONS_BUTTONS = {
  {label = "MODULOS ENEMIGO", command = "enemy_modules", x = 14, y = 82, w = 190, h = 58},
  {label = "SALUD ENEMIGO", command = "enemy_health", x = 14, y = 152, w = 190, h = 58},
  {label = "ESCUDOS ENEMIGO", command = "enemy_shields", x = 14, y = 222, w = 190, h = 58},
  {label = "ARMAS", command = "weapons", x = 14, y = 302, w = 190, h = 50},
  {label = "AYUDA", command = "help", x = 14, y = 366, w = 190, h = 50},
  {label = "LIMPIAR", command = "clear", x = 14, y = 430, w = 190, h = 50},
  
  {label = "DISPARAR ARMA 1", command = "shoot 1 Weapons", x = 600, y = 82, w = 190, h = 58},
  {label = "DISPARAR ARMA 2", command = "shoot 2 Weapons", x = 600, y = 152, w = 190, h = 58},
  {label = "DISPARAR ARMA 3", command = "shoot 3 Weapons", x = 600, y = 222, w = 190, h = 58}
}

local SE_MINING_BUTTONS = {
  {label = "ESCANEAR", command = "asteroids", x = 390, y = 82, w = 190, h = 58},
  {label = "ENGANCHAR", command = "grab 1", x = 390, y = 152, w = 190, h = 58},
  {label = "MINAR", command = "mine", x = 390, y = 222, w = 190, h = 58},
  {label = "BODEGA", command = "resources", x = 390, y = 292, w = 190, h = 58},
  {label = "INFO NIVEL", command = "miner_level", x = 390, y = 362, w = 190, h = 58},
  {label = "LIMPIAR", command = "clear", x = 390, y = 432, w = 190, h = 58}
}

local function se_get_terminal_panel_cursor(ent)
  local ply = LocalPlayer()
  if !IsValid(ply) then return nil end

  local origin = ent:LocalToWorld(SE_TERMINAL_SCREEN_POS)
  local ang = SE_TERMINAL_SCREEN_ANG + ent:GetAngles()
  local hit_pos = util.IntersectRayWithPlane(ply:EyePos(), ply:GetAimVector(), origin, ang:Up())
  if !hit_pos then return nil end
  if hit_pos:DistToSqr(origin) > 120000 then return nil end

  local local_pos = WorldToLocal(hit_pos, Angle(), origin, ang)
  local x = local_pos.x / SE_TERMINAL_SCREEN_SCALE
  local y = -local_pos.y / SE_TERMINAL_SCREEN_SCALE

  return x, y
end

function ENT:Initialize()
  self.lines = {}
  self.userinput = ""
end

local function se_draw_embedded_console(ent, text_color, x_offset)
  local pos = 58
  local x = x_offset or 28
  local slice_size = #ent.lines - 22
  if slice_size < 1 then slice_size = 1 end

  for _, line in pairs(SliceTable(ent.lines or {}, slice_size, #ent.lines, 1)) do
    draw.SimpleText(line or "", "TerminalFont", x, pos, text_color, 0, 0)
    pos = pos + 20
  end

  draw.SimpleText(ent.userinput, "TerminalFont", x, pos + 8, text_color, 0, 0)
end

function ENT:DrawPilotPanel()
  local cursor_x, cursor_y = se_get_terminal_panel_cursor(self)

  cam.Start3D2D(self:LocalToWorld(SE_TERMINAL_SCREEN_POS), SE_TERMINAL_SCREEN_ANG + self:GetAngles(), SE_TERMINAL_SCREEN_SCALE)
    surface.SetDrawColor(5, 8, 10, 238)
    surface.DrawRect(0, 0, 600, 560)

    surface.SetDrawColor(10, 38, 40, 230)
    surface.DrawRect(14, 52, 356, 488)
    surface.SetDrawColor(0, 180, 150, 180)
    surface.DrawOutlinedRect(14, 52, 356, 488)

    draw.SimpleText("PANEL PILOTO", "TerminalFont", 300, 16, Color(235, 255, 255, 230), TEXT_ALIGN_CENTER)
    draw.SimpleText("CONSOLA", "TerminalFont", 28, 24, Color(0, 210, 170, 220), TEXT_ALIGN_LEFT)
    draw.SimpleText("CONTROLES", "TerminalFont", 392, 24, Color(0, 210, 170, 220), TEXT_ALIGN_LEFT)

    se_draw_embedded_console(self, Color(0, 210, 70, 220))

    for _, button in ipairs(SE_PILOT_BUTTONS) do
      local hovered = cursor_x and cursor_y and cursor_x >= button.x and cursor_x <= button.x + button.w and cursor_y >= button.y and cursor_y <= button.y + button.h
      if hovered then
        surface.SetDrawColor(0, 130, 115, 245)
      else
        surface.SetDrawColor(18, 44, 52, 235)
      end
      surface.DrawRect(button.x, button.y, button.w, button.h)
      surface.SetDrawColor(0, 210, 170, hovered and 255 or 170)
      surface.DrawOutlinedRect(button.x, button.y, button.w, button.h)
      draw.SimpleText(button.label, "TerminalFont", button.x + button.w / 2, button.y + 18, Color(235, 255, 255, 235), TEXT_ALIGN_CENTER)
    end
  cam.End3D2D()
end

function ENT:DrawHyperDrivePanel()
  local cursor_x, cursor_y = se_get_terminal_panel_cursor(self)

  cam.Start3D2D(self:LocalToWorld(SE_TERMINAL_SCREEN_POS), SE_TERMINAL_SCREEN_ANG + self:GetAngles(), SE_TERMINAL_SCREEN_SCALE)
    surface.SetDrawColor(6, 7, 12, 240)
    surface.DrawRect(0, 0, 600, 560)

    surface.SetDrawColor(12, 22, 38, 235)
    surface.DrawRect(14, 52, 356, 488)
    surface.SetDrawColor(70, 150, 255, 185)
    surface.DrawOutlinedRect(14, 52, 356, 488)

    draw.SimpleText("CONTROL HIPERMOTOR", "TerminalFont", 300, 16, Color(235, 245, 255, 235), TEXT_ALIGN_CENTER)
    draw.SimpleText("CONSOLA", "TerminalFont", 28, 24, Color(90, 180, 255, 230), TEXT_ALIGN_LEFT)
    draw.SimpleText("NUCLEO", "TerminalFont", 392, 24, Color(90, 180, 255, 230), TEXT_ALIGN_LEFT)

    se_draw_embedded_console(self, Color(90, 180, 255, 220))

    for _, button in ipairs(SE_HYPERDRIVE_BUTTONS) do
      local hovered = cursor_x and cursor_y and cursor_x >= button.x and cursor_x <= button.x + button.w and cursor_y >= button.y and cursor_y <= button.y + button.h
      if hovered then
        surface.SetDrawColor(20, 90, 150, 250)
      else
        surface.SetDrawColor(15, 32, 54, 238)
      end
      surface.DrawRect(button.x, button.y, button.w, button.h)
      surface.SetDrawColor(90, 180, 255, hovered and 255 or 175)
      surface.DrawOutlinedRect(button.x, button.y, button.w, button.h)
      draw.SimpleText(button.label, "TerminalFont", button.x + button.w / 2, button.y + 20, Color(235, 248, 255, 240), TEXT_ALIGN_CENTER)
    end
  cam.End3D2D()
end

function ENT:DrawTeleportPanel()
  local cursor_x, cursor_y = se_get_terminal_panel_cursor(self)

  cam.Start3D2D(self:LocalToWorld(SE_TERMINAL_SCREEN_POS), SE_TERMINAL_SCREEN_ANG + self:GetAngles(), SE_TERMINAL_SCREEN_SCALE)
    surface.SetDrawColor(7, 9, 13, 240)
    surface.DrawRect(0, 0, 600, 560)

    surface.SetDrawColor(14, 28, 36, 235)
    surface.DrawRect(14, 52, 356, 488)
    surface.SetDrawColor(90, 210, 190, 185)
    surface.DrawOutlinedRect(14, 52, 356, 488)

    draw.SimpleText("CONTROL DE DESEMBARCO", "TerminalFont", 300, 16, Color(235, 255, 250, 235), TEXT_ALIGN_CENTER)
    draw.SimpleText("CONSOLA", "TerminalFont", 28, 24, Color(100, 230, 210, 230), TEXT_ALIGN_LEFT)
    draw.SimpleText("TRANSPORTE", "TerminalFont", 392, 24, Color(100, 230, 210, 230), TEXT_ALIGN_LEFT)

    se_draw_embedded_console(self, Color(90, 230, 200, 220))

    for _, button in ipairs(SE_TELEPORT_BUTTONS) do
      local hovered = cursor_x and cursor_y and cursor_x >= button.x and cursor_x <= button.x + button.w and cursor_y >= button.y and cursor_y <= button.y + button.h
      surface.SetDrawColor(hovered and Color(20, 115, 105, 250) or Color(14, 44, 50, 238))
      surface.DrawRect(button.x, button.y, button.w, button.h)
      surface.SetDrawColor(100, 230, 210, hovered and 255 or 175)
      surface.DrawOutlinedRect(button.x, button.y, button.w, button.h)
      draw.SimpleText(button.label, "TerminalFont", button.x + button.w / 2, button.y + 20, Color(235, 255, 250, 240), TEXT_ALIGN_CENTER)
    end
  cam.End3D2D()
end

function ENT:DrawCommunicationPanel()
  local cursor_x, cursor_y = se_get_terminal_panel_cursor(self)

  cam.Start3D2D(self:LocalToWorld(SE_TERMINAL_SCREEN_POS), SE_TERMINAL_SCREEN_ANG + self:GetAngles(), SE_TERMINAL_SCREEN_SCALE)
    surface.SetDrawColor(8, 8, 14, 242)
    surface.DrawRect(0, 0, 600, 560)

    surface.SetDrawColor(22, 18, 34, 235)
    surface.DrawRect(14, 52, 356, 488)
    surface.SetDrawColor(190, 120, 255, 180)
    surface.DrawOutlinedRect(14, 52, 356, 488)

    draw.SimpleText("ENLACE DE COMUNICACION", "TerminalFont", 300, 16, Color(245, 235, 255, 235), TEXT_ALIGN_CENTER)
    draw.SimpleText("CONSOLA", "TerminalFont", 28, 24, Color(210, 150, 255, 230), TEXT_ALIGN_LEFT)
    draw.SimpleText("RESPUESTA", "TerminalFont", 392, 24, Color(210, 150, 255, 230), TEXT_ALIGN_LEFT)
    se_draw_embedded_console(self, Color(220, 170, 255, 220))

    for _, button in ipairs(SE_COMMUNICATION_BUTTONS) do
      local hovered = cursor_x and cursor_y and cursor_x >= button.x and cursor_x <= button.x + button.w and cursor_y >= button.y and cursor_y <= button.y + button.h
      surface.SetDrawColor(hovered and Color(90, 45, 135, 250) or Color(36, 28, 58, 238))
      surface.DrawRect(button.x, button.y, button.w, button.h)
      surface.SetDrawColor(210, 150, 255, hovered and 255 or 175)
      surface.DrawOutlinedRect(button.x, button.y, button.w, button.h)
      draw.SimpleText(button.label, "TerminalFont", button.x + button.w / 2, button.y + 16, Color(248, 240, 255, 240), TEXT_ALIGN_CENTER)
    end
  cam.End3D2D()
end

function ENT:DrawPilotMapPanel()
  cam.Start3D2D(self:LocalToWorld(Vector(-10, -30, 90)), Angle(0, 90, 90) + self:GetAngles(), 0.12)
    surface.SetDrawColor(5, 8, 12, 245)
    surface.DrawRect(0, 0, 520, 330)
    surface.SetDrawColor(0, 210, 170, 180)
    surface.DrawOutlinedRect(0, 0, 520, 330)
    draw.SimpleText("MAPA ESTELAR", "TerminalFont", 260, 8, Color(235, 255, 255, 230), TEXT_ALIGN_CENTER)

    if se_current_star_map and se_draw_star_map then
      surface.SetDrawColor(8, 12, 18, 230)
      surface.DrawRect(14, 40, 492, 276)
      se_draw_star_map(se_current_star_map, 492, 276, false, 14, 40)
    else
      draw.SimpleText("Esperando datos del mapa", "TerminalFont", 260, 150, Color(0, 210, 170, 220), TEXT_ALIGN_CENTER)
    end
  cam.End3D2D()
end

function ENT:DrawHyperDriveStatusPanel()
  local charge = math.Clamp(se_player_spaceship_state and se_player_spaceship_state.drive_charge or 0, 0, 100)
  local pulse = (math.sin(CurTime() * 4) + 1) * 0.5
  local spin = (CurTime() * 80) % 360
  local ready = charge >= 100

  cam.Start3D2D(self:LocalToWorld(Vector(-8, -30, 90)), Angle(0, 90, 90) + self:GetAngles(), 0.09)
    surface.SetDrawColor(5, 8, 14, 245)
    surface.DrawRect(0, 0, 520, 330)
    surface.SetDrawColor(70, 150, 255, 190)
    surface.DrawOutlinedRect(0, 0, 520, 330)
    draw.SimpleText("ESTADO DEL HIPERMOTOR", "TerminalFont", 260, 8, Color(235, 245, 255, 235), TEXT_ALIGN_CENTER)

    surface.SetDrawColor(12, 20, 34, 235)
    surface.DrawRect(18, 46, 484, 260)

    local core_x = 142
    local core_y = 176
    drawCircle(core_x, core_y, 78 + pulse * 8, 32, Color(30, 70, 120, 190))
    drawCircle(core_x, core_y, 54 + pulse * 5, 32, Color(50, 130, 220, 220))
    drawCircle(core_x, core_y, 24 + pulse * 4, 32, ready and Color(80, 240, 180, 245) or Color(110, 190, 255, 230))

    for i = 0, 7 do
      local ang = math.rad(spin + i * 45)
      local x1 = core_x + math.cos(ang) * 42
      local y1 = core_y + math.sin(ang) * 42
      local x2 = core_x + math.cos(ang) * 92
      local y2 = core_y + math.sin(ang) * 92
      surface.SetDrawColor(90, 180, 255, 130 + pulse * 90)
      surface.DrawLine(x1, y1, x2, y2)
    end

    surface.SetDrawColor(18, 36, 60, 255)
    surface.DrawRect(260, 92, 220, 34)
    surface.SetDrawColor(ready and Color(80, 240, 180, 255) or Color(90, 170, 255, 255))
    surface.DrawRect(264, 96, 212 * (charge / 100), 26)
    surface.SetDrawColor(120, 210, 255, 180)
    surface.DrawOutlinedRect(260, 92, 220, 34)

    draw.SimpleText(math.Round(charge) .. "%", "se_ScoreboardFont", 370, 138, ready and Color(120, 255, 200, 255) or Color(180, 225, 255, 255), TEXT_ALIGN_CENTER)
    draw.SimpleText(ready and "SALTO LISTO" or "ACUMULANDO ENERGIA", "TerminalFont", 370, 170, ready and Color(120, 255, 200, 255) or Color(120, 200, 255, 235), TEXT_ALIGN_CENTER)
    draw.SimpleText("FLUJO: " .. math.Round(35 + pulse * 65) .. "%", "TerminalFont", 282, 218, Color(170, 220, 255, 230), TEXT_ALIGN_LEFT)
    draw.SimpleText("CAMPO: " .. (ready and "ESTABLE" or "SINCRONIZANDO"), "TerminalFont", 282, 248, ready and Color(120, 255, 200, 240) or Color(170, 220, 255, 230), TEXT_ALIGN_LEFT)
  cam.End3D2D()
end

function ENT:DrawShieldStatusPanel()
  local shield = math.Clamp(se_player_spaceship_state and se_player_spaceship_state.shields or 0, 0, 100)
  local max_shield = math.max(se_player_spaceship_state and se_player_spaceship_state.max_sh or 100, 1)
  local shield_frac = math.Clamp(shield / max_shield, 0, 1)
  local pulse = (math.sin(CurTime() * (3 + shield_frac * 4)) + 1) * 0.5
  local critical = shield_frac < 0.3
  local shield_color = critical and Color(255, 70, 70, 220) or Color(80, 190, 255, 220)

  cam.Start3D2D(self:LocalToWorld(Vector(-8, -30, 90)), Angle(0, 90, 90) + self:GetAngles(), 0.09)
    surface.SetDrawColor(5, 8, 14, 245)
    surface.DrawRect(0, 0, 520, 330)
    surface.SetDrawColor(shield_color.r, shield_color.g, shield_color.b, 190)
    surface.DrawOutlinedRect(0, 0, 520, 330)
    draw.SimpleText("MATRIZ DE ESCUDOS", "TerminalFont", 260, 8, Color(235, 245, 255, 235), TEXT_ALIGN_CENTER)

    surface.SetDrawColor(12, 20, 34, 235)
    surface.DrawRect(18, 46, 484, 260)

    local ship_x = 162
    local ship_y = 176
    for ring = 1, 3 do
      local radius = 58 + ring * 18 + pulse * 4
      drawCircle(ship_x, ship_y, radius, 40, Color(shield_color.r, shield_color.g, shield_color.b, math.floor(40 + shield_frac * 80)))
    end

    surface.SetDrawColor(210, 230, 255, 240)
    surface.DrawLine(ship_x - 62, ship_y + 30, ship_x, ship_y - 52)
    surface.DrawLine(ship_x, ship_y - 52, ship_x + 62, ship_y + 30)
    surface.DrawLine(ship_x - 62, ship_y + 30, ship_x - 18, ship_y + 14)
    surface.DrawLine(ship_x + 62, ship_y + 30, ship_x + 18, ship_y + 14)
    surface.DrawLine(ship_x - 18, ship_y + 14, ship_x + 18, ship_y + 14)
    surface.DrawLine(ship_x, ship_y - 52, ship_x, ship_y + 36)

    for i = 0, 9 do
      local y = 72 + i * 20
      surface.SetDrawColor(shield_color.r, shield_color.g, shield_color.b, 45 + pulse * 45)
      surface.DrawLine(286, y, 478, y + math.sin(CurTime() * 2 + i) * 8)
    end

    surface.SetDrawColor(18, 36, 60, 255)
    surface.DrawRect(284, 94, 200, 32)
    surface.SetDrawColor(shield_color.r, shield_color.g, shield_color.b, 255)
    surface.DrawRect(288, 98, 192 * shield_frac, 24)
    surface.SetDrawColor(120, 210, 255, 180)
    surface.DrawOutlinedRect(284, 94, 200, 32)

    draw.SimpleText(math.Round(shield_frac * 100) .. "%", "se_ScoreboardFont", 384, 138, shield_color, TEXT_ALIGN_CENTER)
    draw.SimpleText(critical and "ESCUDO CRITICO" or "CAMPO DEFLECTOR ACTIVO", "TerminalFont", 384, 174, shield_color, TEXT_ALIGN_CENTER)
    draw.SimpleText("CAPAS: " .. math.Clamp(math.ceil(shield_frac * 4), 0, 4) .. "/4", "TerminalFont", 304, 218, Color(180, 225, 255, 230), TEXT_ALIGN_LEFT)
    draw.SimpleText("INTEGRIDAD: " .. math.Round(shield) .. "/" .. math.Round(max_shield), "TerminalFont", 304, 248, Color(180, 225, 255, 230), TEXT_ALIGN_LEFT)
  cam.End3D2D()
end

local function se_get_destination_color(info)
  local key = info and info.planet_key or ""
  if key == "DesertPlanet" then return Color(190, 130, 65, 245) end
  if key == "SnowPlanet" then return Color(175, 220, 255, 245) end
  if key == "DryPlanet" then return Color(130, 105, 55, 245) end
  if key == "GrayPlanet" then return Color(120, 130, 125, 245) end

  return Color(100, 180, 220, 245)
end

function ENT:DrawTeleportDestinationPanel()
  local info = se_curret_planet_info or {}
  local pulse = (math.sin(CurTime() * 3) + 1) * 0.5
  local color = se_get_destination_color(info)
  local is_station = info.is_station
  local infected = info.infected

  cam.Start3D2D(self:LocalToWorld(Vector(-8, -30, 90)), Angle(0, 90, 90) + self:GetAngles(), 0.09)
    surface.SetDrawColor(5, 8, 14, 245)
    surface.DrawRect(0, 0, 520, 330)
    surface.SetDrawColor(infected and Color(255, 60, 60, 210) or Color(90, 230, 210, 190))
    surface.DrawOutlinedRect(0, 0, 520, 330)
    draw.SimpleText("DESTINO DE DESEMBARCO", "TerminalFont", 260, 8, Color(235, 255, 250, 235), TEXT_ALIGN_CENTER)

    surface.SetDrawColor(12, 20, 34, 235)
    surface.DrawRect(18, 46, 484, 260)

    if is_station then
      local cx = 156
      local cy = 168
      surface.SetDrawColor(170, 210, 230, 235)
      surface.DrawRect(cx - 62, cy - 10, 124, 20)
      surface.DrawRect(cx - 10, cy - 62, 20, 124)
      surface.DrawOutlinedRect(cx - 42, cy - 42, 84, 84)
      drawCircle(cx, cy, 28 + pulse * 4, 32, infected and Color(210, 60, 60, 170) or Color(80, 210, 190, 170))
      drawCircle(238, 222, 24, 32, Color(70, 120, 170, 190))
    else
      drawCircle(158, 170, 76, 48, color)
      drawCircle(132, 138, 18, 24, Color(255, 255, 255, 35))
      drawCircle(190, 196, 24, 24, Color(10, 10, 10, 35))
      drawCircle(158, 170, 88 + pulse * 6, 48, Color(color.r, color.g, color.b, 45))
    end

    draw.SimpleText(info.name or "Sin destino", "se_ScoreboardFont", 292, 78, infected and Color(255, 95, 95, 255) or Color(235, 255, 250, 245), TEXT_ALIGN_LEFT)
    draw.SimpleText("AIRE: " .. (info.air and "RESPIRABLE" or "NO RESPIRABLE"), "TerminalFont", 292, 126, info.air and Color(120, 255, 190, 240) or Color(255, 180, 90, 240), TEXT_ALIGN_LEFT)
    draw.SimpleText("BIOFIRMA: " .. (info.hostile and "HOSTIL" or "BAJA"), "TerminalFont", 292, 156, info.hostile and Color(255, 110, 90, 240) or Color(120, 255, 190, 240), TEXT_ALIGN_LEFT)

    if infected then
      draw.SimpleText("ESTADO DE ESTACION DESCONOCIDO", "TerminalFont", 260, 280, Color(255, 60, 60, 255), TEXT_ALIGN_CENTER)
    else
      draw.SimpleText("BALIZA DE DESEMBARCO SINCRONIZADA", "TerminalFont", 260, 280, Color(120, 255, 220, 235), TEXT_ALIGN_CENTER)
    end
  cam.End3D2D()
end

function ENT:DrawCommunicationStatusPanel()
  local state = se_comm_state or {}
  local pulse = (math.sin(CurTime() * 3) + 1) * 0.5
  local hostile = state.enemy
  local frame_color = hostile and Color(255, 80, 90, 210) or Color(205, 135, 255, 200)
  local active = state.active

  cam.Start3D2D(self:LocalToWorld(Vector(-8, -30, 90)), Angle(0, 90, 90) + self:GetAngles(), 0.08)
    surface.SetDrawColor(6, 7, 13, 246)
    surface.DrawRect(0, 0, 780, 360)
    surface.SetDrawColor(frame_color)
    surface.DrawOutlinedRect(0, 0, 780, 360)
    draw.SimpleText("RED SUBESPACIAL", "TerminalFont", 390, 8, Color(246, 238, 255, 235), TEXT_ALIGN_CENTER)

    surface.SetDrawColor(14, 16, 30, 238)
    surface.DrawRect(18, 46, 744, 292)
    surface.SetDrawColor(32, 24, 48, 210)
    surface.DrawRect(286, 62, 454, 220)
    surface.SetDrawColor(frame_color.r, frame_color.g, frame_color.b, 125)
    surface.DrawOutlinedRect(286, 62, 454, 220)

    local cx = 142
    local cy = 190
    for ring = 1, 4 do
      drawCircle(cx, cy, 24 + ring * 20 + pulse * 5, 48, Color(frame_color.r, frame_color.g, frame_color.b, 30 + ring * 12))
    end
    for i = 0, 11 do
      local ang = math.rad(i * 30 + CurTime() * 18)
      local x = cx + math.cos(ang) * (78 + math.sin(CurTime() * 2 + i) * 8)
      local y = cy + math.sin(ang) * (78 + math.sin(CurTime() * 2 + i) * 8)
      drawCircle(x, y, 4 + pulse * 2, 12, Color(210, 150, 255, 170))
      surface.SetDrawColor(210, 150, 255, 80)
      surface.DrawLine(cx, cy, x, y)
    end
    drawCircle(cx, cy, 18 + pulse * 4, 32, hostile and Color(255, 80, 90, 220) or Color(210, 150, 255, 220))

    draw.SimpleText(active and (state.name or "Contacto") or "SIN TRANSMISION", "se_ScoreboardFont", 306, 78, active and Color(246, 238, 255, 245) or Color(150, 150, 170, 220), TEXT_ALIGN_LEFT)
    draw.SimpleText(hostile and "FIRMA HOSTIL" or "CANAL ESTABLE", "TerminalFont", 306, 116, hostile and Color(255, 95, 105, 245) or Color(150, 240, 220, 235), TEXT_ALIGN_LEFT)

    local text = state.text or "No hay transmision activa."
    local wrapped = textWrap(text, "TerminalFont", 408):Split("\n")
    for i = 1, math.min(#wrapped, 7) do
      draw.SimpleText(wrapped[i], "TerminalFont", 306, 154 + (i - 1) * 22, Color(220, 205, 245, 225), TEXT_ALIGN_LEFT)
    end

    local options = state.options or {}
    local option_count = math.min(#options, 3)
    draw.SimpleText("OPCIONES: " .. option_count, "TerminalFont", 306, 300, Color(210, 150, 255, 230), TEXT_ALIGN_LEFT)
    draw.SimpleText("POTENCIA DE SENAL: " .. math.Round(64 + pulse * 36) .. "%", "TerminalFont", 500, 300, Color(210, 150, 255, 210), TEXT_ALIGN_LEFT)
  cam.End3D2D()
end

function ENT:DrawWeaponsPanel()
  local cursor_x, cursor_y = se_get_terminal_panel_cursor(self)

  cam.Start3D2D(self:LocalToWorld(SE_TERMINAL_SCREEN_POS), SE_TERMINAL_SCREEN_ANG + self:GetAngles(), SE_TERMINAL_SCREEN_SCALE)
    surface.SetDrawColor(12, 5, 5, 240)
    surface.DrawRect(0, 0, 810, 560)

    surface.SetDrawColor(32, 10, 10, 235)
    surface.DrawRect(230, 52, 356, 488)
    surface.SetDrawColor(255, 100, 50, 185)
    surface.DrawOutlinedRect(230, 52, 356, 488)
    
    surface.SetDrawColor(32, 10, 10, 235)
    surface.DrawRect(600, 52, 190, 488)
    surface.SetDrawColor(255, 100, 50, 185)
    surface.DrawOutlinedRect(600, 52, 190, 488)

    draw.SimpleText("SISTEMA DE ARMAS", "TerminalFont", 405, 16, Color(255, 235, 235, 235), TEXT_ALIGN_CENTER)
    draw.SimpleText("CONTROLES", "TerminalFont", 28, 24, Color(255, 120, 60, 230), TEXT_ALIGN_LEFT)
    draw.SimpleText("CONSOLA", "TerminalFont", 244, 24, Color(255, 120, 60, 230), TEXT_ALIGN_LEFT)
    draw.SimpleText("SIST. DE FUEGO", "TerminalFont", 610, 24, Color(255, 120, 60, 230), TEXT_ALIGN_LEFT)

    se_draw_embedded_console(self, Color(255, 140, 80, 220), 244)

    for _, button in ipairs(SE_WEAPONS_BUTTONS) do
      local hovered = cursor_x and cursor_y and cursor_x >= button.x and cursor_x <= button.x + button.w and cursor_y >= button.y and cursor_y <= button.y + button.h
      if hovered then
        surface.SetDrawColor(130, 30, 15, 250)
      else
        surface.SetDrawColor(44, 15, 10, 238)
      end
      surface.DrawRect(button.x, button.y, button.w, button.h)
      surface.SetDrawColor(255, 100, 50, hovered and 255 or 175)
      surface.DrawOutlinedRect(button.x, button.y, button.w, button.h)
      draw.SimpleText(button.label, "TerminalFont", button.x + button.w / 2, button.y + 18, Color(255, 240, 235, 240), TEXT_ALIGN_CENTER)
    end
  cam.End3D2D()
end

function ENT:DrawWeaponsStatusPanel()
  local enemy = se_enemy_ship_state
  local has_enemy = enemy and (enemy.health or 0) > 0
  local pulse = (math.sin(CurTime() * 4) + 1) * 0.5
  
  cam.Start3D2D(self:LocalToWorld(Vector(-25, -40, 100)), Angle(0, 90, 90) + self:GetAngles(), 0.14)
    surface.SetDrawColor(12, 4, 4, 245)
    surface.DrawRect(0, 0, 520, 330)
    surface.SetDrawColor(255, 60, 40, 190)
    surface.DrawOutlinedRect(0, 0, 520, 330)
    draw.SimpleText("VISOR TACTICO", "TerminalFont", 260, 8, Color(255, 220, 200, 235), TEXT_ALIGN_CENTER)

    surface.SetDrawColor(20, 8, 8, 235)
    surface.DrawRect(18, 46, 234, 260)
    surface.SetDrawColor(255, 60, 40, 100)
    surface.DrawOutlinedRect(18, 46, 234, 260)
    draw.SimpleText("ARMAS INTEGRADAS", "TerminalFont", 135, 54, Color(255, 120, 60, 220), TEXT_ALIGN_CENTER)
    
    local weapons = se_player_spaceship_state and se_player_spaceship_state.weapons or {}
    local wy = 86
    local i = 1
    for k, w in pairs(weapons) do
      local w_name = (type(w) == "table" and w[3]) or (type(w) == "table" and w.Name) or "Arma"
      local w_charge = (type(w) == "table" and w[1]) or (type(w) == "table" and w.Charge) or 0
      local w_maxcharge = (type(w) == "table" and w[2]) or (type(w) == "table" and w.MaxCharge) or 1
      
      draw.SimpleText(w_name, "TerminalFont", 26, wy, Color(255, 200, 150, 240), TEXT_ALIGN_LEFT)
      local chg_frac = w_charge / math.max(1, w_maxcharge)
      local ready = chg_frac >= 1
      surface.SetDrawColor(40, 15, 15, 255)
      surface.DrawRect(26, wy + 20, 218, 12)
      surface.SetDrawColor(ready and Color(150, 255, 100, 255) or Color(255, 120, 40, 255))
      surface.DrawRect(26, wy + 20, 218 * chg_frac, 12)
      draw.SimpleText(ready and "LISTA" or math.floor(chg_frac * 100) .. "%", "TerminalFont", 240, wy + 32, ready and Color(150, 255, 100, 255) or Color(255, 120, 40, 255), TEXT_ALIGN_RIGHT)
      
      wy = wy + 48
      i = i + 1
      if i > 5 then break end
    end
    
    surface.SetDrawColor(20, 8, 8, 235)
    surface.DrawRect(268, 46, 234, 260)
    surface.SetDrawColor(255, 60, 40, 100)
    surface.DrawOutlinedRect(268, 46, 234, 260)
    draw.SimpleText("OBJETIVO HOSTIL", "TerminalFont", 385, 54, Color(255, 80, 40, 220), TEXT_ALIGN_CENTER)
    
    if has_enemy then
      local cx = 385
      local cy = 150
      
      drawCircle(cx, cy, 32 + pulse * 4, 32, Color(255, 60, 40, 180))
      drawCircle(cx, cy, 48, 4, Color(255, 120, 60, 80))
      
      for a = 0, 3 do
        local rad = math.rad(a * 90 + CurTime() * 45)
        local dx = math.cos(rad)
        local dy = math.sin(rad)
        surface.SetDrawColor(255, 80, 40, 200)
        surface.DrawLine(cx + dx * 20, cy + dy * 20, cx + dx * 40, cy + dy * 40)
      end
      
      local e_hp = math.Clamp(enemy.health, 0, 100)
      local e_sh = math.Clamp(enemy.shields, 0, 100)
      
      draw.SimpleText("SALUD:", "TerminalFont", 280, 210, Color(255, 100, 100, 230), TEXT_ALIGN_LEFT)
      surface.SetDrawColor(60, 10, 10, 255)
      surface.DrawRect(280, 228, 210, 14)
      surface.SetDrawColor(255, 50, 50, 255)
      surface.DrawRect(280, 228, 210 * (e_hp / 100), 14)
      draw.SimpleText(math.Round(e_hp) .. "%", "TerminalFont", 485, 210, Color(255, 100, 100, 230), TEXT_ALIGN_RIGHT)
      
      draw.SimpleText("ESCUDOS:", "TerminalFont", 280, 250, Color(100, 180, 255, 230), TEXT_ALIGN_LEFT)
      surface.SetDrawColor(10, 20, 60, 255)
      surface.DrawRect(280, 268, 210, 14)
      surface.SetDrawColor(80, 150, 255, 255)
      surface.DrawRect(280, 268, 210 * (e_sh / 100), 14)
      draw.SimpleText(math.Round(e_sh) .. "%", "TerminalFont", 485, 250, Color(100, 180, 255, 230), TEXT_ALIGN_RIGHT)
    else
      draw.SimpleText("SIN OBJETIVO", "TerminalFont", 385, 160, Color(255, 100, 60, 200), TEXT_ALIGN_CENTER)
      draw.SimpleText("SISTEMAS INACTIVOS", "TerminalFont", 385, 180, Color(150, 60, 40, 150), TEXT_ALIGN_CENTER)
    end

  cam.End3D2D()
end

function ENT:DrawMiningPanel()
  local cursor_x, cursor_y = se_get_terminal_panel_cursor(self)

  cam.Start3D2D(self:LocalToWorld(SE_TERMINAL_SCREEN_POS), SE_TERMINAL_SCREEN_ANG + self:GetAngles(), SE_TERMINAL_SCREEN_SCALE)
    surface.SetDrawColor(16, 12, 6, 240)
    surface.DrawRect(0, 0, 600, 560)

    surface.SetDrawColor(44, 30, 10, 235)
    surface.DrawRect(14, 52, 356, 488)
    surface.SetDrawColor(255, 180, 50, 185)
    surface.DrawOutlinedRect(14, 52, 356, 488)

    draw.SimpleText("CONTROL MINERO INDUSTRIAL", "TerminalFont", 300, 16, Color(255, 240, 210, 235), TEXT_ALIGN_CENTER)
    draw.SimpleText("REGISTRO", "TerminalFont", 28, 24, Color(255, 190, 80, 230), TEXT_ALIGN_LEFT)
    draw.SimpleText("OPERACIONES", "TerminalFont", 392, 24, Color(255, 190, 80, 230), TEXT_ALIGN_LEFT)

    se_draw_embedded_console(self, Color(255, 200, 100, 220))

    for _, button in ipairs(SE_MINING_BUTTONS) do
      local hovered = cursor_x and cursor_y and cursor_x >= button.x and cursor_x <= button.x + button.w and cursor_y >= button.y and cursor_y <= button.y + button.h
      surface.SetDrawColor(hovered and Color(160, 100, 20, 250) or Color(60, 40, 15, 238))
      surface.DrawRect(button.x, button.y, button.w, button.h)
      surface.SetDrawColor(255, 180, 50, hovered and 255 or 175)
      surface.DrawOutlinedRect(button.x, button.y, button.w, button.h)
      draw.SimpleText(button.label, "TerminalFont", button.x + button.w / 2, button.y + 18, Color(255, 245, 220, 240), TEXT_ALIGN_CENTER)
    end
  cam.End3D2D()
end

function ENT:Draw()
    self:DrawModel()

    if self:GetNWString("se_terminal_name", "Terminal") == "Piloto" then
      self:DrawPilotPanel()
      self:DrawPilotMapPanel()
    elseif self:GetNWString("se_terminal_name", "Terminal") == "Hipermotor" then
      self:DrawHyperDrivePanel()
      self:DrawHyperDriveStatusPanel()
    elseif self:GetNWString("se_terminal_name", "Terminal") == "Escudos" then
      self:DrawShieldStatusPanel()
    elseif self:GetNWString("se_terminal_name", "Terminal") == "Teletransporte" then
      self:DrawTeleportPanel()
      self:DrawTeleportDestinationPanel()
    elseif self:GetNWString("se_terminal_name", "Terminal") == "Armas" then
      self:DrawWeaponsPanel()
      self:DrawWeaponsStatusPanel()
    elseif self:GetNWString("se_terminal_name", "Terminal") == "Comunicacion" then
      self:DrawCommunicationPanel()
      self:DrawCommunicationStatusPanel()
    elseif self:GetNWString("se_terminal_name", "Terminal") == "Mineria de asteroides" then
      self:DrawMiningPanel()
    else
      local screen_pos = self:LocalToWorld( Vector(0, -15, 50) )
      local ang = Angle(0, 90, 45) + self:GetAngles()
      cam.Start3D2D(screen_pos, ang, 0.05)
        surface.SetDrawColor(5, 5, 5, 230);
        surface.DrawRect(0, 0, 600, 600);
        local line_pos = 0
        local slice_size = #self.lines - 25
        if slice_size < 1 then slice_size = 1 end
        for k, v in pairs(SliceTable(self.lines or {}, slice_size, #self.lines, 1)) do
          line_pos = k * 20
          draw.SimpleText(v or "", "TerminalFont", 20, line_pos, Color(0, 200, 0, 200), 0, 0);
        end
        line_pos = line_pos + 20
        draw.SimpleText(self.userinput, "TerminalFont", 20, line_pos, Color(0, 200, 0, 200), 0, 0);
      cam.End3D2D()
    end

    cam.Start3D2D(self:LocalToWorld( Vector(20, -5, 28) ), Angle(0, 90, 90) + self:GetAngles(), 0.2)
      draw.SimpleText(self:GetNWString("se_terminal_name", "Terminal"), "TerminalFont", 20, 0, Color(255, 255, 255, 200), TEXT_ALIGN_CENTER);
    cam.End3D2D()
end

function ENT:PrintLn(line)
  local wrap_width = 580
  local terminal_name = self:GetNWString("se_terminal_name", "Terminal")
  if terminal_name == "Piloto" or terminal_name == "Hipermotor" or terminal_name == "Teletransporte" or terminal_name == "Comunicacion" then
    wrap_width = 330
  end

  local output = textWrap(line, "TerminalFont", wrap_width):Split("\n")
  for k, v in ipairs(output) do
    table.insert(self.lines, v)
  end
end

function ENT:Print(line)
  self.lines[#self.lines] = self.lines[#self.lines] .. line
end

function ENT:ClearLines()
  self.lines = {}
end

function ENT:ChangeLastLine(line)
  self.lines[#self.lines] = line
end

function ENT:ChangeLine(line, index)
  self.lines[#self.lines - index] = line
end

function ENT:UserInput(line)
  self.userinput = line
end
