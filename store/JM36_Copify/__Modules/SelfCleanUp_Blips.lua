local ClearTime <const> = 90000

local memory_alloc_int = memory.alloc_int
local memory_write_int = memory.write_int
local memory_read_int = memory.read_int

local DoesBlipExist = DoesBlipExist
local RemoveBlip = RemoveBlip
local MetaTable <const> =
{
	__gc = function(Self)
		if DoesBlipExist(memory_read_int(Self)) then
			RemoveBlip(Self)
		end
	end
}

local setmetatable = setmetatable
local AllBlips <const> = setmetatable
(
	{},
	{
		--__mode = "v",
		__call = function(Self, Blip)
			local _Blip = memory_alloc_int()
			memory_write_int(_Blip, Blip)
			setmetatable(_Blip, MetaTable)
			Self[#Self+1] = _Blip
			return _Blip
		end
	}
)

setmetatable = debug.setmetatable

JM36.CreateThread_HighPriority(function()
	local yield = JM36.yield
	while true do
		for Key in AllBlips do
			AllBlips[Key] = nil
		end
		yield(ClearTime)
	end
end)

return AllBlips