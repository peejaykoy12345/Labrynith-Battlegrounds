local Debris = game:GetService("Debris")
local ServerScriptService = game:GetService("ServerScriptService")

local UtilitiesFolder = ServerScriptService.Server.Utilities
local CombatUtilities = UtilitiesFolder.Combat
local Hitbox = require(CombatUtilities.Hitbox)
local CooldownService = require(ServerScriptService.Server.Services.CooldownService)

local MoveUtils = {}

function MoveUtils:CreateStandardHitbox(config)
	config = config or {}

	local hitbox = Hitbox.CreateHitbox()
	hitbox.Size = config.SIZE or Vector3.new(4, 4, 4)
	hitbox.CFrame = config.CFrame or CFrame.new(0, 0, 0)
	hitbox.Visualizer = false --config.VISUALIZER ~= false 
	return hitbox
end

function MoveUtils:CanPerformAction(plr: Player, actionName: string): boolean
	if CooldownService:IsOnCooldown(plr, actionName) then
		return false
	end

	return true
end

function MoveUtils:GetModelMass(model: Model)
	local Mass = 0
	for _, Part in pairs(model:GetDescendants()) do
		if Part:IsA("BasePart") then
			Mass += Part:GetMass()		
		end
	end
	return Mass
end

function MoveUtils:FacePlayer(enemyRoot: BasePart, attackerRoot: BasePart)
    if not enemyRoot or not attackerRoot then return end
    
    local BodyGyro = Instance.new("BodyGyro")
    BodyGyro.MaxTorque = Vector3.new(12, 15555, 12)
    BodyGyro.P = 10000
    BodyGyro.CFrame = CFrame.lookAt(enemyRoot.CFrame.Position, attackerRoot.Position + Vector3.new(0, 2, 0))
    BodyGyro.Parent = enemyRoot
    Debris:AddItem(BodyGyro, .35)
end

return MoveUtils