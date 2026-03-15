local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Knit = require(ReplicatedStorage.Packages.Knit)

local M1Controller = Knit.CreateController {
	Name = "M1Controller";
}

local player = Players.LocalPlayer

local function getChar()
	return player.Character
end

local function isJumping()
	local char = getChar()
	if not char then return false end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return false end
	return hum.Jump
end

function M1Controller:disableJump(duration)
	local char = getChar()
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	local ogJH = char:GetAttribute("ogJH") or 7.2
	local ogJP = char:GetAttribute("ogJP") or 50
	local elapsed = 0
	if self.conn then self.conn:Disconnect() end
	self.conn = game:GetService("RunService").Heartbeat:Connect(function(dt)
		elapsed += dt
		hum.JumpHeight = 0
		hum.JumpPower = 0
		if elapsed >= duration then
			self.conn:Disconnect()
			hum.JumpHeight = ogJH
			hum.JumpPower = ogJP
		end
	end)
end

function M1Controller:KnitStart()
	self.ActionService = Knit.GetService("ActionService")

	local isHold = false

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			isHold = true

			task.spawn(function()
				while isHold do
					local char = getChar()
					local hum = char and char:FindFirstChildOfClass("Humanoid")

					if char and char:GetAttribute("M1Finisher") and hum:GetState() == Enum.HumanoidStateType.Freefall then
						self.ActionService:PerformAction("Downslam", {})
					elseif isJumping() and char and char:GetAttribute("M1Finisher") then
						self:disableJump(.6)
						self.ActionService:PerformAction("Uppercut", {})
					else
						if not char:GetAttribute("M1Finisher") then
							self:disableJump(.6)
						end
						self.ActionService:PerformAction("M1", {})
					end

					task.wait(0.5)
				end
			end)
		end
	end)

	UserInputService.InputEnded:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			isHold = false
		end
	end)
end

return M1Controller