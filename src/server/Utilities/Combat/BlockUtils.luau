local ServerScriptService = game:GetService("ServerScriptService")
local Block = {}

local StateManager = require(ServerScriptService.Server.Utilities.Combat.StateManager)

local BLOCK_ANGLE = 75 

local function isInFront(defenderHRP, attackerPosition, blockAngle)
	local defenderLook = defenderHRP.CFrame.LookVector
	local toAttacker = (attackerPosition - defenderHRP.Position).Unit
	local dot = defenderLook:Dot(toAttacker)
	local block_angle = blockAngle or BLOCK_ANGLE

	return dot >= math.cos(math.rad(block_angle))
end

function Block.IsBlocking(attackerPosition: Vector3, defender: Model, blockAngle: number?)
	if defender == nil then warn("defender is nil on skibidi") return end
	if not defender:IsA("Model") and not defender.Parent:IsA("Model") then return end

	local hrp = defender:FindFirstChild("HumanoidRootPart")
	if not hrp or not hrp:IsA("BasePart") then return false end

	local isBlocking = StateManager.HasState(defender, "Blocking")
	if not isBlocking then return false end

	if isBlocking and isInFront(hrp, attackerPosition, blockAngle) then
		return true
    end

	return false
end

return Block