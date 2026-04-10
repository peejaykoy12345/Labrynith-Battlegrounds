local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local UtilitiesFolder = ServerScriptService.Server.Utilities
local AnimationService = require(ServerScriptService.Server.Services.AnimationService)
local CooldownService = require(ServerScriptService.Server.Services.CooldownService)
local MoveUtils = require(UtilitiesFolder.Combat.MoveUtils)
local Velocity = require(UtilitiesFolder.Combat.Velocity)
local ActionSession = require(UtilitiesFolder.Combat.ActionSession)
local AsyncTimer = require(UtilitiesFolder.AsyncTimer)
local SoundManagerService = require(ServerScriptService.Server.Services.SoundManagerService)
local ClientFXService = require(ServerScriptService.Server.Services.ClientFXService)
local StunService = require(ServerScriptService.Server.Services.StunService)

local CONFIG = {
    M1Cooldown = 0.3,
    ComboCooldown = 1.2,
    Velocity = {
        ZAxis = 50,
        YAxis = 15,
    },
    UppercutVelocity = {
        ZAxis = 7.5,
        YAxis = 40
    },
    DownslamVelocity = {
        ZAxis = 0,
        YAxis = -10,
    }
}

local Melee = {}
Melee.__index = Melee

Melee.M1anims = {
    [1] = 90039212930093,
    [2] = 80291911899085,
    [3] = 111790066139844,
    [4] = 70861267663329,
    [5] = 112225982123031,
}

Melee.UppercutAnim = 104594668247886
Melee.DownslamAnim = 129079334494827

Melee.SwingSFX = {
    
}

Melee.hitAnims = {
    
}

Melee.hitSFX = {
    
}

Melee.Effects = {
}

Melee.ValidateHitParams = {
    Block = {
        Blockable = true,
    }
}

Melee.ValidateDownslamHitParams = {
    Block = {
        Blockable = false,
    }
}

export type params = {
    char: Model,
}

function Melee.new(params: params)
    local self = setmetatable({}, Melee)

    self.char = params.char
    self.hrp = self.char.HumanoidRootPart
    self.animIdToPlay = 1
    self.timer = AsyncTimer.new(3)
    self.timer.timeout:Connect(function()
        self.animIdToPlay = 1
        self.timer:Reset()
        self.char:SetAttribute("M1Finisher", nil)
    end)

    self.comboCooldown = false

    return self
end

function Melee:ApplyVelocity(enemy: Model)
    local ehrp = enemy:FindFirstChild("HumanoidRootPart")
    if not ehrp then warn(`No hrp for {enemy.Name}`) return end

    local Mass1, Mass2 = MoveUtils:GetModelMass(self.char), MoveUtils:GetModelMass(enemy)

    local function createBv(parent, vel, mass)
        local bv = Velocity.CreateBV(parent, Vector3.new(mass + 30000, 0, mass + 30000))
        bv.Velocity = vel
        Debris:AddItem(bv, .075)
    end

    createBv(self.hrp, self.hrp.CFrame.LookVector * 14, Mass1)
    createBv(ehrp, self.hrp.CFrame.LookVector * 14, Mass2)
end

function Melee:_CreateSession()
    local session = ActionSession.new({
        attacker = self.char,
        actionName = "DefaultM1",
        actionType = "Cooldown",
        states = {
            targetStates = { "CantUse" }
        },
    })
    if not session then return end
    session:Start()
    CooldownService:SetCooldown(self.char, "DefaultM1", CONFIG.M1Cooldown)
    return session
end

function Melee:_CreateHitbox(session, onTouched, validateHitParams)
    if session.stopped then return end
    
    validateHitParams = validateHitParams or self.ValidateHitParams

    local hb = MoveUtils:CreateStandardHitbox({
        CFrame = self.hrp.CFrame * CFrame.new(0, 0, -3)
    })
    session.hitbox = hb
    hb:Start()

    local updateConn = RunService.Heartbeat:Connect(function()
        hb.CFrame = self.hrp.CFrame * CFrame.new(0, 0, -3)
    end)

    hb.Touched:Connect(function(hitChar)
        if not MoveUtils:ValidateHit(self.char, hitChar, validateHitParams) then return end
        local ehrp = hitChar:FindFirstChild("HumanoidRootPart")
        if not ehrp then return end
        session:InitTarget(hitChar)
        onTouched(hitChar, ehrp)
    end)

    task.delay(0.2, function()
        updateConn:Disconnect()
    end)
end

function Melee:_FireHitFX(hitChar)
    --[[ClientFXService:Start({ Name = "Hit", Type = "Combat" }, { target = hitChar })
    ClientFXService:Start({ Name = "EmitParticles", Type = "Combat" }, {
        parent = hitChar.HumanoidRootPart,
        particleContainer = self.Effects.Hit
    })]]
end

function Melee:_EndCombo()
    self.comboCooldown = true
    self.char:SetAttribute("M1Finisher", nil)
    task.delay(CONFIG.ComboCooldown, function()
        self.animIdToPlay = 1
        self.comboCooldown = false
    end)
end

function Melee:M1()
    if not MoveUtils:CanPerformAction(self.char, "DefaultM1") then return end
    if self.comboCooldown then return end

    local animToPlay = self.animIdToPlay
    if animToPlay > #self.M1anims then return end

    local session = self:_CreateSession()
    if not session then return end

    self.animIdToPlay += 1
    self.timer:Reset()

    if self.animIdToPlay > #self.M1anims then
        self:_EndCombo()
    elseif animToPlay == #self.M1anims - 1 then
        self.char:SetAttribute("M1Finisher", true)
    end

    local track: AnimationTrack = session:PlayAndAddAnimation(self.char, self.M1anims[animToPlay], {Priority = 4})

    local hitboxFired = false
    local function fireHitbox()
        if hitboxFired then return end
        hitboxFired = true

        self:_CreateHitbox(session, function(hitChar, ehrp)
            hitChar.Humanoid:TakeDamage(10)
            StunService:Stun(hitChar, {
                stunPriority = 2,
                stunDuration = 1,
                stunSpeed = 0,
                canRotate = false,
            })
            --AnimationService:Play(hitChar, self.hitAnims[animToPlay])
            MoveUtils:FacePlayer(ehrp, self.hrp)
            --SoundManagerService:Play(self.hitSFX[animToPlay], hitChar)
            self:_FireHitFX(hitChar)

            if animToPlay == #self.M1anims then
                MoveUtils:RagdollCharacter(hitChar, 1.5)
                local bv = Velocity.CreateBV(ehrp, Vector3.new(math.huge, math.huge, math.huge))
                bv.Velocity = (self.hrp.CFrame.LookVector * CONFIG.Velocity.ZAxis) + (self.hrp.CFrame.UpVector * CONFIG.Velocity.YAxis)
                Debris:AddItem(bv, 0.2)
            else
                self:ApplyVelocity(hitChar)
            end
        end)
    end

    if animToPlay == #self.M1anims then
        StunService:SpeedDebuff(self.char, {
            priority = 1,
            duration = .7,
            speed = 0,
        })
    end

    track:GetMarkerReachedSignal("Hit"):Connect(fireHitbox)
    task.delay(.275, fireHitbox)
    --SoundManagerService:Play(self.SwingSFX[animToPlay], self.char)
    track.Ended:Connect(function()
        session:Stop()
    end)
end

function Melee:Uppercut()
    if not MoveUtils:CanPerformAction(self.char, "DefaultM1") then return end
    if not self.char:GetAttribute("M1Finisher") then return end

    local session = self:_CreateSession()
    if not session then return end

    self:_EndCombo()

    local track: AnimationTrack = session:PlayAndAddAnimation(self.char, self.UppercutAnim, {Priority = 4})

    local hitboxFired = false
    local function fireHitbox()
        if hitboxFired then return end
        hitboxFired = true

        self:_CreateHitbox(session, function(hitChar, ehrp)
            hitChar.Humanoid:TakeDamage(10)

            StunService:Stun(hitChar, {
                stunPriority = 2,
                stunDuration = 1,
                stunSpeed = 0,
                canRotate = false,
            })

            --[[ClientFXService:Start(
                {   
                    Name = "EmitParticles",
                    Type = "Combat",
                },
                {
                    parent = hitChar.HumanoidRootPart,
                    particleContainer = self.Effects.Uppercut
                }
            )]]

            ClientFXService:Start(
                {
                    Name = "Slam",
                    Type = "Combat",
                },
                {
                    target = hitChar,
                    fxDelay = 0.4
                }
            )

            MoveUtils:FacePlayer(ehrp, self.hrp)
            self:_FireHitFX(hitChar)

            MoveUtils:RagdollCharacter(hitChar, 1.5)

            local bv = Velocity.CreateBV(ehrp, Vector3.new(math.huge, math.huge, math.huge))
            bv.Velocity = (self.hrp.CFrame.LookVector * CONFIG.UppercutVelocity.ZAxis) + (self.hrp.CFrame.UpVector * CONFIG.UppercutVelocity.YAxis)
            Debris:AddItem(bv, 0.2)
        end)
    end

    track:GetMarkerReachedSignal("Hit"):Connect(function()
        fireHitbox()
    end)

    track.Ended:Connect(function()
        session:Stop()
    end)
end

function Melee:Downslam()
    if not MoveUtils:CanPerformAction(self.char, "DefaultM1") then return end
    if not self.char:GetAttribute("M1Finisher") then return end

    local hum: Humanoid = self.char and self.char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    if hum:GetState() ~= Enum.HumanoidStateType.Freefall then return end

    local session = self:_CreateSession()
    if not session then return end

    self:_EndCombo()

    local track: AnimationTrack = session:PlayAndAddAnimation(self.char, self.DownslamAnim, {Priority = 4})

    local hitboxFired = false
    local function fireHitbox()
        if hitboxFired then return end
        hitboxFired = true

        self:_CreateHitbox(session, function(hitChar, ehrp)
            hitChar.Humanoid:TakeDamage(10)
            StunService:Stun(hitChar, {
                stunPriority = 2,
                stunDuration = 1,
                stunSpeed = 0,
                canRotate = false,
            })

            ClientFXService:Start(
                {
                    Name = "Slam",
                    Type = "Combat",
                },
                {
                    target = hitChar,
                }
            )

            MoveUtils:FacePlayer(ehrp, self.hrp)
            self:_FireHitFX(hitChar)
            MoveUtils:RagdollCharacter(hitChar, 1.5)

            local bv = Velocity.CreateBV(ehrp, Vector3.new(math.huge, math.huge, math.huge))
            bv.Velocity = (self.hrp.CFrame.LookVector * CONFIG.DownslamVelocity.ZAxis) + (self.hrp.CFrame.UpVector * CONFIG.DownslamVelocity.YAxis)
            Debris:AddItem(bv, 0.2)

        end, self.ValidateDownslamHitParams)
    end

    --[[track:GetMarkerReachedSignal("Hit"):Connect(function()
        fireHitbox()
    end)]]

    track.Ended:Connect(function()
        session:Stop()
    end)

    task.delay(.275, fireHitbox)
end

return Melee