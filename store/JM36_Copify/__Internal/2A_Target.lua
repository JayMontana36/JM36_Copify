local Info = Info

local Player = Info.Player
local Vehicle = Player.Vehicle

local GetPlayerTargetEntity = GetPlayerTargetEntity
local GetEntityPlayerIsFreeAimingAt = GetEntityPlayerIsFreeAimingAt
local GetVehicleLockOnTarget = GetVehicleLockOnTarget
local GetFinalRenderedCamCoord = GetFinalRenderedCamCoord
local GetFinalRenderedCamRot = GetFinalRenderedCamRot
local GetShapeTestResult = GetShapeTestResult
local StartExpensiveSynchronousShapeTestLosProbe = StartExpensiveSynchronousShapeTestLosProbe
local StartShapeTestCapsule = StartShapeTestCapsule
local DoesEntityExist = DoesEntityExist

local v3_new = v3.new
local memory_alloc = memory.alloc
local memory_alloc_int = memory.alloc_int
local memory_read_int = memory.read_int
local memory_read_byte = memory.read_byte

local CreateThread = JM36.CreateThread
local yield = JM36.yield

local Distance <const> = 2500.0
local Radius <const> = 1.25

local CollisionA = memory_alloc(1)
local EndCoordsA = v3_new()
local EntityHitA = memory_alloc_int()
local EntOffsetA = v3_new()
local CollisionB = memory_alloc(1)
local EndCoordsB = v3_new()
local EntityHitB = memory_alloc_int()
local EntOffsetB = v3_new()

local MemPtrTgt = memory_alloc_int()

local Target <const> =
{
	CollisionA = false,
	EndCoordsA = EndCoordsA,
	EntityHitA = 0,
	EntOffsetA = EntOffsetA,
	CollisionB = false,
	EndCoordsB = EndCoordsB,
	EntityHitB = 0,
	EntOffsetB = EntOffsetB,
	
	TgtCurrent = 0,
	EntityLast = 0,
}
Info.Target = Target

JM36.CreateThread_HighPriority(function()
	while true do
		local Veh = Vehicle.IsIn and Vehicle.Id
		
		do
			local Player_Id = Player.Id
			if (GetPlayerTargetEntity(Player_Id, MemPtrTgt) or GetEntityPlayerIsFreeAimingAt(Player_Id, MemPtrTgt)) or (Veh and GetVehicleLockOnTarget(Veh, MemPtrTgt)) then
				Target.TgtCurrent = memory_read_int(MemPtrTgt)
			else
				Target.TgtCurrent = 0
			end
		end
		
		local Entity = Veh or Player.Ped
		
		local CoordsStart = GetFinalRenderedCamCoord()
		local CoordsEnd = GetFinalRenderedCamRot(2):toDir();CoordsEnd:mul(Distance);CoordsEnd:add(CoordsStart)
		
		local CoordsStart_x, CoordsStart_y, CoordsStart_z = CoordsStart:get()
		local CoordsEnd_x, CoordsEnd_y, CoordsEnd_z = CoordsEnd:get()
		do
			GetShapeTestResult(StartExpensiveSynchronousShapeTestLosProbe(CoordsStart_x, CoordsStart_y, CoordsStart_z, CoordsEnd_x, CoordsEnd_y, CoordsEnd_z, 14--[[15]]--[[17 for info probe]], Entity, 0), CollisionA, EndCoordsA, EntOffsetA, EntityHitA)
			local _CollisionA = memory_read_byte(CollisionA) ~= 0
			Target.CollisionA = _CollisionA
			if not _CollisionA then
				EndCoordsA:set(CoordsEnd)
				EntOffsetA:reset()
				Target.EntityHitA = 0
			else
				Target.EntityHitA = memory_read_int(EntityHitA)
			end
		end
		do
			local ShapeTestHandle = StartShapeTestCapsule(CoordsStart_x, CoordsStart_y, CoordsStart_z, CoordsEnd_x, CoordsEnd_y, CoordsEnd_z, Radius, 14--[[15]]--[[17 for info probe]], Entity, 0)
			local Status = GetShapeTestResult(ShapeTestHandle, CollisionB, EndCoordsB, EntOffsetB, EntityHitB)
			if Status == 2 then
				local _CollisionB = memory_read_byte(CollisionB) ~= 0
				Target.CollisionB = _CollisionB
				if not _CollisionB then
					EndCoordsB:set(CoordsEnd)
					EntOffsetB:reset()
					Target.EntityHitB = 0
				else
					Target.EntityHitB = memory_read_int(EntityHitB)
				end
			else
				Target.CollisionB = false
				EndCoordsB:set(CoordsEnd)
				EntOffsetB:reset()
				Target.EntityHitB = 0
				CreateThread(function()
					while GetShapeTestResult(ShapeTestHandle, memory_alloc(1), v3_new(), v3_new(), memory_alloc_int()) == 1 do
						yield()
					end
				end)
			end
		end
		if Target.TgtCurrent ~= 0 then
			Target.EntityLast = Target.TgtCurrent
		elseif Target.CollisionA and DoesEntityExist(Target.EntityHitA) then
			Target.EntityLast = Target.EntityHitA
		elseif Target.CollisionB and DoesEntityExist(Target.EntityHitB) then
			Target.EntityLast = Target.EntityHitB
		elseif not DoesEntityExist(Target.EntityLast) then
			Target.EntityLast = 0
		end
		yield()
	end
end)
