local Info = Info

local Copify = Info.Copify
local Player = Info.Player

local GetPedLastWeaponImpactCoord = GetPedLastWeaponImpactCoord
local GetSelectedPedWeapon = GetSelectedPedWeapon
local AddOwnedExplosion = AddOwnedExplosion

local yield = JM36.yield

local MemPtr = require'Memory_SharedIntegerPointerSingle'
local Coords = v3.new()
local HshGunEMP <const> =
{
	"weapon_stungun",
	"weapon_stungun_mp",
}

JM36.CreateThread(function()
	do
		local GetHashKey = GetHashKey
		for Index = 1, 2 do
			HshGunEMP[GetHashKey(HshGunEMP[Index])] = true;HshGunEMP[Index] = nil
		end
	end
	while true do
		if Copify.Enabled then
			local Player_Ped = Player.Ped
			if GetPedLastWeaponImpactCoord(Player_Ped, Coords) and HshGunEMP[GetSelectedPedWeapon(Player_Ped)] then
				AddOwnedExplosion(Player_Ped, Coords, 83, 1.0, false, true, 0.0)--EXP_TAG_EMPLAUNCHER_EMP
			end
		end
		yield()
	end
end)