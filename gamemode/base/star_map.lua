function se_find_close_star(from, expect)
  local highest = 10000
  local star = nil
  for k, v in pairs( se_star_map.stars ) do
    local distance = Vector(from.pos[1], from.pos[2]):Distance(Vector(v.pos[1], v.pos[2]))
    if distance < highest and v != from and !table.HasValue(expect, v) then
      star = k
      highest = distance
    end
  end
  return star
end

function se_send_star_map(ply)
  if !se_star_map then return end

  net.Start("se_update_star_map")
  net.WriteTable(se_star_map)
  if IsValid(ply) then
    net.Send(ply)
  else
    net.Broadcast()
  end
end

function se_gen_star_map()
  se_star_map = {}
  se_star_map.stars = {}
  se_star_map.player_pos = 1
  se_star_map.star_choosed = -1
  for k = 0, math.random(3, 12) do
    local star = {
      pos = {math.random(0, 100), math.random(0, 100)},
      type = "Unknow",
      connects_to = {},
      close = false
    }
    if math.random(0, 10) > 8 then
      star.type = "Shop"
    end
    if math.random(0, 10) > 8 then
      star.type = "Station"
    end
    table.insert(se_star_map.stars, star)
  end
  -- Connecting stars to each other
  local star = 1
  local stars = {}
  local iters = 0
  se_star_map.stars[se_star_map.player_pos].explored = true
  se_star_map.stars[se_star_map.player_pos].type = "Unknow"
  while true do
    iters = iters + 1
    if iters > 100 then
      print("Anti-bug system detected a critical issue in se_gen_star_map(). Please report this to the developer.")
      break
    end
    local star_old = star
    star = se_find_close_star(se_star_map.stars[star], stars)
    if star != nil then
      table.insert(se_star_map.stars[star_old].connects_to, star )
      table.insert(se_star_map.stars[star].connects_to, star_old )
      table.insert(stars, se_star_map.stars[star])
    else
      break
    end
  end
  se_star_map.stars[#se_star_map.stars].type = "Exit"
  se_send_star_map()
end

net.Receive("se_choose_star", function(_, ply)
  local indx = net.ReadInt(8)
  if table.HasValue(se_star_map.stars[indx].connects_to, se_star_map.player_pos) then
    se_star_map.star_choosed = indx
    se_send_star_map()
  end
end)

net.Receive("se_jump_to_next_sector", function(_, ply)
  if se_star_map.stars[se_star_map.player_pos].type == "Exit" then
    se_fractions.Mission = false
    se_global_sectors = se_global_sectors + 1
    se_gen_star_map()
  end
end)
