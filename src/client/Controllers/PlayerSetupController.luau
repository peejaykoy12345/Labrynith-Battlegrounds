local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Hit = require(ReplicatedStorage.Assets.ClientFX.Combat.Hit)

local PlayerSetupController = Knit.CreateController{
    Name = "PlayerSetupController"
}

local plr = Players.LocalPlayer

function PlayerSetupController:KnitStart()
    local char = plr.Character
    while not char do
        char = plr.Character
        task.wait(0.1)
    end

    Hit:Start({target = char})

    plr.CharacterAdded:Connect(function(character)
        plr.CharacterAppearanceLoaded:Wait()
        Hit:Start({target = character})
    end)
end

return PlayerSetupController