local GoldDiggers = LibStub("AceAddon-3.0"):GetAddon("GoldDiggers")

local Helpers = GoldDiggers.Helpers

-- Returns the current time in format dd/mm/yyyy-hh:mm
-- @return string
function Helpers.GetCurrentTime()
    local _, month, day, year = CalendarGetDate()
    local hour, minute = GetGameTime()
	return string.format("%02d/%02d/%04d-%02d:%02d", day, month, year, hour, minute)
end