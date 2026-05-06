local names_first = {
  "Alpha",
  "Beta",
  "Ultra",
  "Omega",
  "Semi",
  "Great",
  "Medi",
  "Hopeless",
  "WISE",
  "Sirius",
  "DEN",
  "Delta",
  "Wanker",
  "Epsilon"
}

local names_second = {
  "Centauri",
  "Aquarii",
  "Cygni",
  "Procyon",
  "Ceti",
  "Tauri",
  "645",
  "789"
}

function se_gen_system_name()
  return table.Random(names_first).." "..table.Random(names_second)
end
