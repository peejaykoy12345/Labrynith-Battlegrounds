local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local ActionSession = require(ServerScriptService.Server.Utilities.Combat.ActionSession)
local MoveUtils = require(ServerScriptService.Server.Utilities.Combat.MoveUtils)
local StateManager = require(ServerScriptService.Server.Utilities.Combat.StateManager)

local ClientFXService = require(ServerScriptService.Server.Services.ClientFXService)
local AnimationService = require(ServerScriptService.Server.Services.AnimationService)
local CooldownService = require(ServerScriptService.Server.Services.CooldownService)

local remotes = require(ReplicatedStorage.Packages.remotes)

local DashEvent: RemoteEvent = remotes:getEventAsync("Dash")
local UnDashEvent: RemoteEvent = remotes:getEventAsync("UnDash")

local Dash = {}
Dash.__index = Dash

Dash.Anims = {
    Forward = 83283118074837,
    ForwardHit = 111138858862861,
    Backward = 137300805778395,
    Left = 131173041479328,
    Right = 118374148894248,
    OnHit = 107787809160749,
}

Dash.Effects = {
}

function Dash.CanDash(char: Model, dir): boolean
    local SideDash = dir == "Left" or dir == "Right"
    local dashType = SideDash and "SideDash" or "Dash"

    if StateManager.HasState(char, "Ragdoll") and not CooldownService:IsOnCooldown(char, "RagdollCancel") then
        return true
    else
        local CanPerformAction = MoveUtils:CanPerformAction(char, dashType, { statesToSkip = { "Ragdoll" } })
        return CanPerformAction
    end
end

function Dash:_CreateHitbox(char: Model, session, onTouched, validateHitParams)
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    validateHitParams = validateHitParams or self.ValidateHitParams

    local hb = MoveUtils:CreateStandardHitbox({
        CFrame = hrp.CFrame * CFrame.new(0, 0, -3)
    })
    session.hitbox = hb
    hb:Start()

    local updateConn = RunService.Heartbeat:Connect(function()
        hb.CFrame = hrp.CFrame * CFrame.new(0, 0, -3)
    end)

    hb.Touched:Connect(function(hitChar)
        if not MoveUtils:ValidateHit(char, hitChar, validateHitParams) then return end
        local ehrp = hitChar:FindFirstChild("HumanoidRootPart")
        if not ehrp then return end

        session:InitTarget(hitChar)
        onTouched(hitChar, ehrp)
    end)

    task.delay(0.2, function()
        updateConn:Disconnect()
    end)
end

function Dash:_FireHitFX(hitChar)
end

function Dash:Dash(char: Model, dir: string)
    if not self.CanDash(char, dir) then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local dashType = (dir == "Left" or dir == "Right") and "SideDash" or "Dash"

    local session = ActionSession.new({
        attacker = char,
        actionName = dashType,
        actionType = "Cooldown",
        cooldown = {
            cooldown = 1
        },
        states = {
            attackerStates = {"CantUse"}
        }
    })

    if not session then return end

    local plr = Players:GetPlayerFromCharacter(char)

    session:Start()

    if StateManager.HasState(char, "Ragdoll") then
        CooldownService:SetCooldown(char, "RagdollCancel", 10)
        MoveUtils:UnragdollCharacter(char)
    end

    local track = session:PlayAndAddAnimation(char, Dash.Anims[dir], { Priority = 3 })

    session.extraStopFunction = function()
        if plr then
            UnDashEvent:FireClient(plr)
        end
    end

    local trackLength = track.Length
    if trackLength <= 0 then
        trackLength = .5
    else
        trackLength -= .2
    end

    if dir == "Forward" then
        track:AdjustSpeed(.7)

        local punched = false

        local function punch()
            if punched then return end
            punched = true
            track:Stop()
            local newTrack: AnimationTrack = session:PlayAndAddAnimation(char, Dash.Anims.ForwardHit, { Priority = 3 })

            local newTrackLength = newTrack.Length
            if newTrackLength <= 0 then
                newTrackLength = .5
            else
                newTrackLength -= .1
            end

            self:_CreateHitbox(char, session, function(hitChar, ehrp)
                AnimationService:Play(hitChar, self.Anims.OnHit)

                local hum = hitChar:FindFirstChild("Humanoid")
                if not hum then return end

                hum:TakeDamage(10)

                self:_FireHitFX(hitChar)

                MoveUtils:FacePlayer(ehrp, hrp)
            end)

            task.delay(newTrackLength, function()
                session:Stop()
            end)
        end

        task.delay(trackLength, function()
            punch()
        end)
    else
        task.delay(trackLength, function()
            session:Stop()
        end)
    end

    if plr then
        DashEvent:FireClient(plr, dir)
    end
end

return Dash