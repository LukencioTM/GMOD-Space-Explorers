se_asteroids_aabb = {100, 100}

function se_init_ship()
  se_curret_comm = ""
  se_comm_done = false
  se_is_planet = false
  se_global_jumps = 0
  se_global_explored = 0
  se_global_sectors = 0
  se_fraction = "Federation"
  se_curret_planet = Vector(0, 0, 0)
  -- Player ship. Synchronized every second.
  players_spaceship = {
    name = "Nave aleatoria",
    system_name = "Sistema solar",
    health = 100,
    shields = 100,
    fuel = 10,
    credits = 0,
    max_health = 100,
    max_shields = 100,
    shield_reg_mod = 0,
    drive_charge = 0,
    oxygen  = 100,
    star_pos = 1,
    pos = Vector(),
    ang = Angle(),
    resources = {
      iron = 0,
      silver = 0,
      gold = 0,
    },
    modules = {
      Weapons = {
        name = "Armas",
        health = 100,
        pos = Vector(-716, -1128, 32),
        angle = Angle(0, 90, 0),
        weapons = {
          table.Copy(se_weapons.EnergyBlaster),
          table.Copy(se_weapons.SimpleMissle)
        },
      },
      Pilot = {
        name = "Piloto",
        health = 100,
        pos = Vector(-64, -792, 32),
        angle = Angle(0, -90, 0)
      },
      HyperDrive = {
        name = "Hipermotor",
        health = 100,
        pos = Vector(-1522, -1128, 32),
        angle = Angle(0, 90, 0)
      },
      Teleport = {
        name = "Teletransporte",
        health = 100,
        pos = Vector(-1896, -895, 32),
        angle = Angle(0, 0, 0)
      },
      LifeSupport = {
        name = "Soporte vital",
        health = 100,
        pos = Vector(-1128, -580, 32),
        angle = Angle(0, 0, 0)
      },
      Shields = {
        name = "Escudos",
        health = 100,
        pos = Vector(-716, -664, 32),
        angle = Angle(0, -90, 0)
      },
      Communication = {
        name = "Comunicacion",
        health = 100,
        pos = Vector(-63, -1000, 32),
        angle = Angle(0, 90, 0),
      },
    }
  }
  space_explorers_spawn_modules()
end

sound.Add( {
  name = "se_drive_charge_sound",
  channel = CHAN_STATIC,
  volume = 1.0,
  level = 80,
  pitch = { 95, 110 },
  sound = "ambient/energy/force_field_loop1.wav"
} )

function se_game_losed()
  net.Start("se_game_losed")
  net.WriteTable({
    jumps = se_global_jumps,
    sectors = se_global_sectors,
    explored = se_global_explored
  })
  net.Broadcast()
  players_spaceship.health = 9999
  timer.Simple(30, function()
    RunConsoleCommand("changelevel", "se_spaceship")
  end)
end

local SE_SAVE_DIR = "space_explorers/saves"

local function se_ensure_save_dir()
  file.CreateDir("space_explorers")
  file.CreateDir(SE_SAVE_DIR)
end

local function se_vector_to_table(vec)
  if !vec then return nil end
  return {x = vec.x, y = vec.y, z = vec.z}
end

local function se_angle_to_table(ang)
  if !ang then return nil end
  return {p = ang.p, y = ang.y, r = ang.r}
end

local function se_color_to_table(color)
  if !color then return nil end
  return {r = color.r, g = color.g, b = color.b, a = color.a}
end

local function se_color_from_table(tbl)
  if !tbl then return Color(255, 255, 255) end
  return Color(tbl.r or 255, tbl.g or 255, tbl.b or 255, tbl.a or 255)
end

local function se_sanitize_save_name(name)
  name = string.Trim(name or "")
  if name == "" then
    name = os.date("Partida %Y-%m-%d %H-%M-%S")
  end

  name = string.gsub(name, "[^%w%s_%-]", "")
  name = string.gsub(name, "%s+", "_")
  name = string.sub(name, 1, 48)

  if name == "" then
    name = "partida"
  end

  return string.lower(name)
end

local function se_find_planet_key(planet)
  if !planet or !istable(planet) then return nil end
  for key, data in pairs(se_planet_positions or {}) do
    if data == planet then
      return key
    end
  end
  return nil
end

local function se_copy_weapon_data(weapon)
  return {
    Name = weapon.Name,
    Damage = weapon.Damage,
    Shots = weapon.Shots,
    Charge = weapon.Charge,
    IgnoreShileds = weapon.IgnoreShileds,
    ShotChanse = weapon.ShotChanse,
    MaxCharge = weapon.MaxCharge
  }
end

local function se_copy_ship_modules_for_save()
  local modules = {}

  for module_name, module in pairs(players_spaceship.modules or {}) do
    modules[module_name] = {
      name = module.name,
      health = module.health,
      miner_level = module.miner_level,
      asteroid = module.asteroid,
      allow_mine = module.allow_mine,
      asteroid_level = module.asteroid_level,
      weapons = {}
    }

    if module.weapons then
      for weapon_id, weapon in pairs(module.weapons) do
        modules[module_name].weapons[weapon_id] = se_copy_weapon_data(weapon)
      end
    end
  end

  return modules
end

local function se_copy_ship_for_save()
  return {
    name = players_spaceship.name,
    system_name = players_spaceship.system_name,
    health = players_spaceship.health,
    shields = players_spaceship.shields,
    fuel = players_spaceship.fuel,
    credits = players_spaceship.credits,
    max_health = players_spaceship.max_health,
    max_shields = players_spaceship.max_shields,
    shield_reg_mod = players_spaceship.shield_reg_mod,
    drive_charge = players_spaceship.drive_charge,
    oxygen = players_spaceship.oxygen,
    star_pos = players_spaceship.star_pos,
    pos = se_vector_to_table(players_spaceship.pos),
    ang = se_angle_to_table(players_spaceship.ang),
    resources = table.Copy(players_spaceship.resources or {}),
    modules = se_copy_ship_modules_for_save()
  }
end

local function se_copy_star_map_for_save()
  return table.Copy(se_star_map or {})
end

local function se_copy_space_body_for_save()
  local body = table.Copy(space_body or {})
  body.Color = se_color_to_table(space_body and space_body.Color)
  body.Exists = body.Exists or false
  body.Material = tonumber(body.Material) or 1
  body.Size = tonumber(body.Size) or 1000

  if body.asteroids then
    local asteroids = {}
    for asteroid_id, asteroid in pairs(body.asteroids) do
      asteroids[asteroid_id] = {
        se_vector_to_table(asteroid[1]),
        asteroid[2]
      }
    end
    body.asteroids = asteroids
  end

  return body
end

local function se_restore_space_body(body)
  if !body then return nil end

  local restored = table.Copy(body)
  restored.Color = se_color_from_table(restored.Color)
  restored.Exists = restored.Exists or false
  restored.Material = tonumber(restored.Material) or 1
  restored.Size = tonumber(restored.Size) or 1000

  if restored.asteroids then
    local asteroids = {}
    for asteroid_id, asteroid in pairs(restored.asteroids) do
      local pos = asteroid[1] or {}
      asteroids[asteroid_id] = {
        Vector(pos.x or 0, pos.y or 0, pos.z or 0),
        asteroid[2] or 0
      }
    end
    restored.asteroids = asteroids
  end

  return restored
end

local function se_copy_enemy_for_save()
  if !enemy_spaceship then return nil end

  local enemy = {
    valid = enemy_spaceship.valid,
    health = enemy_spaceship.health,
    shields = enemy_spaceship.shields,
    modules = {}
  }

  for module_name, module in pairs(enemy_spaceship.modules or {}) do
    enemy.modules[module_name] = {
      name = module.name,
      health = module.health,
      weapons = {}
    }

    if module.weapons then
      for weapon_id, weapon in pairs(module.weapons) do
        enemy.modules[module_name].weapons[weapon_id] = se_copy_weapon_data(weapon)
      end
    end
  end

  return enemy
end

local function se_copy_players_for_save()
  local players = {}

  for _, ply in ipairs(player.GetAll()) do
    local steam_id = ply:SteamID64()
    if !steam_id or steam_id == "0" then
      steam_id = ply:SteamID()
    end

    players[steam_id] = {
      name = ply:Nick(),
      race = ply.race or ply:GetNWString("se_race", "Humans"),
      health = ply:Health(),
      skills = table.Copy(ply.skills or {}),
      talent_points = ply:GetNWInt("se_talent_points", 0),
      shopping_enabled = ply.shopping_enabled or ply:GetNWBool("se_shopping_enabled", false),
      is_captain = ply.is_captain or false,
      in_suit = ply:GetNWBool("SE_InSuit", false),
      on_planet = ply.on_planet or false
    }
  end

  return players
end

local function se_copy_dynamic_entity(ent)
  local color = ent:GetColor()
  return {
    class = ent:GetClass(),
    model = ent:GetModel(),
    pos = se_vector_to_table(ent:GetPos()),
    ang = se_angle_to_table(ent:GetAngles()),
    health = ent:Health(),
    color = se_color_to_table(color)
  }
end

local function se_copy_dynamic_entities_for_save()
  local entities = {}

  for _, ent in pairs(ents.FindByClass("npc_*")) do
    if IsValid(ent) then
      entities[#entities + 1] = se_copy_dynamic_entity(ent)
    end
  end

  for _, ent in pairs(ents.FindByClass("se_rare_item")) do
    if IsValid(ent) then
      entities[#entities + 1] = se_copy_dynamic_entity(ent)
    end
  end

  return entities
end

local function se_build_save_data(display_name)
  return {
    version = 2,
    name = display_name,
    created_at = os.time(),
    globals = {
      se_curret_comm = se_curret_comm,
      se_comm_done = se_comm_done,
      se_is_planet = se_is_planet,
      se_global_jumps = se_global_jumps,
      se_global_explored = se_global_explored,
      se_global_sectors = se_global_sectors,
      se_fraction = se_fraction,
      se_curret_planet_key = se_find_planet_key(se_curret_planet)
    },
    ship = se_copy_ship_for_save(),
    star_map = se_copy_star_map_for_save(),
    fractions = table.Copy(se_fractions or {}),
    space_body = se_copy_space_body_for_save(),
    asteroids_for_mining = table.Copy(se_asteroids_for_mining or {}),
    enemy_spaceship = se_copy_enemy_for_save(),
    players = se_copy_players_for_save(),
    dynamic_entities = se_copy_dynamic_entities_for_save()
  }
end

local function se_restore_dynamic_entities(entities_save)
  for _, ent_save in ipairs(entities_save or {}) do
    if ent_save.class then
      local ent = ents.Create(ent_save.class)
      if IsValid(ent) then
        local pos = ent_save.pos or {}
        local ang = ent_save.ang or {}
        ent:SetPos(Vector(pos.x or 0, pos.y or 0, pos.z or 0))
        ent:SetAngles(Angle(ang.p or 0, ang.y or 0, ang.r or 0))
        if ent_save.model then
          ent:SetModel(ent_save.model)
        end
        ent:Spawn()
        if ent_save.model then
          ent:SetModel(ent_save.model)
        end
        if ent_save.health and ent_save.health > 0 then
          ent:SetHealth(ent_save.health)
        end
        if ent_save.color then
          ent:SetColor(se_color_from_table(ent_save.color))
        end
      end
    end
  end
end

se_global_players_save = se_global_players_save or {}

local function se_apply_players_save(players_save)
  if !players_save then return end
  
  se_global_players_save = table.Copy(players_save)

  local captain_found = false

  for _, ply in ipairs(player.GetAll()) do
    local steam_id = ply:SteamID64()
    if !steam_id or steam_id == "0" then
      steam_id = ply:SteamID()
    end

    local saved = players_save[steam_id]
    if saved then
      ply.skills = saved.skills or ply.skills
      ply:SetNWInt("se_talent_points", saved.talent_points or 0)
      ply.shopping_enabled = saved.shopping_enabled or false
      ply:SetNWBool("se_shopping_enabled", ply.shopping_enabled)
      ply.is_captain = saved.is_captain or false
      ply:SetNWBool("se_is_сaptain", ply.is_captain)

      if ply.is_captain then
        captain_found = true
      end

      if saved.race and races[saved.race] then
        space_explorers_change_race(ply, saved.race)
      end

      se_update_skills(ply)
      ply:SetHealth(math.Clamp(saved.health or ply:Health(), 1, ply:GetMaxHealth()))
      ply:WearSuit(saved.in_suit or false)
      ply.on_planet = saved.on_planet or false

      if ply.on_planet and se_is_planet and istable(se_curret_planet) then
        ply:SetPos(se_curret_planet.player)
      end
    else
      ply:SetNWBool("se_is_сaptain", false)
      ply.is_captain = false
    end
  end

  if !captain_found then
    local first_ply = player.GetAll()[1]
    if IsValid(first_ply) then
      first_ply.is_captain = true
      first_ply:SetNWBool("se_is_сaptain", true)
      first_ply.shopping_enabled = true
      first_ply:SetNWBool("se_shopping_enabled", true)
    end
  end
end

local function se_apply_ship_save(ship)
  if !ship then return end

  players_spaceship.name = ship.name or players_spaceship.name
  players_spaceship.system_name = ship.system_name or players_spaceship.system_name
  players_spaceship.health = ship.health or players_spaceship.health
  players_spaceship.shields = ship.shields or players_spaceship.shields
  players_spaceship.fuel = ship.fuel or players_spaceship.fuel
  players_spaceship.credits = ship.credits or players_spaceship.credits
  players_spaceship.max_health = ship.max_health or players_spaceship.max_health
  players_spaceship.max_shields = ship.max_shields or players_spaceship.max_shields
  players_spaceship.shield_reg_mod = ship.shield_reg_mod or players_spaceship.shield_reg_mod
  players_spaceship.drive_charge = ship.drive_charge or players_spaceship.drive_charge
  players_spaceship.oxygen = ship.oxygen or players_spaceship.oxygen
  players_spaceship.star_pos = ship.star_pos or players_spaceship.star_pos
  players_spaceship.resources = ship.resources or players_spaceship.resources

  if ship.modules and ship.modules.AsteroidMining and !players_spaceship.modules.AsteroidMining then
    se_spawn_maining()
  end

  for module_name, module_save in pairs(ship.modules or {}) do
    local module = players_spaceship.modules[module_name]
    if module then
      module.health = module_save.health or module.health
      module.name = module_save.name or module.name

      if module_save.weapons and module.weapons then
        module.weapons = module_save.weapons
      end

      if module_name == "AsteroidMining" then
        module.miner_level = module_save.miner_level or module.miner_level
        module.asteroid = module_save.asteroid or false
        module.allow_mine = module_save.allow_mine or false
        module.asteroid_level = module_save.asteroid_level or -1
      end
    end
  end
end

local function se_apply_world_save(save_data)
  local globals = save_data.globals or {}

  for _, ent in pairs(ents.FindByClass("npc_*")) do
    ent:Remove()
  end
  for _, ent in pairs(ents.FindByClass("se_shop_npc")) do
    ent:Remove()
  end
  for _, ent in pairs(ents.FindByClass("se_rare_item")) do
    ent:Remove()
  end
  timer.Stop("se_spawn_enemy_npcs")
  timer.Stop("se_spawn_atrifacts")

  se_curret_comm = globals.se_curret_comm or ""
  se_comm_done = globals.se_comm_done or false
  se_global_jumps = globals.se_global_jumps or 0
  se_global_explored = globals.se_global_explored or 0
  se_global_sectors = globals.se_global_sectors or 0
  se_fraction = globals.se_fraction or "Federation"

  se_star_map = save_data.star_map or se_star_map
  se_fractions = save_data.fractions or se_fractions
  se_asteroids_for_mining = save_data.asteroids_for_mining or {}
  enemy_spaceship = save_data.enemy_spaceship

  if save_data.space_body then
    space_body = se_restore_space_body(save_data.space_body)
  end

  se_is_planet = globals.se_is_planet or false
  if se_is_planet and globals.se_curret_planet_key and se_planet_positions[globals.se_curret_planet_key] then
    se_curret_planet = se_planet_positions[globals.se_curret_planet_key]
    net.Start("se_update_space_body")
    net.WriteTable(space_body)
    net.Broadcast()
    if se_curret_planet.spawn_npcs then
      se_init_npcs()
    end
    se_send_planet_info()
  else
    se_is_planet = false
    se_curret_planet = Vector(0, 0, 0)
    if space_body then
      space_body.Exists = false
      net.Start("se_update_space_body")
      net.WriteTable(space_body)
      net.Broadcast()
    end
  end

  if enemy_spaceship and enemy_spaceship.valid then
    se_update_enemy_sprite(true, enemy_spaceship.shields or 0, enemy_spaceship.health or 0)
    se_update_enemy_state()
  else
    se_update_enemy_sprite(false, 0, 0)
  end

  se_restore_dynamic_entities(save_data.dynamic_entities)
end

local function se_send_save_result(ply, success, message)
  if !IsValid(ply) then return end

  net.Start("se_save_game_result")
  net.WriteBool(success)
  net.WriteString(message or "")
  net.Send(ply)
end

function se_send_save_list(ply)
  if !IsValid(ply) then return end

  se_ensure_save_dir()

  local files = file.Find(SE_SAVE_DIR .. "/*.txt", "DATA")
  local saves = {}

  for _, file_name in ipairs(files or {}) do
    local raw = file.Read(SE_SAVE_DIR .. "/" .. file_name, "DATA")
    local data = raw and util.JSONToTable(raw) or nil
    local save_id = string.gsub(file_name, "%.txt$", "")

    if data then
      saves[#saves + 1] = {
        id = save_id,
        name = data.name or save_id,
        created_at = data.created_at or 0,
        system_name = data.ship and data.ship.system_name or "Sistema desconocido",
        fuel = data.ship and data.ship.fuel or 0,
        health = data.ship and data.ship.health or 0,
        credits = data.ship and data.ship.credits or 0
      }
    end
  end

  table.sort(saves, function(a, b)
    return (a.created_at or 0) > (b.created_at or 0)
  end)

  net.Start("se_send_save_list")
  net.WriteTable(saves)
  net.Send(ply)
end

function se_save_game(save_name, ply)
  se_ensure_save_dir()

  local display_name = string.Trim(save_name or "")
  if display_name == "" then
    display_name = os.date("Partida %Y-%m-%d %H-%M-%S")
  end

  local save_id = se_sanitize_save_name(display_name)
  local save_data = se_build_save_data(display_name)
  local encoded = util.TableToJSON(save_data, true)

  if !encoded then
    se_send_save_result(ply, false, "No se pudo serializar la partida.")
    return
  end

  file.Write(SE_SAVE_DIR .. "/" .. save_id .. ".txt", encoded)
  se_send_save_result(ply, true, "Partida guardada: " .. display_name)
end

function se_load_game(save_id, ply)
  save_id = se_sanitize_save_name(save_id or "")
  if save_id == "" then
    se_send_save_result(ply, false, "Selecciona una partida valida.")
    return
  end

  local path = SE_SAVE_DIR .. "/" .. save_id .. ".txt"
  if !file.Exists(path, "DATA") then
    se_send_save_result(ply, false, "La partida no existe.")
    return
  end

  local raw = file.Read(path, "DATA")
  local save_data = raw and util.JSONToTable(raw) or nil
  if !save_data then
    se_send_save_result(ply, false, "No se pudo leer la partida.")
    return
  end

  timer.Remove("se_charge_drive_timer")
  for _, ent in pairs(ents.FindByClass("se_asteroid_miner")) do
    ent:Remove()
  end
  se_init_ship()
  se_apply_ship_save(save_data.ship)
  space_explorers_spawn_modules()
  se_apply_world_save(save_data)
  se_apply_players_save(save_data.players)
  se_send_ship_state()
  if se_send_star_map then
    se_send_star_map()
  end

  se_send_save_result(ply, true, "Partida cargada: " .. (save_data.name or save_id))
end

function se_delete_save_game(save_id, ply)
  save_id = se_sanitize_save_name(save_id or "")
  if save_id == "" then
    se_send_save_result(ply, false, "Selecciona una partida valida.")
    return
  end

  local path = SE_SAVE_DIR .. "/" .. save_id .. ".txt"
  if !file.Exists(path, "DATA") then
    se_send_save_result(ply, false, "La partida no existe.")
    return
  end

  file.Delete(path)
  se_send_save_result(ply, true, "Partida borrada correctamente.")
  se_send_save_list(ply)
end

-- Main update function
function se_ship_update()
  if !players_spaceship then return end
  se_update_enemy_spaceship()
  -- Check shields HP
  if players_spaceship.modules.Shields.health > 50 and players_spaceship.modules.Shields.ent.enabled then
    players_spaceship.shields = math.Clamp(players_spaceship.shields + 3 + players_spaceship.shield_reg_mod, 0, players_spaceship.max_shields)
  end
  -- Checks oxygen, if there is not enough of it make player take damage
  for k, v in pairs(player.GetAll()) do
    local low_oxygen = players_spaceship.oxygen < 40
    local outside_ship = !v:GetPos():WithinAABox(Vector(506, -1946, 723), Vector(-2667, -173, -229))
    if (low_oxygen or (outside_ship and !se_curret_planet.air)) and v.race != "Robots" and !v.in_suit then
      v:TakeDamage(2, v, v)
      v:EmitSound("hl1/fvox/warning.wav")
      v:ChatPrint("Advertencia: nivel de oxigeno bajo.")
    end
  end
  -- Charging weapons
  for k, v in pairs(players_spaceship.modules.Weapons.weapons) do
    v.Charge = math.Clamp(v.Charge + 2, 0, v.MaxCharge)
  end
  -- Turn terminal off if HP is too small, I think better to move it to entity itself
  for k, v in pairs(players_spaceship.modules) do
    if v.health < 50 and v.ent.enabled then
      v.ent:PrintLn("El terminal tiene poca salud. Reparalo primero")
      v.ent.enabled = false
    end
  end
  -- If LifeSupport is damaged, turn off oxygen generation
  if players_spaceship.modules.LifeSupport.health < 70 or !players_spaceship.modules.LifeSupport.ent.enabled then
    players_spaceship.oxygen = math.Clamp(players_spaceship.oxygen - 2, 0, 100)
  else
    players_spaceship.oxygen = math.Clamp(players_spaceship.oxygen + 4, 0, 100)
  end
  -- Destroy ship if hp is too low
  if players_spaceship.health <= 0 then
    se_game_losed()
  end
  se_send_ship_state()
end

function se_ship_ignite_random_module()
  local module = table.Random(players_spaceship.modules)
  module.ent:Ignite( 10, 250 )
end

function se_send_ship_state()
  local se_ship_state = {
    health  = math.floor(players_spaceship.health),
    shields = math.floor(players_spaceship.shields),
    oxygen  = math.floor(players_spaceship.oxygen),
    drive_charge  = math.floor(players_spaceship.drive_charge),
    max_hp  = math.floor(players_spaceship.max_health),
    max_sh  = math.floor(players_spaceship.max_shields),
    modules = {},
    weapons = {}
  }
  for k, v in pairs(players_spaceship.modules) do
    se_ship_state.modules[k] = math.floor(v.health)
  end
  for k, v in pairs(players_spaceship.modules.Weapons.weapons) do
    se_ship_state.weapons[k] = {math.floor(v.Charge), v.MaxCharge, v.Name}
  end
  net.Start("se_send_ship_state")
  net.WriteTable(se_ship_state)
  net.Broadcast()
end

-- Ship's modules spawn
function space_explorers_spawn_modules()
  for k, v in pairs( ents.FindByClass( "se_terminal" ) ) do
     v:Remove()
  end
  for k, v in pairs( ents.FindByClass( "se_spacesuit" ) ) do
     v:Remove()
  end
  for k, v in pairs(players_spaceship.modules) do
    local terminal = ents.Create("se_terminal")
    terminal:SetPos( v.pos )
    terminal:SetAngles( v.angle )
    terminal:Spawn()
    terminal.ModuleName = k
    terminal.enabled = true
    v.ent = terminal
    v.ent:SetNWString("se_terminal_name", v.name)
  end
  for k = 1, 3 do
    local suit = ents.Create("se_spacesuit")
    suit:SetPos( Vector(-1718 + k * 80, -664, 32) )
    suit:SetAngles( Angle(0, -90, 0) )
    suit:Spawn()
  end
end

-- Drive charging
function se_charge_drive()
  local charge_rate = 10
  if enemy_spaceship and enemy_spaceship.valid then
    charge_rate = 1
  else
    charge_rate = 10
  end
  players_spaceship.modules.HyperDrive.ent:StopSound("se_drive_charge_sound")
  players_spaceship.modules.HyperDrive.ent:EmitSound("se_drive_charge_sound")
  timer.Create("se_charge_drive_timer", 1, 0, function()
    if players_spaceship.modules.HyperDrive.ent.enabled then
      if players_spaceship.drive_charge < 100 then
        players_spaceship.drive_charge = players_spaceship.drive_charge + charge_rate
      else
        timer.Stop("se_charge_drive_timer")
        players_spaceship.drive_charge = 100
        players_spaceship.modules.HyperDrive.ent:StopSound("se_drive_charge_sound")
      end
    end
  end)
end

-- Jump, big and ugly function
function se_try_jump()
  if players_spaceship.drive_charge >= 100 and players_spaceship.fuel > 0 then
    if se_star_map.star_choosed != -1 then
      se_star_map.player_pos = se_star_map.star_choosed
      se_star_map.star_choosed = -1
    else
      players_spaceship.modules.Pilot.ent:PrintLn("Elige un destino. Presiona TAB y usa 'Abrir mapa'.")
      return
    end
    local star = se_star_map.stars[se_star_map.player_pos]
    se_remove_planet_model()
    se_comm_done = false
    players_spaceship.fuel = players_spaceship.fuel - 1
    players_spaceship.drive_charge = 0
    if !star.explored then
      star.saved_system_name = se_gen_system_name()
      
      if star.type == "Station" then
        star.has_planet = true
        star.saved_planet_key = "Station"
      else
        star.has_planet = math.random( 1, 8 ) > 5
        if se_force_next_desert then
          star.has_planet = true
        end
        if star.has_planet then
          se_create_planet_model()
          star.saved_planet_key = se_find_planet_key(se_curret_planet)
        end
      end
    end
    
    players_spaceship.system_name = star.saved_system_name or se_gen_system_name()
    players_spaceship.pos = Vector()
    players_spaceship.ang = Angle()
    se_update_enemy_sprite(false, 0, 0)
    if enemy_spaceship then enemy_spaceship.valid = false end

    local comm_enabled = math.random( 1, 8 ) > 2 and !star.explored
    if comm_enabled then
      local talent_points = math.random( 1, 8 ) > 5
      if talent_points then
        for k, v in pairs(player.GetAll()) do
          v:GiveTalentPoints(1)
        end
      end
      se_random_comm(star)
    end
    
    if star.explored then
      if star.has_planet and star.saved_planet_key then
        se_create_planet_model(star.saved_planet_key)
      end
    else
      if star.type == "Station" then
        se_create_planet_model("Station")
      end
    end
    
    if star.type == "Mission" then
      se_award_for_mission()
    end

    if !star.explored and se_fractions.MoneyForExploring then
      players_spaceship.credits = players_spaceship.credits + 3
      players_spaceship.modules.Communication.ent:PrintLn("+3 creditos por explorar el sistema")
    end

    se_global_jumps = se_global_jumps + 1
    if !star.explored then
      se_global_explored = se_global_explored + 1
    end

    se_star_map.stars[se_star_map.player_pos].explored = true
    if se_send_star_map then
      se_send_star_map()
    end
    players_spaceship.modules.Pilot.ent:EmitSound("ambient/machines/teleport3.wav")
  end
end

function se_update_module_lang()
	players_spaceship.modules.Weapons.name = se_language[se_settings.language]["WeaponsTerminal"]
	players_spaceship.modules.Pilot.name = se_language[se_settings.language]["PilotTerminal"]
	players_spaceship.modules.HyperDrive.name = se_language[se_settings.language]["HyperDriveTerminal"]
	players_spaceship.modules.Teleport.name = se_language[se_settings.language]["TeleportTerminal"]
	players_spaceship.modules.LifeSupport.name = se_language[se_settings.language]["LifeSupportTerminal"]
	players_spaceship.modules.Shields.name = se_language[se_settings.language]["ShieldsTerminal"]
	players_spaceship.modules.Communication.name = se_language[se_settings.language]["CommunicationTerminal"]
	
	local modulesList = {Weapons = "WeaponsTerminal", Pilot = "PilotTerminal", HyperDrive = "HyperDriveTerminal", Teleport = "TeleportTerminal", LifeSupport = ["LifeSupportTerminal", Shields = "ShieldsTerminal", Communication = "CommunicationTerminal"}
	for k,v in pairs(modulesList) do
	print(k,v)
		--players_spaceship.modules.Weapons.name = se_language[se_settings.language]["WeaponsTerminal"]
	end
end