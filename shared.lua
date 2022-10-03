--Shared data interface between data and script, notably prototype names.

local data = {}

data.repair_rate = settings.startup["building-speed"].value -- In health per second

return data
