surface.CreateFont("se_shop_title", {
  font = "Trebuchet MS",
  size = 38,
  weight = 800,
  antialias = true,
})
surface.CreateFont("se_shop_credits", {
  font = "Trebuchet MS",
  size = 24,
  weight = 600,
  antialias = true,
})
surface.CreateFont("se_shop_item_name", {
  font = "Trebuchet MS",
  size = 22,
  weight = 700,
  antialias = true,
})
surface.CreateFont("se_shop_item_price", {
  font = "Trebuchet MS",
  size = 18,
  weight = 500,
  antialias = true,
})

local blur = Material("pp/blurscreen")
local function DrawBlur(panel, amount)
  local x, y = panel:LocalToScreen(0, 0)
  surface.SetDrawColor(255, 255, 255)
  surface.SetMaterial(blur)
  for i = 1, 3 do
    blur:SetFloat("$blur", (i / 3) * (amount or 6))
    blur:Recompute()
    render.UpdateScreenEffectTexture()
    surface.DrawTexturedRect(x * -1, y * -1, ScrW(), ScrH())
  end
end

net.Receive("se_open_npc_shop", function()
  local ent = net.ReadEntity()
  local shop = net.ReadTable()
  local credits = net.ReadInt(32)

  local se_shop_main = vgui.Create( "DFrame" )
  se_shop_main:SetSize(700, 600)
  se_shop_main:Center()
  se_shop_main:SetDraggable( true )
  se_shop_main:MakePopup()
  se_shop_main:SetTitle( "" )
  se_shop_main:ShowCloseButton( false )
  
  se_shop_main.Paint = function(self, w, h)
    DrawBlur(self, 5)
    draw.RoundedBox( 8, 0, 0, w, h, Color(15, 20, 30, 230) )
    draw.RoundedBoxEx( 8, 0, 0, w, 80, Color(25, 35, 55, 250), true, true, false, false )
    
    -- Decorative tech lines
    surface.SetDrawColor(80, 180, 255, 100)
    surface.DrawRect(0, 78, w, 2)
    surface.SetDrawColor(80, 180, 255, 30)
    surface.DrawRect(20, h - 20, w - 40, 1)

    draw.SimpleText( "MERCADO ESTELAR", "se_shop_title", 30, 40, Color(230, 245, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
    
    -- Credits box
    draw.RoundedBox( 6, w - 220, 20, 180, 40, Color(10, 15, 20, 200) )
    draw.SimpleText( string.Comma(credits) .. " CR", "se_shop_credits", w - 130, 40, Color(100, 220, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
  end

  local close_btn = vgui.Create( "DButton", se_shop_main )
  close_btn:SetSize( 40, 40 )
  close_btn:SetPos( se_shop_main:GetWide() - 40, 0 )
  close_btn:SetText( "" )
  close_btn.Paint = function(self, w, h)
    if self:IsHovered() then
      draw.RoundedBoxEx( 8, 0, 0, w, h, Color(220, 50, 50, 200), false, true, false, false )
    end
    draw.SimpleText( "X", "se_shop_credits", w/2, h/2, Color(255, 255, 255, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
  end
  close_btn.DoClick = function()
    se_shop_main:Close()
  end

  local scroll = vgui.Create( "DScrollPanel", se_shop_main )
  scroll:Dock( FILL )
  scroll:DockMargin( 20, 90, 20, 30 )
  
  local sbar = scroll:GetVBar()
  function sbar:Paint(w, h)
    draw.RoundedBox(4, 0, 0, w, h, Color(10, 15, 25, 150))
  end
  function sbar.btnUp:Paint(w, h) end
  function sbar.btnDown:Paint(w, h) end
  function sbar.btnGrip:Paint(w, h)
    draw.RoundedBox(4, 2, 0, w-4, h, Color(80, 140, 200, 150))
  end

  for k, item in pairs(shop) do
    local item_pnl = scroll:Add( "DPanel" )
    item_pnl:Dock( TOP )
    item_pnl:SetTall( 70 )
    item_pnl:DockMargin( 0, 0, 10, 10 )
    
    local can_afford = credits >= item.Price
    local hover_frac = 0

    item_pnl.Paint = function(self, w, h)
      local is_hovered = self:IsHovered() or self:IsChildHovered()
      hover_frac = math.Approach(hover_frac, is_hovered and 1 or 0, FrameTime() * 8)
      
      local bg_color = can_afford and Color(30, 45, 65, 200) or Color(40, 25, 25, 200)
      local hover_color = can_afford and Color(50, 80, 120, 250) or Color(70, 30, 30, 250)
      
      local col = Color(
        Lerp(hover_frac, bg_color.r, hover_color.r),
        Lerp(hover_frac, bg_color.g, hover_color.g),
        Lerp(hover_frac, bg_color.b, hover_color.b),
        Lerp(hover_frac, bg_color.a, hover_color.a)
      )
      
      draw.RoundedBox( 6, 0, 0, w, h, col )
      
      -- Left accent line
      draw.RoundedBoxEx( 6, 0, 0, 6, h, can_afford and Color(80, 180, 255) or Color(255, 80, 80), true, false, true, false )

      draw.SimpleText( item.Name, "se_shop_item_name", 25, h/2 - 12, Color(240, 245, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
      draw.SimpleText( "Adquisición de tecnología", "se_shop_item_price", 25, h/2 + 12, Color(150, 170, 190), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
    end

    local buy_btn = vgui.Create( "DButton", item_pnl )
    buy_btn:Dock( RIGHT )
    buy_btn:SetWide( 140 )
    buy_btn:DockMargin( 10, 15, 15, 15 )
    buy_btn:SetText( "" )
    
    buy_btn.Paint = function(self, w, h)
      if can_afford then
        if self:IsHovered() then
          draw.RoundedBox( 4, 0, 0, w, h, Color(80, 200, 120, 255) )
          draw.SimpleText( string.Comma(item.Price) .. " CR", "se_shop_item_name", w/2, h/2, Color(20, 50, 30), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        else
          draw.RoundedBox( 4, 0, 0, w, h, Color(20, 30, 40, 250) )
          surface.SetDrawColor(80, 200, 120, 150)
          surface.DrawOutlinedRect(0, 0, w, h, 1)
          draw.SimpleText( string.Comma(item.Price) .. " CR", "se_shop_item_name", w/2, h/2, Color(80, 200, 120), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
      else
        draw.RoundedBox( 4, 0, 0, w, h, Color(30, 20, 20, 200) )
        draw.SimpleText( string.Comma(item.Price) .. " CR", "se_shop_item_name", w/2, h/2, Color(150, 80, 80), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
      end
    end
    
    buy_btn.DoClick = function()
      if can_afford then
        net.Start("se_buy_item")
        net.WriteEntity(ent)
        net.WriteInt(k, 8)
        net.SendToServer()
        
        surface.PlaySound("UI/buttonclick.wav")
        
        if item.Close then
          se_shop_main:Close()
        end
        if LocalPlayer():GetNWBool("se_shopping_enabled", false) then
          credits = credits - item.Price
        end
        
        -- Force re-evaluation of affordability for all items
        for _, pnl in ipairs(scroll:GetCanvas():GetChildren()) do
           pnl:InvalidateLayout()
        end
      else
        surface.PlaySound("buttons/button10.wav")
      end
    end
  end
end)
