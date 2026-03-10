local BufferService = {}
BufferService.__index = BufferService

local BUFFER_TIME = 0.25
local InputBuffer: {[Player]: {input: string, params: any, time: number}} = {}

function BufferService:Press(plr: Player, input: string, executeFunc: (plr: Player, params: any?) -> (), params: any)
	InputBuffer[plr] = {
		input = input,
		params = params,
		executeFunc = executeFunc,
		time = os.clock(),
	}
end

function BufferService.TryConsumeBuffer(plr: Player)	
	local buffered = InputBuffer[plr]
	if not buffered then return end
	if os.clock() - buffered.time > BUFFER_TIME then
		InputBuffer[plr] = nil
		return
	end

	InputBuffer[plr] = nil

	local func = buffered.executeFunc
	if not func then return end

	func(plr, buffered.params)
end

return BufferService
