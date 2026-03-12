local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VFXUtils = require(ReplicatedStorage.Shared.Utils.VFXUtils)

local Hit = {}

function Hit:Start(args)
    local target = args.target

	local HL = script.Highlight:Clone()
	HL.Parent = target
	HL.FillTransparency = 0
	HL.OutlineTransparency = 0

	-- Tween to fade out quickly
	VFXUtils.Tween(HL, {FillTransparency = 1, OutlineTransparency = 1}, 0.15)

	-- Destroy after tween
	Debris:AddItem(HL, 0.155)
end

return Hit