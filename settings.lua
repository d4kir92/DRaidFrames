-- By D4KiR
local AddonName, DRaidFrames = ...
local BuildNr = select(4, GetBuildInfo())
local Build = "CLASSIC"
if BuildNr >= 100000 then
	Build = "RETAIL"
elseif BuildNr > 29999 then
	Build = "WRATH"
elseif BuildNr > 19999 then
	Build = "TBC"
end

function DRaidFrames:GetWoWBuildNr()
	return BuildNr
end

function DRaidFrames:GetWoWBuild()
	return Build
end

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

function DRaidFrames:CreateSlider(parent, key, vval, x, y, vmin, vmax, steps, lstr)
	local SL = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")
	SL:SetWidth(400)
	SL:SetPoint("TOPLEFT", x, y)
	SL.Low:SetText(vmin)
	SL.High:SetText(vmax)
	SL.Text:SetText(DRaidFrames:GT(lstr) .. ": " .. DRaidFrames:GetConfig(key, vval))
	SL:SetMinMaxValues(vmin, vmax)
	SL:SetValue(DRaidFrames:GetConfig(key, vval))
	SL:SetObeyStepOnDrag(steps)
	SL:SetValueStep(steps)
	SL:SetScript(
		"OnValueChanged",
		function(sel, val)
			if steps == 1 then
				val = string.format("%" .. ".0" .. "f", val)
			else
				val = string.format("%" .. steps .. "f", val)
			end

			DRFTAB[key] = val
			SL.Text:SetText(DRaidFrames:GT(lstr) .. ": " .. val)
			DRaidFrames:SetSizing(true)
		end
	)

	return SL
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

function DRaidFrames:CreateCheckBox(parent, key, vval, x, y, lstr, pc)
	local CB = CreateFrame("CheckButton", nil, parent, "ChatConfigCheckButtonTemplate")
	CB:SetSize(18, 18)
	CB:SetPoint("TOPLEFT", x, y)
	CB.Text:SetPoint("LEFT", CB, "RIGHT", 0, 0)
	CB.Text:SetText(DRaidFrames:GT(lstr))
	CB:SetChecked(DRaidFrames:GetConfig(key, vval))
	CB:SetScript(
		"OnClick",
		function(sel, val)
			val = CB:GetChecked()
			if pc then
				DRFTABPC[key] = val
			else
				DRFTAB[key] = val
			end

			CB.Text:SetText(DRaidFrames:GT(lstr))
			DRaidFrames:SetSizing(true)
		end
	)

	return CB
end

local Y = 0
local sliderX = 12
function DRaidFrames:InitSettings()
	local DRFSettings = {}
	D4:SetVersion(AddonName, 254652, "1.0.51")
	local DRFname = "DRaidFrames |T254652:16:16:0:0|t by |cff3FC7EBD4KiR |T132115:16:16:0:0|t"
	local settingname = DRFname
	DRFSettings.panel = CreateFrame("FRAME")
	DRFSettings.panel.name = settingname
	Y = 0
	H = 16
	BR = 30
	Y = Y - 10
	local text = DRFSettings.panel:CreateFontString(nil, "ARTWORK")
	text:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
	text:SetPoint("TOPLEFT", DRFSettings.panel, "TOPLEFT", 10, Y)
	text:SetText("Watch SubSites")
	DRaidFrames:CreateSlider(DRFSettings.panel, "DECI", 0, 12, -40, 0, 3, 1.0, "DECI") --parent, key, vval, x, y, vmin, vmax, steps, lstr
	DRaidFrames:CreateCheckBox(DRFSettings.panel, "SHTO", true, 12, -80, "Show Tooltip", false)
	local b = CreateFrame("Button", "MyButton", DRFSettings.panel, "UIPanelButtonTemplate")
	b:SetSize(200, 24) -- width, height
	b:SetText("DISCORD")
	b:SetPoint("BOTTOMLEFT", 10, 10)
	b:SetScript(
		"OnClick",
		function()
			local iconbtn = 32
			local s = CreateFrame("Frame", nil, UIParent) -- or you actual parent instead
			s:SetSize(300, 2 * iconbtn + 2 * 10)
			s:SetPoint("CENTER")
			s.texture = s:CreateTexture(nil, "BACKGROUND")
			s.texture:SetColorTexture(0, 0, 0, 0.5)
			s.texture:SetAllPoints(s)
			s.text = s:CreateFontString(nil, "ARTWORK")
			s.text:SetFont(STANDARD_TEXT_FONT, 11, "")
			s.text:SetText("Feedback")
			s.text:SetPoint("CENTER", s, "TOP", 0, -10)
			local eb = CreateFrame("EditBox", "logEditBox", s, "InputBoxTemplate")
			eb:SetFrameStrata("DIALOG")
			eb:SetSize(280, iconbtn)
			eb:SetAutoFocus(false)
			eb:SetText("https://discord.gg/UeBsafs")
			eb:SetPoint("TOPLEFT", 10, -10 - iconbtn)
			s.close = CreateFrame("Button", "closediscord", s, "UIPanelButtonTemplate")
			s.close:SetFrameStrata("DIALOG")
			s.close:SetPoint("TOPLEFT", 300 - 10 - iconbtn, -10)
			s.close:SetSize(iconbtn, iconbtn)
			s.close:SetText("X")
			s.close:SetScript(
				"OnClick",
				function(sel, btn, down)
					s:Hide()
				end
			)
		end
	)

	InterfaceOptions_AddCategory(DRFSettings.panel)
	local settinggname = PARTY
	DRFSettings.gpanel = CreateFrame("FRAME", settinggname, DRFSettings.panel)
	DRFSettings.gpanel.name = settinggname
	DRFSettings.gpanel.parent = settingname
	Y = 0
	H = 16
	BR = 30
	--Y = Y - 30
	Y = Y - 10
	local X = 500
	DRFSettings.gpanel.Text = DRFSettings.gpanel:CreateFontString(nil, "ARTWORK")
	DRFSettings.gpanel.Text:SetFont(STANDARD_TEXT_FONT, 11, "")
	DRFSettings.gpanel.Text:SetPoint("TOPLEFT", DRFSettings.gpanel, "TOPLEFT", X, Y)
	DRFSettings.gpanel.Text:SetText(DRaidFrames:GT("DETY"))
	Y = Y - 18
	for i, v in pairs(DebuffTypeSymbol) do
		DRaidFrames:CreateCheckBox(DRFSettings.gpanel, "G" .. i, true, X, Y, i, true) -- parent, key, vval, x, y, lstr)
		Y = Y - 18
	end

	DRaidFrames:CreateCheckBox(DRFSettings.gpanel, "G" .. "None", true, X, Y, "None", true)
	Y = -10
	--Y = Y - 32
	DRaidFrames:CreateComboBox(DRFSettings.gpanel, "GTETOTY", "Name", 0, Y, "TETOTY", {"Name", "Name + Realm", "Class", "Class + Name", "Name + Class", "None"})
	Y = Y - 32
	DRaidFrames:CreateComboBox(DRFSettings.gpanel, "GTECETY", "Health in Percent", 0, Y, "TECETY", {"Health in Percent", "Lost Health in Percent", "None"})
	Y = Y - 32
	DRaidFrames:CreateSlider(DRFSettings.gpanel, "GELEM", 5, 12, Y, 1, 40, 1.0, "ELEMENTS")
	Y = Y - 32
	DRaidFrames:CreateCheckBox(DRFSettings.gpanel, "GSHPO", true, 12, Y, "SHPO") -- parent, key, vval, x, y, lstr)
	Y = Y - 20
	DRaidFrames:CreateCheckBox(DRFSettings.gpanel, "GGRHO", true, 12, Y, "GRHO") -- parent, key, vval, x, y, lstr)
	Y = Y - 20
	DRaidFrames:CreateCheckBox(DRFSettings.gpanel, "GBAUP", true, 12, Y, "BAUP") -- parent, key, vval, x, y, lstr)
	Y = Y - 20
	DRaidFrames:CreateCheckBox(DRFSettings.gpanel, "GOVER", true, 12, Y, "OVER") -- parent, key, vval, x, y, lstr)
	if UnitHasRating then
		DRaidFrames:CreateCheckBox(DRFSettings.gpanel, "GRATE", true, 200, Y + 60, "Rating") -- parent, key, vval, x, y, lstr)
	end

	if DRaidFrames:GetWoWBuild() == "RETAIL" then
		DRaidFrames:CreateCheckBox(DRFSettings.gpanel, "GCOVE", true, 400, Y + 60, GARRISON_TYPE_9_0_LANDING_PAGE_TITLE) -- parent, key, vval, x, y, lstr)
	end

	DRaidFrames:CreateCheckBox(DRFSettings.gpanel, "GFLAG", true, 200, Y + 40, LANGUAGE) -- parent, key, vval, x, y, lstr)
	DRaidFrames:CreateCheckBox(DRFSettings.gpanel, "GCLAS", true, 200, Y + 20, CLASS) -- parent, key, vval, x, y, lstr)
	DRaidFrames:CreateCheckBox(DRFSettings.gpanel, "GTHRE", true, 200, Y + 0, "Threat") -- parent, key, vval, x, y, lstr)
	Y = Y - 28
	DRaidFrames:CreateSlider(DRFSettings.gpanel, "GOUBR", 6, sliderX, Y, 0, 20, 1.0, "OUBR")
	Y = Y - 32
	DRaidFrames:CreateSlider(DRFSettings.gpanel, "GROSP", 6, sliderX, Y, 0, 50, 1.0, "ROSP")
	Y = Y - 32
	DRaidFrames:CreateSlider(DRFSettings.gpanel, "GCOSP", 6, sliderX, Y, 0, 50, 1.0, "COSP")
	Y = Y - 10
	Y = Y - 32
	DRaidFrames:CreateSlider(DRFSettings.gpanel, "GHEWI", 120, sliderX, Y, 20, 300, 1.0, "HEWI")
	Y = Y - 32
	DRaidFrames:CreateSlider(DRFSettings.gpanel, "GHEHE", 60, sliderX, Y, 20, 300, 1.0, "HEHE")
	Y = Y - 32
	DRaidFrames:CreateSlider(DRFSettings.gpanel, "GPOSI", 20, sliderX, Y, 8, 300, 1.0, "POSI")
	Y = Y - 10
	Y = Y - 32
	DRaidFrames:CreateSlider(DRFSettings.gpanel, "GDESI", 16, sliderX, Y, 8, 64, 1.0, "DESI")
	Y = Y - 32
	DRaidFrames:CreateSlider(DRFSettings.gpanel, "GBUSI", 16, sliderX, Y, 8, 64, 1.0, "BUSI")
	Y = Y - 32
	DRaidFrames:CreateSlider(DRFSettings.gpanel, "GOORA", 0.4, sliderX, Y, 0.1, 0.9, 0.1, "OORA")
	InterfaceOptions_AddCategory(DRFSettings.gpanel)
	local settingrname = RAID
	DRFSettings.rpanel = CreateFrame("FRAME", settingrname, DRFSettings.panel)
	DRFSettings.rpanel.name = settingrname
	DRFSettings.rpanel.parent = settingname
	Y = 0
	H = 16
	BR = 30
	--Y = Y - 30
	Y = Y - 10
	X = 500
	DRFSettings.rpanel.Text = DRFSettings.rpanel:CreateFontString(nil, "ARTWORK")
	DRFSettings.rpanel.Text:SetFont(STANDARD_TEXT_FONT, 11, "")
	DRFSettings.rpanel.Text:SetPoint("TOPLEFT", DRFSettings.rpanel, "TOPLEFT", X, Y)
	DRFSettings.rpanel.Text:SetText(DRaidFrames:GT("DETY"))
	Y = Y - 18
	for i, v in pairs(DebuffTypeSymbol) do
		DRaidFrames:CreateCheckBox(DRFSettings.rpanel, "R" .. i, true, X, Y, i, true) -- parent, key, vval, x, y, lstr)
		Y = Y - 18
	end

	DRaidFrames:CreateCheckBox(DRFSettings.rpanel, "R" .. "None", true, X, Y, "None", true)
	Y = -10
	DRaidFrames:CreateComboBox(DRFSettings.rpanel, "RSORT", "Role", 0, Y, "SORTTYPE", {"Group", "Role"})
	Y = Y - 32
	DRaidFrames:CreateComboBox(DRFSettings.rpanel, "RTETOTY", "Name", 0, Y, "TETOTY", {"Name", "Class", "Class + Name", "Name + Class", "None"})
	Y = Y - 32
	DRaidFrames:CreateComboBox(DRFSettings.rpanel, "RTECETY", "Health in Percent", 0, Y, "TECETY", {"Health in Percent", "Lost Health in Percent", "None"})
	Y = Y - 32
	DRaidFrames:CreateSlider(DRFSettings.rpanel, "RELEM", 5, 12, Y, 1, 40, 1.0, "ELEMENTS")
	Y = Y - 32
	DRaidFrames:CreateCheckBox(DRFSettings.rpanel, "RSHPO", true, 12, Y, "SHPO") -- parent, key, vval, x, y, lstr)
	Y = Y - 20
	DRaidFrames:CreateCheckBox(DRFSettings.rpanel, "RGRHO", true, 12, Y, "GRHO") -- parent, key, vval, x, y, lstr)
	Y = Y - 20
	DRaidFrames:CreateCheckBox(DRFSettings.rpanel, "RBAUP", true, 12, Y, "BAUP") -- parent, key, vval, x, y, lstr)
	Y = Y - 20
	DRaidFrames:CreateCheckBox(DRFSettings.rpanel, "ROVER", false, 12, Y, "OVER") -- parent, key, vval, x, y, lstr)
	if UnitHasRating then
		DRaidFrames:CreateCheckBox(DRFSettings.rpanel, "RRATE", true, 200, Y + 60, "Rating") -- parent, key, vval, x, y, lstr)
	end

	if DRaidFrames:GetWoWBuild() == "RETAIL" then
		DRaidFrames:CreateCheckBox(DRFSettings.rpanel, "RCOVE", true, 400, Y + 60, GARRISON_TYPE_9_0_LANDING_PAGE_TITLE) -- parent, key, vval, x, y, lstr)
	end

	DRaidFrames:CreateCheckBox(DRFSettings.rpanel, "RFLAG", true, 200, Y + 40, LANGUAGE) -- parent, key, vval, x, y, lstr)
	DRaidFrames:CreateCheckBox(DRFSettings.rpanel, "RCLAS", true, 200, Y + 20, CLASS) -- parent, key, vval, x, y, lstr)
	DRaidFrames:CreateCheckBox(DRFSettings.rpanel, "RTHRE", false, 200, Y + 0, "Threat") -- parent, key, vval, x, y, lstr)
	Y = Y - 28
	DRaidFrames:CreateSlider(DRFSettings.rpanel, "ROUBR", 6, sliderX, Y, 0, 20, 1.0, "OUBR")
	Y = Y - 32
	DRaidFrames:CreateSlider(DRFSettings.rpanel, "RROSP", 4, sliderX, Y, 0, 50, 1.0, "ROSP")
	Y = Y - 32
	DRaidFrames:CreateSlider(DRFSettings.rpanel, "RCOSP", 20, sliderX, Y, 0, 50, 1.0, "COSP")
	Y = Y - 10
	Y = Y - 32
	DRaidFrames:CreateSlider(DRFSettings.rpanel, "RHEWI", 80, sliderX, Y, 20, 300, 1.0, "HEWI")
	Y = Y - 32
	DRaidFrames:CreateSlider(DRFSettings.rpanel, "RHEHE", 60, sliderX, Y, 20, 300, 1.0, "HEHE")
	Y = Y - 32
	DRaidFrames:CreateSlider(DRFSettings.rpanel, "RPOSI", 10, sliderX, Y, 8, 300, 1.0, "POSI")
	Y = Y - 10
	Y = Y - 32
	DRaidFrames:CreateSlider(DRFSettings.rpanel, "RDESI", 16, sliderX, Y, 8, 64, 1.0, "DESI")
	Y = Y - 32
	DRaidFrames:CreateSlider(DRFSettings.rpanel, "RBUSI", 16, sliderX, Y, 8, 64, 1.0, "BUSI")
	Y = Y - 32
	DRaidFrames:CreateSlider(DRFSettings.rpanel, "ROORA", 0.4, sliderX, Y, 0.1, 0.9, 0.1, "OORA")
	InterfaceOptions_AddCategory(DRFSettings.rpanel)
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