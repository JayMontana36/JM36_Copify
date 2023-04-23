local Info = Info

local Copify = Info.Copify
local Player = Info.Player
local Vehicle = Player.Vehicle

local players_list = players.list

local GetPlayerPed = GetPlayerPed
local GetPlayerWantedLevel = GetPlayerWantedLevel
local IsEntityOnScreen = IsEntityOnScreen
local IsEntityOccluded = IsEntityOccluded
local HasEntityClearLosToEntityInFront = HasEntityClearLosToEntityInFront
local ReportPoliceSpottedPlayer = ReportPoliceSpottedPlayer

local yield = JM36.yield

JM36.CreateThread(function()
	while true do
		if Copify.Enabled then
			local SelfPlayerPed, SelfPlayerVeh = Player.Ped, Vehicle.Id
			local Players = players_list(false, true, true)
			for Index, PlayerId in Players do
				local PlayerPed = GetPlayerPed(PlayerId)
				if PlayerPed ~= 0 and GetPlayerWantedLevel(PlayerId) ~= 0 then
					if IsEntityOnScreen(PlayerPed) and (not IsEntityOccluded(PlayerPed) or HasEntityClearLosToEntityInFront(SelfPlayerPed, PlayerPed)) then
						ReportPoliceSpottedPlayer(PlayerId)
					end
				end
			end
		end
		yield()
	end
end)