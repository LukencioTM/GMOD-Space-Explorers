include("shared.lua")

ENT.RenderGroup = RENDERGROUP_OPAQUE

local SE_HOLOGRAM_COLORS = {
  DryPlanet = Color(155, 140, 78, 255),
  GrayPlanet = Color(115, 130, 125, 255),
  DesertPlanet = Color(220, 145, 62, 255),
  SnowPlanet = Color(170, 225, 255, 255),
  Station = Color(70, 210, 255, 255),
  LostStation = Color(255, 55, 45, 255)
}

local SE_HOLOGRAM_RING = Material("sprites/light_glow02_add")
local SE_PLANET_REGION_CACHE = {}

local function se_load_opaque_planet_material(path)
  local material = Material(path, "noclamp smooth")
  material:SetInt("$vertexalpha", 0)
  material:SetInt("$translucent", 0)
  material:SetInt("$alphatest", 0)
  material:SetInt("$ignorez", 0)
  material:SetInt("$nocull", 0)
  material:SetInt("$vertexcolor", 1)

  return material
end

local SE_PLANET_MATERIALS = {
  DryPlanet = se_load_opaque_planet_material("se_materials/se_planets/Planetaseco.png"),
  GrayPlanet = se_load_opaque_planet_material("se_materials/se_planets/Planetagris.png"),
  DesertPlanet = se_load_opaque_planet_material("se_materials/se_planets/Planetadesertico.png"),
  SnowPlanet = se_load_opaque_planet_material("se_materials/se_planets/Planetanevado.png"),
  Station = se_load_opaque_planet_material("se_materials/se_planets/Planetaestacion.png"),
  LostStation = se_load_opaque_planet_material("se_materials/se_planets/Planetaestacionabandonada.png")
}

local function se_region_hash(seed, a, b, c)
  local value = seed * 1103515245 + a * 73856093 + b * 19349663 + c * 83492791
  value = math.abs(math.sin(value) * 10000)

  return value - math.floor(value)
end

local function se_region_seed(key)
  local seed = 0
  key = key or "planet"

  for index = 1, #key do
    seed = seed + string.byte(key, index) * index
  end

  return seed
end

local function se_sphere_point(radius, lat_deg, lon_deg)
  local lat = math.rad(lat_deg)
  local lon = math.rad(lon_deg)
  local cos_lat = math.cos(lat)

  return Vector(
    math.cos(lon) * cos_lat * radius,
    math.sin(lon) * cos_lat * radius,
    math.sin(lat) * radius
  )
end

local function se_sphere_uv(lat_deg, lon_deg)
  local u = lon_deg / 360
  if lon_deg >= 360 then
    u = 1
  elseif lon_deg <= 0 then
    u = 0
  end

  return math.Clamp(u, 0, 1), 1 - ((lat_deg + 90) / 180)
end

local function se_build_planet_regions(key)
  if SE_PLANET_REGION_CACHE[key] then return SE_PLANET_REGION_CACHE[key] end

  local seed = se_region_seed(key)
  
  local province_centers = {}
  for i=1, 20 do
    local lat = (se_region_hash(seed, i, 1, 0) - 0.5) * 160
    local lon = (se_region_hash(seed, i, 2, 0)) * 360
    province_centers[i] = se_sphere_point(30, lat, lon)
  end

  local lat_count = 24
  local lon_count = 48
  local lat_lines = {}
  local lon_lines = {}
  local regions = {}

  for lat_index = 0, lat_count do
    local base_lat = -90 + (180 / lat_count) * lat_index
    local polar = lat_index == 0 or lat_index == lat_count
    lat_lines[lat_index] = polar and base_lat or base_lat + (se_region_hash(seed, lat_index, 11, 0) - 0.5) * 4
  end

  for lat_index = 0, lat_count do
    lon_lines[lat_index] = {}
    for lon_index = 0, lon_count do
      local base_lon = (360 / lon_count) * lon_index
      local offset = 0
      if lon_index != 0 and lon_index != lon_count then
        offset = (se_region_hash(seed, lat_index, lon_index, 31) - 0.5) * 5
      end

      lon_lines[lat_index][lon_index] = base_lon + offset
    end
  end

  local cell_province = {}
  for lat_index = 0, lat_count - 1 do
    cell_province[lat_index] = {}
    for lon_index = 0, lon_count - 1 do
      local lat_a = lat_lines[lat_index]
      local lat_b = lat_lines[lat_index + 1]
      local lon_a = lon_lines[lat_index][lon_index]
      local lon_b = lon_lines[lat_index][lon_index + 1]
      local lon_c = lon_lines[lat_index + 1][lon_index + 1]
      local lon_d = lon_lines[lat_index + 1][lon_index]
      
      local u1, v1 = se_sphere_uv(lat_a, lon_a)
      local u2, v2 = se_sphere_uv(lat_a, lon_b)
      local u3, v3 = se_sphere_uv(lat_b, lon_c)
      local u4, v4 = se_sphere_uv(lat_b, lon_d)

      local center_lat = (lat_a + lat_b) / 2
      local center_lon = (lon_a + lon_c) / 2
      local pt = se_sphere_point(30, center_lat, center_lon)
      local best_dist = 999999
      local best_id = 1
      for i=1, 20 do
        local d = pt:Distance(province_centers[i])
        if d < best_dist then
          best_dist = d
          best_id = i
        end
      end
      cell_province[lat_index][lon_index] = best_id

      regions[#regions + 1] = {
        province = best_id,
        vertices = {
          {pos = se_sphere_point(30, lat_a, lon_a), u = u1, v = v1},
          {pos = se_sphere_point(30, lat_a, lon_b), u = u2, v = v2},
          {pos = se_sphere_point(30, lat_b, lon_c), u = u3, v = v3},
          {pos = se_sphere_point(30, lat_b, lon_d), u = u4, v = v4}
        }
      }
    end
  end

  local borders = {}
  local border_radius = 30.45
  
  for lat_index = 0, lat_count - 2 do
    for lon_index = 0, lon_count - 1 do
      if cell_province[lat_index][lon_index] ~= cell_province[lat_index + 1][lon_index] then
        borders[#borders + 1] = {
          se_sphere_point(border_radius, lat_lines[lat_index + 1], lon_lines[lat_index + 1][lon_index]),
          se_sphere_point(border_radius, lat_lines[lat_index + 1], lon_lines[lat_index + 1][lon_index + 1])
        }
      end
    end
  end

  for lat_index = 0, lat_count - 1 do
    for lon_index = 0, lon_count - 1 do
      local next_lon = (lon_index + 1) % lon_count
      if cell_province[lat_index][lon_index] ~= cell_province[lat_index][next_lon] then
        borders[#borders + 1] = {
          se_sphere_point(border_radius, lat_lines[lat_index], lon_lines[lat_index][lon_index + 1]),
          se_sphere_point(border_radius, lat_lines[lat_index + 1], lon_lines[lat_index + 1][lon_index + 1])
        }
      end
    end
  end

  SE_PLANET_REGION_CACHE[key] = {
    regions = regions,
    borders = borders,
    province_centers = province_centers
  }

  return SE_PLANET_REGION_CACHE[key]
end

local function se_planet_material(key)
  return SE_PLANET_MATERIALS[key] or SE_PLANET_MATERIALS.DryPlanet
end

local function se_hologram_color(key)
  return SE_HOLOGRAM_COLORS[key or ""] or Color(90, 190, 255, 135)
end

local function se_draw_hologram_label(pos, ang, text, color_value)
  cam.Start3D2D(pos, ang, 0.04)
    draw.SimpleText(text, "DermaLarge", 0, 0, color_value, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
  cam.End3D2D()
end

local function se_draw_region_vertex(center, vertex, color_value)
  mesh.Position(center + vertex.pos)
  mesh.TexCoord(0, vertex.u, vertex.v)
  mesh.Color(color_value.r, color_value.g, color_value.b, color_value.a)
  mesh.AdvanceVertex()
end

local function se_draw_region_mesh(center, region_data, color_value, hovered_id)
  mesh.Begin(MATERIAL_TRIANGLES, #region_data.regions * 2)
    for _, region in ipairs(region_data.regions) do
      local vertices = region.vertices
      local c = color_value
      if hovered_id then
        if region.province == hovered_id then
          c = Color(255, 255, 255, 255)
        else
          c = Color(140, 140, 140, 255)
        end
      end

      se_draw_region_vertex(center, vertices[1], c)
      se_draw_region_vertex(center, vertices[3], c)
      se_draw_region_vertex(center, vertices[2], c)

      se_draw_region_vertex(center, vertices[1], c)
      se_draw_region_vertex(center, vertices[4], c)
      se_draw_region_vertex(center, vertices[3], c)
    end
  mesh.End()
end

local function se_draw_planet_regions(center, key, border_color, ent)
  local region_data = se_build_planet_regions(key)

  local is_active_holo = (ent == SE_ACTIVE_HOLOGRAM)
  local holo_angle = is_active_holo and SE_HOLOGRAM_ANGLE or Angle(0,0,0)
  
  local mat = Matrix()
  mat:Translate(center)
  mat:Rotate(holo_angle)
  mat:Translate(-center)
  
  cam.PushModelMatrix(mat)

  render.SetColorMaterial()
  render.DrawSphere(center, 30.2, 48, 24, se_hologram_color(key))

  render.SetMaterial(se_planet_material(key))
  se_draw_region_mesh(center, region_data, Color(255, 255, 255, 255), is_active_holo and SE_HOVERED_PROVINCE or nil)

  render.SetColorMaterial()
  
  cam.PopModelMatrix()

  local eye_pos = EyePos()
  for _, line in ipairs(region_data.borders) do
    local normal = (line[1] + line[2]) / 2
    local world_pos = center + normal
    local real_world_pos = mat * world_pos
    local real_normal = real_world_pos - center
    local dir_to_cam = eye_pos - real_world_pos
    if real_normal:Dot(dir_to_cam) > 0 then
      local real_p1 = mat * (center + line[1])
      local real_p2 = mat * (center + line[2])
      render.DrawBeam(real_p1, real_p2, 0.8, 0, 1, Color(0, 0, 0, 255))
    end
  end
end

local function se_draw_orbit_circle(center, radius, color_value)
  local segments = 64
  local previous

  for index = 0, segments do
    local angle = math.rad((index / segments) * 360)
    local point = center + Vector(math.cos(angle) * radius, math.sin(angle) * radius, 5)

    if previous then
      render.DrawLine(previous, point, color_value, false)
    end

    previous = point
  end
end

local function se_draw_station_icon(center, color_value)
  local station_pos = center + Vector(44, -8, 12)

  render.DrawWireframeBox(station_pos, Angle(0, 20, 0), Vector(-7, -7, -5), Vector(7, 7, 5), color_value, true)
  render.DrawWireframeBox(station_pos, Angle(0, 20, 0), Vector(-3, -22, -2), Vector(3, 22, 2), color_value, true)
  render.DrawWireframeBox(station_pos, Angle(0, 20, 90), Vector(-3, -18, -2), Vector(3, 18, 2), color_value, true)

  render.DrawLine(station_pos + Vector(-18, -18, 0), station_pos + Vector(18, 18, 0), color_value, false)
  render.DrawLine(station_pos + Vector(-18, 18, 0), station_pos + Vector(18, -18, 0), color_value, false)
end

local function se_draw_hologram_body(ent)
  local base_pos = ent:LocalToWorld(Vector(0, 0, 34))
  local key = ent:GetPlanetKey()

  if ent:GetStation() then
    local center = base_pos + Vector(0, 0, 42)
    local station_color = ent:GetInfected() and Color(255, 55, 45, 235) or Color(65, 175, 255, 235)

    se_draw_planet_regions(center, key, Color(20, 24, 30, 235), ent)
    se_draw_orbit_circle(center, 48, Color(station_color.r, station_color.g, station_color.b, 150))
    se_draw_station_icon(center, station_color)
  else
    se_draw_planet_regions(base_pos + Vector(0, 0, 42), key, nil, ent)
  end
end

function ENT:Draw()
  local dist_sqr = LocalPlayer():GetPos():DistToSqr(self:GetPos())
  
  -- El prop base (la mesa) se renderiza hasta a 50 metros (2000 unidades)
  if dist_sqr > 4000000 then return end
  self:DrawModel()

  -- El holograma y su interfaz se ocultan a los 10 metros (400 unidades)
  if dist_sqr > 160000 then return end

  local base_pos = self:LocalToWorld(Vector(0, 0, 34))
  local key = self:GetPlanetKey()
  local active = self:GetHologramActive()
  local color_value = se_hologram_color(key)

  if !active then
    render.SetMaterial(SE_HOLOGRAM_RING)
    render.DrawSprite(base_pos + Vector(0, 0, 2), 42, 42, Color(35, 70, 80, 35))

    local label_ang = LocalPlayer():EyeAngles()
    label_ang:RotateAroundAxis(label_ang:Right(), 90)
    label_ang:RotateAroundAxis(label_ang:Up(), -90)
    se_draw_hologram_label(base_pos + Vector(0, 0, 34), label_ang, "SIN DESTINO", Color(90, 120, 130, 180))
    return
  end

  render.SetColorMaterial()
  se_draw_hologram_body(self)

  local label_ang = LocalPlayer():EyeAngles()
  label_ang:RotateAroundAxis(label_ang:Right(), 90)
  label_ang:RotateAroundAxis(label_ang:Up(), -90)

  local label = string.upper(self:GetPlanetName() or "")
  if self:GetInfected() then
    label = "ESTADO DESCONOCIDO"
    color_value = Color(255, 70, 60, 230)
  end

  se_draw_hologram_label(base_pos + Vector(0, 0, 88), label_ang, label, color_value)
end

hook.Add("PostDrawTranslucentRenderables", "SE_PlanetaryHologramOcclusionPass", function()
  for _, ent in ipairs(ents.FindByClass("se_planetary_hologram")) do
    if IsValid(ent) and ent:GetHologramActive() then
      if LocalPlayer():GetPos():DistToSqr(ent:GetPos()) <= 160000 then
        se_draw_hologram_body(ent)
      end
    end
  end
end)

SE_ACTIVE_HOLOGRAM = SE_ACTIVE_HOLOGRAM or nil
SE_HOLOGRAM_UI = SE_HOLOGRAM_UI or nil
SE_HOLOGRAM_ANGLE = SE_HOLOGRAM_ANGLE or Angle(0, 0, 0)
SE_HOVERED_PROVINCE = SE_HOVERED_PROVINCE or nil
SE_HOLOGRAM_VIEW = SE_HOLOGRAM_VIEW or nil

net.Receive("se_hologram_interact", function()
  local ent = net.ReadEntity()
  if !IsValid(ent) then return end

  if IsValid(SE_HOLOGRAM_UI) then
    SE_HOLOGRAM_UI:Remove()
  end

  SE_ACTIVE_HOLOGRAM = ent
  SE_HOLOGRAM_ANGLE = Angle(0, 0, 0)
  SE_HOVERED_PROVINCE = nil

  SE_HOLOGRAM_UI = vgui.Create("DFrame")
  SE_HOLOGRAM_UI:SetSize(ScrW(), ScrH())
  SE_HOLOGRAM_UI:SetPos(0, 0)
  SE_HOLOGRAM_UI:SetTitle("")
  SE_HOLOGRAM_UI:ShowCloseButton(false)
  SE_HOLOGRAM_UI:SetDraggable(false)
  SE_HOLOGRAM_UI:MakePopup()
  SE_HOLOGRAM_UI.Paint = function(self, w, h)
    draw.SimpleText("Arrastra para rotar. Presiona Click Derecho o Escape para salir", "DermaLarge", w/2, h - 50, Color(255, 255, 255, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
  end

  local is_dragging = false
  local last_mouse_x, last_mouse_y = 0, 0

  SE_HOLOGRAM_UI.OnMousePressed = function(self, mousecode)
    if mousecode == MOUSE_RIGHT then
      self:Remove()
      return
    end
    if mousecode == MOUSE_LEFT then
      is_dragging = true
      last_mouse_x, last_mouse_y = input.GetCursorPos()
    end
  end

  SE_HOLOGRAM_UI.OnMouseReleased = function(self, mousecode)
    if mousecode == MOUSE_LEFT then
      is_dragging = false
    end
  end
  
  SE_HOLOGRAM_UI.OnKeyCodePressed = function(self, keycode)
    if keycode == KEY_ESCAPE then
      self:Remove()
      gui.HideGameUI()
    end
  end

  SE_HOLOGRAM_UI.Think = function(self)
    if !IsValid(SE_ACTIVE_HOLOGRAM) or !SE_ACTIVE_HOLOGRAM:GetHologramActive() then
      self:Remove()
      return
    end

    local mx, my = input.GetCursorPos()
    if is_dragging then
      local dx = mx - last_mouse_x
      local dy = my - last_mouse_y
      
      SE_HOLOGRAM_ANGLE.yaw = SE_HOLOGRAM_ANGLE.yaw + dx * 0.5
      SE_HOLOGRAM_ANGLE.pitch = math.Clamp(SE_HOLOGRAM_ANGLE.pitch - dy * 0.5, -90, 90)
      
      last_mouse_x, last_mouse_y = mx, my
    elseif SE_HOLOGRAM_VIEW then
      local ray_dir = util.AimVector(SE_HOLOGRAM_VIEW.angles, SE_HOLOGRAM_VIEW.fov, mx, my, ScrW(), ScrH())
      local origin = SE_HOLOGRAM_VIEW.origin
      local sphere_center = SE_ACTIVE_HOLOGRAM:LocalToWorld(Vector(0, 0, 76))
      
      local L = sphere_center - origin
      local tca = L:Dot(ray_dir)
      if tca < 0 then
        SE_HOVERED_PROVINCE = nil
      else
        local d2 = L:Dot(L) - tca * tca
        local radius2 = 30 * 30
        if d2 > radius2 then
          SE_HOVERED_PROVINCE = nil
        else
          local thc = math.sqrt(radius2 - d2)
          local t0 = tca - thc
          local hit_pos = origin + ray_dir * t0
          
          local local_hit = hit_pos - sphere_center
          local inv_rot = Matrix()
          inv_rot:SetAngles(SE_HOLOGRAM_ANGLE)
          inv_rot:Invert()
          local point_on_sphere = inv_rot * local_hit
          
          local key = SE_ACTIVE_HOLOGRAM:GetPlanetKey()
          local region_data = se_build_planet_regions(key)
          
          if region_data and region_data.province_centers then
            local best_dist = 999999
            local best_id = nil
            for i, center_pos in ipairs(region_data.province_centers) do
              local d = point_on_sphere:Distance(center_pos)
              if d < best_dist then
                best_dist = d
                best_id = i
              end
            end
            SE_HOVERED_PROVINCE = best_id
          end
        end
      end
    end
  end

  SE_HOLOGRAM_UI.OnRemove = function(self)
    SE_ACTIVE_HOLOGRAM = nil
  end
end)

hook.Add("CalcView", "SE_HologramCamera", function(ply, pos, angles, fov)
  if IsValid(SE_ACTIVE_HOLOGRAM) and IsValid(SE_HOLOGRAM_UI) then
    local center = SE_ACTIVE_HOLOGRAM:LocalToWorld(Vector(0, 0, 76))
    
    local view = {}
    view.origin = center + SE_ACTIVE_HOLOGRAM:GetForward() * 120 + Vector(0, 0, 20)
    view.angles = (center - view.origin):Angle()
    view.fov = fov
    view.drawviewer = true
    
    SE_HOLOGRAM_VIEW = view
    return view
  end
end)
