local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local MeleeInstances = require(script.MeleeInstances)

local ActionService = Knit.CreateService({
    Name = "ActionService",
    Client = {}
})

local DiedConnections: {[Player]: RBXScriptConnection} = {}

function ActionService.Client:PerformAction(plr: Player, actionName: string, params)
    local moduleName = actionName .. "Handler"
    local module = script:FindFirstChild(moduleName)
    if module then
        require(module):HandleAction(plr, params)
    end

    DiedConnections[plr] = plr.Character.Humanoid.Died:Connect(function()
        MeleeInstances[plr] = nil
    end)
end

Players.PlayerRemoving:Connect(function(plr)
    if DiedConnections[plr] then
        DiedConnections[plr]:Disconnect()
        DiedConnections[plr] = nil
    end
end)

return ActionService