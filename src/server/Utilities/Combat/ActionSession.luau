local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Services
local AnimationService = Knit.GetService("AnimationService")
local CooldownService = Knit.GetService("CooldownService")
local ServerScriptService = game:GetService("ServerScriptService")

-- Utils
local TableUtils = require(ReplicatedStorage.Shared.Utils.TableUtils)
local BufferInput = require(ServerScriptService.Server.Utilities.BufferInput)

local AttackSession = {}
AttackSession.__index = AttackSession

type cooldownParams = {
    cooldown: number
}

export type AttackSessionParams = {
    model: Model,
    actionName: string,
    actionType: "Cooldown" | "Misc",
    cooldown: cooldownParams,
}

function AttackSession.new(params: AttackSessionParams)
    assert(params.attacker, "Attacker is required")
    assert(params.actionName, "actionName is required")
    assert(params.actionType, "ActionType is required")

    local self = setmetatable({}, AttackSession)

    self.attacker = params.attacker
    self.actionName = params.actionName
    self.actionType = params.actionType
    self.cooldown = params.cooldown

    self.animations = {}

    self.options = params
    return self
end

type playOptionsParams = {
    Priority: number
}

function AttackSession:PlayAndAddAnimation(char: Model, animationId: number, playOptions: playOptionsParams?): Animation
    local anim = AnimationService:Play(char, animationId, playOptions)
    self:AddAnimation(anim)

    return anim
end

function AttackSession:AddAnimation(animation: Animation)
    table.insert(self.animations, animation)
end

function AttackSession:StopAnimation(animation: Animation)
    TableUtils:ArrayRemove(self.animations, animation)
    AnimationService:StopAnimation(animation)
end

function AttackSession:StopAllAnimations()
    for _, anim in ipairs(self.animations) do
        AnimationService:StopAnimation(anim)
    end
    self.animations = {}
end

function AttackSession:Stop(forcestop: boolean?)
    if forcestop then
        self:StopAllAnimations()
    end

    if self.cooldown then
        CooldownService:SetCooldown(self.attacker, self.actionName, self.cooldown.cooldown)
    end

    if self.hitbox then
        self.hitbox:Stop()
        self.hitbox = nil
    end

    -- After each action session is stopped, check if there are any buffered inputs to consume
    local plr = Players:GetPlayerFromCharacter(self.char)
    if plr then
        BufferInput.TryConsumeBuffer(plr)
    end

    self = nil
end

export type AttackSessionType = typeof(AttackSession.new())

return AttackSession :: AttackSessionType