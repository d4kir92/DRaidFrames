local _, DRaidFrames = ...
DRaidFrames:SetAddonOutput("DRaidFrames", 254652)
local lang = {}
function DRaidFrames:GetLangTab()
	return lang
end

function DRaidFrames:GT(str, tab)
	local strid = str
	local result = DRaidFrames:GetLangTab()[strid]
	if result ~= nil then
		if tab ~= nil then
			for i, v in pairs(tab) do
				local find = i -- "[" .. i .. "]"
				local replace = v
				if find ~= nil and replace ~= nil then
					result = string.gsub(result, find, replace)
				end
			end
		end

		return result
	else
		return str
	end
end

function DRaidFrames:UpdateLanguage()
	DRaidFrames:DRFLangenUS()
	if GetLocale() == "enUS" then
		DRaidFrames:DRFLangenUS()
	elseif GetLocale() == "deDE" then
		DRaidFrames:DRFLangdeDE()
	elseif GetLocale() == "ruRU" then
		DRaidFrames:DRFLangruRU()
	elseif GetLocale() == "zhTW" then
		DRaidFrames:DRFLangzhTW()
	end
end

DRaidFrames:UpdateLanguage()
