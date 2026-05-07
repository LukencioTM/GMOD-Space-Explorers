se_terminal_history = {}

surface.CreateFont("TerminalFont", {
  size = 22,
  antialias = false,
  font = "Arial"
} );

surface.CreateFont("se_map_font", {
  size = 18,
  antialias = false,
  font = "Arial"
} );

net.Receive("se_terminal_println", function()
  local entity = net.ReadEntity()
  local line = net.ReadString()
  entity:PrintLn(line)
end)

net.Receive("se_terminal_print", function()
  local entity = net.ReadEntity()
  local line = net.ReadString()
  entity:Print(line)
end)

net.Receive("se_terminal_changeline", function()
  local entity = net.ReadEntity()
  local line = net.ReadString()
  local index = net.ReadInt(32)
  entity:ChangeLine(line, index)
end)

net.Receive("se_terminal_clear", function()
  local entity = net.ReadEntity()
  entity:ClearLines()
end)

function se_open_terminal_text_entry(entity)
  if !IsValid(entity) then return end

  local index = 0
  local cooldown = SysTime()
  TextEntry = vgui.Create("DTextEntry")
  TextEntry:SetPos(0, 0)
  TextEntry:SetSize(0, 0)
  TextEntry:MakePopup()
  function TextEntry:Think()
    local text = string.ToTable( self:GetValue() )
    table.insert(text, TextEntry:GetCaretPos() + 1, "|")
    local final_text = ""
    for k, v in ipairs(text) do
      final_text = final_text .. v
    end
    entity:UserInput(LocalPlayer():Name() .. ":/ " .. final_text)
    if !LocalPlayer():Alive() or LocalPlayer():GetPos():Distance(entity:GetPos()) > 300 then
      self:Remove()
    end
    if input.IsButtonDown( KEY_UP  ) and SysTime() > cooldown then
      cooldown = SysTime() + 0.3
      if se_terminal_history[#se_terminal_history - index] then
        TextEntry:SetText(se_terminal_history[#se_terminal_history - index])
        TextEntry:SetCaretPos( #se_terminal_history[#se_terminal_history - index]  )
        index = index + 1
      end
    end
    if input.IsButtonDown( KEY_DOWN  ) and SysTime() > cooldown then
      cooldown = SysTime() + 0.3
      index = index - 1
      if se_terminal_history[#se_terminal_history - index] then
        TextEntry:SetText(se_terminal_history[#se_terminal_history - index] or "")
        TextEntry:SetCaretPos( #se_terminal_history  )
      end
    end
  end
  function TextEntry:OnEnter()
    local text = self:GetValue()
    if text == "exit" then
      self:Remove()
    end
    if text != "" then
      table.insert(se_terminal_history, text)
      index = 0
      entity:UserInput(LocalPlayer():Name() .. ":/ ")
      self:SetText("")
      net.Start("se_terminal_send_input")
      net.WriteEntity(entity)
      net.WriteString(text)
      net.SendToServer()
    else
      self:Remove()
    end
  end
end

net.Receive("se_terminal_start_type", function()
  local entity = net.ReadEntity()
  se_open_terminal_text_entry(entity)
end)
