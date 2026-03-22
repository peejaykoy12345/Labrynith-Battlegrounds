local Velocity = {}

function Velocity.CreateBV(parent: Instance, MaxForce: Vector3)
    local bv = Instance.new("BodyVelocity")
	bv.MaxForce = MaxForce or bv.MaxForce
	bv.Parent = parent
	return bv
end

type LinearVelocityParams = {
	Velocity: Vector3,
	Attachment: Attachment?,
	MaxForce: number?,
	Lifetime: number?,
	Name: string?
}

function Velocity.ParentAndCreateAttachment(parent: Instance)
	local att = Instance.new("Attachment", parent)
	return att
end

function Velocity.CreateLV(parent: Instance, params: LinearVelocityParams)
	local att = Velocity.ParentAndCreateAttachment(parent)

	local lv = Instance.new("LinearVelocity")
	lv.MaxForce = params.MaxForce or 40000
	lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
	lv.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
	lv.VectorVelocity = params.Velocity
	lv.Attachment0 = params.Attachment or att
	lv.Name = params.Name or "LinearVelocity"
	lv.Parent = parent

	local lifetime = params.Lifetime
	if lifetime then
		task.delay(lifetime, function()
			lv:Destroy()
			att:Destroy()
		end)
	end

	return lv, att
end

return Velocity