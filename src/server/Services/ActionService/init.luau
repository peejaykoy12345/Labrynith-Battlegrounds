local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local ActionService = Knit.CreateService({
    Name = "ActionService",
    Client = {}
})

function ActionService.Client:PerformAction(plr: Player, actionName: string, params)
    local moduleName = actionName .. "Handler"
    local module = script:FindFirstChild(moduleName)
    if module then
        require(module):HandleAction(plr, params)
    end
end

return ActionService