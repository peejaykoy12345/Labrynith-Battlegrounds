local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)
local AnimationPlayer = require(ReplicatedStorage.Shared.AnimationPlayer)

local RunController = Knit.CreateController{
    Name = "RunController"
}

local WALK_ANIM_ID = 86773468874558
local WALK_SPEED = 20

local heldKeys = {}
local walkTrack = nil

local MOVE_KEYS = {
    [Enum.KeyCode.W] = true,
    [Enum.KeyCode.A] = true,
    [Enum.KeyCode.S] = true,
    [Enum.KeyCode.D] = true,
}

local function isMoving()
    for key in heldKeys do
        if MOVE_KEYS[key] then return true end
    end
    return false
end

local function getChar()
    return Players.LocalPlayer.Character
end

local function startWalkAnim()
    if walkTrack then return end
    local char = getChar()
    if not char then return end
    walkTrack = AnimationPlayer:Play(char, WALK_ANIM_ID, { Priority = 2 })
end

local function stopWalkAnim()
    if not walkTrack then return end
    AnimationPlayer:StopAnimation(walkTrack)
    walkTrack = nil
end

local function setSpeed(speed: number)
    local char = getChar()
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    hum.WalkSpeed = speed
end

function RunController:KnitStart()
    setSpeed(WALK_SPEED)

    Players.LocalPlayer.CharacterAdded:Connect(function()
        task.wait()
        setSpeed(WALK_SPEED)
        walkTrack = nil
    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end

        if MOVE_KEYS[input.KeyCode] then
            heldKeys[input.KeyCode] = true
            startWalkAnim()
        end
    end)

    UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if gameProcessed then return end

        if MOVE_KEYS[input.KeyCode] then
            heldKeys[input.KeyCode] = nil
            if not isMoving() then
                stopWalkAnim()
            end
        end
    end)
end

return RunController