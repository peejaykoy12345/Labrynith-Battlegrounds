local Debris = game:GetService("Debris")
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
        ZAxis = 35, 
        YAxis = 15,
    },
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

Melee.SwingSFX = {

}

Melee.hitAnims = {
    
}

Melee.hitSFX = {
    
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
    end)

    self.comboCooldown = false

    return self
end

function Melee:ApplyVelocity(enemy: Model)
    local char = self.char
    local hrp = self.hrp
    local ehrp = enemy:FindFirstChild("HumanoidRootPart")
    if not ehrp then warn(`No hrp for {enemy.Name}`) return end

    local Mass1, Mass2 = MoveUtils:GetModelMass(char), MoveUtils:GetModelMass(enemy)

    local function createBv(parent, vel)
        local bv = Velocity.CreateBV(parent, Vector3.new(Mass1 + 30000, 0, Mass1 + 30000))
        bv.Velocity = vel
        Debris:AddItem(bv, .075)
    end

    createBv(hrp, hrp.CFrame.LookVector * 14)
    createBv(ehrp, hrp.CFrame.LookVector * 7)
end

function Melee:M1()
    if not MoveUtils:CanPerformAction(self.char, "DefaultM1") then return end
    if self.comboCooldown then return end

    local animToPlay = self.animIdToPlay

    if animToPlay > #self.M1anims then return end

    local session = ActionSession.new({
        attacker = self.char,
        actionName = "DefaultM1",
        actionType = "Cooldown",
    })

    if not session then return end

    CooldownService:SetCooldown(self.char, "DefaultM1", CONFIG.M1Cooldown)

    self.animIdToPlay += 1
    self.timer:Reset()

    if self.animIdToPlay > #self.M1anims then
        self.comboCooldown = true
        task.delay(CONFIG.ComboCooldown, function()
            self.animIdToPlay = 1
            self.comboCooldown = false
        end)
    end

    local track: AnimationTrack = session:PlayAndAddAnimation(self.char, self.M1anims[animToPlay], {Priority = 4})

    local hitboxFired = false

    local function fireHitbox()
        if hitboxFired then return end
        hitboxFired = true

        local hb = MoveUtils:CreateStandardHitbox({
            CFrame = self.hrp.CFrame * CFrame.new(0, 0, -3)
        })
        hb:Start()

        local updateConn = RunService.Heartbeat:Connect(function()
            hb.CFrame = self.hrp.CFrame * CFrame.new(0, 0, -3)
        end)

        hb.Touched:Connect(function(hitChar)
            if hitChar == self.char then return end
            local ehrp = hitChar:FindFirstChild("HumanoidRootPart")
            if not ehrp then return end

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

            if animToPlay == #self.M1anims then
                MoveUtils:RagdollCharacter(hitChar, 1.5)
                
                local cf = self.hrp.CFrame
                local bv = Velocity.CreateBV(ehrp, Vector3.new(math.huge, math.huge, math.huge))
                bv.Velocity = (cf.LookVector * CONFIG.Velocity.ZAxis) + (cf.UpVector * CONFIG.Velocity.YAxis)

                Debris:AddItem(bv, 0.2)
            else
                self:ApplyVelocity(hitChar)
            end
        end)

        session.hitbox = hb

        -- disconnect when hitbox stops
        task.delay(0.2, function()
            updateConn:Disconnect()
        end)
    end

    track:GetMarkerReachedSignal("Hit"):Connect(fireHitbox)
    task.delay(.275, fireHitbox) -- In case marker doesnt trigger

    --SoundManagerService:Play(self.SwingSFX[animToPlay], self.char)

    track.Ended:Connect(function()
        session:Stop()
    end)
end

return Melee