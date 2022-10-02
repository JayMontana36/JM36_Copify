local Player = Info.Player

local menu_trigger_command = menu.trigger_command

local IsPedMale = IsPedMale
local GetEntityModel = GetEntityModel
local GetHashKey = GetHashKey

local OnlineCopMale, OnlineCopFemale
do
	local menu_ref_by_path = menu.ref_by_path
	OnlineCopMale, OnlineCopFemale = menu_ref_by_path("Self>Appearance>Outfit>Wardrobe>Prefabricated Outfits>Online Male: Cop"), menu_ref_by_path("Self>Appearance>Outfit>Wardrobe>Prefabricated Outfits>Online Female: Cop")
end

Info.Copify.MenuList:action("Apply Multiplayer Ped Cop Outfit", {}, '',
	function()
		local Player_Ped = Player.Ped
		if not IsPedMale(Player_Ped) or GetEntityModel(Player_Ped) == GetHashKey("mp_f_freemode_01") then
			menu_trigger_command(OnlineCopFemale)
		else
			menu_trigger_command(OnlineCopMale)
		end
	end,
false)