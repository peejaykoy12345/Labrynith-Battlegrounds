local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local RunHandler = {}

local DefaultRun = require(ServerStorage.ServerStorage.Characters.Default.Run)

function RunHandler:HandleAction(plr: Player, params)
    params = params or {}

    local run = params.run

    local char = plr.Character
    if not char then return end

    if run then
        DefaultRun:Run(char)
    else
        DefaultRun:StopRun(char)
    end
end

return RunHandler