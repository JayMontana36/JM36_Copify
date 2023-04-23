local Info = Info

local Copify = Info.Copify
local World = Info.World
local Player = Info.Player

local entities_handle_to_pointer = entities.handle_to_pointer
local entities_get_model_hash = entities.get_model_hash
local entities_get_player_info = entities.get_player_info
local entities_pointer_to_handle = entities.pointer_to_handle
local util_remove_blip = util.remove_blip

local GetPedType = GetPedType
local GetBlipFromEntity = GetBlipFromEntity
local AddBlipForEntity = AddBlipForEntity
local SetBlipAsFriendly = SetBlipAsFriendly
local SetBlipScale = SetBlipScale
local SetBlipAsMinimalOnEdge = SetBlipAsMinimalOnEdge
local ShowHeadingIndicatorOnBlip = ShowHeadingIndicatorOnBlip
--local SetBlipRotationWithFloat = SetBlipRotationWithFloat
--local GetEntityHeadingFromEulers = GetEntityHeadingFromEulers
local NetworkGetPlayerIndexFromPed = NetworkGetPlayerIndexFromPed
local GetPlayerWantedLevel = GetPlayerWantedLevel
local GetPlayerWantedCentrePosition = GetPlayerWantedCentrePosition
local NetworkGetLastPlayerPosReceivedOverNetwork = NetworkGetLastPlayerPosReceivedOverNetwork
local SetBlipCoords = SetBlipCoords
local AddBlipForRadius = AddBlipForRadius
local SetBlipAlpha = SetBlipAlpha
local SetBlipPriority = SetBlipPriority
local SetBlipColour = SetBlipColour
local SetBlipRoute = SetBlipRoute
--local SetBlipRouteColour = SetBlipRouteColour

local AutoCleanBlip = require'SelfCleanUp_Blips'

--local GetPlayerWantedCoordsFunction = GetPlayerWantedCentrePosition
local GetPlayerWantedCoordsFunction = NetworkGetLastPlayerPosReceivedOverNetwork
local WantedPlayerRadiusBlips <const> = {}
local WantedBlipColorChangeTime = 0
local WantedBlipFriendlyBool = false
local WasEnabled = false
local CopPedHsh <const> =
{
	"csb_cop",
	"s_f_y_cop_01",
	"s_f_y_ranger_01",
	"s_f_y_sheriff_01",
	--"s_m_m_armoured_01",
	--"s_m_m_armoured_02",
	--"s_m_m_chemsec_01",
	"s_m_m_ciasec_01",
	--"s_m_m_fiboffice_01",
	--"s_m_m_fiboffice_02",
	"s_m_m_fibsec_01",
	--"s_m_m_highsec_01",
	--"s_m_m_highsec_02",
	"s_m_m_marine_01",
	"s_m_m_marine_02",
	----"s_m_m_paramedic_01",
	--"s_m_m_pilot_01",
	"s_m_m_pilot_02",
	"s_m_m_prisguard_01",
	"s_m_m_security_01",
	"s_m_m_snowcop_01",
	----"s_m_y_ammucity_01",
	"s_m_y_armymech_01",
	"s_m_y_blackops_01",
	"s_m_y_blackops_02",
	"s_m_y_blackops_03",
	"s_m_y_cop_01",
	--"s_m_y_devinsec_01",
	--"s_m_y_fireman_01",
	--"s_m_y_grip_01",
	"s_m_y_hwaycop_01",
	"s_m_y_marine_01",
	"s_m_y_marine_02",
	"s_m_y_marine_03",
	"s_m_y_pilot_01",
	"s_m_y_ranger_01",
	"s_m_y_sheriff_01",
	"s_m_y_swat_01",
	"s_m_y_uscg_01",
	--"s_m_y_westsec_01",
}

local yield = JM36.yield

--[[Copify.MenuList:toggle("Don't show last known location", {}, 'Gave this a "weird/bad" name because I want people to investigate who is wanted themselves; turning this on means that the player\'s exact location is shown/pinned instead of the player\'s last known (by cops) location.',
	function(state)
		GetPlayerWantedCoordsFunction = (not state) ? GetPlayerWantedCentrePosition : NetworkGetLastPlayerPosReceivedOverNetwork
	end,
false)]]
Copify.MenuList:toggle("Don't pinpoint exact location", {}, "Turning this on means that the player's last known location (by cops) is shown instead of the player's exact location.",
	function(state)
		GetPlayerWantedCoordsFunction = state ? GetPlayerWantedCentrePosition : NetworkGetLastPlayerPosReceivedOverNetwork
	end,
false)

JM36.CreateThread(function()
	do
		local GetHashKey = GetHashKey
		for Index = 1, #CopPedHsh do
			CopPedHsh[GetHashKey(CopPedHsh[Index])] = true;CopPedHsh[Index] = nil
		end
	end
	while true do
		if Copify.Enabled then
			WasEnabled = true
			local WantedBlipFriendlyBoolFlip = Info.Time > WantedBlipColorChangeTime
			if WantedBlipFriendlyBoolFlip then
				WantedBlipFriendlyBool = not WantedBlipFriendlyBool
				WantedBlipColorChangeTime = Info.Time + 500
			end
			local SelfPedPointer = entities_handle_to_pointer(Player.Ped)
			local SelfPedCoords = Player.Coords
			local ClosestWantedBlipId, ClosestWantedBlipDistance = 0, 16384
			local PointersPeds = World.PointersPeds
			for Index, PedPointer in PointersPeds do
				local PedIsNonPlayerCharacter = entities_get_player_info == 0
				if CopPedHsh[entities_get_model_hash(PedPointer)] and PedIsNonPlayerCharacter then
					local PedHandle = entities_pointer_to_handle(PedPointer)
					local PedBlip
					pluto_switch GetPedType(PedHandle) do
						case 6:		-- cop
						case 27:	-- swat
						case 29:	-- army
						default:
							PedBlip = true
					end
					if PedBlip then
						PedBlip = GetBlipFromEntity(PedHandle)
						if PedBlip == 0 then
							PedBlip = AddBlipForEntity(PedHandle)
							AutoCleanBlip(PedBlip)
							SetBlipAsFriendly(PedBlip, true)
							SetBlipScale(PedBlip, 0.75)
							SetBlipAsMinimalOnEdge(PedBlip, true)
							ShowHeadingIndicatorOnBlip(PedBlip, true)
						end
						--SetBlipRotationWithFloat(PedBlip, GetEntityHeadingFromEulers())
					end
				elseif not PedIsNonPlayerCharacter and PedPointer ~= SelfPedPointer then
					local PedHandle = entities_pointer_to_handle(PedPointer)
					local PlayerId = NetworkGetPlayerIndexFromPed(PedHandle)
					local WantedBlip = WantedPlayerRadiusBlips[PlayerId]
					if GetPlayerWantedLevel(PlayerId) ~= 0 then
						local BlipCoords = GetPlayerWantedCoordsFunction(PlayerId)
						if WantedBlip then
							SetBlipCoords(WantedBlip, BlipCoords)
						else
							WantedBlip = AddBlipForRadius(BlipCoords, 50.0)
							WantedPlayerRadiusBlips[PlayerId] = WantedBlip
							SetBlipAlpha(WantedBlip, 96)
							SetBlipPriority(WantedBlip, 0)
							SetBlipColour(WantedBlip, WantedBlipFriendlyBool ? 3 : 1)
						end
						do
							local BlipDistance = SelfPedCoords:distance(BlipCoords)
							if ClosestWantedBlipDistance > BlipDistance then
								ClosestWantedBlipDistance = BlipDistance
								ClosestWantedBlipId = WantedBlip
							end
						end
						if WantedBlipFriendlyBoolFlip then
							SetBlipColour(WantedBlip, WantedBlipFriendlyBool ? 3 : 1)
						end
					elseif WantedBlip then
						util_remove_blip(WantedBlip)
						WantedPlayerRadiusBlips[PlayerId] = nil
					end
				end
			end
			if ClosestWantedBlipId ~= 0 then
				SetBlipRoute(ClosestWantedBlipId, true)
				--SetBlipRouteColour
			end
		elseif WasEnabled then
			for Index = 0, 31 do
				local WantedBlip = WantedPlayerRadiusBlips[Index]
				if WantedBlip then
					util_remove_blip(WantedBlip)
					WantedPlayerRadiusBlips[Index] = nil
				end
			end
			WasEnabled = false
		end
		yield()
	end
end)

return
{
	stop	=	function()
					for Index = 0, 31 do
						local WantedBlip = WantedPlayerRadiusBlips[Index]
						if WantedBlip then
							util_remove_blip(WantedBlip)
							WantedPlayerRadiusBlips[Index] = nil
						end
					end
				end
}
