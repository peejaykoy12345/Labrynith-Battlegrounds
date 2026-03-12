local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local PlayerSetupService = Knit.CreateService {
    Name = "PlayerSetupService";
    Client = {};
}

function PlayerSetupService:KnitStart()
    -- Placeholder

    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(character)
            self:SetupCharacter(player, character)
        end)
    end)
end

function PlayerSetupService:SetupCharacter(player: Player, character: Model)
    local RightArm = character:WaitForChild("Right Arm")

    local dagger = ReplicatedStorage.Assets.Models["Meshes/dagger"]:Clone()
    dagger.Parent = character

    local armAttachment = RightArm:WaitForChild("RightGripAttachment")
    local daggerAttachment = dagger:WaitForChild("GripAttachment")

    dagger:PivotTo(armAttachment.WorldCFrame * daggerAttachment.CFrame)

    local Motor6D = Instance.new("Motor6D")
    Motor6D.Name = "RightGrip"
    Motor6D.Part0 = RightArm
    Motor6D.Part1 = dagger
    Motor6D.C0 = armAttachment.CFrame
    Motor6D.C1 = daggerAttachment.CFrame
    Motor6D.Parent = RightArm
end

return PlayerSetupService