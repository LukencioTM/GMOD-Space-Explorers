TOOL.Category = "VenceAddons"
TOOL.Name = "#tool.se_permanent_entity.name"
TOOL.Command = nil
TOOL.ConfigName = ""

if CLIENT then
  language.Add("tool.se_permanent_entity.name", "PERMANTEAR ENTIDAD")
  language.Add("tool.se_permanent_entity.desc", "Guarda una entidad fija para que reaparezca siempre en este mapa.")
  language.Add("tool.se_permanent_entity.0", "Click izquierdo: hacer permanente. Click derecho: eliminar permanente. R: actualizar permanente.")
end

local function se_can_use_permanent_tool(ply)
  if !IsValid(ply) then return false end
  if game.SinglePlayer() then return true end
  if ply:IsListenServerHost() then return true end

  return false
end

function TOOL:LeftClick(trace)
  if !IsValid(trace.Entity) or trace.Entity:IsPlayer() then return false end
  if CLIENT then return true end

  local ply = self:GetOwner()
  if !se_can_use_permanent_tool(ply) then return false end
  if !SE_MakeEntityPermanent then return false end

  local ok, message = SE_MakeEntityPermanent(trace.Entity, ply)
  if IsValid(ply) then
    ply:ChatPrint(message or (ok and "Entidad permanente guardada." or "No se pudo guardar la entidad."))
  end

  return ok
end

function TOOL:RightClick(trace)
  if !IsValid(trace.Entity) or trace.Entity:IsPlayer() then return false end
  if CLIENT then return true end

  local ply = self:GetOwner()
  if !se_can_use_permanent_tool(ply) then return false end
  if !SE_RemovePermanentEntity then return false end

  local ok, message = SE_RemovePermanentEntity(trace.Entity, ply)
  if IsValid(ply) then
    ply:ChatPrint(message or (ok and "Entidad permanente eliminada." or "No se pudo eliminar la entidad."))
  end

  return ok
end

function TOOL:Reload(trace)
  if !IsValid(trace.Entity) or trace.Entity:IsPlayer() then return false end
  if CLIENT then return true end

  local ply = self:GetOwner()
  if !se_can_use_permanent_tool(ply) then return false end
  if !SE_UpdatePermanentEntity then return false end

  local ok, message = SE_UpdatePermanentEntity(trace.Entity, ply)
  if IsValid(ply) then
    ply:ChatPrint(message or (ok and "Entidad permanente actualizada." or "No se pudo actualizar la entidad."))
  end

  return ok
end

if SERVER then
  concommand.Add("se_remove_permanent_entity", function(ply, _, args)
    if !se_can_use_permanent_tool(ply) then return end

    local ent_index = tonumber(args[1] or "")
    if !ent_index then return end

    local ent = Entity(ent_index)
    if !IsValid(ent) or !SE_RemovePermanentEntity then return end

    local ok, message = SE_RemovePermanentEntity(ent, ply)
    if IsValid(ply) then
      ply:ChatPrint(message or (ok and "Entidad permanente eliminada." or "No se pudo eliminar la entidad."))
    end
  end)
end

function TOOL.BuildCPanel(panel)
  panel:AddControl("Header", {
    Description = "Guarda entidades como parte fija del mapa. Click izquierdo guarda y congela. Click derecho elimina. R actualiza posicion, angulo, modelo, skin, color, material, submateriales y bodygroups."
  })
end
