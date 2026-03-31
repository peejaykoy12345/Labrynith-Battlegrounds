local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local RaycastHelper = require(ReplicatedStorage.Packages.RaycastHelper)

local RocksModule = require(script.Parent.RocksModule)
local CraterModule = require(script.Parent.CraterModule)
local VFXUtils = require(ReplicatedStorage.Shared.Utils.VFXUtils)

local module = {}

function module:Start(args)
    local target = args.target
    local fxDelay = args.fxDelay or 0

    local hrp = target:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local CanContinue = true
    local connection: RBXScriptConnection?

    task.wait(fxDelay)
    if not CanContinue then
        if connection then connection:Disconnect(); connection = nil end
        return
    end

    connection = RunService.Heartbeat:Connect(function()
        if not CanContinue then
            if connection then connection:Disconnect(); connection = nil end
            return
        end

        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        rayParams.FilterDescendantsInstances = {target}

        local result = RaycastHelper.raycast({
            origin = hrp.Position,
            direction = Vector3.new(0, -4, 0),
            rayParams = rayParams
        })

        if result then
            local pos = result.Position

            --RocksModule.Ground(pos, 8, Vector3.new(1.2, .9, 1.2) * 2, nil, 8, false, 1.4)
            CraterModule.formCrater({
                Position = pos,
                Radius = tonumber(10);
                rockSize = tonumber(2)
            })
            CraterModule.formCrater({
                Position = pos,
                Radius = tonumber(15);
                rockSize = tonumber(3)
            })
            CanContinue = false
        end
    end)
end

return module