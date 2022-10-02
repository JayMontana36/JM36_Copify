local SetPedAsCop = SetPedAsCop
local SetPedRelationshipGroupHash = SetPedRelationshipGroupHash
local NetworkIsSessionStarted = util.is_session_started
local GetPedRelationshipGroupDefaultHash = GetPedRelationshipGroupDefaultHash

local GetHashKey = require'GetHashKey'

local Player = Info.Player

local PedRelGrpHshCop;JM36.CreateThread_HighPriority(function()PedRelGrpHshCop=GetHashKey"COP"end)

return function(Bool, Ped)
	local Player_Id, Self
	if not Ped then
		Ped = Player.Ped
		Self = true
	else
		Self = Ped == Player.Ped
	end
	if Self then
		Player_Id = Player.Id
		SetPoliceIgnorePlayer(Player_Id, Bool)
	end
	
	SetPedAsCop(Ped, Bool) -- Seemingly does nothing with false, needs ped respawn but y'know.
	
	if Bool then
		SetPedRelationshipGroupHash(Ped, PedRelGrpHshCop)
	else
		if Self and NetworkIsSessionStarted() then
			SetPedRelationshipGroupHash(Ped, GetHashKey(("rgFM_Team%s"):format(Player_Id)))
		else
			SetPedRelationshipGroupHash(Ped, GetPedRelationshipGroupDefaultHash(Ped))
		end
	end
end