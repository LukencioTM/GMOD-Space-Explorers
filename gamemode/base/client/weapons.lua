se_weapons = {
  EnergyBlaster = {
    Name = "Blaster de energia",
    Damage = 5,
    Shots = 3,
    Charge = 0,
    IgnoreShileds = false,
    ShotChanse = 70,
    MaxCharge = 10
  },
  SimpleMissle = {
    Name = "Misil simple",
    Damage = 20,
    Shots = 1,
    Charge = 0,
    IgnoreShileds = true,
    ShotChanse = 50,
    MaxCharge = 20
  },
  TripleMissle = {
    Name = "Misil triple",
    Damage = 10,
    Shots = 3,
    Charge = 0,
    IgnoreShileds = true,
    ShotChanse = 50,
    MaxCharge = 40
  },
  MegaBlaster = {
    Name = "Mega Blaster",
    Damage = 5,
    Shots = 7,
    Charge = 0,
    IgnoreShileds = false,
    ShotChanse = 50,
    MaxCharge = 30
  },
  DevilGun = {
    Name = "Canon del diablo",
    Damage = 40,
    Shots = 2,
    Charge = 0,
    IgnoreShileds = false,
    ShotChanse = 50,
    MaxCharge = 50
  },
  MegaDevilGun = {
    Name = "Mega canon del diablo",
    Damage = 40,
    Shots = 4,
    Charge = 0,
    IgnoreShileds = false,
    ShotChanse = 50,
    MaxCharge = 50
  },
}

function se_damage_players_ship_with_weapon(weapon, module)
  timer.Create("se_weapon_shoot_main", 0.5, weapon.Shots, function()
    if players_spaceship.shields > 20 and !weapon.IgnoreShileds then
        players_spaceship.modules.Shields.ent:EmitSound("ambient/explosions/exp"..math.random(1, 4)..".wav")
        players_spaceship.shields = math.Clamp(players_spaceship.shields - weapon.Damage, 0, players_spaceship.max_shields)
    else
      local hit = weapon.ShotChanse < math.random(0, 100)
      if hit then
        players_spaceship.modules[module].ent:EmitSound("ambient/explosions/explode_"..math.random(1, 9)..".wav")
        players_spaceship.health = players_spaceship.health - (weapon.Damage / 3)
        players_spaceship.modules[module].health = math.Clamp(players_spaceship.modules[module].health - weapon.Damage, 0, 100)
        se_send_event_broadcast(3)
        if math.random(0, 100) > 91 then
          se_ship_ignite_random_module()
        end
      end
    end
  end)
end

-- Damage ship with specific weapon
function se_damage_enemy_ship_with_weapon(weapon, module)
  timer.Create("se_weapon_shoot_main", 0.5, weapon.Shots, function()
    if not enemy_spaceship or not enemy_spaceship.valid then
      timer.Remove("se_weapon_shoot_main")
      return
    end

    players_spaceship.modules.Weapons.ent:EmitSound("weapons/ar2/fire1.wav")
    if enemy_spaceship.shields > 20 and not weapon.IgnoreShileds then
        enemy_spaceship.shields = math.Clamp(enemy_spaceship.shields - weapon.Damage, 0, 100)
    else
      local hit = weapon.ShotChanse < math.random(0, 100)
      if hit then
        enemy_spaceship.health = enemy_spaceship.health - weapon.Damage
        enemy_spaceship.modules[module].health = math.Clamp(enemy_spaceship.modules[module].health - weapon.Damage, 0, 100)
      end
    end
    se_update_enemy_sprite(true, enemy_spaceship.shields, enemy_spaceship.health)
  end)
end
