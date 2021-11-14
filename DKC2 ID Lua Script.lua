function DKC2()
	local scount = 0
	local cx = memory.readwordsigned(0x7E17BA)
	local cy = memory.readwordsigned(0x7E17C0)
	local x = memory.readword(0x7E0A2A)
	local y = memory.readword(0x7E0A2C)
	local spx = memory.readwordsigned(0x7E0A30)
	local spy1 = memory.readwordsigned(0x7E0E06)
	local spy2 = memory.readwordsigned(0x7E0E64)
	local saru = memory.readbyte(0x7E08A4)
	local hold = memory.readword(0x7E0D7A)
	if hold == 0 then
		disphold = 0
	else
		disphold = 1
	end
	for id = 0, 21 do
			local stat = memory.readword(0x7E0E9E+id*94)
			local sx = memory.readword(0x7E0EA4+id*94)
			local sy = memory.readword(0x7E0EA8+id*94)
			local sspx = memory.readwordsigned(0x7E0EBE+id*94)
			local sspy = memory.readwordsigned(0x7E0EC2+id*94)
			local num = memory.readword(0x7E0ED4+id*94)

			if id < 7 then
				if stat ~= 0 then
					gui.opacity(0.7)
				else
					gui.opacity(0.2)
				end
				gui.text(2, 80+id*8, string.format("%d(%x, %d, %d)", id, num, sx, sy))	
			end

			gui.opacity(0.7)
			if stat ~= 0 then 
				gui.text(sx-cx-4, sy-cy-(id%4)*8, string.format("%d (%x)", id, num))
				scount = scount + 1
			end
	end


	if saru == 0 then
		spy = spy1
	else
		spy = spy2
	end
	gui.text(2, 150+0*8, string.format("speed: %d, %d", spx, spy))
	gui.text(2, 150+1*8, string.format("position: %d, %d", x, y))
	if disphold == 1 then
		gui.text(2, 50, string.format("Holding ID: %d", (hold-3742)/94))
	end
	gui.text(254-24, 2, string.format("SPR:%02d", scount))
end
gui.register(DKC2)