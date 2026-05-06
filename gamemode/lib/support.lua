function SliceTable(tbl, first, last, step)
  local sliced = {}

  for i = first or 1, last or #tbl, step or 1 do
    sliced[#sliced+1] = tbl[i]
  end

  return sliced
end

-- I took that from DarkRP, hope it's ok
-- https://github.com/FPtje/DarkRP/blob/fd95cf68e6a01a1b0522c4a989d4512fc0fb202d/gamemode/modules/base/cl_util.lua#L42
function textWrap(text, font, pxWidth)
    local total = 0

    surface.SetFont(font)

    local spaceSize = surface.GetTextSize(' ')
    text = text:gsub("(%s?[%S]+)", function(word)
            local char = string.sub(word, 1, 1)
            if char == "\n" or char == "\t" then
                total = 0
            end

            local wordlen = surface.GetTextSize(word)
            total = total + wordlen

            -- Wrap around when the max width is reached
            if wordlen >= pxWidth then -- Split the word if the word is too big
                local splitWord, splitPoint = charWrap(word, pxWidth - (total - wordlen))
                total = splitPoint
                return splitWord
            elseif total < pxWidth then
                return word
            end

            -- Split before the word
            if char == ' ' then
                total = wordlen - spaceSize
                return '\n' .. string.sub(word, 2)
            end

            total = wordlen
            return '\n' .. word
        end)

    return text
end


function se_create_progress_bar(ent, time, elements)
  ent:PrintLn("")
  local i = 0
  timer.Create("se_progress_bar"..math.random(0, 999), time, elements, function()
    i = i + 1
    local text = "["
    for k = 0,elements do
      if k <= i then
        text = text.."#"
      else
        text = text.."_"
      end
    end
    text = text.."]"
    ent:ChangeLine(text, 0)
  end)
end
