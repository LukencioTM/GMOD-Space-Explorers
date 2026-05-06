-- A lot of code there is shit, but it works and I'm too lazy to make it better

-- Prints help
function se_terminal_help(ent, args)
  for k, v in pairs(se_terminal_commands) do
    if v.help then
      local allow_print = true
      if v.module and v.module != ent.ModuleName then allow_print = false end
      if allow_print then
        ent:PrintLn(k .. " - " .. v.help)
      end
    end
  end
end

-- Function name says everything
function se_terminal_print_weapons_list(ent, args)
  for k, v in pairs(players_spaceship.modules.Weapons.weapons) do
    ent:PrintLn(k .. ". " .. v.Name)
    ent:PrintLn("  * Dano: " .. v.Damage)
    ent:PrintLn("  * Disparos: " .. v.Shots)
    ent:PrintLn("  * Ignora escudos: " .. tostring(v.IgnoreShileds))
  end
end

-- Function name says everything
function se_terminal_print_enemy_weapons(ent, args)
  if !enemy_spaceship or !enemy_spaceship.valid then return end
  for k, v in pairs(enemy_spaceship.modules.Weapons.weapons) do
    ent:PrintLn(k .. ". " .. v.Name)
    ent:PrintLn("  * Dano: " .. v.Damage)
    ent:PrintLn("  * Disparos: " .. v.Shots)
    ent:PrintLn("  * Ignora escudos: " .. tostring(v.IgnoreShileds))
  end
end

-- Function name says everything
function se_terminal_enemy_modules(ent, args)
  if !enemy_spaceship or !enemy_spaceship.valid then return end
  for k, v in pairs(enemy_spaceship.modules) do
    ent:PrintLn(k .. " - " .. v.health)
  end
end

-- Shoot in enemy spaceship
function se_terminal_shoot(ent, args)
  if !enemy_spaceship or !enemy_spaceship.valid then return end
  local weapon_id = tonumber(args[1])
  local module = args[2]
  local weapon = players_spaceship.modules.Weapons.weapons[weapon_id]
  local module_exists = enemy_spaceship.modules[module]

  if !weapon then
    ent:PrintLn("No existe esa arma. Ejemplo: shoot 2 Shields")
    ent:PrintLn("Escribe 'weapons' para ver la lista de armas")
    return
  end
  if !module_exists then
    ent:PrintLn("No existe ese modulo. Ejemplo: shoot 2 Shields")
    return
  end
  if weapon.Charge >= weapon.MaxCharge then
    weapon.Charge = 0
    se_damage_enemy_ship_with_weapon(weapon, module)
  else
    ent:PrintLn("Carga de arma baja, " .. weapon.Charge .. "/" .. weapon.MaxCharge)
  end
end

-- Clears the screen
function se_terminal_clear(ent, args)
  ent:ClearLines()
end

-- Jump into next system, again function name says everything
function se_terminal_jump(ent, args)
  if players_spaceship.drive_charge >= 100 then
    se_try_jump()
  else
    ent:PrintLn("Carga el motor primero")
  end
end

-- Old and unused anymore
function se_terminal_start_flying(ent, args, ply)
  ply:StartFlying(true)
end

-- Function name says everything
function se_terminaL_charge_drive(ent, args)
  se_charge_drive()
  ent:PrintLn("Cargando hipermotor...")
end

-- Answer into communication terminal
function se_terminal_answer(ent, args)
  if !communication_options[se_curret_comm] then return end
  local keys = table.GetKeys( communication_options[se_curret_comm].Options )
  if keys[tonumber(args[1])] then
    se_choose_comm(keys[tonumber(args[1])])
  end
end

-- Function name says everything
function se_terminal_teleport(ent, args, ply)
  if !se_is_planet or !istable(se_curret_planet) then
    ent:PrintLn("No hay planetas cercanos")
    return
  end

  if !IsValid(ply) or !ply:IsPlayer() then
    ent:PrintLn("Jugador invalido")
    return
  end

  if !ply:Alive() then
    ent:PrintLn("No puedes desembarcar muerto")
    return
  end

  net.Start("se_disembark_fade")
  net.WriteString("DESEMBARCANDO....")
  net.Send(ply)

  ent:PrintLn(ply:Name() .. " inicio desembarco.")

  timer.Simple(2, function()
    if !IsValid(ply) then return end
    if !se_is_planet or !istable(se_curret_planet) then return end

    ply:SetPos(se_curret_planet.player)
    ply.on_planet = true
  end)
end

-- Function name says everything
function se_terminal_teleport_planet_info(ent, args)
  if se_is_planet then
    ent:PrintLn("")
    ent:PrintLn("Nombre: " .. se_curret_planet.name)
    ent:PrintLn("")
    ent:PrintLn("Descripcion: " .. se_curret_planet.desc)
    ent:PrintLn("")
    ent:PrintLn("Aire: " .. tostring(se_curret_planet.air))
    ent:PrintLn("")
  else
    ent:PrintLn("No hay planetas cercanos")
  end
end

-- Fn to analize what user typed
function se_terminal_read_line(ent, line, ply)
  local args = string.Split( line, " " )
  local programm = args[1]
  table.remove( args, 1 )
  if ent.enabled then
    if se_terminal_commands[programm] then
      local command = se_terminal_commands[programm]
      if command.module and command.module != ent.ModuleName then return end
      command.fn(ent, args, ply)
    else
      ent:PrintLn("Comando inexistente")
    end
  else
    -- If terminal is turned off we have to type 'boot'
    if programm == "boot" and players_spaceship.modules[ent.ModuleName].health > 50 then
      ent:PrintLn("")
      se_create_progress_bar(ent, 1, 10)
      timer.Simple(11, function()
        ent:PrintLn("Bienvenido al terminal. Escribe 'help' para mas informacion")
        ent.enabled = true
      end)
    else
      if players_spaceship.modules[ent.ModuleName].health > 50 then
        ent:PrintLn("El terminal esta apagado. Escribe 'boot' para continuar")
      else
        ent:PrintLn("El terminal tiene poca salud. Reparalo primero")
      end
    end
  end
end

-- Main array with all commands, key is command name
se_terminal_commands = {
  help = {
    man = "",
    help = "muestra la ayuda",
    fn = se_terminal_help
  },
  jump = {
    man = "",
    help = "salta al siguiente sistema",
    module = "Pilot",
    fn = se_terminal_jump
  },
  --[[pilot = {
    man = "",
    help = "",
    module = "Pilot",
    fn = se_terminal_start_flying
  },--]]
  answer = {
    man = "",
    help = "responde una comunicacion",
    module = "Communication",
    fn = se_terminal_answer
  },
  charge = {
    man = "",
    help = "carga el hipermotor",
    module = "HyperDrive",
    fn = se_charge_drive
  },
  get_charge = {
    man = "",
    help = "muestra la carga del motor",
    module = "HyperDrive",
    fn = function(ent) ent:PrintLn(players_spaceship.drive_charge .. "%") end,
  },
  oxygen = {
    man = "",
    help = "muestra el nivel de oxigeno",
    module = "LifeSupport",
    fn = function(ent) ent:PrintLn(math.Round(players_spaceship.oxygen) .. "%") end,
  },
  ship_health = {
    man = "",
    help = "muestra la salud de la nave",
    module = "Pilot",
    fn = function(ent) ent:PrintLn(math.Round(players_spaceship.health) .. "%") end,
  },
  fuel = {
    man = "",
    help = "muestra el combustible",
    module = "Pilot",
    fn = function(ent) ent:PrintLn(math.Round(players_spaceship.fuel)) end,
  },
  ship_shields = {
    man = "",
    help = "muestra los escudos de la nave",
    module = "Pilot",
    fn = function(ent) ent:PrintLn(math.Round(players_spaceship.shields) .. "%") end,
  },
  enemy_health = {
    man = "",
    help = "muestra la salud de la nave enemiga",
    module = "Weapons",
    fn = function(ent)
      if !enemy_spaceship or !enemy_spaceship.valid then return end
      ent:PrintLn(math.Round(enemy_spaceship.health) .. "%")
    end,
  },
  enemy_shields = {
    man = "",
    help = "muestra los escudos de la nave enemiga",
    module = "Weapons",
    fn = function(ent)
      if !enemy_spaceship or !enemy_spaceship.valid then return end
      ent:PrintLn(math.Round(enemy_spaceship.shields) .. "%")
    end,
  },
  credits = {
    man = "",
    help = "muestra la cantidad de creditos",
    module = "Communication",
    fn = function(ent) ent:PrintLn(players_spaceship.credits .. " credits") end,
  },
  weapons = {
    man = "",
    help = "muestra la lista de armas",
    module = "Weapons",
    fn = se_terminal_print_weapons_list
  },
  enemy_modules = {
    man = "",
    help = "muestra los modulos enemigos",
    module = "Weapons",
    fn = se_terminal_enemy_modules
  },
  shoot = {
    man = "",
    help = "dispara",
    module = "Weapons",
    fn = se_terminal_shoot
  },
  enemy_weapons = {
    man = "",
    help = "muestra las armas enemigas",
    module = "Weapons",
    fn = se_terminal_print_enemy_weapons
  },
  clear = {
    man = "",
    help = "limpia la pantalla",
    fn = se_terminal_clear
  },
  teleport = {
    man = "",
    help = "teletransporta al planeta o estacion cercana",
    module = "Teleport",
    fn = se_terminal_teleport
  },
  planet_info = {
    man = "",
    help = "muestra informacion del planeta",
    module = "Teleport",
    fn = se_terminal_teleport_planet_info
  },
  shutdown = {
    man = "",
    help = "apaga el terminal",
    fn = function(ent) ent.enabled = false end,
  },
  asteroids = {
    man = "",
    help = "muestra la lista de asteroides",
    module = "AsteroidMining",
    fn = se_terminal_asteroids,
  },
  mine = {
    man = "",
    help = "mina el asteroide",
    module = "AsteroidMining",
    fn = se_terminal_mine,
  },
  grab = {
    man = "",
    help = "trae el asteroide a la nave",
    module = "AsteroidMining",
    fn = se_terminal_grab,
  },
  resources = {
    man = "",
    help = "muestra los recursos",
    module = "AsteroidMining",
    fn = se_terminal_resources,
  },
  miner_level = {
    man = "",
    help = "muestra el nivel del minero",
    module = "AsteroidMining",
    fn = se_terminal_miner_level,
  },
}

net.Receive("se_terminal_send_input", function(_, ply)
  local ent = net.ReadEntity()
  local text = net.ReadString()
  ent:PrintLn(ply:Name() .. ":/ " .. text)
  se_terminal_read_line(ent, text, ply)
end)
