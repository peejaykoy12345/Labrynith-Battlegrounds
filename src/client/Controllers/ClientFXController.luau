local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local remotes = require(ReplicatedStorage.Packages.remotes)

local ClientFXEvent: RemoteEvent = remotes:getEventAsync("ClientFX")

local ClientFX = ReplicatedStorage.Assets.ClientFX

local ClientFXController = Knit.CreateController {
    Name = "ClientFXController",
}

function ClientFXController:KnitStart()
    ClientFXEvent.OnClientEvent:Connect(function(fxData, args)
        local fxType = fxData.Type
        local typeFolder = ClientFX[fxType]

        local name = fxData.Name
        local module_script = typeFolder:FindFirstChild(name)
        if not module_script then
            warn("Module script not found: " .. name)
            return
        end

        local fxModule = require(module_script)
        fxModule:Start(args)
    end)
end

return ClientFXController