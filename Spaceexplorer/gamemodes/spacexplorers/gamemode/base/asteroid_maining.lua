sound.Add( {
	name = "se_mining_sound",
	channel = CHAN_STATIC,
	volume = 0.5,
	level = 80,
	pitch = { 95, 110 },
	sound = "ambient/energy/electric_loop.wav"
} )

function se_spawn_maining()
  local se_mainer = ents.Create("se_asteroid_miner")
  se_mainer:SetPos(Vector(-1086,-1231,28))
  se_mainer:SetAngles( Angle(0, 180, 0) )
  se_mainer:Spawn()

  local terminal = ents.Create("se_terminal")
  terminal:SetPos( Vector(-1017,-1231,32) )
  terminal:SetAngles( Angle(0, 0, 0) )
  terminal:Spawn()
  terminal.ModuleName = "AsteroidMining"
  terminal.enabled = true
  players_spaceship.modules.AsteroidMining = {
    name = "Mineria de asteroides",
    health = 100,
    miner_level = 2,
    asteroid = false,
    allow_mine = false,
    asteroid_level = -1,
    miner_ent = se_mainer,
    pos = Vector(-1017,-1231,32),
    angle = Angle(0, 0, 0)
  }

  players_spaceship.modules.AsteroidMining.ent = terminal
  players_spaceship.modules.AsteroidMining.ent:SetNWString("se_terminal_name", "Mineria de asteroides")
end


function se_terminal_asteroids(ent, args)
  if se_asteroids_for_mining and se_asteroids_for_mining != {} then
    for k, v in pairs(se_asteroids_for_mining) do
      ent:PrintLn(k..". Asteroide: Nivel "..v.level)
    end
  else
    ent:PrintLn("No hay asteroides cerca")
  end
end

function se_terminal_mine(ent, args, ply)
  if se_asteroids_for_mining and se_asteroids_for_mining != {} then
    if !players_spaceship.modules.AsteroidMining.allow_mine then ent:PrintLn("No puedes minar ahora") return end
    if !players_spaceship.modules.AsteroidMining.asteroid then ent:PrintLn("No hay asteroides en el minero") return end
    players_spaceship.modules.AsteroidMining.allow_mine = false
    local time = 0.2 * players_spaceship.modules.AsteroidMining.asteroid_level
    players_spaceship.modules.AsteroidMining.miner_ent:StopSound( "se_mining_sound" )
    players_spaceship.modules.AsteroidMining.miner_ent:EmitSound( "se_mining_sound" )
    players_spaceship.modules.AsteroidMining.miner_ent:SetNWBool("se_asteroid_emit_particles", false)
    players_spaceship.modules.AsteroidMining.miner_ent:SetNWBool("se_asteroid_emit_particles", true)
    se_create_progress_bar(ent, time, 30)
    timer.Simple(time * 31, function()
      local iron = math.random(10, 20) * players_spaceship.modules.AsteroidMining.asteroid_level
      local silver = math.random(5, 10) * players_spaceship.modules.AsteroidMining.asteroid_level
      local gold = math.random(1, 6) * players_spaceship.modules.AsteroidMining.asteroid_level

      ent:PrintLn("+"..gold.." mineral de oro")
      players_spaceship.resources.gold = players_spaceship.resources.gold + gold

      ent:PrintLn("+"..silver.." mineral de plata")
      players_spaceship.resources.silver = players_spaceship.resources.silver + silver

      ent:PrintLn("+"..iron.." mineral de hierro")
      players_spaceship.resources.iron = players_spaceship.resources.iron + iron

      players_spaceship.modules.AsteroidMining.miner_ent:StopSound( "se_mining_sound" )
      players_spaceship.modules.AsteroidMining.asteroid = false
      players_spaceship.modules.AsteroidMining.allow_mine = false
      players_spaceship.modules.AsteroidMining.asteroid_level = -1
      players_spaceship.modules.AsteroidMining.miner_ent:DeattachAsteroid()
      players_spaceship.modules.AsteroidMining.miner_ent:SetNWBool("se_asteroid_emit_particles", false)
    end)
  else
    ent:PrintLn("No hay asteroides cerca")
  end
end

function se_terminal_grab(ent, args, ply)
  if se_asteroids_for_mining and se_asteroids_for_mining != {} then
    if args[1] == nil then
      ent:PrintLn("No se puede ejecutar. Uso: grab {asteroid_id}; ejemplo: grab 1")
      return
    end
    args[1] = tonumber(args[1])
    if se_asteroids_for_mining[args[1]] == nil then ent:PrintLn("No existe ese asteroide") return end
    local asteroid = se_asteroids_for_mining[args[1]]
    if asteroid.level > players_spaceship.modules.AsteroidMining.miner_level then ent:PrintLn("Tu nivel de mineria es demasiado bajo para este asteroide") return end
    table.remove(se_asteroids_for_mining, args[1])
    players_spaceship.modules.AsteroidMining.asteroid = true
    players_spaceship.modules.AsteroidMining.allow_mine = true
    players_spaceship.modules.AsteroidMining.asteroid_level = asteroid.level
    players_spaceship.modules.AsteroidMining.miner_ent:AttachAsteroid()
  else
    ent:PrintLn("No hay asteroides cerca")
  end
end

function se_terminal_resources(ent, args, ply)
  for k, v in pairs(players_spaceship.resources) do
    ent:PrintLn(v.." "..k)
  end
end

function se_terminal_miner_level(ent, args, ply)
  ent:PrintLn("Nivel del minero: "..players_spaceship.modules.AsteroidMining.miner_level)
end
