local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Knit = require(ReplicatedStorage.Packages.Knit)

local M1Controller = Knit.CreateController {
	Name = "M1Controller";
}

function M1Controller:KnitStart()
    self.ActionService = Knit.GetService("ActionService")

    local isHold = false

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isHold = true

            task.spawn(function()
                while isHold do
                    self.ActionService:PerformAction("M1", {})
                    task.wait(0.5)
                end
            end)
        end
    end)

    UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isHold = false
        end
    end)
end

return M1Controller