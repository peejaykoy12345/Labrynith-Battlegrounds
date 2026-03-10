local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Knit = require(ReplicatedStorage.Packages.Knit)

local M1Controller = Knit.CreateController {
	Name = "M1Controller";
}

function M1Controller:KnitStart()
    self.ActionService = Knit.GetService("ActionService")

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.ActionService:PerformAction("M1", {})
        end
    end)
end

return M1Controller