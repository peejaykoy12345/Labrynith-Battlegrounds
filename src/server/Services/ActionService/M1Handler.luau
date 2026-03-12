local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local MoveUtils = require(ServerScriptService.Server.Utilities.Combat.MoveUtils)
local BufferInput = require(ServerScriptService.Server.Utilities.BufferInput)

local CharacterFolder = ServerStorage.ServerStorage.Characters

local module = {}
module.__index = module

module.M1Instances = {}

function module:_HandleM1(plr)
    local module = require(CharacterFolder.Default.Melee)
    
    if self.M1Instances[plr] then
        self.M1Instances[plr]:M1()
    else
        self.M1Instances[plr] = module.new({
            char = plr.Character
        }) 
        self.M1Instances[plr]:M1()
    end
end

function module:HandleAction(plr: Player, params)
    params = params or {}

    local char = plr.Character
    if not char then return end

    if not MoveUtils:CanPerformAction(char, "M1") then
        BufferInput:Press(plr, "DefaultM1", function(plr, params)
            self:_HandleM1(plr)
        end)
        return
    end

    self:_HandleM1(plr)
end

return module