-- Initializes remote events so that the they can be accessed through the client

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remotes = require(ReplicatedStorage.Packages.remotes)

local DashEvent: RemoteEvent = remotes:getEventAsync("Dash")
local UndashEvent: RemoteEvent = remotes:getEventAsync("UnDash")