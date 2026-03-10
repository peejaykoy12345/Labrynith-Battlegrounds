local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

Knit.AddControllersDeep(script.Parent.Controllers)
Knit.AddControllersDeep(ReplicatedStorage.UI)

Knit.Start()