local Velocity = {}

function Velocity.CreateBV(parent: Instance, MaxForce: Vector3)
    local bv = Instance.new("BodyVelocity")
	bv.MaxForce = MaxForce or bv.MaxForce
	bv.Parent = parent
	return bv
end

return Velocity