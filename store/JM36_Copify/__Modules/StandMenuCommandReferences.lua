local menu_ref_by_path = menu.ref_by_path
return
{
	OffTheRadar	=	menu_ref_by_path("Online>Off The Radar"),
	Wanted = menu_ref_by_path("Self>Set Wanted Level"),
	WantedLock = menu_ref_by_path("Self>Lock Wanted Level"),
	--WantedFake = menu_ref_by_path("Self>Fake Wanted Level"),
	AutoHeal = menu_ref_by_path("Self>Auto Heal"),
	FixVehicle = menu_ref_by_path("Vehicle>Fix Vehicle"),
}