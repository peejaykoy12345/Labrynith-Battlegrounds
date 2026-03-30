local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local remotes = require(ReplicatedStorage.Packages.remotes)

local DashEvent: RemoteEvent = remotes:getEventAsync("Dash")
local UnDashEvent: RemoteEvent = remotes:getEventAsync("UnDash")

local plr = Players.LocalPlayer

local DashController = Knit.CreateController{
    Name = "DashController"
}

function DashController:StartDash(hrp: BasePart, dir: string)
    if not hrp then return end

    local isForward = dir == "Forward"
    local isBackward = dir == "Backward"
    local isSide = dir == "Right" or dir == "Left"
    local isMain = not isSide

    local alignDirection = if isForward then 0
        elseif isBackward then 180
        elseif dir == "Right" then -90
        else 90

    local char = hrp.Parent
    local hum = char:FindFirstChildOfClass("Humanoid")
    local isGrounded = hum and hum.FloorMaterial ~= Enum.Material.Air

    local multiplier = if isForward then .95 else 0.98
    local Speed = if isForward then 175 * .75 elseif isBackward then 70 else 140
    if not isGrounded then
        Speed = if isForward then 168.5 * .75 elseif isBackward then 70 else 95
    end
    local int = Speed
    local usedint = int
    local lifetime = if isMain then 1 else 0.15
    local bindName = hrp.Parent.Name .. dir .. "ModuleDashRotate"

    if hrp:FindFirstChild("DashVel") then
        hrp:FindFirstChild("DashVel"):Destroy()
    end
    RunService:UnbindFromRenderStep(bindName)

    local vel = Instance.new("BodyVelocity")
    vel.MaxForce = Vector3.new(1, 0, 1) * 40000
    vel.Name = "DashVel"
    vel:SetAttribute("Direction", dir)
    vel.Parent = hrp

    if isBackward then
        task.delay(.5, function()
            usedint = 0
            task.wait(.2)
            usedint = 150
        end)
    end

    if isForward then
        task.delay(.365, function()
            multiplier = .625
            int = 30
            usedint = 30
        end)
    end

    RunService:BindToRenderStep(bindName, Enum.RenderPriority.Character.Value + 1, function()
        local liveCam = workspace.CurrentCamera.CFrame
        hrp.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + liveCam.LookVector * Vector3.new(1, 0, 1))
        vel.Velocity = (hrp.CFrame * CFrame.Angles(0, math.rad(alignDirection), 0)).LookVector * usedint
    end)

    task.spawn(function()
        while vel.Parent do
            int *= multiplier
            usedint = int
            if int <= 1 then break end
            task.wait(1 / 60)
        end
        if vel and vel.Parent then vel:Destroy() end
    end)

    task.delay(lifetime, function()
        RunService:UnbindFromRenderStep(bindName)
        if vel and vel.Parent then vel:Destroy() end
    end)

    vel.Destroying:Connect(function()
        RunService:UnbindFromRenderStep(bindName)
    end)
end

function DashController:StopDash(hrp: BasePart)
    if not hrp then return end
    if hrp:FindFirstChild("DashVel") then
        hrp:FindFirstChild("DashVel"):Destroy()
    end
    if hrp:FindFirstChild("DashAttachment") then
        hrp:FindFirstChild("DashAttachment"):Destroy()
    end
end

local function GetDirection(hrp: BasePart, camCFrame: CFrame): string
    local moveDir = Vector3.new(
        (UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.A) and 1 or 0),
        0,
        (UserInputService:IsKeyDown(Enum.KeyCode.S) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.W) and 1 or 0)
    )

    if moveDir == Vector3.zero then return "Forward" end

    local flatLook = Vector3.new(camCFrame.LookVector.X, 0, camCFrame.LookVector.Z).Unit
    local flatRight = Vector3.new(camCFrame.RightVector.X, 0, camCFrame.RightVector.Z).Unit

    local worldDir = (flatLook * -moveDir.Z + flatRight * moveDir.X).Unit
    local dot = flatLook:Dot(worldDir)
    local cross = flatLook:Cross(worldDir).Y

    if dot >= 0.5 then
        return "Forward"
    elseif dot <= -0.5 then
        return "Backward"
    elseif cross > 0 then
        return "Left"
    else
        return "Right"
    end
end

function DashController:KnitInit()
    DashEvent.OnClientEvent:Connect(function(dir: string)
        local char = plr.Character
        if not char then return end

        local hrp = char:WaitForChild("HumanoidRootPart")
        local camCFrame = workspace.CurrentCamera.CFrame

        self:StartDash(hrp, dir, camCFrame)
    end)

    UnDashEvent.OnClientEvent:Connect(function()
        local char = plr.Character
        if not char then return end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        self:StopDash(hrp)
    end)
end

function DashController:KnitStart()
    self.ActionService = Knit.GetService("ActionService")

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed or input.KeyCode ~= Enum.KeyCode.Q then return end

        local char = plr.Character
        if not char then return end

        local hrp = char:WaitForChild("HumanoidRootPart")
        local camCFrame = workspace.CurrentCamera.CFrame

        local dir = GetDirection(hrp, camCFrame)
        if not dir then return end

        self.ActionService:PerformAction("Dash", {dir = dir})
    end)
end

return DashController