local Info = Info

local Copify = Info.Copify
local World = Info.World
local Player = Info.Player
local Vehicle = Player.Vehicle

local memory_read_long = memory.read_long
local memory_read_byte = memory.read_byte
local entities_get_position = entities.get_position
local entities_pointer_to_handle = entities.pointer_to_handle

local GetEntityVelocity = GetEntityVelocity
local GetPedInVehicleSeat = GetPedInVehicleSeat
local GetEntityAttachedTo = GetEntityAttachedTo
local IsPedAPlayer = IsPedAPlayer
local NetworkRequestControlOfEntity = NetworkRequestControlOfEntity

local yield = JM36.yield

local NetworkGetEntityOwnerFromPointer <const> = function(EntityPointer)
	local EntityPointerOwnerAddress = memory_read_long(EntityPointer + 0xD0)
	return EntityPointerOwnerAddress ~= 0 and memory_read_byte(EntityPointerOwnerAddress + 0x49) or -1
end
local SelfPlayerCoords = v3.new()

JM36.CreateThread(function()
	while true do
		if Copify.Enabled then
			local SelfPlayerId = Player.Id
			SelfPlayerCoords:set(Player.Coords);SelfPlayerCoords:add(Vehicle.IsIn ? GetEntityVelocity(Vehicle.Id) : GetEntityVelocity(Player.Ped))
			local PointersVehicles = World.PointersVehicles
			for Index, VehiclePointer in PointersVehicles do
				local EntityOwner = NetworkGetEntityOwnerFromPointer(VehiclePointer)
				if EntityOwner ~= -1 and EntityOwner ~= SelfPlayerId and SelfPlayerCoords:distance(entities_get_position(VehiclePointer)) < 125.0--[[250.0]] then
					local VehicleHandle = entities_pointer_to_handle(VehiclePointer)
					local VehicleOperator = GetPedInVehicleSeat(VehicleHandle, -1, false)
					if GetEntityAttachedTo(VehicleHandle) == 0 and (VehicleOperator == 0 or not IsPedAPlayer(VehicleOperator)) then
						NetworkRequestControlOfEntity(VehicleHandle)
					end
				end
			end
		end
		yield()
	end
end)