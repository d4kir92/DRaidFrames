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
	DRaidFrames:SetVersion(AddonName, 254652, "1.1.5")
	drf_settings = DRaidFrames:CreateFrame(
		{
			["name"] = "DRaidFrames",
			["pTab"] = {"CENTER"},
			["sw"] = 520,
			["sh"] = 520,
			["title"] = format("DRaidFrames |T254652:16:16:0:0|t v|cff3FC7EB%s", "1.1.5")
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
	C_Timer.After(
		0,
		function()
			DRaidFrames:CreateMinimapButton(
				{
					["name"] = "DRaidFrames",
					["icon"] = 254652,
					["dbtab"] = DRFTAB,
					["vTT"] = {{"DRaidFrames |T254652:16:16:0:0|t", "v|cff3FC7EB1.1.5"}, {"Leftclick", "Toggle Settings"}, {"Rightclick", "Hide Minimap Icon"}},
					["funcL"] = function()
						DRaidFrames:ToggleSettings()
					end,
					["funcR"] = function()
						DRaidFrames:SV(DRFTAB, "MMBTN", false)
						DRaidFrames:MSG("Minimap Button is now hidden.")
						DRaidFrames:HideMMBtn("DRaidFrames")
					end,
				}
			)

			if DRaidFrames:GV(DRFTAB, "MMBTN", DRaidFrames:GetWoWBuild() ~= "RETAIL") then
				DRaidFrames:ShowMMBtn("DRaidFrames")
			else
				DRaidFrames:HideMMBtn("DRaidFrames")
			end
		end
	)

	DRaidFrames:AddSlash("hla", DRaidFrames.ToggleSettings)
	DRaidFrames:AddSlash("DRaidFrames", DRaidFrames.ToggleSettings)
	--[[
	




	local settingrname = RAID
	DRFSettings.rpanel = CreateFrame("FRAME", settingrname, DRFSettings.panel)
	DRFSettings.rpanel.name = settingrname
	DRFSettings.rpanel.parent = settingname
	Y = 0
	--Y = Y - 30
	Y = Y - 10
	X = 500
	DRFSettings.rpanel.Text = DRFSettings.rpanel:CreateFontString(nil, "ARTWORK")
	DRFSettings.rpanel.Text:SetFont(STANDARD_TEXT_FONT, 11, "")
	DRFSettings.rpanel.Text:SetPoint("TOPLEFT", DRFSettings.rpanel, "TOPLEFT", X, Y)
	DRFSettings.rpanel.Text:SetText(DRaidFrames:Trans("DETY"))
	Y = Y - 18
	for i, v in pairs(DebuffTypeSymbol) do
		DRaidFrames:CreateCheckBox(DRFSettings.rpanel, "R" .. i, true, X, Y, i, true) -- parent, key, vval, x, y, lstr)
		Y = Y - 18
	end

	DRaidFrames:CreateCheckBox(DRFSettings.rpanel, "R" .. "None", true, X, Y, "None", true)
	Y = -10
	DRaidFrames:CreateComboBox(DRFSettings.rpanel, "SORTTYPE", "Role", 0, Y, "SORTTYPE", {"Group", "Role"})
	Y = Y - 32
	DRaidFrames:CreateComboBox(DRFSettings.rpanel, "RTETOTY", "Name", 0, Y, "TETOTY", {"Name", "Class", "Class + Name", "Name + Class", "None"})
	Y = Y - 32
	DRaidFrames:CreateComboBox(DRFSettings.rpanel, "RTECETY", "Health in Percent", 0, Y, "TECETY", {"Health in Percent", "Lost Health in Percent", "None"})
	Y = Y - 32
	DRaidFrames:CreateSlider(DRFSettings.rpanel, "RELEM", 5, 12, Y, 1, 40, 1.0, "ELEMENTS")
	Y = Y - 32
	DRaidFrames:CreateCheckBox(DRFSettings.rpanel, "RSHPO", true, 12, Y, "SHPO") -- parent, key, vval, x, y, lstr)
	Y = Y - 20
	DRaidFrames:CreateCheckBox(DRFSettings.rpanel, "RGRHO", true, 12, Y, "GGRHO") -- parent, key, vval, x, y, lstr)
	Y = Y - 20
	DRaidFrames:CreateCheckBox(DRFSettings.rpanel, "RBAUP", true, 12, Y, "GBAUP") -- parent, key, vval, x, y, lstr)
	Y = Y - 20
	DRaidFrames:CreateCheckBox(DRFSettings.rpanel, "ROVER", false, 12, Y, "OVER") -- parent, key, vval, x, y, lstr)
	if UnitHasRating then
		DRaidFrames:CreateCheckBox(DRFSettings.rpanel, "RRATE", true, 200, Y + 60, "Rating") -- parent, key, vval, x, y, lstr)
	end

	DRaidFrames:CreateCheckBox(DRFSettings.rpanel, "RFLAG", true, 200, Y + 40, LANGUAGE) -- parent, key, vval, x, y, lstr)
	DRaidFrames:CreateCheckBox(DRFSettings.rpanel, "RCLAS", true, 200, Y + 20, CLASS) -- parent, key, vval, x, y, lstr)
	DRaidFrames:CreateCheckBox(DRFSettings.rpanel, "RTHRE", false, 200, Y + 0, "Threat") -- parent, key, vval, x, y, lstr)
	Y = Y - 28
	DRaidFrames:CreateSlider(DRFSettings.rpanel, "ROUBR", 6, sliderX, Y, 0, 20, 1.0, "GOUBR")
	Y = Y - 32
	DRaidFrames:CreateSlider(DRFSettings.rpanel, "RROSP", 4, sliderX, Y, 0, 50, 1.0, "GROSP")
	Y = Y - 32
	DRaidFrames:CreateSlider(DRFSettings.rpanel, "RCOSP", 20, sliderX, Y, 0, 50, 1.0, "COSP")
	Y = Y - 10
	Y = Y - 32
	DRaidFrames:CreateSlider(DRFSettings.rpanel, "RHEWI", 80, sliderX, Y, 20, 300, 1.0, "HEWI")
	Y = Y - 32
	DRaidFrames:CreateSlider(DRFSettings.rpanel, "RHEHE", 60, sliderX, Y, 20, 300, 1.0, "GHEHE")
	Y = Y - 32
	DRaidFrames:CreateSlider(DRFSettings.rpanel, "RPOSI", 10, sliderX, Y, 8, 300, 1.0, "GPOSI")
	Y = Y - 10
	Y = Y - 32
	DRaidFrames:CreateSlider(DRFSettings.rpanel, "RDESI", 16, sliderX, Y, 8, 64, 1.0, "GDESI")
	Y = Y - 32
	DRaidFrames:CreateSlider(DRFSettings.rpanel, "RBUSI", 16, sliderX, Y, 8, 64, 1.0, "BUSI")
	Y = Y - 32
	DRaidFrames:CreateSlider(DRFSettings.rpanel, "ROORA", 0.4, sliderX, Y, 0.1, 0.9, 0.1, "OORA")
	if InterfaceOptions_AddCategory then
		InterfaceOptions_AddCategory(DRFSettings.rpanel)
	else
		print("[DRaidFrames] WORK IN PROGRESS (Options)")
	end]]
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
