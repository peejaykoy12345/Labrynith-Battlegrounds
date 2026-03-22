local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local BufferInput = require(ServerScriptService.Server.Utilities.BufferInput)

local module = {}

function module:_Dash(char, dir)
    local Default = require(ServerStorage.ServerStorage.Characters.Default.Dash)

    if not Default.CanDash(char, dir) then return end

    Default:Dash(char, dir)
end

function module:HandleAction(plr: Player, params)
    local char = plr.Character
    if not char then return end

    local Default = require(ServerStorage.ServerStorage.Characters.Default.Dash)

    local dir = params.dir  
    print(params.dir)

    if not Default.CanDash(char, dir) then
        BufferInput:Press(plr, "Dash", function(plr, params)
            self:_Dash(plr.Character, dir)
        end, params)
        return
    end

    self:_Dash(char, dir)
end

return module