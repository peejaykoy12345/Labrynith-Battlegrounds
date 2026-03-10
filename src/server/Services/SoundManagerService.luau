local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local SoundManagerService = Knit.CreateService({
	Name = "SoundManagerService",
	Client = {}
})

local cache = {} -- [soundId] = {Sound}

local function returnToCache(soundId: string, sound: Sound)
	sound:Stop()
	sound.Parent = nil

	if not cache[soundId] then
		cache[soundId] = {}
	end

	table.insert(cache[soundId], sound)
end

function SoundManagerService:Play(soundId: string, parent: Instance)
	local sound = self:LoadSound(soundId, parent)

	sound:Play()

	task.delay(sound.TimeLength, function()
		if not sound.Playing then
			returnToCache(soundId, sound)
		else
			sound.Stopped:Wait()
			returnToCache(soundId, sound)
		end
	end)
end

function SoundManagerService:LoadSound(soundId: string, parent: Instance)
	local assetUri = "rbxassetid://" .. tostring(soundId)  

	if cache[soundId] and #cache[soundId] > 0 then
		local sound = table.remove(cache[soundId])
		sound.Parent = parent
		return sound
	end

	local sound = Instance.new("Sound")
	sound.SoundId = assetUri  
	sound.Parent = parent
	return sound
end

return SoundManagerService