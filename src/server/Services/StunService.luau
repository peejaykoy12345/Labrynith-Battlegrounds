local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Knit = require(ReplicatedStorage.Packages.Knit)

local StateManager = require(ServerScriptService.Server.Utilities.Combat.StateManager)

local StunService = Knit.CreateService{
    Name = "StunService",
    Client = {}
}

type stunParams = {
    stunPriority: number,
    stunDuration: number,
    stunSpeed: number,
    canRotate: boolean?,
}

type speedDebuffParams = {
    priority: number,
    duration: number,
    speed: number,
}

local charStates = {}

function StunService:Stun(char: Model, params: stunParams): () -> ()
    if not char then return function() end end
    local humanoid: Humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return function() end end

    local speed = params.stunSpeed
    local priority = params.stunPriority
    local time = params.stunDuration
    local canRotate = params.canRotate

    if not charStates[char] then
        charStates[char] = {
            originalSpeed = humanoid.WalkSpeed,
            originalJump = humanoid.JumpHeight,
            originalAutoRotate = humanoid.AutoRotate,
            currentPriority = -1,
            stopCurrent = nil
        }
    end

    if charStates[char].currentPriority > priority then
        return function() end
    end

    if charStates[char].stopCurrent then
        charStates[char].stopCurrent = nil
    end

    charStates[char].currentPriority = priority

    humanoid.WalkSpeed = speed
    humanoid.JumpHeight = 0
    if canRotate == false then
        humanoid.AutoRotate = false
    end
    StateManager.SetState(char, "Stunned", true)

    local diedConn
    diedConn = humanoid.Died:Connect(function()
        charStates[char] = nil
        diedConn:Disconnect()
    end)

    local function stopStun()
        if not charStates[char] then return end

        if charStates[char].stopCurrent == stopStun then
            StateManager.RemoveState(char, "Stunned")
            humanoid.JumpHeight = charStates[char].originalJump
            humanoid.WalkSpeed = charStates[char].originalSpeed
            humanoid.AutoRotate = charStates[char].originalAutoRotate
            charStates[char].currentPriority = -1
            charStates[char].stopCurrent = nil
        end
    end

    charStates[char].stopCurrent = stopStun

    task.delay(time, stopStun)
    return stopStun
end

function StunService:SpeedDebuff(char: Model, params: speedDebuffParams): () -> ()
    if not char then return function() end end
    local humanoid: Humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return function() end end

    local speed = params.speed
    local priority = params.priority
    local time = params.duration

    if not charStates[char] then
        charStates[char] = {
            originalSpeed = humanoid.WalkSpeed,
            originalJump = humanoid.JumpHeight,
            originalAutoRotate = humanoid.AutoRotate,
            currentPriority = -1,
            stopCurrent = nil
        }
    end

    if charStates[char].currentPriority > priority then
        return function() end
    end

    if charStates[char].stopCurrent then
        charStates[char].stopCurrent = nil
    end

    charStates[char].currentPriority = priority
    humanoid.WalkSpeed = speed

    local diedConn
    diedConn = humanoid.Died:Connect(function()
        charStates[char] = nil
        diedConn:Disconnect()
    end)

    local function stopDebuff()
        if not charStates[char] then return end

        if charStates[char].stopCurrent == stopDebuff then
            humanoid.WalkSpeed = charStates[char].originalSpeed
            charStates[char].currentPriority = -1
            charStates[char].stopCurrent = nil
        end
    end

    charStates[char].stopCurrent = stopDebuff

    task.delay(time, stopDebuff)
    return stopDebuff
end

return StunService