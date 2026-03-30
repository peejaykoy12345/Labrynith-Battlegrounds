local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local AnimationPlayer = require(ReplicatedStorage.Shared.AnimationPlayer)

local AnimationService = Knit.CreateService{
	Name = "AnimationService",
	Client = {},
}

function AnimationService:KnitInit()
	local animationLoader = workspace.AnimationLoader
	local humanoid = animationLoader:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

	if not animator then
		warn("[AnimationService] No Animator found on AnimationLoader rig")
		return
	end

	local animationAssets = ReplicatedStorage.Animations

	task.spawn(function()
		for _, animationAsset in pairs(animationAssets:GetChildren()) do
			if not animationAsset:IsA("Animation") then continue end

			local track = animator:LoadAnimation(animationAsset)
			track:Play()
			track.Stopped:Wait()
		end

		print("Finished preplaying animations")
	end)
end

function AnimationService:Play(character: Model, animationId: string, playOptionsParams)
	return AnimationPlayer:Play(character, animationId, playOptionsParams)
end

function AnimationService:StopAnimation(track: AnimationTrack)
	return AnimationPlayer:StopAnimation(track)
end

return AnimationService