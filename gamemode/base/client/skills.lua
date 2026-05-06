net.Receive("se_skill_update", function(_, ply)
  local skill = net.ReadString()
  if !ply:GetNWBool("SE_InSuit", false) then
    if ply:GetNWInt("se_talent_points", 0) > 0 then
      if ply.skills[skill] then
        if ply.skills[skill].level < ply.skills[skill].max then
          ply.skills[skill].level = ply.skills[skill].level + 1
          ply:GiveTalentPoints(-1)
          se_update_skills(ply)
        end
      end
    end
  else
    ply:ChatPrint("Quitate el traje espacial")
  end
end)

function se_update_skills(ply)
  local new_health = races[ply.race].health + (ply.skills.Health.level * 10)
  local new_speed_w = 200 + (ply.skills.Speed.level * 5)
  local new_speed_r = 320 + (ply.skills.Speed.level * 5)
  ply:SetWalkSpeed( new_speed_w )
  ply:SetRunSpeed( new_speed_r )

  local new_rep_ab = math.Round(races[ply.race].repair_ab + (0.2 * ply.skills.Repairing.level), 1)

  ply:SetMaxHealth(new_health)
  ply:SetNWInt("se_maxhealth", new_health)
  ply:SetHealth(new_health)
  ply:SetNWInt("repair_skills", new_rep_ab)
end
