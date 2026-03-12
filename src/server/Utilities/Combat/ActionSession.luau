local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")  

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Services
local AnimationService = require(ServerScriptService.Server.Services.AnimationService)
local CooldownService = require(ServerScriptService.Server.Services.CooldownService)

-- Utils
local TableUtils = require(ReplicatedStorage.Shared.Utils.TableUtils)
local BufferInput = require(ServerScriptService.Server.Utilities.BufferInput)
local StateManager = require(ServerScriptService.Server.Utilities.Combat.StateManager)
local MoveUtils = require(ServerScriptService.Server.Utilities.Combat.MoveUtils)

local ActionSession = {}
ActionSession.__index = ActionSession

type cooldownParams = {
    cooldown: number
}

type statesParams = {
    sharedStates: {string},
    attackerStates: {string},
    targetStates: {string},
}

export type ActionSessionParams = {
    model: Model,
    actionName: string,
    actionType: "Cooldown" | "Misc",
    cooldown: cooldownParams,
    states: statesParams
}

local CharacterAttackSessions = {}

function ActionSession.StopSession(char)
    if CharacterAttackSessions[char] then
        CharacterAttackSessions[char]:Stop(true)
    end
end

function ActionSession.new(params: ActionSessionParams)
    assert(params.attacker, "Attacker is required")
    assert(params.actionName, "actionName is required")
    assert(params.actionType, "ActionType is required")

    local self = setmetatable({}, ActionSession)

    self.attacker = params.attacker
    self.actionName = params.actionName
    self.actionType = params.actionType
    self.cooldown = params.cooldown

    self.states = params.states

    self.animations = {}
    self.targets = {}

    self.options = params

    CharacterAttackSessions[self.attacker] = self

    return self
end

function ActionSession:InitTarget(target: Model)
    ActionSession.StopSession(target)

    self:SetStatesTo(target, self.states.sharedStates)
    self:SetStatesTo(target, self.states.targetStates)

    MoveUtils:RegisterHit(self.attacker, target)

    table.insert(self.targets, target)
end

-------------------
--- ANIMATIONS ----
-------------------

type playOptionsParams = {
    Priority: number
}

function ActionSession:PlayAndAddAnimation(char: Model, animationId: number, playOptions: playOptionsParams?): Animation
    local anim = AnimationService:Play(char, animationId, playOptions)
    self:AddAnimation(anim)

    return anim
end

function ActionSession:AddAnimation(animation: Animation)
    table.insert(self.animations, animation)
end

function ActionSession:StopAnimation(animation: Animation)
    TableUtils:ArrayRemove(self.animations, animation)
    AnimationService:StopAnimation(animation)
end

function ActionSession:StopAllAnimations()
    for _, anim in ipairs(self.animations) do
        AnimationService:StopAnimation(anim)
    end
    self.animations = {}
end

function ActionSession:SetStatesTo(target: Model, states)
    if not states then return end

    for _, state in ipairs(states) do 
        StateManager.SetState(target, state, true)
    end
end

function ActionSession:RemoveStatesTo(target: Model, states)
    if not states then return end

    for _, state in ipairs(states) do 
        StateManager.RemoveState(target, state)
    end
end

function ActionSession:Start()
    local states = self.states
    if states then
        if states.sharedStates then
            self:SetStatesTo(self.attacker, states.sharedStates)
        end
        
        if states.attackerStates then
            self:SetStatesTo(self.attacker, states.attackerStates)
        end
    end
end

function ActionSession:Stop(forcestop: boolean?)
    if forcestop then
        print("Stopping")
        self:StopAllAnimations()
    end

    if self.hitbox then
        self.hitbox:Stop()
        self.hitbox = nil
    end

    if self.cooldown then
        CooldownService:SetCooldown(self.attacker, self.actionName, self.cooldown.cooldown)
    end

    if self.states then
        self:RemoveStatesTo(self.attacker, self.states.attackerStates)
        self:RemoveStatesTo(self.attacker, self.states.sharedStates)

        for _, target in ipairs(self.targets) do
            self:RemoveStatesTo(target, self.states.sharedStates)
            self:RemoveStatesTo(target, self.states.targetStates)
        end
    end

    -- After each action session is stopped, check if there are any buffered inputs to consume
    local plr = Players:GetPlayerFromCharacter(self.attacker)
    if plr then
        BufferInput.TryConsumeBuffer(plr)
    end

    self = nil
end

export type ActionSessionType = typeof(ActionSession.new())

return ActionSession :: ActionSessionType