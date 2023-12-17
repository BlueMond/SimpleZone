--[[
    Zone class
    Written in Lua for Roblox by BlueMond

    Description:
    The Zone class is used to create and manage zone-based game mechanics. 
    A Zone is defined as a spherical region in 3D space with a certain position and radius. 

    Each Zone can track BaseParts, such that when the part enters or exits the zone, 
    corresponding events are triggered. Users can attach callback functions to these 
    events via the onPartEnter and onPartExit methods. 

    The class is designed to efficiently manage multiple parts and zones, using a 
    simplified approach by leveraging magnitude to determine if a part is within the zone. 
    This makes it useful for a variety of game mechanics that involve region tracking 
    like capture points, proximity-based effects, etc.

    Class Properties:
    position - The center of the zone as a Vector3.
    radius - The radius of the zone as a number.
    
    Internal Properties:
    _trackedParts - A table that stores all the parts being tracked by the Zone instance.
    _heartbeat - A reference to the heartbeat connection used for regular zone updates.

    Class Methods:
    new() - Creates a new instance of Zone.
    track(BasePart) - Tracks a part within the zone.
    untrack(BasePart) - Stops tracking a part within the zone.
    onPartEnter(BasePart, function) - Connects a callback function to the onEnter signal of a tracked part.
    onPartExit(BasePart, function) - Connects a callback function to the onExit signal of a tracked part.
    isPointInZone(Vector3) - Returns true if the given point is within the zone.
    destroy() - Disconnects the heartbeat, disconnects all signals, and cleans up the Zone instance.

    Internal Methods:
    _update() - Checks which tracked parts are currently in the zone, and fires corresponding events.
    _connectHeartbeat() - Connects the Zone update method to the RunService heartbeat.
]]


local Zone = {}
Zone.__index = Zone

local RunService = game:GetService("RunService")
local Signal = require(game:GetService("ReplicatedStorage").Utilities.GoodSignal)

function Zone.new(position: Vector3, radius: number, name: string)
	local self = setmetatable({}, Zone)

	self.position = position
	self.radius = radius
	self.name = name

	self._trackedParts = {}
	self._heartbeat = nil

	self:_connectHeartbeat()

	return self
end

function Zone:track(part: BasePart, isCamera: boolean?)
	if not part:IsA("BasePart") and not isCamera then 
		warn("Argument must be a BasePart or Camera") 
		return
	end

	if not self._trackedParts[part] then
		self._trackedParts[part] = {
			inZone = false,
			signals = {
				onEnter = Signal.new(),
				onExit = Signal.new()
			},
			isCamera = isCamera
		}
	end
end

function Zone:untrack(part: BasePart)
	if not self._trackedParts[part] then return end

	self._trackedParts[part].signals.onEnter:DisconnectAll()
	self._trackedParts[part].signals.onExit:DisconnectAll()
	self._trackedParts[part] = nil
end

function Zone:onPartEnter(part: BasePart, callback)
	local trackedPart = self._trackedParts[part]
	if not trackedPart then
		warn("Part is not being tracked")
		return
	end

	return trackedPart.signals.onEnter:Connect(callback)
end

function Zone:onPartExit(part: BasePart, callback)
	local trackedPart = self._trackedParts[part]
	if not trackedPart then
		warn("Part is not being tracked")
		return
	end

	return trackedPart.signals.onExit:Connect(callback)
end

function Zone:isPointInZone(position: Vector3)
	return (position - self.position).Magnitude <= self.radius
end

function Zone:_update()
	for part, data in pairs(self._trackedParts) do
		if not part.Parent and not data.isCamera then
			self:untrack(part)
			continue
		end

		local partPosition = data.isCamera and part.CFrame.Position or part.Position
		local inZone = (partPosition - self.position).Magnitude <= self.radius

		if inZone ~= data.inZone then
			data.inZone = inZone
			if inZone then
				data.signals.onEnter:Fire()
			else
				data.signals.onExit:Fire()
			end
		end
	end
end

function Zone:_connectHeartbeat()
	self._heartbeat = RunService.Heartbeat:Connect(function()
		self:_update()
	end)
end

function Zone:destroy()
	self._heartbeat:Disconnect()
	for _, trackedPart in pairs(self._trackedParts) do
		trackedPart.signals.onEnter:DisconnectAll()
		trackedPart.signals.onExit:DisconnectAll()
	end

	self._trackedParts = nil
end

return Zone
