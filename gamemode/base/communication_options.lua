local cooldown = 0

function se_send_comm_state()
  local comm = communication_options and communication_options[se_curret_comm] or nil
  local state = {
    active = comm != nil and !se_comm_done,
    name = comm and comm.Name or "Sin senal",
    text = comm and comm.Text or "No hay transmision activa.",
    enemy = comm and comm.Enemy or false,
    options = {}
  }

  if comm and comm.Options then
    local keys = table.GetKeys(comm.Options)
    table.SortByMember(keys)
    for index, key in ipairs(keys) do
      local option = comm.Options[key]
      state.options[#state.options + 1] = {
        index = index,
        text = option.text or key
      }
    end
  end

  net.Start("se_update_comm_state")
  net.WriteTable(state)
  net.Broadcast()
end

function se_init_comms()
  communication_options = {
    ShopSimple = {
      Name = "Tienda",
      Text = se_language[se_settings.language]["BuyFuelMain"],
      Enemy = false,
      Options = {
        BuyFuel = {
          text = se_language[se_settings.language]["BuyFuel"],
          static = true,
          events = {
            {
              event_text = "",
              resources = {
                fuel = 4,
                health = 0,
                credits = -2,
              }
            },
          },
        },
        RepairShip = {
          text = se_language[se_settings.language]["RepairShip"],
          static = true,
          events = {
            {
              event_text = "",
              resources = {
                fuel = 0,
                health = 5,
                credits = -3
              }
            },
          },
        }
      }
    },
    PirateShip = {
      Name = "Piratas",
      Text = se_language[se_settings.language]["PirateShip"],
      Enemy = true,
      Options = {}
    },
    AsteroidColony = {
      Name = "Colonia en asteroides",
      Text = se_language[se_settings.language]["AsteroidColonyMain"],
      Enemy = false,
      Options = {
        GiveFuel = {
          text = se_language[se_settings.language]["Givefuel"],
          static = false,
          events = {
            {
              event_text = se_language[se_settings.language]["AsteroidColonyThanks"],
              resources = {
                fuel = -5,
                health = 0,
                credits = 40,
              }
            },
            {
              event_text = se_language[se_settings.language]["AsteroidColonyLie"],
              resources = {
                fuel = -5,
                health = 0,
                credits = 0,
              }
            },
          },
        },
        FlyAway = {
          text = se_language[se_settings.language]["Deny"],
          static = false,
          events = {
            {
              event_text = se_language[se_settings.language]["AsteroidColonyNotMad"],
              resources = {
                fuel = 0,
                health = 0,
                credits = 0
              }
            },
            {
              event_text = se_language[se_settings.language]["AsteroidColonyMad"],
              resources = {
                fuel = 0,
                health = -10,
                credits = 0
              }
            },
          },
        }
      }
    },
    ShipInAsteroidBelt = {
      Name = "Nave en campo de asteroides",
      Text = se_language[se_settings.language]["ShipInAsteroidBelt"],
      Enemy = false,
      Options = {
        SaveShip = {
          -- Save the ship
          text = se_language[se_settings.language]["SaveShip"],
          static = false,
          events = {
            {
              event_text = se_language[se_settings.language]["ShipInAsteroidBeltSaved"],
              resources = {
                fuel = 5,
                health = -20,
                credits = 25,
              }
            },
            {
              event_text = se_language[se_settings.language]["ShipInAsteroidBeltNotSaved"],
              resources = {
                fuel = 0,
                health = -20,
                credits = 5,
              }
            },
          },
        },
        FlyAway = {
          text = se_language[se_settings.language]["FlyAway"],
          static = false,
          events = {
            {
              event_text = se_language[se_settings.language]["ShipInAsteroidBeltFlyAway"],
              resources = {
                fuel = 0,
                health = 0,
                credits = 0
              }
            },
          },
        }
      }
    },
    ScienceStation = {
      Name = "Estacion cientifica",
      Text = se_language[se_settings.language]["ScienceStationMain"],
      Enemy = false,
      Options = {
        TakeAPart = {
          --
          text = se_language[se_settings.language]["TakeAPart"],
          static = false,
          events = {
            {
              --
              event_text = se_language[se_settings.language]["ScienceStationMainTakeAPart"],
              resources = {
                fuel = 2,
                health = 0,
                credits = 10,
              }
            },
            {
              event_text = se_language[se_settings.language]["ScienceStationMainPirates"],
              enemy = true,
              resources = {
                fuel = 0,
                health = 0,
                credits = 0,
              }
            },
          },
        },
        FlyAway = {
          text = se_language[se_settings.language]["FlyAway"],
          static = false,
          events = {
            {
              event_text = se_language[se_settings.language]["DebyInvite"],
              resources = {
                fuel = 0,
                health = 0,
                credits = 0
              }
            },
          },
        }
      }
    },
    PiratesInAsteroids = {
      Name = "Nave pirata en asteroides",
      Text = se_language[se_settings.language]["PiratesInAsteroidsMain"],
      Enemy = false,
      Options = {
        SaveShip = {
          --
          text = se_language[se_settings.language]["SavePirateShip"],
          static = false,
          events = {
            {
              --
              event_text = se_language[se_settings.language]["PiratesInAsteroidsGrateful"],
              resources = {
                fuel = 2,
                health = 0,
                credits = 10,
              }
            },
            {
              event_text = se_language[se_settings.language]["PiratesInAsteroidsAttack"],
              enemy = true,
              resources = {
                fuel = 0,
                health = 0,
                credits = 0,
              }
            },
          },
        },
        Destroy = {
          text = se_language[se_settings.language]["DestroyThem"],
          static = false,
          events = {
            {
              event_text = se_language[se_settings.language]["PiratesInAsteroidsAttackDestroyThem"],
              resources = {
                fuel = 5,
                health = 0,
                credits = 20
              }
            },
            {
              event_text = se_language[se_settings.language]["PiratesInAsteroidsAttackDestroyThemFriends"],
              enemy = true,
              resources = {
                fuel = 5,
                health = 0,
                credits = 20
              }
            },
          },
        }
      }
    },
    FireOnScienceStation = {
      Name = "Incendio en la estacion cientifica",
      Text = se_language[se_settings.language]["FireOnScienceStationMain"],
      Enemy = false,
      Options = {
        TrySaveScientists = {
          text = se_language[se_settings.language]["TrySaveScientists"],
          static = false,
          events = {
            {
              event_text = se_language[se_settings.language]["FireOnScienceStationMainTrySaveScientistsGr"],
              resources = {
                fuel = 2,
                health = -10,
                credits = 25,
              }
            },
            {
              event_text = se_language[se_settings.language]["FireOnScienceStationMainTrySaveScientistsFail"],
              resources = {
                fuel = 0,
                health = -10,
                credits = 0,
              }
            },
            {
              event_text = se_language[se_settings.language]["FireOnScienceStationMainTrySaveScientistsPirates"],
              enemy = true,
              resources = {
                fuel = 0,
                health = 0,
                credits = 0,
              }
            },
          },
        },
        FlyAway = {
          text = se_language[se_settings.language]["Leave"],
          static = false,
          events = {
            {
              event_text = se_language[se_settings.language]["FireOnScienceStationMainLeave"],
              resources = {
                fuel = 0,
                health = 0,
                credits = 0
              }
            },
          },
        }
      }
    },
    BugsAtStation = {
      Name = "Criaturas en la estacion",
      Text = se_language[se_settings.language]["BugsAtStationMain"],
      Enemy = false,
      Options = {
        TrySavePeople = {
          text = se_language[se_settings.language]["FireOnScienceTrySavePeople"],
          static = false,
          events = {
            {
              event_text = se_language[se_settings.language]["FireOnScienceTrySavePeopleDock"],
              resources = {
                fuel = 5,
                health = 0,
                credits = 30,
              }
            },
            {
              event_text = se_language[se_settings.language]["FireOnScienceTrySavePeopleDockDead"],
              resources = {
                fuel = 1,
                health = 0,
                credits = 5,
              }
            },
          },
        },
      }
    },
    AteroidWithBugs = {
      Name = "Asteroide con criaturas",
      Text = se_language[se_settings.language]["BugsOnAsteroids"],
      Enemy = false,
      CustomFnEnabled = true,
      CustomFn = function()
        se_send_event_broadcast(3)
        local bugs_pos = {
          Vector(-1695,-1024,32),
          Vector(-1691,-907,32),
          Vector(-1691,-769,32),
          Vector(-1548,-766,32),
          Vector(-1458,-905,32),
          Vector(-1208,-927,32),
          Vector(-989,-941,32),
          Vector(-857,-791,32),
          Vector(-728,-1024,32),
          Vector(-442,-895,32),
        }
        for k, v in pairs(bugs_pos) do
          local ant = ents.Create("npc_antlion")
          ant:SetPos(v)
          ant:Spawn()
        end
      end,
      Options = {}
    },
  }
end
function se_choose_comm(choose)
  if cooldown < SysTime() and !se_comm_done then
    cooldown = SysTime() + 0.5
    local comm_event = communication_options[se_curret_comm]
    local option = comm_event.Options[choose]
    local selected_event = table.Random(option.events)
    if !option.static then
      se_comm_done = true
    end
    if selected_event.enemy then
      se_create_random_enemy_ship()
    end
    if (players_spaceship.credits + selected_event.resources.credits) >= 0 then
      players_spaceship.fuel = players_spaceship.fuel + selected_event.resources.fuel
      players_spaceship.health = players_spaceship.health + selected_event.resources.health
      players_spaceship.credits = players_spaceship.credits + selected_event.resources.credits
      if players_spaceship.fuel < 0 then
        players_spaceship.fuel = 0
      end
      if players_spaceship.health < 0 then
        players_spaceship.health = 0
      end
      if players_spaceship.health > players_spaceship.max_health then
        players_spaceship.health = players_spaceship.max_health
      end
      if selected_event.event_text != "" then
        players_spaceship.modules.Communication.ent:PrintLn(selected_event.event_text)
      end
      if selected_event.resources.fuel != 0 then
        players_spaceship.modules.Communication.ent:PrintLn(selected_event.resources.fuel .. " combustible")
      end
      if selected_event.resources.health != 0 then
        players_spaceship.modules.Communication.ent:PrintLn(selected_event.resources.health .. " salud")
      end
      if selected_event.resources.credits != 0 then
        players_spaceship.modules.Communication.ent:PrintLn(selected_event.resources.credits .. " creditos")
      end
    else
      players_spaceship.modules.Communication.ent:PrintLn("No hay creditos suficientes")
    end
    se_send_comm_state()
  end
end


function se_random_comm(star)
  local option, key = table.Random(communication_options)
  if star.type == "Shop" then
    option = communication_options.ShopSimple
    key = "ShopSimple"
  end
  se_curret_comm = key
  players_spaceship.modules.Communication.ent:PrintLn("- " .. option.Text)
  local i = 0
  for k, v in pairs(option.Options) do
    i = i + 1
    players_spaceship.modules.Communication.ent:PrintLn("  " .. i .. "." .. v.text)
  end
  if option.Enemy then
    se_create_random_enemy_ship()
  end
  if option.CustomFnEnabled then
    option.CustomFn()
  end
  se_send_comm_state()
end

net.Receive("send_my_team", function(len, ply)
  local team = net.ReadInt(8)
  ply:SetNWInt("wantrole", team)
end)
