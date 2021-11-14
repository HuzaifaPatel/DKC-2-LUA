runningTimerSpeed = 3

--Game-specific RAM addresses
RAM = {
	dwords = {
        inGameFrames = 0x7e00d5,
    },
    bytes = {
        mode = 0x7e0de5,
    }
}

--Locations to output text
output = {
	x = 0,
	y = 210,
	yOffset = 0,
}

showOptions = {
    time = true,
    levelTime = true,
}

whiteBox = false
levelStart = 0
previousMode = 0

function CalculateTime(frames)
    local hour = math.floor(frames / 216000)
    local minute = math.floor(frames / 3600 - hour * 60)
    local sec = math.floor(frames / 60 - hour * 3600 - minute * 60)
    local mil = frames - hour * 216000 - minute * 3600 - sec * 60
    mil = math.floor(mil * 100 / 60)

    return hour, minute, sec, mil
end

function OutputTime(outOffset)
	--set in-game time
    local inGameFrames = memory.readdword(RAM.dwords.inGameFrames)
    local hour, minute, sec, mil = CalculateTime(inGameFrames)

	gui.text(output.x, output.y - output.yOffset, "(T) Time: " .. hour .. ":" .. string.format("%02d",minute) .. ":" .. string.format("%02d",sec) .. "." .. string.format("%02d",mil))
	output.yOffset = output.yOffset + 10
end

function OutputLevelTime(outOffset)
	--set in-game time
    local inGameFrames = memory.readdword(RAM.dwords.inGameFrames)
    local mode = memory.readbyte(RAM.bytes.mode)
    if mode == 0 and previousMode == 1 then 
        levelStart = inGameFrames
    end
    previousMode = mode
    local hour, minute, sec, mil = CalculateTime(inGameFrames - levelStart)

	gui.text(output.x, output.y - output.yOffset, "(L) Level Time: " .. hour .. ":" .. string.format("%02d",minute) .. ":" .. string.format("%02d",sec) .. "." .. string.format("%02d",mil))
	output.yOffset = output.yOffset + 10
end

--Outputs relevant game information
function OutputGameInfo()
	output.yOffset = 0
	
    if showOptions.time then
        OutputTime()
    end
    if showOptions.levelTime then
        OutputLevelTime()
    end
end

--Handles all the hotkey stuff
function HandleKeys()
	keys = input.get()

    if press('T') then
        showOptions.time = not showOptions.time
    end
    if press('L') then
        showOptions.levelTime = not showOptions.levelTime
    end
	
	last_keys = keys                                              
end

function press(button)
    if keys[button] and not last_keys[button] then
        return true
    end
    return false
end
 	
while true do
	OutputGameInfo()
	HandleKeys()
	snes9x.frameadvance()
end