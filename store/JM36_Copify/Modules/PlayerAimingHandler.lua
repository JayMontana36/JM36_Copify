local Info = Info

local Copify = Info.Copify
local Player = Info.Player
local Vehicle = Player.Vehicle

local players_list = players.list

local GetPlayerPed = GetPlayerPed
local GetPlayerWantedLevel = GetPlayerWantedLevel
local IsPlayerFreeAiming = IsPlayerFreeAiming
local IsPlayerFreeAimingAtEntity = IsPlayerFreeAimingAtEntity

local GivePlayerWantedLevel = require'GivePlayerWantedLevel'

local yield = JM36.yield

JM36.CreateThread(function()
	while true do
		if Copify.Enabled then
			local SelfPlayerPed, SelfPlayerVeh = Player.Ped, Vehicle.Id
			local Players = players_list(false, true, true)
			for Index, PlayerId in Players do
				if GetPlayerPed(PlayerId) ~= 0 and GetPlayerWantedLevel(PlayerId) == 0 and IsPlayerFreeAiming(PlayerId) and (IsPlayerFreeAimingAtEntity(PlayerId, SelfPlayerPed) or IsPlayerFreeAimingAtEntity(PlayerId, SelfPlayerVeh)) then
					GivePlayerWantedLevel(PlayerId)
				end
			end
		end
		yield()
	end
end)