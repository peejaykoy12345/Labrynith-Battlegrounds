local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local remotes = require(ReplicatedStorage.Packages.remotes)

local ClientFXEvent: RemoteEvent = remotes:getEventAsync("ClientFX")

local ClientFXService = Knit.CreateService{
    Name = "ClientFXService",
    Client = {}
}

function ClientFXService:Start(fxData, args)
    ClientFXEvent:FireAllClients(fxData, args)
end

return ClientFXService