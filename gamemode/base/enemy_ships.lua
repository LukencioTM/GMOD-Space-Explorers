function se_create_random_enemy_ship()
  local weapons = {}
  for k=0,math.random(0, 1) do
    local weapon = table.Random(se_weapons)
    table.insert(weapons, table.Copy(weapon))
  end
  se_update_enemy_sprite(true, 100, 100)
  se_send_event_broadcast(2)
  se_send_event_broadcast(6)
  enemy_spaceship = {
    valid = true,
    health = 100,
    shields = 100,
    modules = {
      Weapons = {
        name = "Weapons",
        health = 100,
        weapons = weapons
      },
      Pilot = {
        name = "Pilot",
        health = 100,
      },
      Shields = {
        name = "Shields",
        health = 100,
      },
      LifeSupport = {
        name = "Life Support",
        health = 100,
      },
    }
  }
  -- If you are in the pirates fraction, then they are friendly
  if se_fractions.FriendlyPirates then
    if 5 > math.random(0, 10) then
      enemy_spaceship.valid = false
      players_spaceship.modules.Communication.ent:PrintLn("Los piratas los dejan pasar porque pertenecen a su faccion")
    end
  end
  se_update_enemy_state()
end

function se_update_enemy_state()
  local se_enemy_ship_state = {
    health = math.floor(enemy_spaceship.health),
    shields = math.floor(enemy_spaceship.shields),
    modules = {}
  }
  for k, v in pairs(enemy_spaceship.modules) do
    se_enemy_ship_state.modules[k] = math.floor(v.health)
  end
  net.Start("se_update_enemy_state")
  net.WriteTable(se_enemy_ship_state)
  net.Broadcast()
end

-- Destroys enemy spaceship with award if we win
function se_destroy_enemy_ship(win)
  if enemy_spaceship then
    local win = win or false
	se_send_event_broadcast(4)
	se_send_event_broadcast(4)
    enemy_spaceship.valid = false
    enemy_spaceship.health = 0
    enemy_spaceship.shields = 0
    enemy_spaceship.modules = {}
    se_update_enemy_sprite(false, 0, 0)
    if win then
      local credits = math.random(10, 50)
      local fuel = math.random(0, 15)

      players_spaceship.credits = players_spaceship.credits + credits
      players_spaceship.fuel = players_spaceship.fuel + fuel
      players_spaceship.modules.Communication.ent:PrintLn("+"..credits.." creditos por destruir la nave enemiga")
      players_spaceship.modules.Communication.ent:PrintLn("+"..fuel.." combustible por destruir la nave enemiga")

      for k, v in pairs(player.GetAll()) do
        v:GiveTalentPoints(1)
      end

    end
  end
end

-- Main update function
function se_update_enemy_spaceship()
  if !enemy_spaceship or !enemy_spaceship.valid then return end

  if enemy_spaceship.modules.Shields.health > 50 then
    enemy_spaceship.shields = math.Clamp(enemy_spaceship.shields + (enemy_spaceship.modules.Shields.health / 100), 0, 100)
  end
  if enemy_spaceship.modules.Weapons.health > 50 then
    for k, v in pairs(enemy_spaceship.modules.Weapons.weapons) do
      v.Charge = math.Clamp(v.Charge + 2, 0, v.MaxCharge)
    end
    se_enemy_spaceship_make_random_shot()
  end
  if enemy_spaceship.health <= 0 then
    se_destroy_enemy_ship(true)
    se_update_enemy_state()
    return
  end
  se_update_enemy_state()
end

-- Make a random shot
function se_enemy_spaceship_make_random_shot()
  local ready_weapons = {}
  for k, v in pairs(enemy_spaceship.modules.Weapons.weapons) do
    if v.Charge >= v.MaxCharge then
      table.insert(ready_weapons, v)
    end
  end
  local weapon = table.Random(ready_weapons)
  if weapon then
    local _, module_name = table.Random(players_spaceship.modules)
    se_damage_players_ship_with_weapon(weapon, module_name)
    weapon.Charge = 0
  end
end
