--Donkey Kong Country 2 BizHawk TAS script
def_txt_color = 0x80ffffff
def_txt_color_deep = 0xc0ffffff

spr_data_size = 94
xm = client.screenwidth() / 256
ym = client.screenheight() / 224

-- FORM
local hndl=forms.newform(300,250,"Donkey Kong Country 2")
local hide_spr_data = forms.checkbox(hndl,"hide sprite data",10,0)
local spr_num_label = forms.label(hndl,"num:",140,7,30,15)
local disp_spr_num = forms.textbox(hndl,"7",30,20,"UNSIGNED",170,5)
forms.setproperty(hide_spr_data, "Checked",false)

local disp_all_spr_data = forms.label(hndl,"display all data of selected sprite",10,30,190,15)
local selected_spr = forms.textbox(hndl,"",30,20,"UNSIGNED",200,30)
local disp_spr_data = {
	forms.label(hndl,"00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00",10,50,300,15),
	forms.label(hndl,"00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00",10,70,300,15),
	forms.label(hndl,"00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00",10,90,300,15),
	forms.label(hndl,"00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00",10,110,300,15),
	forms.label(hndl,"00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00",10,130,300,15),
	forms.label(hndl,"00 00 00 00 00 00 00 00 00 00 00 00 00 00",10,150,300,15)
}

local hide_pos_data = forms.checkbox(hndl,"hide position data",10,170)
forms.setproperty(hide_pos_data,"Checked",false)

local ghost_display = forms.checkbox(hndl,"display ghost",10,190)
forms.setproperty(ghost_display,"Checked",false)

--forms.destroy(hndl)

-- LAG
local cur_lag
local prev_lag = 0
local laglength = 0
local laglength_display = 0
local lag_frame = {0,0,0}
local lag_frame_idx = 0

-- for GHOST
local filepath='ghosts/DKC2 1.1 Any% TAS - Comicalflop - Dooty - Umihoshi.dump'
local ddposepath='ghosts/DDtp.png'
local dxposepath='ghosts/DXtp.png'
local in_game_frame=0
local action_frame=0
local level=0
local room=0
local change_igframe = 0
local file_open = 0

local function draw_hitbox(boxid, direct, xpos, ypos, cam_x, cam_y, type)

--	memory.usememorydomain("System Bus")
--	local offset = memory.read_u16_le(0xbcb600 + bit.rshift(boxid, 1))
--	local xoff = memory.read_s16_le(0xbc0000 + offset)
--	local yoff = memory.read_s16_le(0xbc0002 + offset)
--	local width = memory.read_s16_le(0xbc0004 + offset)
--	local height = memory.read_s16_le(0xbc0006 + offset)
	memory.usememorydomain("CARTROM")
	local offset = memory.read_u16_le(0x3cb600 + bit.rshift(boxid, 1))
	local xoff = memory.read_s16_le(0x3c0000 + offset)
	local yoff = memory.read_s16_le(0x3c0002 + offset)
	local width = memory.read_s16_le(0x3c0004 + offset)
	local height = memory.read_s16_le(0x3c0006 + offset)
	memory.usememorydomain("WRAM")
	if bit.check(direct, 6) == true then
		xoff = - xoff
		width = - width
	end
	if bit.check(direct, 7) == true then
		yoff = - yoff
		height = - height
	end

	local x_screen = xpos - cam_x
	local y_screen = ypos - cam_y
	local color
	if type == 0xFFFF then
		color = 0x0000FF
	elseif type == 0x02fe or
	       type == 0x0302 then
		color = 0x00FF00
	else
		color = 0xFF0000
	end

--	gui.drawBox((x_screen + xoff)*xm, (y_screen + yoff)*ym, (x_screen + xoff + width)*xm, (y_screen + yoff + height)*ym, 0xFF000000+color, 0x40000000+color)
	gui.drawBox((x_screen + xoff), (y_screen + yoff), (x_screen + xoff + width), (y_screen + yoff + height), 0xFF000000+color, 0x40000000+color)

end

x = memory.read_u16_le(0x000A2A)
y = memory.read_u16_le(0x000A2C)
while true do

	spr_count = 0
	camera_x_prev = camera_x
	camera_y_prev = camera_y
	camera_x = memory.read_s16_le(0x0017BA)
	camera_y = memory.read_s16_le(0x0017C0)
	hold = memory.read_u16_le(0x000D7A)
	-- rope = memory.read_u8(0x000AEB)

--memory.write_u16_le(0x000D7A, 0x000E9E + spr_data_size * ?SpriteID?)

	-- sprite info
	for id = 0, 21 do
		base = 0x000E9E + spr_data_size * id
		stat = memory.read_u16_le(base)
		pos_x = memory.read_u16_le(base+0x6)
		pos_y = memory.read_u16_le(base+0xA)
		spd_x = memory.read_s16_le(base+0x20)
		spd_y = memory.read_s16_le(base+0x24)
		num = memory.read_u16_le(base+0x36)

		-- sprite info (type, x-pos, y-pos)
		if forms.ischecked(hide_spr_data) == false then
			disp_num = forms.gettext(disp_spr_num)
			if disp_num == "" then
				disp_num = "4"
			end
			if id < tonumber(disp_num) then
				disp_y = 80+id*15
				if (hold ~= 0) and ((hold-3742) / spr_data_size == id) then
					gui.text(2, disp_y, "+", def_txt_color_deep, 0x00000000)
				end
				if stat ~= 0 then
					gui.text(15, disp_y, "*", def_txt_color_deep, 0x00000000)
				end
				gui.text(30, disp_y, string.format("%d(%04x,%5d,%5d,%5d,%5d)", id, num, pos_x, pos_y, spd_x, spd_y), def_txt_color, 0x00000000)
			end
		end

		if stat ~= 0 then
			if forms.ischecked(hide_spr_data) == false then
				gui.text(xm * (pos_x - camera_x), ym * (pos_y - camera_y), string.format("%d(%x)", id, num), def_txt_color, 0x00000000)
			end
			draw_hitbox(memory.read_u16_le(base + 0x1A), memory.read_u16_le(base + 0x13), pos_x, pos_y, camera_x, camera_y, num)

			spr_count = spr_count + 1
		end

		selected_spr_num = forms.gettext(selected_spr)
		if selected_spr_num ~= "" then
			selected_spr_num = tonumber(selected_spr_num)
			if selected_spr_num == id then
				spr_data_line = ""
				for id_data = 0, spr_data_size-1 do
					if (id_data % 16 == 0) and (id_data ~= 0) then
						forms.setproperty(disp_spr_data[id_data/16], "Text", spr_data_line)
						spr_data_line = ""
					end
					spr_data_line = spr_data_line .. string.format("%02x ", memory.read_u8(base+id_data))
				end
				forms.setproperty(disp_spr_data[6], "Text", spr_data_line)
			end
		end
	end
	if forms.ischecked(hide_spr_data) == false then
		gui.text(2, 68, string.format("Count of Spr:%02d", spr_count), def_txt_color, 0x00000000)
	end

	-- Diddy & Dixie info
	x_prev = x
	y_prev = y
	--x = memory.read_u16_le(0x000A2A)
	--y = memory.read_u16_le(0x000A2C)
	x = memory.read_u32_le(0x000ABE)
	y = memory.read_u32_le(0x000AC2)
	x1 = memory.read_u16_le(0x000DE8)
	y1 = memory.read_u16_le(0x000DEC)
	x2 = memory.read_u16_le(0x000DE8 + spr_data_size)
	y2 = memory.read_u16_le(0x000DEC + spr_data_size)
	spx = memory.read_s16_le(0x000A30)
	spy = memory.read_s16_le(0x000A34)
	spx1 = memory.read_s16_le(0x000E02)
	spy1 = memory.read_s16_le(0x000E06)
	spx2 = memory.read_s16_le(0x000E02 + spr_data_size)
	spy2 = memory.read_s16_le(0x000E06 + spr_data_size)
	saru = memory.read_u8(0x0008A4)

	base = 0x000DE2
	draw_hitbox(memory.read_u16_le(base + 0x1A), memory.read_u16_le(base + 0x13), x1, y1, camera_x, camera_y, 0xFFFF)
	base = 0x000DE2 + spr_data_size
	draw_hitbox(memory.read_u16_le(base + 0x1A), memory.read_u16_le(base + 0x13), x2, y2, camera_x, camera_y, 0xFFFF)

	-- position info
	if forms.ischecked(hide_pos_data) == false then
		if hold == 3554 then
			gui.text(3, 400, "+", def_txt_color_deep, 0x00000000)
		elseif hold == 3648 then
			gui.text(3, 420, "+", def_txt_color_deep, 0x00000000)
		end
		if saru == 0 then
			gui.text(14, 400, "*", def_txt_color_deep, 0x00000000)
		else
			gui.text(14, 420, "*", def_txt_color_deep, 0x00000000)
		end
		gui.text(15, 380, string.format("(X:%5d/%3d, Y:%5d/%3d), (dX:%5d, dY:%5d)", bit.rshift(x,8), bit.band(x,0x000000FF), bit.rshift(y,8), bit.band(y,0x000000FF), x-x_prev, y-y_prev ), def_txt_color_deep, 0x00000000)
		gui.text(25, 400, string.format("Diddy (X:%5d, Y:%5d),(spX:%5d, spY:%5d)", x1, y1, spx1, spy1 ), def_txt_color_deep, 0x00000000)
		gui.text(25, 420, string.format("Dixie (X:%5d, Y:%5d),(spX:%5d, spY:%5d)", x2, y2, spx2, spy2 ), def_txt_color_deep, 0x00000000)
	end

	-- lag info
	cur_lag = emu.lagcount()
	if cur_lag ~= prev_lag then
		lag_frame_idx = ((lag_frame_idx+1)%3)
		lag_frame[lag_frame_idx+1] = emu.framecount()
		laglength = laglength+1
		laglength_display = laglength
	else
		laglength = 0
	end
	gui.text(180, 10, "LAG:", def_txt_color, 0x00000000)
	for i = 0, 2 do
		if lag_frame[i+1] ~= 0 then
			if lag_frame_idx == i then
				warn_color = 0xFFFF0000
			else
				warn_color = def_txt_color
			end
			gui.text((240+75*i), 10, lag_frame[i+1], warn_color, 0x00000000)
		end
	end
	if (laglength_display == laglength) and (laglength ~= 0) then
		gui.text(180, 25, "(LAG LENGTH:"..laglength_display..")", 0xFFFF0000, 0x00000000)
	else
		gui.text(180, 25, "(LAG LENGTH:"..laglength_display..")", def_txt_color, 0x00000000)
	end
	prev_lag = cur_lag

	-- level info
	level_prev = level
	room_prev = room
	level = memory.read_u8(0x0006AB)
	room = memory.read_u8(0x000D3)
	if forms.ischecked(hide_pos_data) == false then
		gui.text(5, 360, string.format("Level:%02X(%02X)", level, room), def_txt_color_deep, 0x00000000)
		gui.text(2, 50, string.format("Camera:(%d,%d)", camera_x, camera_y), def_txt_color, 0x00000000)
		--gui.text(2, 50, string.format("Camera (X:%5d, Y:%5d),(dX:%5d, dY:%5d)", camera_x, camera_y, camera_x-camera_x_prev, camera_y-camera_y_prev ), def_txt_color, 0x00000000)
	end

	-- display ghost
	if forms.ischecked(ghost_display) == true then

		in_game_frame_prev = in_game_frame
		in_game_frame = memory.read_u16_le(0x0002C)
		action_frame_prev = action_frame
		action_frame = memory.read_u32_le(0x000D5)

		--debug info
		--gui.text(5, 345, line, def_txt_color, 0x00000000)
		--gui.text(140, 360, string.format("Time:%d(%d)", in_game_frame, action_frame), def_txt_color, 0x00000000)

		if (level ~= level_prev) then
			io.input(filepath)
			file_open = 1

			-- skip first 1024 frame
			for i=1,1024 do
				io.read()
			end

			-- search first frame of current place
			while true do
				line = io.read()
				if not line then
					break
				end
				_,_,area_g = string.find(line, "^%d+ (%x+ %x+).+")
				if string.format("%02X %02X",level,room) == area_g then
					break
				end
			end

			-- skip frame for level 5-6
			if (level == 0x33) and (room == 0x0D) then
				for i=1,32 do
					io.read()
				end
			end

		end
		if (level == level_prev) and (room ~= room_prev) then
			for i=1,32 do
				io.read()
			end
		end

		if file_open == 1 then
			if in_game_frame == in_game_frame_prev then
				change_igframe = 0
			else
				if change_igframe == 0 then
					-- search first in-game frame of current room
					line = io.read()
					_,_,ig_g_prev = string.find(line, "^%d+ %x+ %x+ (%d+).+")
					while true do
						line = io.read()
						if not line then
							break
						end
						_,_,ig_g = string.find(line, "^%d+ %x+ %x+ (%d+).+")
						if ig_g ~= ig_g_prev then
							break
						end
					end
					change_igframe = 1
				else
					if change_igframe == 1 then
						change_igframe = 2
						max_cnt = 1
						if (level == 0x1C and room == 0x01) or (level == 0x20) or
						   (level == 0x2A) or
						   (level == 0x34) then
							max_cnt = 2
						end
						if (level == 0x1B) then
							max_cnt = 3
						end
						for i=1,max_cnt do
							io.read()
						end
					else
						line = io.read()
					end
				end
			end

			if action_frame ~= action_frame_prev then
				gui.text(xm * (x1 - camera_x) - 8, ym * (y1 - camera_y) - 24, "DD", 0xFF0000FF, 0x00000000)
				gui.text(xm * (x2 - camera_x) - 8, ym * (y2 - camera_y) - 24, "DX", 0xFF0000FF, 0x00000000)

				_,_, frame_g, area_g, ig_g, x1_g, y1_g, x2_g, y2_g = string.find(line, "^(%d+) (%x+ %x+) (%d+) (%d+) (%d+) (%d+) (%d+)")
				gui.text(xm * (x1_g - camera_x) - 8, ym * (y1_g - camera_y) - 24, "DD", 0xFF00FF00, 0x00000000)
				gui.text(xm * (x2_g - camera_x) - 8, ym * (y2_g - camera_y) - 24, "DX", 0xFF00FF00, 0x00000000)

				-- display when active kong motion differ
				threshold = 10
				if (saru==0 and (math.abs(x1-x1_g)>threshold or math.abs(y1-y1_g)>threshold)) or
				   (saru~=0 and (math.abs(x2-x2_g)>threshold or math.abs(y2-y2_g)>threshold)) then
					gui.drawImage(ddposepath, x1_g-camera_x-20, y1_g-camera_y-38, 48, 40)
					gui.drawImage(dxposepath, x2_g-camera_x-16, y2_g-camera_y-36, 32, 38)
				end
			end
		end
	end

	emu.frameadvance()
end
