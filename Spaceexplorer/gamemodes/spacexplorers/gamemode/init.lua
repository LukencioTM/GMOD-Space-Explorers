-- Space Explorers. Gamemode made by The HellBox.
-- Use the code as you want, just don't forget that orginally gamemode was made by me.
-- If you want to contribute, feel free. But if you want to change something(Not just bug fixing), contact with me before pull request [thehellbox11@gmail.com]

-- About comments, I made them AFTER I wrote all the code, so they can be wrong in some places
resource.AddWorkshop( "1590745371" )

-- Heredamos del Sandbox
DeriveGamemode("sandbox")

space_explorers = {}

-- Init all NetWorkStrings
util.AddNetworkString( "se_change_module_ui" )
util.AddNetworkString( "se_choose_race" )
util.AddNetworkString( "se_race_choosen" )
util.AddNetworkString( "se_charge_drive" )
util.AddNetworkString( "se_try_jump" )
util.AddNetworkString( "se_event_simple" )
util.AddNetworkString( "se_terminal_start_type" )
util.AddNetworkString( "se_terminal_send_input" )
util.AddNetworkString( "se_terminal_println" )
util.AddNetworkString( "se_terminal_print" )
util.AddNetworkString( "se_terminal_clear" )
util.AddNetworkString( "se_terminal_changeline" )
util.AddNetworkString( "se_wear_suit" )
util.AddNetworkString( "se_open_scoreboard" )
util.AddNetworkString( "se_skill_update" )
util.AddNetworkString( "se_update_space_body" )
util.AddNetworkString( "se_update_enemy_sprite" )
util.AddNetworkString( "se_open_npc_shop" )
util.AddNetworkString( "se_buy_item" )
util.AddNetworkString( "se_open_pilot_camera" )
util.AddNetworkString( "se_update_ship_pos" )
util.AddNetworkString( "se_update_ship_angle" )
util.AddNetworkString( "se_choose_star" )
util.AddNetworkString( "se_jump_to_next_sector" )
util.AddNetworkString( "se_update_star_map" )
util.AddNetworkString( "se_open_fractions_npc" )
util.AddNetworkString( "se_change_fraction" )
util.AddNetworkString( "se_take_mission" )
util.AddNetworkString( "se_update_enemy_state" )
util.AddNetworkString( "se_send_ship_state" )
util.AddNetworkString( "se_send_planet_info" )
util.AddNetworkString( "se_disembark_countdown" )
util.AddNetworkString( "se_disembark_fade" )
util.AddNetworkString( "se_update_comm_state" )
util.AddNetworkString( "se_change_lang" )
util.AddNetworkString( "se_make_captain" )
util.AddNetworkString( "se_game_losed" )
util.AddNetworkString( "se_load_game" )
util.AddNetworkString( "se_save_game" )
util.AddNetworkString( "se_request_save_list" )
util.AddNetworkString( "se_send_save_list" )
util.AddNetworkString( "se_save_game_result" )
util.AddNetworkString( "se_enable_shopping" )
util.AddNetworkString( "se_chat_message" )
util.AddNetworkString( "se_delete_save_game" )

-- Include libs
include("lib/name_gen.lua")
include("lib/races.lua")
include("lib/draw.lua")
include("lib/player_lib.lua")
include("lib/events_simple.lua")
include("lib/support.lua")

-- Include base
include("base/se_lang_es.lua")
include("base/se_lang_en.lua")
include("base/se_lang_ru.lua")
include("base/se_settings.lua")
include("base/communication_options.lua")
include("base/skills.lua")
include("base/weapons.lua")
include("base/ship.lua")
include("base/races.lua")
include("base/enemy_ships.lua")
include("base/asteroid_maining.lua")
include("base/terminal_commands.lua")
include("base/planets.lua")
include("base/shop_npc.lua")
include("base/star_map.lua")
include("base/fractions.lua")

-- AddCSLuaFile(Make client download all client side scripts)
AddCSLuaFile("base/client/ship_state_update.lua")
AddCSLuaFile("base/client/race_choose_menu.lua")
AddCSLuaFile("base/client/ship_uis.lua")
AddCSLuaFile("base/client/draw_space_body.lua")
AddCSLuaFile("base/client/hud.lua")
AddCSLuaFile("base/client/shop_npc.lua")
AddCSLuaFile("base/client/fractions_ui.lua")
AddCSLuaFile("base/client/scoreboard.lua")
AddCSLuaFile("base/client/lose_menu.lua")
AddCSLuaFile("lib/support.lua")
AddCSLuaFile("lib/draw.lua")

-- Comando generador de naves enemigas (llama a la funcion "se_create_random_enemy_ship" en gamemodes/base/enemy_ships.lua)
concommand.Add("se_generate_enemy_ship", se_create_random_enemy_ship)

concommand.Add("se_destroy_enemy_ship", se_destroy_enemy_ship)

local function se_give_credits_cmd(ply, _, args)
  if !se_is_sandbox_host(ply) and (IsValid(ply) and not ply:IsAdmin()) then
    if IsValid(ply) then
      ply:ChatPrint("Solo el host o admins pueden usar este comando.")
    end
    return
  end

  local amount = tonumber(args[1]) or 100
  if players_spaceship then
    players_spaceship.credits = players_spaceship.credits + amount
    se_send_ship_state()
    if IsValid(ply) then
      ply:ChatPrint("Se han añadido " .. amount .. " creditos a la nave.")
    end
  end
end
concommand.Add("se_give_credits", se_give_credits_cmd)

function GM:PlayerSpawn( ply )
  ply:SetTeam(123)
  ply.on_planet = false
  ply:SetNoCollideWithTeammates(true)
  
  local steam_id = ply:SteamID64() or ply:SteamID()
  
  if se_global_players_save and se_global_players_save[steam_id] then
    local saved = se_global_players_save[steam_id]
    ply.race = saved.race or "Humans"
    ply.shopping_enabled = saved.shopping_enabled or false
    ply:SetNWBool("se_shopping_enabled", ply.shopping_enabled)
    ply.is_captain = saved.is_captain or false
    ply:SetNWBool("se_is_сaptain", ply.is_captain)
    ply:SetNWInt("se_talent_points", saved.talent_points or 0)
    
    if saved.skills then
      ply.skills = table.Copy(saved.skills)
    end
    se_update_skills(ply)
    
    if races and races[ply.race] then
      space_explorers_change_race(ply, ply.race)
    else
      ply:SetModel("models/player/kleiner.mdl")
    end
    ply:WearSuit(saved.in_suit or false)
    
    if saved.health and saved.health > 0 then
      ply:SetHealth(math.Clamp(saved.health, 1, ply:GetMaxHealth()))
    end
  else
    ply.race = "Humans"
    ply:SetModel("models/player/kleiner.mdl")
    ply:WearSuit(false)
    ply:ChooseRace()
    
    if player.GetCount() == 1 then
      ply:SetNWBool("se_is_сaptain", true)
      ply:SetNWBool("se_shopping_enabled", true)
      ply.is_captain = true
      ply.shopping_enabled = true
    end
  end

  for k, v in pairs(player.GetAll()) do
     v:ChatPrint( ply:Nick() .. " ha aparecido." )
  end

  local hands = ents.Create( "gmod_hands" )
  if ( IsValid( hands ) ) then
      hands:DoSetup( ply )
      hands:Spawn()
  end
  if ply:GetNWBool("se_sandbox_enabled", false) then
    timer.Simple(0, function()
      se_give_sandbox_tools(ply)
    end)
  end
end

function GM:PlayerInitialSpawn( ply )
  -- There we just print some info about gamemode and doSetCustomCollisionCheck(For disabling collision) and SetupSkills(lib/player_lib.lua)
  ply:SetCustomCollisionCheck(true)
  ply:SetupSkills()
  ply:ChatPrint("---------------------------------------------------")
  ply:ChatPrint("Space Explorers. Gamemode creado por The HellBox")
  ply:ChatPrint("Agradecimientos especiales a: ")
  ply:ChatPrint("-    Niteko - por crear el prototipo del mapa")
  ply:ChatPrint("-    Klark - por ayudar con la traduccion")
  ply:ChatPrint("---------------------------------------------------")
  timer.Simple(2, function()
    if IsValid(ply) and se_send_star_map then
      se_send_star_map(ply)
    end
  end)
end

function GM:Initialize()
  se_init_comms()
  -- I don't remember why I made custom team for players, but I don't want to break anything
  team.SetUp( 123, "Players", Color( 255, 0, 0 ) )
end

function GM:PlayerSay(ply, text, teamonly)
  text = string.Trim(text or "")
  if text == "" then return "" end

  net.Start("se_chat_message")
  net.WriteEntity(ply)
  net.WriteString(text)
  net.WriteBool(teamonly)

  if teamonly then
    local recipients = {}
    for _, other_ply in ipairs(player.GetAll()) do
      if other_ply:Team() == ply:Team() then
        recipients[#recipients + 1] = other_ply
      end
    end
    net.Send(recipients)
  else
    net.Broadcast()
  end

  return ""
end

function GM:InitPostEntity()
  -- Generating star map
  se_gen_star_map()
  -- Initialiazing players spaceship
  se_init_ship()
  -- Initialiazing teleports on the planets
  se_init_teleports()
  -- Init fractions
  se_init_fractions()
  -- Create timer for ship update
  timer.Create("se_ship_update", 1, 0, se_ship_update)
end

function GM:Think()
  -- Reset timer if something fails
  if !timer.Exists("se_ship_update") then
    timer.Create("se_ship_update", 1, 0, se_ship_update)
  end
end

hook.Add("ShouldCollide","se_nocollide_player",function(a,b)
  -- Disable collision and damage
  if a:IsPlayer() and b:IsPlayer() then
    return false
  end
  if a:IsNPC() and b:IsNPC() then
    return false
  end
end)

function se_change_lang(lang)
  print("El idioma fue cambiado a " .. lang)
  se_settings.language = lang
  se_init_comms()
end

net.Receive("se_change_lang", function(_, ply)
  local lang = net.ReadString()
  if !ply.is_captain then ply:ChatPrint("Solo el capitan puede cambiar el idioma") return end
  if se_language[lang] != nil then
    se_change_lang(lang)
  end
end)

net.Receive("se_load_game", function(_, ply)
  if !ply.is_captain then ply:ChatPrint("Solo el capitan puede cargar la partida") return end
  local save_id = net.ReadString()
  se_load_game(save_id, ply)
end)
net.Receive("se_save_game", function(_, ply)
  if !ply.is_captain then ply:ChatPrint("Solo el capitan puede guardar la partida") return end
  local save_name = net.ReadString()
  se_save_game(save_name, ply)
end)
net.Receive("se_request_save_list", function(_, ply)
  if !ply.is_captain then ply:ChatPrint("Solo el capitan puede cargar la partida") return end
  se_send_save_list(ply)
end)
net.Receive("se_delete_save_game", function(_, ply)
  if !ply.is_captain then ply:ChatPrint("Solo el capitan puede borrar la partida") return end
  local save_id = net.ReadString()
  se_delete_save_game(save_id, ply)
end)
net.Receive("se_enable_shopping", function(_, ply)
  local pl = net.ReadEntity()
  local enabled = net.ReadBool()
  if !ply.is_captain then ply:ChatPrint("Solo el capitan puede hacer esto") return end
  pl:SetNWBool("se_shopping_enabled", enabled)
  pl.shopping_enabled = enabled
end)

net.Receive("se_make_captain", function(_, ply)
  local new_captain = net.ReadEntity()
  if IsValid(new_captain) and new_captain:IsPlayer() and ply.is_captain then
    ply:SetNWBool("se_is_сaptain", false)
    ply.is_captain = false

    new_captain:SetNWBool("se_is_сaptain", true)
    new_captain.is_captain = true
  end
end)

hook.Add("PlayerDisconnected", "SE_SavePlayerState", function(ply)
  se_global_players_save = se_global_players_save or {}
  local steam_id = ply:SteamID64() or ply:SteamID()
  
  se_global_players_save[steam_id] = {
    name = ply:Nick(),
    race = ply.race,
    health = ply:Health(),
    skills = table.Copy(ply.skills or {}),
    talent_points = ply:GetNWInt("se_talent_points", 0),
    shopping_enabled = ply.shopping_enabled,
    is_captain = ply.is_captain,
    in_suit = ply:GetNWBool("SE_InSuit", false),
    on_planet = ply.on_planet
  }
end)

-------------------------- SANDBOX --------------------------

-- Tu comando limpio y optimizado
local function se_set_sandbox_mode(ply, cmd, args)
    -- Asumo que tienes tu función de seguridad en algún lado
    if not ply:IsAdmin() then 
        ply:ChatPrint("Solo los administradores pueden usar se_sandbox.")
        return 
    end

    -- Leemos el estado actual global y lo invertimos
    local currentState = GetGlobalBool("se_sandbox_enabled", false)
    SetGlobalBool("se_sandbox_enabled", not currentState)

    if GetGlobalBool("se_sandbox_enabled") then
        PrintMessage(HUD_PRINTTALK, "Modo Sandbox ACTIVADO.")
        -- Opcional: Dar las herramientas inmediatamente
        ply:Give("weapon_physgun")
        ply:Give("gmod_tool")
    else
        PrintMessage(HUD_PRINTTALK, "Modo Sandbox DESACTIVADO.")
        -- Opcional: Quitar las herramientas
        ply:StripWeapon("weapon_physgun")
        ply:StripWeapon("gmod_tool")
    end
end
concommand.Add("se_sandbox", se_set_sandbox_mode)

-- === LOS BLOQUEOS (AQUÍ OCURRE LA MAGIA) ===

-- Bloquear Spawn de Props (Modelos)
function GM:PlayerSpawnProp(ply, model)
    if not GetGlobalBool("se_sandbox_enabled", false) then return false end
    return self.BaseClass.PlayerSpawnProp(self, ply, model)
end

-- Bloquear Spawn de NPCs
function GM:PlayerSpawnNPC(ply, npc, tr)
    if not GetGlobalBool("se_sandbox_enabled", false) then return false end
    return self.BaseClass.PlayerSpawnNPC(self, ply, npc, tr)
end

-- Bloquear Spawn de Armas/Entidades
function GM:PlayerSpawnSWEP(ply, weapon, info)
    if not GetGlobalBool("se_sandbox_enabled", false) then return false end
    return self.BaseClass.PlayerSpawnSWEP(self, ply, weapon, info)
end

-- Bloquear el uso de la Toolgun (Herramientas)
function GM:CanTool(ply, tr, toolname)
    if not GetGlobalBool("se_sandbox_enabled", false) then return false end
    return self.BaseClass.CanTool(self, ply, tr, toolname)
end