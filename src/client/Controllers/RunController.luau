local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Knit = require(ReplicatedStorage.Packages.Knit)

local RunController = Knit.CreateController{
    Name = "RunController"
}

local pressedW = false

function RunController:KnitStart()
    self.ActionService = Knit.GetService("ActionService")

    UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if gameProcessedEvent then return end

        if input.KeyCode == Enum.KeyCode.W then
            print(pressedW)
            if pressedW then
                self.ActionService:PerformAction("Run", {run = true})
            else
                pressedW = true
                task.delay(2, function()
                    pressedW = false
                end)
            end
        end

        if input.KeyCode == Enum.KeyCode.S then
            self.ActionService:PerformAction("Run", {run = false})
        end
    end)

    UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
        if gameProcessedEvent then return end

        if input.KeyCode == Enum.KeyCode.W then
            self.ActionService:PerformAction("Run", {run = false})
        end
    end)
end

return RunController