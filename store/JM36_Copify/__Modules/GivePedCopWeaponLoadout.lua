local WeaponLoadout <const> =
{
	"weapon_petrolcan",
	"weapon_fireextinguisher",
	"weapon_flashlight",
	"weapon_nightstick",
	"weapon_stungun",
	"weapon_switchblade",
	"weapon_combatpistol",
	"weapon_carbinerifle",
	"weapon_sniperrifle",
	"weapon_pumpshotgun",
	"weapon_flaregun",
	"weapon_flare",
	"weapon_bzgas",
}
local WeaponLoadoutCount <const> = 13 -- #WeaponLoadout
JM36.CreateThread_HighPriority(function()
	local GetHashKey = GetHashKey
	for Index, Weapon in WeaponLoadout do
		WeaponLoadout[Index] = GetHashKey(Weapon)
	end--for i=1, WeaponLoadoutCount do WeaponLoadout[i] = GetHashKey(WeaponLoadout[i]) end
end)

local GiveWeaponToPed = GiveWeaponToPed
return function(Ped)
	for i=1, WeaponLoadoutCount do
		GiveWeaponToPed(Ped, WeaponLoadout[i], 9999, true, false)
	end
end