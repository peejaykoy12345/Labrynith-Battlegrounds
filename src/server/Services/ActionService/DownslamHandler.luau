local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local MoveUtils = require(ServerScriptService.Server.Utilities.Combat.MoveUtils)
local BufferInput = require(ServerScriptService.Server.Utilities.BufferInput)

local MeleeInstances = require(script.Parent.MeleeInstances)

local CharacterFolder = ServerStorage.ServerStorage.Characters

local module = {}
module.__index = module

function module:_HandleM1(plr)
    local module = require(CharacterFolder.Default.Melee)
    
    if MeleeInstances[plr] then
        MeleeInstances[plr]:Downslam()
    else
        MeleeInstances[plr] = module.new({
            char = plr.Character
        }) 
        MeleeInstances[plr]:Downslam()
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