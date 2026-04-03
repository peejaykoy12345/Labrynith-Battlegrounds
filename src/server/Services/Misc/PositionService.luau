local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local PositionService = Knit.CreateService{
    Name = "PositionService",
    Client = {},
}
PositionService.PlayerPositions = {} -- {[Player]: Vector3}

local function setupPlayer(plr: Player)
    while task.wait(1) do
        local char = plr.Character
        if not char then continue end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        PositionService.PlayerPositions[plr] = hrp.Position
    end
end

function PositionService:KnitInit()
    for _, plr in ipairs(Players:GetPlayers()) do
        setupPlayer(plr)
    end
    Players.PlayerAdded:Connect(setupPlayer)
end

function PositionService:GetPlayerLastPosition(plr: Player): Vector3?
    return PositionService.PlayerPositions[plr]
end

return PositionService