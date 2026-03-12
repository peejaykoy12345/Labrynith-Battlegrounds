local States: {[Model]: {[string]: boolean}} = {}

local AncestryChangedConnections: {[Model]: RBXScriptConnection} = {}
local HumanoidDiedConnection: {[Model]: RBXScriptConnection} = {}

local StateManager = {}

function StateManager.InitializeModel(char: Model)
	States[char] = {}
	
	if not AncestryChangedConnections[char] then
		AncestryChangedConnections[char] = char.AncestryChanged:Connect(function(_, parent)
			if not parent then
				States[char] = nil
				if AncestryChangedConnections[char] then
					AncestryChangedConnections[char]:Disconnect()
					AncestryChangedConnections[char] = nil
				end
			end
		end)
	end
	
	if not HumanoidDiedConnection[char] then
		HumanoidDiedConnection[char] = char.Humanoid.Died:Connect(function()
			States[char] = nil
			if HumanoidDiedConnection[char] then
				HumanoidDiedConnection[char]:Disconnect()
				HumanoidDiedConnection[char] = nil
			end
		end)
	end
end

function StateManager.RemoveState(char: Model, state: string)
	if not States[char] then return end

	States[char][state] = nil
end

function StateManager.BulkRemoveState(chars: {Model}, state: string)
	for _, char in ipairs(chars) do
		StateManager.RemoveState(char, state)
	end
end

function StateManager.SetState(char: Model, state: string, value: boolean | number | string)
	if not States[char] then
		StateManager.InitializeModel(char)
	end
	
	if not HumanoidDiedConnection[char] then
		HumanoidDiedConnection[char] = char:WaitForChild("Humanoid").Died:Connect(function()
			States[char] = nil
			if HumanoidDiedConnection[char] then
				HumanoidDiedConnection[char]:Disconnect()
				HumanoidDiedConnection[char] = nil
			end
		end)
	end
	
	States[char][state] = value
end

function StateManager.GetAllStates(char: Model)
	if not States[char] then
		StateManager.InitializeModel(char)
		return {}
	end
	return States[char]
end

function StateManager.BulkSetState(chars: {Model}, state: string, value: boolean | number | string)
	for _, char in ipairs(chars) do
		StateManager.SetState(char, state, value)
	end
end

function StateManager.HasState(char: Model, state: string)
	if not States[char] then
		StateManager.InitializeModel(char)
		return false
	end
	return States[char][state]
end

local RESTRICTED_ACTION_STATES = {
	"CantUse",
	"InCutscene",
    "Stunned",
	"Blocking"
}

function StateManager.isActionBlocked(char: Model, statesToSkip: {string}?): boolean
	for _, state in ipairs(RESTRICTED_ACTION_STATES) do
		if statesToSkip and statesToSkip[state] then continue end
		
		if StateManager.HasState(char, state) then
			return true
		end
	end
	
	local humanoid = char:FindFirstChildWhichIsA("Humanoid")
	if not humanoid then
		warn(`{char.Name} has no humanoid`)
		return true
	end

	if humanoid.Health <= 0 then
		return true
	end
	
	return false
end

local INVINCIBLE_STATES = {
	"IFrames",
	"Ragdoll",
	"AwakeningIFrames",
	"SpawnIFrames",
}

function StateManager.isCharacterInvincible(char: Model, statesToSkip: {string}?): boolean
	for _, state in ipairs(INVINCIBLE_STATES) do
		if statesToSkip and statesToSkip[state] then continue end
		
		if StateManager.HasState(char, state) then
			print(`{char.Name} == {state}`)
			return true
		end
	end
	
	local humanoid = char:FindFirstChildWhichIsA("Humanoid")
	if not humanoid then
		warn(`{char.Name} has no humanoid`)
		return true
	end

	if humanoid.Health <= 0 then
		return true
	end
	
	return false
end

return StateManager