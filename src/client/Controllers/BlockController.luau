local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Knit = require(ReplicatedStorage.Packages.Knit)

local BlockController = Knit.CreateController{
    Name = "BlockController"
}

function BlockController:KnitStart()
    self.ActionService = Knit.GetService("ActionService")

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.KeyCode == Enum.KeyCode.F and not gameProcessed then
            self.ActionService:PerformAction("Block", {isHold = true})
        end
    end)

    UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if input.KeyCode == Enum.KeyCode.F and not gameProcessed then
            self.ActionService:PerformAction("Block", {isHold = false})
        end
    end)
end

return BlockController