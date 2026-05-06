se_planet_ent = {}

se_force_next_desert = false

concommand.Add("se_debug_desert", function(ply, cmd, args)
  if IsValid(ply) and not ply:IsSuperAdmin() then return end
  se_force_next_desert = not se_force_next_desert
  local msg = se_force_next_desert and "se_debug_desert: ON - A partir de ahora siempre saldra planeta desertico/yermo." or "se_debug_desert: OFF - Generacion normal."
  if IsValid(ply) then
    ply:PrintMessage(HUD_PRINTCONSOLE, msg)
  else
    print(msg)
  end
end)

se_planet_npcs = {
  {
    ent = "npc_antlion",
    min_hp = 100,
    max_hp = 250,
  },
  {
    ent = "npc_headcrab",
    min_hp = 20,
    max_hp = 80,
  },
  {
    ent = "npc_headcrab_fast",
    min_hp = 20,
    max_hp = 50,
  },
  {
    ent = "npc_headcrab_black",
    min_hp = 20,
    max_hp = 50,
  },
  {
    ent = "npc_zombie",
    min_hp = 150,
    max_hp = 350,
  },
  {
    ent = "npc_antlionguard",
    min_hp = 200,
    max_hp = 500,
  },
}

se_planet_positions = {
  DryPlanet = {
    name = "Planeta seco",
    desc = "Parece que este planeta tuvo vida, pero ahora esta cubierto de pasto seco.",
    player = Vector(-8588, -10325, -5495),
    teleport = Vector(-9810, -10220, -5252),
    spawn_bugs = true,
    air = false,
    max_npc = 30,
    bugs = {
      Vector(-10601, -9664, -5286),
      Vector(-12149, -9506, -5218),
      Vector(-12900, -9046, -4912),
      Vector(-13416, -8418, -5007),
      Vector(-13616, -7045, -5047),
      Vector(-12889, -6309, -5344),
      Vector(-12279, -7245, -4445),
      Vector(-10871, -7176, -5613),
      Vector(-9738, -6840, -5461),
      Vector(-9064, -5808, -4900),
      Vector(-8037, -5472, -5235),
      Vector(-7162, -4359, -5251),
      Vector(-5587, -3834, -5472),
      Vector(-4220, -5240, -5475),
      Vector(-4177, -6257, -5448),
      Vector(-4143, -7768, -5475),
      Vector(-4366, -9010, -5395),
      Vector(-5117, -8998, -5265),
      Vector(-5760, -8091, -4941),
      Vector(-6392, -9907, -5763),
      Vector(-5298, -10349, -5725),
      Vector(-5652, -10548, -5734),
      Vector(-12266, -12811, -5424),
      Vector(-12130, -10385, -5715),
      Vector(-13137, -7384, -5354),
      Vector(-11945, -6605, -5205),
      Vector(-10795, -3846, -5025),
      Vector(-10169, -4391, -5404),
    }
  },
  WastelandPlanet = {
    name = "Mundo yermo",
    desc = "Un planeta inhospito y desolado, cubierto de formaciones rocosas. No hay rastros de vida.",
    player = Vector(-8455, -8106, 322),
    teleport = Vector(-9411, -7987, 325),
    spawn_bugs = false,
    air = false,
    max_npc = 0,
    bugs = {
      Vector(-10580, -10196, 321),
      Vector(-11255, -11448, 625),
      Vector(-9625, -11653, 377),
      Vector(-7824, -11774, 290),
      Vector(-6832, -11830, 284),
      Vector(-5649, -11897, 296),
      Vector(-5397, -10943, 293),
      Vector(-5350, -9602, 445),
      Vector(-5445, -8589, 498),
      Vector(-5785, -6126, 414),
      Vector(-7045, -5465, 394),
      Vector(-8456, -4829, 354),
      Vector(-9579, -4562, 425),
      Vector(-10968, -4162, 452),
      Vector(-12471, -4473, 495),
      Vector(-13265, -6072, 379),
      Vector(-13455, -7617, 355),
      Vector(-13398, -9055, 501),
      Vector(-13035, -10883, 553),
      Vector(-13593, -12081, 850),
      Vector(-12416, -12815, 424),
    }
  },
  GrayPlanet = {
    name = "Planeta gris",
    desc = "Parece que este planeta tiene pasto, arcilla y tierra. Aun queda algo de vida aqui.",
    player = Vector(-8237, -8711, -3468),
    teleport = Vector(-8877, -9778, -3787),
    spawn_bugs = true,
    air = false,
    max_npc = 50,
    bugs = {
      Vector(-7753, -11212, -3797),
      Vector(-6211, -11467, -3805),
      Vector(-5784, -11097, -3798),
      Vector(-5053, -11060, -3389),
      Vector(-5759, -9140, -3414),
      Vector(-5527, -8399, -3262),
      Vector(-5519, -7868, -3211),
      Vector(-5982, -6858, -3437),
      Vector(-6000, -6311, -3411),
      Vector(-5087, -5146, -3613),
      Vector(-4355, -4370, -3670),
      Vector(-3996, -2511, -3805),
      Vector(-5393, -2405, -3806),
      Vector(-6858, -2761, -3703),
      Vector(-8309, -2668, -3773),
      Vector(-9736, -2834, -3719),
      Vector(-11326, -2968, -3430),
      Vector(-12701, -4487, -3383),
      Vector(-13410, -5519, -3770),
      Vector(-13742, -6531, -3631),
      Vector(-13875, -7707, -3589),
      Vector(-12344, -7724, -3709),
      Vector(-11769, -7021, -4036),
      Vector(-11569, -9955, -3738),
      Vector(-9267, -8864, -3737),
    }
  },
  DesertPlanet = {
    name = "Planeta desertico",
    desc = "Un planeta arido lleno de desierto.",
    player = Vector(-8455, -8106, 322),
    teleport = Vector(-9411, -7987, 325),
    spawn_bugs = true,
    air = false,
    max_npc = 30,
    bugs = {
      Vector(-10580, -10196, 321),
      Vector(-11255, -11448, 625),
      Vector(-9625, -11653, 377),
      Vector(-7824, -11774, 290),
      Vector(-6832, -11830, 284),
      Vector(-5649, -11897, 296),
      Vector(-5397, -10943, 293),
      Vector(-5350, -9602, 445),
      Vector(-5445, -8589, 498),
      Vector(-5785, -6126, 414),
      Vector(-7045, -5465, 394),
      Vector(-8456, -4829, 354),
      Vector(-9579, -4562, 425),
      Vector(-10968, -4162, 452),
      Vector(-12471, -4473, 495),
      Vector(-13265, -6072, 379),
      Vector(-13455, -7617, 355),
      Vector(-13398, -9055, 501),
      Vector(-13035, -10883, 553),
      Vector(-13593, -12081, 850),
      Vector(-12416, -12815, 424),
    }
  },
  Station = {
    name = "Estacion espacial orbital",
    desc = "Una estacion espacial en orbita. Tal vez podamos comprar o vender algo aqui.",
    player = Vector(725, -5541, -975),
    teleport = Vector(562, -6473, -783),
    max_artifacts = 1,
    spawn_npcs = true,
    spawn_bugs = false,
    air = true
  },
  LostStation = {
    name = "Estacion espacial perdida",
    desc = "Parece que esta estacion se quedo sin energia y ahora flota a la deriva.",
    player = Vector(725, -5541, -975),
    teleport = Vector(562, -6473, -783),
    max_artifacts = 5,
    spawn_bugs = true,
    only_bugs = true,
    air = false,
    max_npc = 10,
    bugs = {
      Vector(1802, -5878, -783),
      Vector(1976, -4992, -783),
      Vector(1314, -4143, -783),
      Vector(367, -3988, -783),
      Vector(-490, -5040, -783),
      Vector(648, -5444, -975),
      Vector(791, -5379, -815),
      Vector(1049, -5125, -815),
      Vector(901, -4915, -815),
      Vector(671, -4964, -815),
      Vector(1675, -4117, -463),
      Vector(1987, -5881, -463),
      Vector(564, -6384, -463),
    }
  },
  SnowPlanet = {
    name = "Planeta nevado",
    desc = "Un planeta cubierto de nieve.",
    player = Vector(-10060,-7024,-7487),
    teleport = Vector(-10492,-7883,-7674),
    spawn_bugs = true,
    air = false,
    max_npc = 50,
    bugs = {
      Vector(-12327,-8754,-7395),
      Vector(-13681,-9172,-7185),
      Vector(-13844,-7678,-7025),
      Vector(-13554,-4839,-7310),
      Vector(-12954,-2936,-7212),
      Vector(-10665,-3737,-6961),
      Vector(-7960,-3468,-7383),
      Vector(-6090,-3437,-7374),
      Vector(-4227,-3353,-7514),
      Vector(-3918,-4996,-7364),
      Vector(-4198,-6875,-7546),
      Vector(-4342,-8373,-7357),
      Vector(-4159,-10172,-7480),
      Vector(-3915,-11692,-7383),
      Vector(-4325,-12980,-7375),
      Vector(-5373,-11457,-6770),
      Vector(-7650,-10241,-7227),
      Vector(-7930,-8938,-7156),
      Vector(-8449,-7994,-7256),
    }
  },
}

local function se_get_planet_key(planet)
  for key, data in pairs(se_planet_positions) do
    if data == planet then
      return key
    end
  end

  return nil
end

space_body = {
  Exists = true,
  Color = Color(math.random(1, 200), math.random(1, 200), math.random(1, 200)),
  Size = math.random(50, 150)
}

function se_gen_asteroids()
  local asteroids = {}
  for k = 0, 50 do
    local asteroid = {
      Vector(math.random(-5000, 5000), math.random(-5000, 5000), math.random(-5000, 5000)),
      math.random(0, 3)
    }
    table.insert(asteroids, asteroid)
  end

  local asteroids_for_mining = {}
  for k = 0, math.random(1, 5) do
    local asteroid = {
      level = math.random(1, 5)
    }
    table.insert(asteroids_for_mining, asteroid)
  end

  return asteroids, asteroids_for_mining
end

se_spawned_environment_props = se_spawned_environment_props or {}
local se_desert_props_list = {
  "models/props_wasteland/rockcliff_cluster02a.mdl",
  "models/props_wasteland/rockcliff_cluster01b.mdl",
  "models/props_wasteland/rockcliff05b.mdl",
  "models/props_canal/rock_riverbed01d.mdl",
  "models/props_canal/rock_riverbed01b.mdl",
  "models/props_wasteland/rockcliff_cluster02c.mdl",
  "models/props_wasteland/rockcliff01j.mdl",
  "models/props_foliage/bramble001a.mdl"
}

local se_snow_props_list = {
  "models/props_foliage/bramble001a.mdl",
  "models/props_canal/rock_riverbed02c.mdl",
  "models/props_canal/rock_riverbed01c.mdl"
}

local se_gray_rocks_list = {
  "models/props_canal/rock_riverbed02c.mdl",
  "models/props_canal/rock_riverbed02a.mdl",
  "models/props_canal/rock_riverbed01d.mdl",
  "models/props_canal/rock_riverbed01b.mdl"
}

local se_wasteland_props_list = {
  "models/props_wasteland/rockcliff_cluster02b.mdl",
  "models/props_wasteland/rockcliff_cluster02a.mdl",
  "models/props_wasteland/rockcliff_cluster01b.mdl",
  "models/props_wasteland/rockcliff_cluster02c.mdl",
  "models/props_wasteland/rockcliff_cluster03a.mdl",
  "models/props_wasteland/rockcliff_cluster03b.mdl"
}

function se_clear_environment_props()
  for _, prop in ipairs(se_spawned_environment_props) do
    if IsValid(prop) then prop:Remove() end
  end
  se_spawned_environment_props = {}
end

function se_spawn_environment_props(planet_key, planet)
  if planet_key ~= "DryPlanet" and planet_key ~= "DesertPlanet" and planet_key ~= "SnowPlanet" and planet_key ~= "GrayPlanet" and planet_key ~= "WastelandPlanet" then return end
  if not planet.bugs then return end
  
  if planet_key == "WastelandPlanet" then
    local rock_amount = math.random(80, 150)
    local giant_rock_index = -1
    if math.random(1, 100) <= 30 then
      giant_rock_index = math.random(1, rock_amount)
    end
    for i=1, rock_amount do
      local base_pos = table.Random(planet.bugs)
      local offset = Vector(math.random(-800, 800), math.random(-800, 800), 200)
      local tr = util.TraceLine({ start = base_pos + offset, endpos = base_pos + offset - Vector(0, 0, 1000), mask = MASK_SOLID_BRUSHONLY })
      if tr.Hit and tr.HitNormal.z > 0.6 then
        local prop = ents.Create("prop_physics")
        prop:SetModel(table.Random(se_wasteland_props_list))
        prop:SetPos(tr.HitPos)
        prop:SetAngles(Angle(math.random(-15, 15), math.random(0, 360), math.random(-15, 15)))
        prop:Spawn()
        
        if i == giant_rock_index then
            local scaleVec = Vector(12, 12, 4)
            prop:ManipulateBoneScale(0, scaleVec)
            
            local mins = prop:OBBMins()
            local maxs = prop:OBBMaxs()
            prop:PhysicsInitBox(mins * scaleVec, maxs * scaleVec)
            prop:SetCollisionBounds(mins * scaleVec, maxs * scaleVec)
            prop:SetSolid(SOLID_VPHYSICS)
            prop:EnableCustomCollisions(true)
        end

        local phys = prop:GetPhysicsObject()
        if IsValid(phys) then 
          phys:EnableMotion(false)
        end
        
        table.insert(se_spawned_environment_props, prop)
      end
    end

    local event_count = math.random(1, 3)
    for ev = 1, event_count do
      if math.random(1, 100) <= 70 then
        local crash_base = table.Random(planet.bugs)
        local tr = util.TraceLine({ start = crash_base + Vector(0, 0, 400), endpos = crash_base - Vector(0, 0, 1000), mask = MASK_SOLID_BRUSHONLY })
        if tr.Hit and tr.HitNormal.z > 0.6 then
          local sat = ents.Create("prop_physics")
          sat:SetModel("models/props_lab/teleportbulkeli.mdl")
          sat:SetPos(tr.HitPos - Vector(0, 0, 40))
          sat:SetAngles(Angle(math.random(20, 60), math.random(0, 360), math.random(-30, 30)))
          sat:Spawn()
          local phys = sat:GetPhysicsObject()
          if IsValid(phys) then phys:EnableMotion(false) end
          table.insert(se_spawned_environment_props, sat)

          for a=1, math.random(4, 8) do
            local art_offset = Vector(math.random(-400, 400), math.random(-400, 400), 100)
            local atr = util.TraceLine({ start = tr.HitPos + art_offset, endpos = tr.HitPos + art_offset - Vector(0, 0, 400), mask = MASK_SOLID_BRUSHONLY })
            if atr.Hit then
              local art = ents.Create("se_rare_item")
              art:SetPos(atr.HitPos)
              art:Spawn()
              art:SetColor(Color(math.random(1, 200), math.random(1, 200), math.random(1, 200)))
            end
          end

          for a=1, math.random(1, 3) do
            local plug_offset = Vector(math.random(-300, 300), math.random(-300, 300), 100)
            local ptr = util.TraceLine({ start = tr.HitPos + plug_offset, endpos = tr.HitPos + plug_offset - Vector(0, 0, 400), mask = MASK_SOLID_BRUSHONLY })
            if ptr.Hit then
              local p = ents.Create("prop_physics")
              p:SetModel("models/props_lab/tpplug.mdl")
              p:SetPos(ptr.HitPos)
              p:SetAngles(Angle(math.random(-180, 180), math.random(0, 360), math.random(-180, 180)))
              p:Spawn()
              table.insert(se_spawned_environment_props, p)
            end
          end

          for a=1, math.random(1, 2) do
            local cart_offset = Vector(math.random(-300, 300), math.random(-300, 300), 100)
            local ctr = util.TraceLine({ start = tr.HitPos + cart_offset, endpos = tr.HitPos + cart_offset - Vector(0, 0, 400), mask = MASK_SOLID_BRUSHONLY })
            if ctr.Hit then
              local c = ents.Create("prop_physics")
              c:SetModel("models/props_lab/reciever_cart.mdl")
              c:SetPos(ctr.HitPos - Vector(0, 0, 20))
              c:SetAngles(Angle(math.random(-45, 45), math.random(0, 360), math.random(-45, 45)))
              c:Spawn()
              local cphys = c:GetPhysicsObject()
              if IsValid(cphys) then cphys:EnableMotion(false) end
              table.insert(se_spawned_environment_props, c)
            end
          end

          if math.random(1, 100) <= 30 then
            for a=1, math.random(1, 3) do
              local hp_offset = Vector(math.random(-250, 250), math.random(-250, 250), 100)
              local htr = util.TraceLine({ start = tr.HitPos + hp_offset, endpos = tr.HitPos + hp_offset - Vector(0, 0, 400), mask = MASK_SOLID_BRUSHONLY })
              if htr.Hit then
                local h = ents.Create("item_healthkit")
                h:SetPos(htr.HitPos + Vector(0, 0, 5))
                h:Spawn()
              end
            end
          end
        end
      end
    end
    return
  end
  
  if planet_key == "GrayPlanet" then
    -- Capa 1: Rocas
    local rock_density = math.random(1, 3)
    local rock_amount = 0
    if rock_density == 1 then rock_amount = math.random(10, 25)
    elseif rock_density == 2 then rock_amount = math.random(40, 70)
    else rock_amount = math.random(100, 150) end
    
    for i=1, rock_amount do
      local base_pos = table.Random(planet.bugs)
      local offset = Vector(math.random(-800, 800), math.random(-800, 800), 200)
      local tr = util.TraceLine({ start = base_pos + offset, endpos = base_pos + offset - Vector(0, 0, 1000), mask = MASK_SOLID_BRUSHONLY })
      if tr.Hit and tr.HitNormal.z > 0.6 then
        local prop = ents.Create("prop_physics")
        prop:SetModel(table.Random(se_gray_rocks_list))
        prop:SetPos(tr.HitPos)
        prop:SetAngles(Angle(0, math.random(0, 360), 0))
        prop:Spawn()
        local phys = prop:GetPhysicsObject()
        if IsValid(phys) then phys:EnableMotion(false) end
        table.insert(se_spawned_environment_props, prop)
      end
    end
    
    -- Capa 2: Maleza
    local weed_amount = math.random(1, 100) <= 50 and math.random(10, 30) or math.random(100, 200)
    for i=1, weed_amount do
      local base_pos = table.Random(planet.bugs)
      local offset = Vector(math.random(-800, 800), math.random(-800, 800), 200)
      local tr = util.TraceLine({ start = base_pos + offset, endpos = base_pos + offset - Vector(0, 0, 1000), mask = MASK_SOLID_BRUSHONLY })
      if tr.Hit and tr.HitNormal.z > 0.6 then
        local prop = ents.Create("prop_physics")
        prop:SetModel("models/props_foliage/bramble001a.mdl")
        prop:SetPos(tr.HitPos)
        prop:SetAngles(Angle(0, math.random(0, 360), 0))
        prop:Spawn()
        local phys = prop:GetPhysicsObject()
        if IsValid(phys) then phys:EnableMotion(false) end
        table.insert(se_spawned_environment_props, prop)
      end
    end
    
    -- Capa 3: Arboles
    local is_forest = math.random(1, 100) <= 30
    local tree_amount = is_forest and math.random(40, 80) or math.random(5, 15)
    for i=1, tree_amount do
      local base_pos = table.Random(planet.bugs)
      local offset = Vector(math.random(-800, 800), math.random(-800, 800), 200)
      local tr = util.TraceLine({ start = base_pos + offset, endpos = base_pos + offset - Vector(0, 0, 1000), mask = MASK_SOLID_BRUSHONLY })
      if tr.Hit and tr.HitNormal.z > 0.6 then
        local prop = ents.Create("prop_physics")
        prop:SetModel("models/props_foliage/tree_deciduous_01a.mdl")
        prop:SetPos(tr.HitPos)
        prop:SetAngles(Angle(0, math.random(0, 360), 0))
        prop:Spawn()
        local phys = prop:GetPhysicsObject()
        if IsValid(phys) then phys:EnableMotion(false) end
        table.insert(se_spawned_environment_props, prop)
      end
    end
    
    return
  end
  
  local available_models = planet_key == "SnowPlanet" and table.Copy(se_snow_props_list) or table.Copy(se_desert_props_list)
  local chosen_models = {}
  
  -- Para SnowPlanet, a veces hacemos que "bramble001a.mdl" domine exageradamente
  if planet_key == "SnowPlanet" and math.random(1, 100) <= 50 then
    table.insert(chosen_models, "models/props_foliage/bramble001a.mdl")
  else
    for i=1, math.random(1, 4) do
      if #available_models == 0 then break end
      local idx = math.random(1, #available_models)
      table.insert(chosen_models, available_models[idx])
      table.remove(available_models, idx)
    end
  end
  
  local amount = math.random(20, 60)
  local giant_rock_index = -1
  if planet_key == "DesertPlanet" and math.random(1, 100) <= 20 then
    giant_rock_index = math.random(1, amount)
  end
  for i=1, amount do
    local base_pos = table.Random(planet.bugs)
    local offset = Vector(math.random(-800, 800), math.random(-800, 800), 200)
    local tr = util.TraceLine({
      start = base_pos + offset,
      endpos = base_pos + offset - Vector(0, 0, 1000),
      mask = MASK_SOLID_BRUSHONLY
    })
    
    if tr.Hit and tr.HitNormal.z > 0.6 then
      local prop = ents.Create("prop_physics")
      prop:SetModel(table.Random(chosen_models))
      prop:SetPos(tr.HitPos)
      prop:SetAngles(Angle(0, math.random(0, 360), 0))
      prop:Spawn()
      
      if i == giant_rock_index then
          local scaleVec = Vector(10, 10, 4)
          prop:ManipulateBoneScale(0, scaleVec)
          
          local mins = prop:OBBMins()
          local maxs = prop:OBBMaxs()
          prop:PhysicsInitBox(mins * scaleVec, maxs * scaleVec)
          prop:SetCollisionBounds(mins * scaleVec, maxs * scaleVec)
          prop:SetSolid(SOLID_VPHYSICS)
          prop:EnableCustomCollisions(true)
      end

      local phys = prop:GetPhysicsObject()
      if IsValid(phys) then
        phys:EnableMotion(false)
      end
      
      table.insert(se_spawned_environment_props, prop)
    end
  end

  -- Evento del tren estrellado para SnowPlanet (20% chance)
  if planet_key == "SnowPlanet" and math.random(1, 100) <= 20 then
    local crash_base = table.Random(planet.bugs)
    local tr = util.TraceLine({
      start = crash_base + Vector(0, 0, 400),
      endpos = crash_base - Vector(0, 0, 1000),
      mask = MASK_SOLID_BRUSHONLY
    })
    
    if tr.Hit and tr.HitNormal.z > 0.6 then
      local train = ents.Create("prop_physics")
      train:SetModel("models/props_combine/CombineTrain01a.mdl")
      train:SetPos(tr.HitPos)
      train:SetAngles(Angle(math.random(-15, 15), math.random(0, 360), math.random(-15, 15)))
      train:Spawn()
      local tphys = train:GetPhysicsObject()
      if IsValid(tphys) then tphys:EnableMotion(false) end
      table.insert(se_spawned_environment_props, train)
      
      -- Generar artefactos alrededor
      for a=1, math.random(5, 10) do
        local art_offset = Vector(math.random(-400, 400), math.random(-400, 400), 100)
        local atr = util.TraceLine({ start = tr.HitPos + art_offset, endpos = tr.HitPos + art_offset - Vector(0, 0, 400), mask = MASK_SOLID_BRUSHONLY })
        if atr.Hit then
          local art = ents.Create("se_rare_item")
          art:SetPos(atr.HitPos)
          art:Spawn()
          art:SetColor(Color(math.random(1, 200), math.random(1, 200), math.random(1, 200)))
        end
      end
      
      -- Escombros
      local scatter_props = {"models/props_combine/combine_intmonitor003.mdl", "models/props_combine/combine_intwallunit.mdl", "models/player/skeleton.mdl"}
      for a=1, math.random(4, 8) do
        local p_offset = Vector(math.random(-300, 300), math.random(-300, 300), 100)
        local ptr = util.TraceLine({ start = tr.HitPos + p_offset, endpos = tr.HitPos + p_offset - Vector(0, 0, 400), mask = MASK_SOLID_BRUSHONLY })
        if ptr.Hit then
          local mdl = table.Random(scatter_props)
          local cls = (mdl == "models/player/skeleton.mdl") and "prop_ragdoll" or "prop_physics"
          local deb = ents.Create(cls)
          deb:SetModel(mdl)
          deb:SetPos(ptr.HitPos)
          deb:SetAngles(Angle(math.random(-45, 45), math.random(0, 360), math.random(-45, 45)))
          deb:Spawn()
          if cls == "prop_physics" then
            local dphys = deb:GetPhysicsObject()
            if IsValid(dphys) then dphys:EnableMotion(false) end
          end
          table.insert(se_spawned_environment_props, deb)
        end
      end
    end
  end
end

function se_create_planet_model(planet_name)
  local asteroids = {}
  if math.random(0, 10) > 6 then
    asteroids, se_asteroids_for_mining = se_gen_asteroids()
  else
    asteroids, se_asteroids_for_mining = {}, {}
  end
  
  local planet_key = nil
  if planet_name != nil then
    planet_key = planet_name
  else
    if se_force_next_desert then
      planet_key = "DesertPlanet"
    else
      local valid_planets = {}
      for k, v in pairs(se_planet_positions) do
        if k ~= "WastelandPlanet" then table.insert(valid_planets, k) end
      end
      planet_key = table.Random(valid_planets)
    end
    
    if planet_key == "DesertPlanet" and math.random(1, 100) <= 30 then
      planet_key = "WastelandPlanet"
    end
  end
  
  local planet = se_planet_positions[planet_key]
  
  se_clear_environment_props()
  for k, v in pairs( ents.FindByClass( "npc_*" ) ) do
    v:Remove()
  end
  timer.Stop("se_spawn_enemy_npcs")
  timer.Stop("se_spawn_atrifacts")
  for k, v in pairs( ents.FindByClass( "se_shop_npc" ) ) do
     v:Remove()
  end
  for k, v in pairs( ents.FindByClass( "se_rare_item" ) ) do
     v:Remove()
  end

  se_spawn_environment_props(planet_key, planet)
  
  space_body = {
    Exists = true,
    Color = Color(math.random(1, 200), math.random(1, 200), math.random(1, 200)),
    Size = math.random(1000, 5000),
    Atmoshpere = math.random(0, 10) > 5,
    Material = math.random(1, 3),
    asteroids = asteroids
  }
  net.Start("se_update_space_body")
  net.WriteTable(space_body)
  net.Broadcast()

  se_is_planet = true
  se_curret_planet = planet
  se_asteroids = asteroids

  local sky_color = Vector(space_body.Color.r / 255, space_body.Color.g / 255, space_body.Color.b / 255)
  local paint = ents.FindByClass("env_skypaint")[1]
  paint:SetDrawStars(true)
  paint:SetStarTexture("skybox/starfield")

  paint:SetTopColor(sky_color)
  paint:SetBottomColor(sky_color)
  paint:SetFadeBias(1)

  paint:SetDuskColor(Vector(1.0, 0.2, 0.0))
  paint:SetDuskScale(1)
  paint:SetDuskIntensity(1)

  if planet.spawn_bugs then
    local chosen_npc_pool = {}
    if planet.only_bugs then
      table.insert(chosen_npc_pool, se_planet_npcs[1])
    else
      local pool_size = math.random(1, 2)
      local temp_pool = table.Copy(se_planet_npcs)
      for i=1, pool_size do
        local idx = math.random(1, #temp_pool)
        table.insert(chosen_npc_pool, temp_pool[idx])
        table.remove(temp_pool, idx)
      end
    end

    timer.Create("se_spawn_enemy_npcs", 0.2, math.random(5, planet.max_npc), function()
      local npc = table.Random(chosen_npc_pool)
      local bug_pos = table.Random(planet.bugs)
      
      -- Agregar un offset aleatorio a los NPCs
      local offset = Vector(math.random(-250, 250), math.random(-250, 250), 0)
      local pos = Vector(bug_pos[1], bug_pos[2], bug_pos[3]) + offset
      
      -- Corregir altura con un TraceLine para que no floten ni caigan al vacio
      local tr = util.TraceLine({
        start = pos + Vector(0, 0, 300),
        endpos = pos - Vector(0, 0, 500),
        mask = MASK_SOLID_BRUSHONLY
      })
      
      if tr.Hit and not tr.StartSolid and tr.HitNormal.z > 0.5 then 
        pos = tr.HitPos + Vector(0, 0, 25) 
      else
        pos = Vector(bug_pos[1], bug_pos[2], bug_pos[3] + 25)
      end

      local ant = ents.Create(npc.ent)
      ant:SetPos(pos)
      ant:Spawn()
      ant:SetHealth(math.random(npc.min_hp, npc.max_hp))
      ant:SetColor(Color(math.random(1, 200), math.random(1, 200), math.random(1, 200)))
      for k, v in pairs( ents.FindByClass( "npc_*" ) ) do
        ant:AddEntityRelationship( v, D_FR, 99 )
      end
    end)
    timer.Create("se_spawn_atrifacts", 0.2, math.random(2, planet.max_artifacts or 20), function()
      local bug_pos = table.Random(planet.bugs)
      local offset = Vector(math.random(-200, 200), math.random(-200, 200), 0)
      local pos = Vector(bug_pos[1], bug_pos[2], bug_pos[3]) + offset
      
      local tr = util.TraceLine({
        start = pos + Vector(0, 0, 300),
        endpos = pos - Vector(0, 0, 500),
        mask = MASK_SOLID_BRUSHONLY
      })
      
      if tr.Hit and not tr.StartSolid and tr.HitNormal.z > 0.5 then 
        pos = tr.HitPos + Vector(0, 0, 20) 
      else
        pos = Vector(bug_pos[1], bug_pos[2], bug_pos[3] + 20)
      end

      local artefact = ents.Create("se_rare_item")
      artefact:SetPos(pos)
      artefact:Spawn()
      artefact:SetColor(Color(math.random(1, 200), math.random(1, 200), math.random(1, 200)))
    end)
  end
  if planet.spawn_npcs then
    se_init_npcs()
  end
  se_send_planet_info()
end

function se_remove_planet_model()
  se_clear_environment_props()
  
  local asteroids = {}
  if math.random(0, 10) > 6 then
    asteroids, se_asteroids_for_mining = se_gen_asteroids()
  else
    asteroids, se_asteroids_for_mining = {}, {}
  end
  space_body = {
    Exists = false,
    Color = Color(math.random(1, 200), math.random(1, 200), math.random(1, 200)),
    Size = math.random(2000, 5000),
    Material = math.random(1, 3),
    asteroids = asteroids
  }
  net.Start("se_update_space_body")
  net.WriteTable(space_body)
  net.Broadcast()
  se_is_planet = false
  se_send_planet_info()
end

function se_init_teleports()
  for k, planet_data in pairs(se_planet_positions) do
    if k == "WastelandPlanet" then continue end
    local teleport_pos = planet_data.teleport
    local teleport = ents.Create("se_teleport")
    teleport:SetPos(Vector(teleport_pos[1], teleport_pos[2], teleport_pos[3]))
    teleport:Spawn()
  end
end

function se_send_planet_info()
  if se_is_planet then
    local planet_key = se_get_planet_key(se_curret_planet)
    local planet = {
      name = se_curret_planet.name,
      desk = se_curret_planet.desc,
      air = se_curret_planet.air,
      planet_key = planet_key or "",
      is_station = planet_key == "Station" or planet_key == "LostStation",
      infected = planet_key == "LostStation",
      hostile = se_curret_planet.spawn_bugs or false
    }
    net.Start("se_send_planet_info")
    net.WriteTable(planet)
    net.Broadcast()
  else
    net.Start("se_send_planet_info")
    net.WriteTable({
      name = "Sin destino",
      desk = "No hay planetas o estaciones cercanas.",
      air = false,
      planet_key = "",
      is_station = false,
      infected = false,
      hostile = false
    })
    net.Broadcast()
  end
end
