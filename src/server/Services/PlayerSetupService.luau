local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local AnimationService = require(ServerScriptService.Server.Services.AnimationService)

local Knit = require(ReplicatedStorage.Packages.Knit)

local PlayerSetupService = Knit.CreateService {
    Name = "PlayerSetupService";
    Client = {};
}

function PlayerSetupService:KnitStart()
    self.AnimationService = Knit.GetService("AnimationService")

    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(character)
            self:SetupCharacter(player, character)

            character.Humanoid.WalkSpeed = 20
            
            player.CharacterAppearanceLoaded:Wait()
            task.wait(0.5)
            self.AnimationService:Play(character, 85866271350050)
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
    Motor6D.C0 = daggerAttachment.CFrame
    Motor6D.C1 = CFrame.new(0, 0, 0)
    Motor6D.Parent = RightArm
end

return PlayerSetupService