-- By D4KiR
local AddonName, DRaidFrames = ...
local DRFLoaded = false
function DRaidFrames:GetConfig(key, value, pc)
	DRFTAB = DRFTAB or {}
	DRFTABPC = DRFTABPC or {}
	if DRFLoaded and DRFTAB ~= nil and DRFTABPC ~= nil then
		if pc then
			if DRFTABPC[key] ~= nil then
				value = DRFTABPC[key]
			else
				DRFTABPC[key] = value
			end
		else
			if DRFTAB[key] ~= nil then
				value = DRFTAB[key]
			else
				DRFTAB[key] = value
			end
		end
	end

	if tonumber(value) ~= nil then
		value = tonumber(value)
	end

	return value
end

function DRaidFrames:CreateComboBox(parent, key, vval, x, y, lstr, tab)
	local rows = {
		["name"] = lstr,
		["parent"] = parent,
		["title"] = lstr,
		["items"] = tab,
		["defaultVal"] = DRaidFrames:GetConfig(key, vval),
		["changeFunc"] = function(dropdown_frame, dropdown_val)
			--dropdown_val = tonumber( dropdown_val )
			DRFTAB[key] = dropdown_val
			DRaidFrames:SetSizing(true)
		end
	}

	local DD = DRaidFrames:CreateDropdown(rows)
	DD:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)

	return DD
end

DRaidFrames:SetAddonOutput("DRaidFrames", 254652)
local drf_settings = nil
function DRaidFrames:ToggleSettings()
	if drf_settings then
		if drf_settings:IsShown() then
			drf_settings:Hide()
		else
			drf_settings:Show()
		end
	end
end

function DRaidFrames:InitSettings()
	DRFTAB = DRFTAB or {}
	DRaidFrames:SetVersion(254652, "1.1.25")
	drf_settings = DRaidFrames:CreateFrame(
		{
			["name"] = "DRaidFrames",
			["pTab"] = {"CENTER"},
			["sw"] = 520,
			["sh"] = 520,
			["title"] = format("|T254652:16:16:0:0|t DRaidFrames v|cff3FC7EB%s", DRaidFrames:GetVersion())
		}
	)

	drf_settings.SF = CreateFrame("ScrollFrame", "drf_settings_SF", drf_settings, "UIPanelScrollFrameTemplate")
	drf_settings.SF:SetPoint("TOPLEFT", drf_settings, 8, -26)
	drf_settings.SF:SetPoint("BOTTOMRIGHT", drf_settings, -32, 8)
	drf_settings.SC = CreateFrame("Frame", "drf_settings_SC", drf_settings.SF)
	drf_settings.SC:SetSize(drf_settings.SF:GetSize())
	drf_settings.SC:SetPoint("TOPLEFT", drf_settings.SF, "TOPLEFT", 0, 0)
	drf_settings.SF:SetScrollChild(drf_settings.SC)
	local y = 0
	DRaidFrames:SetAppendY(y)
	DRaidFrames:SetAppendParent(drf_settings.SC)
	DRaidFrames:SetAppendTab(DRFTAB)
	DRaidFrames:AppendCategory("GENERAL")
	DRaidFrames:AppendCheckbox(
		"MMBTN",
		DRaidFrames:GetWoWBuild() ~= "RETAIL",
		function(sel, checked)
			if checked then
				DRaidFrames:ShowMMBtn("DRaidFrames")
			else
				DRaidFrames:HideMMBtn("DRaidFrames")
			end
		end
	)

	--parent, key, vval, x, y, vmin, vmax, steps, lstr
	DRaidFrames:AppendSlider("DECI", 0, 0, 3, 1, 0)
	DRaidFrames:AppendCheckbox("SHTO", true)
	DRaidFrames:AppendCategory("PARTY")
	DRaidFrames:AppendCheckbox("GSHPO", true)
	DRaidFrames:AppendCheckbox("GGRHO", true)
	DRaidFrames:AppendCheckbox("GBAUP", true)
	DRaidFrames:AppendCheckbox("GOVER", true)
	if UnitHasRating then
		DRaidFrames:AppendCheckbox("GRATE", true)
	end

	DRaidFrames:AppendCheckbox("GFLAG", true)
	DRaidFrames:AppendCheckbox("GCLAS", true)
	DRaidFrames:AppendCheckbox("GTHRE", true)
	DRaidFrames:CreateComboBox(drf_settings.SC, "GTETOTY", "Name", 0, DRaidFrames:GetAppendY(), "GTETOTY", {"Name", "Name + Realm", "Class", "Class + Name", "Name + Class", "None"})
	DRaidFrames:SetAppendY(DRaidFrames:GetAppendY() - 32)
	DRaidFrames:CreateComboBox(drf_settings.SC, "GTECETY", "Health in Percent", 0, DRaidFrames:GetAppendY(), "GTECETY", {"Health in Percent", "Lost Health in Percent", "None"})
	DRaidFrames:SetAppendY(DRaidFrames:GetAppendY() - 32)
	DRaidFrames:AppendSlider("GELEM", 5, 1, 40, 1, 0)
	DRaidFrames:AppendSlider("GOUBR", 6, 0, 20, 1, 0)
	DRaidFrames:AppendSlider("GROSP", 6, 0, 50, 1, 0)
	DRaidFrames:AppendSlider("GCOSP", 6, 0, 50, 1, 0)
	DRaidFrames:AppendSlider("GHEWI", 120, 20, 300, 1, 0)
	DRaidFrames:AppendSlider("GHEHE", 60, 20, 300, 1, 0)
	DRaidFrames:AppendSlider("GPOSI", 20, 8, 300, 1, 0)
	DRaidFrames:AppendSlider("GDESI", 16, 8, 65, 1, 0)
	DRaidFrames:AppendSlider("GBUSI", 16, 8, 65, 1, 0)
	DRaidFrames:AppendSlider("GOORA", 0.4, 0.1, 0.9, 0.1, 1)
	DRaidFrames:AppendCategory("GDETY", 24)
	for i, v in pairs(DebuffTypeSymbol) do
		DRaidFrames:AppendCheckbox("G" .. i, true, nil, 28)
	end

	DRaidFrames:AppendCheckbox("GNone", true, null, 28)
	DRaidFrames:AppendCategory("RAID")
	DRaidFrames:AppendCheckbox("RSHPO", true)
	DRaidFrames:AppendCheckbox("RGRHO", true)
	DRaidFrames:AppendCheckbox("RBAUP", true)
	DRaidFrames:AppendCheckbox("ROVER", true)
	if UnitHasRating then
		DRaidFrames:AppendCheckbox("RRATE", true)
	end

	DRaidFrames:AppendCheckbox("RFLAG", true)
	DRaidFrames:AppendCheckbox("RCLAS", true)
	DRaidFrames:AppendCheckbox("RTHRE", true)
	DRaidFrames:CreateComboBox(drf_settings.SC, "GTETOTY", "Name", 0, DRaidFrames:GetAppendY(), "GTETOTY", {"Name", "Name + Realm", "Class", "Class + Name", "Name + Class", "None"})
	DRaidFrames:SetAppendY(DRaidFrames:GetAppendY() - 32)
	DRaidFrames:CreateComboBox(drf_settings.SC, "GTECETY", "Health in Percent", 0, DRaidFrames:GetAppendY(), "GTECETY", {"Health in Percent", "Lost Health in Percent", "None"})
	DRaidFrames:SetAppendY(DRaidFrames:GetAppendY() - 32)
	DRaidFrames:AppendSlider("RELEM", 5, 1, 40, 1, 0)
	DRaidFrames:AppendSlider("ROUBR", 6, 0, 20, 1, 0)
	DRaidFrames:AppendSlider("RROSP", 6, 0, 50, 1, 0)
	DRaidFrames:AppendSlider("RCOSP", 6, 0, 50, 1, 0)
	DRaidFrames:AppendSlider("RHEWI", 120, 20, 300, 1, 0)
	DRaidFrames:AppendSlider("RHEHE", 60, 20, 300, 1, 0)
	DRaidFrames:AppendSlider("RPOSI", 20, 8, 300, 1, 0)
	DRaidFrames:AppendSlider("RDESI", 16, 8, 65, 1, 0)
	DRaidFrames:AppendSlider("RBUSI", 16, 8, 65, 1, 0)
	DRaidFrames:AppendSlider("ROORA", 0.4, 0.1, 0.9, 0.1, 1)
	DRaidFrames:AppendCategory("RDETY", 24)
	for i, v in pairs(DebuffTypeSymbol) do
		DRaidFrames:AppendCheckbox("R" .. i, true, nil, 28)
	end

	DRaidFrames:AppendCheckbox("RNone", true, nil, 28)
	DRaidFrames:CreateComboBox(drf_settings.SC, "SORTTYPE", "Role", 0, DRaidFrames:GetAppendY(), "SORTTYPE", {"Group", "Role"})
	DRaidFrames:SetAppendY(DRaidFrames:GetAppendY() - 32)
	DRaidFrames:CreateMinimapButton(
		{
			["name"] = "DRaidFrames",
			["icon"] = 254652,
			["dbtab"] = DRFTAB,
			["vTT"] = {{"|T254652:16:16:0:0|t DRaidFrames", "v|cff3FC7EB" .. DRaidFrames:GetVersion()}, {DRaidFrames:Trans("LID_LEFTCLICK"), DRaidFrames:Trans("LID_OPENSETTINGS")}, {DRaidFrames:Trans("LID_RIGHTCLICK"), DRaidFrames:Trans("LID_HIDEMINIMAPBUTTON")}},
			["funcL"] = function()
				DRaidFrames:ToggleSettings()
			end,
			["funcR"] = function()
				DRaidFrames:SV(DRFTAB, "MMBTN", false)
				DRaidFrames:MSG("Minimap Button is now hidden.")
				DRaidFrames:HideMMBtn("DRaidFrames")
			end,
			["dbkey"] = "MMBTN"
		}
	)

	DRaidFrames:AddSlash("drf", DRaidFrames.ToggleSettings)
	DRaidFrames:AddSlash("DRaidFrames", DRaidFrames.ToggleSettings)
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("GROUP_ROSTER_UPDATE")
function f:OnEvent(event)
	if event == "GROUP_ROSTER_UPDATE" then
		DRaidFrames:SetSizing(true)
	end

	if (event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD") and not DRFLoaded then
		DRFLoaded = true
		DRaidFrames:SetSizingForce(true)
		DRaidFrames:UpdateSize()
		DRaidFrames:SetUpdating(true)
		DRaidFrames:OnUpdate()
		C_Timer.After(
			0,
			function()
				DRaidFrames:InitSettings()
			end
		)
	end
end

f:SetScript("OnEvent", f.OnEvent)
