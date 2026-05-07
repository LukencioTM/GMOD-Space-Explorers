function space_explorers_change_race(ply, race)
  ply.race = race
  local race = space_explorers.races[race]
  if race then
    ply:SetHealth(race.health)
    ply:SetMaxHealth(race.health)
    ply:SetNWInt("repair_skills", race.repair_ab)
    ply:SetNWString("se_race", ply.race)
    ply:SetModel(table.Random(race.models))
  end
end

net.Receive("se_race_choosen", function(len, ply)
  local race = net.ReadString()
  local race_table = races[race]
  if race_table then
    space_explorers_change_race(ply, race)
  end
  ply:Give("weapon_crowbar")
  ply:Give("weapon_se_repair_tool")
  ply:Give("weapon_se_analyze_tool")
  se_update_skills(ply)
end)
