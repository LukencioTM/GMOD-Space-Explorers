GM.Version = "0.1.0"
GM.Name = "Space Explorers"
GM.Author = "The HellBox"

DeriveGamemode("sandbox")

include("base/client/ship_state_update.lua")
include("base/client/race_choose_menu.lua")
include("base/client/draw_space_body.lua")
include("base/client/ship_uis.lua")
include("base/client/hud.lua")

include("lib/draw.lua")
include("lib/support.lua")

net.Receive("se_chat_message", function()
  local ply = net.ReadEntity()
  local text = net.ReadString()
  local teamonly = net.ReadBool()

  local name = IsValid(ply) and ply:Nick() or "Jugador"
  local name_color = IsValid(ply) and team.GetColor(ply:Team()) or Color(180, 180, 180)

  if teamonly then
    chat.AddText(Color(120, 200, 120), "(Equipo) ", name_color, name, Color(255, 255, 255), ": " .. text)
  else
    chat.AddText(name_color, name, Color(255, 255, 255), ": " .. text)
  end
end)

hook.Add( "CreateClientsideRagdoll", "se_fade_out_corpses", function( entity, ragdoll )
  timer.Simple(10, function()
    if IsValid(ragdoll) then
      ragdoll:SetSaveValue( "m_bFadingOut", true )
    end
  end)
end )

-------------------------- SANDBOX --------------------------

-- Bloquear el Menú Q (Spawnmenu)
function GM:OnSpawnMenuOpen()
    if not GetGlobalBool("se_sandbox_enabled", false) then 
        return false -- Devuelve falso para impedir que se abra
    end
    -- Si está activado, dejamos que el Sandbox lo abra normalmente
    return self.BaseClass.OnSpawnMenuOpen(self)
end

-- Bloquear el Menú C (Context Menu, donde cambias colores y materiales)
function GM:OnContextMenuOpen()
    if not GetGlobalBool("se_sandbox_enabled", false) then 
        return false 
    end
    return self.BaseClass.OnContextMenuOpen(self)
end