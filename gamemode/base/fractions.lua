
function se_init_fractions()
  se_fractions = {
    Fractions = {
      Pirates = {
        Name = "Piratas",
        Reputation = 0,
        Desc = "*Mas dinero al destruir naves enemigas\n*A veces los piratas son amistosos contigo",
        FriendlyPirates = true
      },
      Federation = {
        Name = "Federacion",
        Reputation = 0,
        Desc = "*Precios mas bajos en estaciones espaciales",
        PriceMod = 0.8
      },
      Scientists = {
        Name = "Cientificos",
        Reputation = 0,
        Desc = "*Dinero por explorar nuevas estrellas",
        MoneyForExploring = true
      }
    },
    Player_Fraction = "None",
    Price_Mod = 1,
    FriendlyPirates = false,
    MoneyForExploring = false,
    Mission = false
  }
end

function se_change_fraction(franction)
  if se_fractions then
    se_fractions.Player_Fraction = franction
    if franction != "None" then
      local fraction = se_fractions.Fractions[franction]

      if fraction.PriceMod then
        se_fractions.Price_Mod = fraction.PriceMod
      else
        se_fractions.Price_Mod = 1
      end
      if fraction.FriendlyPirates then
        se_fractions.FriendlyPirates = fraction.FriendlyPirates
      else
        se_fractions.FriendlyPirates = false
      end
      if fraction.MoneyForExploring then
        se_fractions.MoneyForExploring = fraction.MoneyForExploring
      else
        se_fractions.MoneyForExploring = false
      end
      se_take_mission()
    end
  end
end

function se_award_for_mission()
  local credits = math.random(10, 50)
  players_spaceship.credits = players_spaceship.credits + credits
  players_spaceship.modules.Communication.ent:PrintLn("+"..credits.." creditos por completar la mision")
  se_fractions.Mission = false
  for k, v in pairs(se_star_map.stars) do
    if v.type == "Mission" then
       v.type = "Unknow"
    end
  end
end

function se_take_mission()
  se_fractions.Mission = true
  local star, key = table.Random(se_star_map.stars)
  for k, v in pairs(se_star_map.stars) do
    if v.type == "Mission" then
       v.type = "Unknow"
    end
  end
  for k, v in pairs(se_star_map.stars) do
    if v.type == "Unknow" and k != se_star_map.player_pos then
      v.type = "Mission"
      break
    end
  end
end

net.Receive("se_change_fraction", function()
  local fraction = net.ReadString()
  if fraction != "None" then
    if players_spaceship.credits >= 150 then
      players_spaceship.credits = players_spaceship.credits - 150
      se_change_fraction(fraction)
    end
  else
    se_change_fraction(fraction)
  end
end)

net.Receive("se_take_mission", function()
  if !se_fractions.Mission then
    se_take_mission(fraction)
  end
end)
