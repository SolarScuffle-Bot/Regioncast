--!strict

local Module = {}

function Module.getClosestCorner(origin: Vector3, object: Model | BasePart): Vector3
	local size, pivot
	if object:IsA("BasePart") then
		size = object.Size
		pivot = object.CFrame
	elseif object:IsA("Model") then
		size = object:GetExtentsSize()
		pivot = object:GetPivot()
	end

	local relative = pivot:PointToObjectSpace(origin)
	local sign = Vector3.new(math.sign(relative.X), math.sign(relative.Y), math.sign(relative.Z))
	return pivot * (size * sign / 2)
end

function Module.regioncast(origin: Vector3, radius: number, overlapParams: OverlapParams, raycastParams: RaycastParams): { Model | BasePart }
	local found = workspace:GetPartBoundsInRadius(origin, radius, overlapParams)

	local objects = {}
	for _, part in found do
		local model = part:FindFirstAncestorWhichIsA("Model")
		local key =  if not model or model == workspace then part else model
		objects[key] = true
	end

	local seen = {}
	for object in objects do
		local corner = Module.getClosestCorner(origin, object)
		local delta = corner - origin
		local offsetDelta = if delta.Magnitude < 1e-8 then Vector3.zero else delta.Unit * math.min(radius, delta.Magnitude + 0.1) -- If I just do delta.Magnitude, it will sometimes just barely not reach
		local result = workspace:Raycast(origin, offsetDelta, raycastParams)

		if result and if object:IsA("BasePart")
			then result.Instance == object
			else result.Instance:FindFirstAncestorWhichIsA("Model") == object
		then
			table.insert(seen, object)
		end
	end

	return seen
end

return Module
