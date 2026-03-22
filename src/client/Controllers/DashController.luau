

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local remotes = require(ReplicatedStorage.Packages.remotes)

local plr = Players.LocalPlayer

local DashController = Knit.CreateController{
	Name = "DashController"
}

function DashController:StartDash(hrp: BasePart, dir: string, camCFrame: CFrame)
	if not hrp then return end

	local isForward = dir == "Forward"
	local isBackward = dir == "Backward"
	local isMain = not (dir == "Right" or dir == "Left")

	local Speed = if isForward then 175 * .75 elseif isBackward then 70 else 140
	local multiplier = if isForward then .95 else 0.98
	local int = Speed
	local usedint = int

	local dirVector = if isForward then Vector3.new(0, 0, -1)
		elseif isBackward then Vector3.new(0, 0, 1)
		elseif dir == "Right" then Vector3.new(1, 0, 0)
		else Vector3.new(-1, 0, 0)

	if hrp:FindFirstChild("DashAttachment") then
		hrp:FindFirstChild("DashAttachment"):Destroy()
	end

	local attachment = Instance.new("Attachment")
	attachment.Name = "DashAttachment"
	attachment.Parent = hrp

	local lv = Instance.new("LinearVelocity")
	lv.MaxForce = 40000
	lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
	lv.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
	lv.VectorVelocity = dirVector * usedint
	lv.Attachment0 = attachment
	lv.Name = "DashVel"
	lv.Parent = hrp

	local lifetime = if isMain then 1 else 0.15
	local bindName = hrp.Parent.Name .. dir .. "ModuleDashRotate"

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
		hrp.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + camCFrame.LookVector * Vector3.new(1, 0, 1))
		lv.VectorVelocity = dirVector * usedint
	end)

	task.spawn(function()
		while lv.Parent do
			int *= multiplier
			usedint = int
			if int <= 1 then break end
			task.wait(1 / 60)
		end
		if lv and lv.Parent then lv:Destroy() end
		if attachment and attachment.Parent then attachment:Destroy() end
	end)

	task.delay(lifetime, function()
		RunService:UnbindFromRenderStep(bindName)
		if lv and lv.Parent then lv:Destroy() end
		if attachment and attachment.Parent then attachment:Destroy() end
	end)

	lv.Destroying:Connect(function()
		RunService:UnbindFromRenderStep(bindName)
		if attachment and attachment.Parent then attachment:Destroy() end
	end)
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