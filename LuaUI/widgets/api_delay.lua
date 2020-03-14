function widget:GetInfo()
	return {
		name      = "Delay API",
		desc      = "Allows delaying of widget calls.",
		author    = "gajop",
		date      = "future",
		license   = "MIT",
		layer     = -10000,
		enabled   = true  --  loaded by default?
	}
end

local currentTime = os.clock()
local calls = {}
local ids = 0

-- delay in miliseconds
local function DelayCall(f, delay)
	local executeTime = currentTime + delay
    local id = ids
	calls[id] = {f, executeTime}
    ids = ids + 1
end

function widget:Update()
	currentTime = os.clock()
	for i, call in pairs(calls) do
		if currentTime >= call[2] then
            call[1]()
            calls[i] = nil
		end
	end
end

WG.Delay = DelayCall
