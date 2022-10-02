local Info = Info

local Copify = Info.Copify
local Player = Info.Player

local menu_get_value = menu.get_value
local menu_trigger_command = menu.trigger_command

local RemoveAllPedWeapons = RemoveAllPedWeapons

local GivePedCopWeaponLoadout = require'GivePedCopWeaponLoadout'
local SetPedAsCop = require'SetPedAsCop'
local CommandReferences = require'StandMenuCommandReferences'

local yield = JM36.yield

local MenuSettingsOriginal <const> = {OffTheRadar=0,WantedLock=0,AutoHeal=0}
local SelfPlayerPedLast
local WasEnabled

JM36.CreateThread(function()
	while true do
		if Copify.Enabled then
			local SelfPlayerPed = Player.Ped
			if SelfPlayerPed ~= SelfPlayerPedLast then
				RemoveAllPedWeapons(SelfPlayerPed, true)
				GivePedCopWeaponLoadout(SelfPlayerPed)
				SetPedAsCop(true, SelfPlayerPed)
				if not WasEnabled then
					do
						local OTR_CR = CommandReferences.OffTheRadar
						local OTR_State = menu_get_value(OTR_CR)
						MenuSettingsOriginal.OffTheRadar = OTR_State
						if OTR_State ~= 1 then
							menu_trigger_command(OTR_CR, "on")
						end
					end
					do
						local WantedLock_CR = CommandReferences.WantedLock
						local WantedLock_State = menu_get_value(WantedLock_CR)
						MenuSettingsOriginal.WantedLock = WantedLock_State
						if WantedLock_State ~= 1 then
							menu_trigger_command(WantedLock_CR, "on")
						end
						menu_trigger_command(CommandReferences.Wanted, 0)
					end
					do
						local AutoHeal_CR = CommandReferences.AutoHeal
						local AutoHeal_State = menu_get_value(AutoHeal_CR)
						MenuSettingsOriginal.AutoHeal = AutoHeal_State
						if AutoHeal_State ~= 0 then
							menu_trigger_command(AutoHeal_CR, 0)
						end
					end
				end
				SelfPlayerPedLast = SelfPlayerPed
				WasEnabled = true
			end
		elseif WasEnabled then
			SetPedAsCop(false, SelfPlayerPed)
			SelfPlayerPedLast = nil
			WasEnabled = nil
			menu_trigger_command(CommandReferences.OffTheRadar, (MenuSettingsOriginal.OffTheRadar == 1) ? "on" : 0)
			menu_trigger_command(CommandReferences.WantedLock, (MenuSettingsOriginal.WantedLock == 1) ? "on" : 0)
			menu_trigger_command(CommandReferences.Wanted, 0)
			menu_trigger_command(CommandReferences.AutoHeal, (MenuSettingsOriginal.AutoHeal == 1) ? "on" : 0)
		end
		yield()
	end
end)

return
{
	stop	=	function()
					if WasEnabled and SelfPlayerPedLast then
						SetPedAsCop(false, SelfPlayerPedLast)
						SelfPlayerPedLast = nil
						menu_trigger_command(CommandReferences.OffTheRadar, (MenuSettingsOriginal.OffTheRadar == 1) ? "on" : 0)
						menu_trigger_command(CommandReferences.WantedLock, (MenuSettingsOriginal.WantedLock == 1) ? "on" : 0)
						menu_trigger_command(CommandReferences.Wanted, 0)
						menu_trigger_command(CommandReferences.AutoHeal, (MenuSettingsOriginal.AutoHeal == 1) ? "on" : 0)
					end
				end,
}