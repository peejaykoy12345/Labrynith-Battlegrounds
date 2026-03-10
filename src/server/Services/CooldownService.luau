local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local CooldownService = Knit.CreateService {
    Name = "CooldownService";
    Client = {};
}

function CooldownService:KnitInit()
    self.Cooldowns = {}
end

function CooldownService:InitializeCharacter(char: Model)
    self.Cooldowns[char] = {}

    char.Humanoid.Died:Connect(function()
        self.Cooldowns[char] = nil
    end)
end

function CooldownService:SetCooldown(char: Model, action: string, cooldown: number)
    if not self.Cooldowns[char] then
        self:InitializeCharacter(char)
    end
    
    self.Cooldowns[char][action] = true
    task.delay(cooldown, function()
        self.Cooldowns[char][action] = nil
    end)
end

function CooldownService:IsOnCooldown(char: Model, action: string): boolean
    if not self.Cooldowns[char] then
        return false
    end

    return self.Cooldowns[char][action] ~= nil
    
end

return CooldownService