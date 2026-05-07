function se_send_event(ply, id)
  net.Start("se_event_simple")
  net.WriteInt(id, 8)
  net.Send(ply)
end

function se_send_event_broadcast(id)
  net.Start("se_event_simple")
  net.WriteInt(id, 8)
  net.Broadcast()
end

function se_update_enemy_sprite(exists, shields, health)
  local sprite_info = {
    Exists = exists,
    Shields = shields,
    Health = health
  }
  net.Start("se_update_enemy_sprite")
  net.WriteTable(sprite_info)
  net.Broadcast()
end

net.Receive("se_open_scoreboard", function(_, ply)
  net.Start("se_open_scoreboard")
  net.WriteTable(ply.skills)
  net.WriteTable(se_star_map)
  net.Send(ply)
end)
