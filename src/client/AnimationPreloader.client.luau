local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")

local AnimationsFolder = RS.Animations

ContentProvider:PreloadAsync(AnimationsFolder:GetDescendants())

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local animator = hum:WaitForChild("Animator")

for _, anim in pairs(AnimationsFolder:GetDescendants()) do
    if not anim:IsA("Animation") then continue end
    local track = animator:LoadAnimation(anim)
    track:Play()
    track:Stop(0)
end

print("Animations preloaded")