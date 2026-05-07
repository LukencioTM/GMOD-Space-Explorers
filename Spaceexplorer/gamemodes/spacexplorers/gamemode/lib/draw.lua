function draw_frame(w, h)
  draw.RoundedBox( 0, 0, 0, w, h, Color(10, 10, 50, 200) )
end

function draw_button_default(w, h)
  draw.RoundedBox( 0, 0, 0, w, h, Color(10, 10, 80, 200) )
end

function draw_panel(w, h)
  draw.RoundedBox( 0, 0, 0, w, h, Color(10, 10, 40, 200) )
end

function drawCircle( x, y, radius, seg, color )
  surface.SetDrawColor( color.r, color.g, color.b, color.a )
  draw.NoTexture()

	local cir = {}

	table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
	for i = 0, seg do
		local a = math.rad( ( i / seg ) * -360 )
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	end

	local a = math.rad( 0 ) -- This is needed for non absolute segment counts
	table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

	surface.DrawPoly( cir )
end
