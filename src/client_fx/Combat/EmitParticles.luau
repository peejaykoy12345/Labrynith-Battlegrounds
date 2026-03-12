local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VFXUtils = require(ReplicatedStorage.Shared.Utils.VFXUtils)

local module = {}

function module:Start(args)
    local parent = args.parent
    local particleContainer = args.particleContainer:Clone()

    particleContainer.Parent = parent
    if particleContainer:IsA("BasePart") then
        particleContainer.CFrame = parent.CFrame
    end

    VFXUtils.emitEveryParticleEmitter(particleContainer)
end

return module