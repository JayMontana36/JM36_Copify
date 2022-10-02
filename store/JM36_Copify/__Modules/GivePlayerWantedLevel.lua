local CreateThread = JM36.CreateThread_HighPriority
local yield = JM36.yield

local entities_create_ped = entities.create_ped
local entities_delete_by_handle = entities.delete_by_handle

local NetworkGetLastPlayerPosReceivedOverNetwork = NetworkGetLastPlayerPosReceivedOverNetwork
local IsSphereVisibleToAnotherMachine = IsSphereVisibleToAnotherMachine
local GetPlayerPed = GetPlayerPed
local AddOwnedExplosion = AddOwnedExplosion

local RequestEntityModel = require'RequestEntityModel'

local CopHsh;CreateThread(function()CopHsh=GetHashKey"s_m_y_cop_01"end)

return function(PlayerId)CreateThread(function()
	if RequestEntityModel(CopHsh) then
		local CopCoords = NetworkGetLastPlayerPosReceivedOverNetwork(PlayerId)
		CopCoords.z = CopCoords.z + 125.0
		while IsSphereVisibleToAnotherMachine(CopCoords, 1.5) and CopCoords.z < 2400 do
			CopCoords.z = CopCoords.z + 25.0
		end
		local CopPed = entities_create_ped(6, CopHsh, CopCoords, 0.0)
		if CopPed ~= 0 then
			AddOwnedExplosion(GetPlayerPed(PlayerId), CopCoords, 45, 1.0, false, true, 0.0)
			entities_delete_by_handle(CopPed)
		end
	end
end)end
