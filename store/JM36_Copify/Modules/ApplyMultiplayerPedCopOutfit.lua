local Player = Info.Player

local menu_trigger_command = menu.trigger_command

local IsPedMale = IsPedMale

local OnlineCopMale, OnlineCopFemale
do
	local menu_ref_by_path = menu.ref_by_path
	OnlineCopMale, OnlineCopFemale = menu_ref_by_path("Self>Appearance>Outfit>Wardrobe>Prefabricated Outfits>Online Male: Cop"), menu_ref_by_path("Self>Appearance>Outfit>Wardrobe>Prefabricated Outfits>Online Female: Cop")
end

Info.Copify.MenuList:action("Apply Multiplayer Ped Cop Outfit", {}, '',
	function()
		if IsPedMale(Player.Ped) then
			menu_trigger_command(OnlineCopMale)
		else
			menu_trigger_command(OnlineCopFemale)
		end
	end,
false)
