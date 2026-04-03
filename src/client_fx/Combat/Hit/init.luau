local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VFXUtils = require(ReplicatedStorage.Shared.Utils.VFXUtils)

local Hit = {}

function Hit:Start(args)
    local target = args.target

	local HL = script.Highlight:Clone()
	HL.Parent = target
	HL.FillTransparency = 0.5
	HL.OutlineTransparency = 0
	HL.Adornee = target
	HL.FillColor = Color3.fromRGB(255, 255, 255)

	-- Tween to fade out quickly
	--VFXUtils.Tween(HL, {FillTransparency = 1, OutlineTransparency = 1}, 0.15)

	print(target, HL)

	-- Destroy after tween
	Debris:AddItem(HL, 3)
end

return Hit