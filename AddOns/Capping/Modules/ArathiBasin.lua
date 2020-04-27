
local mod, L
do
	local _, core = ...
	mod, L = core:NewMod()
end

function mod:EnterZone(id)
	self:StartFlagCaptures(60, 1461)
	self:StartScoreEstimator()
end

function mod:ExitZone()
	self:StopScoreEstimator()
	self:StopFlagCaptures()
end

mod:RegisterZone(529)
