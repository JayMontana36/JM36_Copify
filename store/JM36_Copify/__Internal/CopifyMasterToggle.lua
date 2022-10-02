local CopifyTable <const> =
{
	InfoKeyName		=	"Copify",
	InfoKeyOnly		=	true,
	Enabled			=	false,
	MasterToggle	=	0,
	MenuList		=	0,
}
do
	local menu = menu
	local menu_my_root = menu.my_root()
	CopifyTable.MasterToggle = menu_my_root:toggle("Become a cop", {"beacop"}, "", function(state)CopifyTable.Enabled = state end, false)
	CopifyTable.MenuList = menu_my_root:list("Copify Options", {}, "Copify Related Options")
end

return CopifyTable