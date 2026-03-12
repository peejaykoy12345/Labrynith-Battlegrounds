local Debris = game:GetService("Debris")
local ServerScriptService = game:GetService("ServerScriptService")

local UtilitiesFolder = ServerScriptService.Server.Utilities
local CombatUtilities = UtilitiesFolder.Combat
local Hitbox = require(CombatUtilities.Hitbox)
local CooldownService = require(ServerScriptService.Server.Services.CooldownService)
local StateManager = require(CombatUtilities.StateManager)
local BlockUtils = require(CombatUtilities.BlockUtils)

local MoveUtils = {}

function MoveUtils:CreateStandardHitbox(config)
	config = config or {}

	local hitbox = Hitbox.CreateHitbox()
	hitbox.Size = config.SIZE or Vector3.new(4, 4, 4)
	hitbox.CFrame = config.CFrame or CFrame.new(0, 0, 0)
	hitbox.Visualizer = false --config.VISUALIZER ~= false 
	return hitbox
end

function MoveUtils:CanPerformAction(char: Model, actionName: string, params): boolean
	params = params or {}

	if StateManager.isActionBlocked(char, params.statesToSkip) then
		return false
	end

	if CooldownService:IsOnCooldown(char, actionName) then
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

function MoveUtils:RagdollCharacter(target: Model, duration: number, ragdollStatus: boolean?)
	ragdollStatus = ragdollStatus or true

	local RagdollTrigger = target:FindFirstChild("RagdollTrigger")
	if not RagdollTrigger then
		warn(`RagdollTrigger not found in {target.Name}`)
		return
	end

	RagdollTrigger.Value = ragdollStatus
	task.delay(duration, function()
		RagdollTrigger.Value = not ragdollStatus
	end)
end

local RecentHits = {} -- [attacker][target] = true

function MoveUtils:RegisterHit(attacker, target)
    RecentHits[attacker] = RecentHits[attacker] or {}
    RecentHits[attacker][target] = true
    task.delay(0.5, function()
        if RecentHits[attacker] then
            RecentHits[attacker][target] = nil
        end
    end)
end

type ValidateHitParams = {
	StatesToSkip: {[string]: boolean}
}

function MoveUtils:ValidateHit(attacker, target, params: ValidateHitParams?): boolean
	params = params or {}

	if attacker == target then
		return false
	end

	if RecentHits[target] and RecentHits[target][attacker] then return false end

	if StateManager.isCharacterInvincible(target, params.StatesToSkip) then
		return false
	end

	local hrp = attacker:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return false
	end

	if params.Block ~= nil and params.Block.Blockable then
		local blockAngle = params.blockAngle
		if BlockUtils.IsBlocking(hrp.Position, target, blockAngle) then return false end
	end

	return true
end

return MoveUtils