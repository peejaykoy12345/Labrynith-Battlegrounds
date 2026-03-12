local TweenService = game:GetService("TweenService")

local Utils = {}

function Utils.Tween(object, goal, Time, loopstime, reverse)
	Time = Time or 1
	local Ti = TweenInfo.new(
		Time,
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.In,
		loopstime or 0,
		reverse or false
	)
	local goal = goal or {}
	local t = TweenService:Create(object, Ti, goal)
	t:Play()
	return t
end

function Utils.emitEveryParticleEmitter(part: BasePart | Attachment)
	for _, particleEmitter in pairs(part:GetDescendants()) do
		if not particleEmitter:IsA("ParticleEmitter") then continue end
		
		task.spawn(function()
			task.wait(0.05)
			local emitCount = particleEmitter:GetAttribute("EmitCount")
			particleEmitter:Emit(emitCount)
		end)
		
	end
end

function Utils.toggleParticleEmitters(part: BasePart | Attachment, status: boolean)
	for _, particleEmitter in pairs(part:GetDescendants()) do
		if not particleEmitter:IsA("ParticleEmitter") then continue end

		task.spawn(function()
			task.wait(0.05)
			particleEmitter.Enabled = status
		end)
	end
end

return Utils