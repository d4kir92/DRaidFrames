-- By D4KiR

local LibDD = LibStub:GetLibrary("LibUIDropDownMenu-4.0")

DRFBUILD = "CLASSIC"
if select(4, GetBuildInfo()) > 90000 then
	DRFBUILD = "RETAIL"
elseif select(4, GetBuildInfo()) > 29999 then
	DRFBUILD = "WRATH"
elseif select(4, GetBuildInfo()) > 19999 then
	DRFBUILD = "TBC"
end



local DRFLoaded = false

DRFTAB = DRFTAB or {}
DRFTABPC = DRFTABPC or {}

function DRFGetConfig(key, value, pc)
	if DRFLoaded then
		if DRFTAB ~= nil and DRFTABPC ~= nil then
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
	end
	if tonumber(value) ~= nil then
		value = tonumber(value)
	end
	return value
end



function DRFCreateSlider(parent, key, vval, x, y, vmin, vmax, steps, lstr)
	local SL = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")

	SL:SetWidth(400)
	SL:SetPoint("TOPLEFT", x, y)

	SL.Low:SetText(vmin)
	SL.High:SetText(vmax)
	
	SL.Text:SetText(DRFGT(lstr) .. ": " .. DRFGetConfig(key, vval))

	SL:SetMinMaxValues(vmin, vmax)

	SL:SetValue(DRFGetConfig(key, vval))

	SL:SetObeyStepOnDrag(steps)
	SL:SetValueStep(steps)

	SL:SetScript("OnValueChanged", function(self, val)
		if steps == 1 then
			val = string.format("%" .. ".0" .. "f", val)
		else
			val = string.format("%" .. steps .. "f", val)
		end
		DRFTAB[key] = val
		SL.Text:SetText(DRFGT(lstr) .. ": " .. val)

		DRFSizing = true
	end)

	return SL
end

function DRFCreateCheckBox(parent, key, vval, x, y, lstr, pc)
	local CB = CreateFrame("CheckButton", nil, parent, "ChatConfigCheckButtonTemplate")
	CB:SetSize(18, 18)

	CB:SetPoint("TOPLEFT", x, y)

	CB.Text:SetPoint("LEFT", CB, "RIGHT", 0, 0)
	CB.Text:SetText(DRFGT(lstr))

	CB:SetChecked(DRFGetConfig(key, vval))

	CB:SetScript("OnClick", function(self, val)
		val = CB:GetChecked()
		if pc then
			DRFTABPC[key] = val
		else
			DRFTAB[key] = val
		end
		CB.Text:SetText(DRFGT(lstr))

		DRFSizing = true
	end)

	return CB
end

function DRFCreateComboBox(parent, key, vval, x, y, lstr, tab)
	local CB = LibDD:Create_UIDropDownMenu("Frame", parent)
	CB:SetPoint("TOPLEFT", x, y)

	
	CB.text = CB:CreateFontString(nil, "ARTWORK") 
	CB.text:SetFont(STANDARD_TEXT_FONT, 12, "")
	CB.text:SetText(DRFGT(lstr))
	CB.text:SetPoint("LEFT", CB, "RIGHT", 0, 3)
	CB.Text:SetText(DRFGT(lstr) .. ": " .. tostring(DRFGetConfig(key, vval)))

	LibDD:UIDropDownMenu_SetWidth(CB, 120)
	LibDD:UIDropDownMenu_SetText(CB, DRFGetConfig(key, vval))

	-- Create and bind the initialization function to the dropdown menu
	LibDD:UIDropDownMenu_Initialize(CB, function(self, level, menuList)
		for i, v in pairs(tab) do
			local info = LibDD:UIDropDownMenu_CreateInfo()
			info.func = self.SetValue
			info.text = v
			info.arg1 = v
			LibDD:UIDropDownMenu_AddButton(info)
		end
	end)

	function CB:SetValue(newValue)
		DRFTAB[key] = newValue
		LibDD:UIDropDownMenu_SetText(CB, newValue)
		LibDD:CloseDropDownMenus()

		DRFSizing = true
	end

	return CB
end



local Y = 0
local H = 16
local BR = 30
local sliderX = 12

local SORTTAB = {}
SORTTAB = {"Group", "Role"}

function DRFInitSettings()
	local DRFSettings = {}

	local DRFname = "DRaidFrames |T254652/:16:16:0:0|t by |cff3FC7EBD4KiR |T132115/:16:16:0:0|t"

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

	DRFCreateSlider(DRFSettings.panel, "DECI", 0, 12, -40, 0, 3, 1.0, "DECI") --parent, key, vval, x, y, vmin, vmax, steps, lstr

	DRFCreateCheckBox(DRFSettings.panel, "SHTO", true, 12, -80, "Show Tooltip", false)

	local b = CreateFrame("Button", "MyButton", DRFSettings.panel, "UIPanelButtonTemplate")
	b:SetSize(200, 24) -- width, height
	b:SetText("DISCORD")
	b:SetPoint("BOTTOMLEFT", 10, 10)
	b:SetScript("OnClick", function()
		local iconbtn = 32
		local s = CreateFrame("Frame", nil, UIParent) -- or you actual parent instead
		s:SetSize(300, 2 * iconbtn + 2 * 10)
		s:SetPoint("CENTER")

		s.texture = s:CreateTexture(nil, "BACKGROUND")
		s.texture:SetColorTexture(0, 0, 0, 0.5)
		s.texture:SetAllPoints(s)

		s.text = s:CreateFontString(nil,"ARTWORK") 
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
		s.close:SetScript("OnClick", function(self, btn, down)
			s:Hide()
		end)
	end)

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
	DRFSettings.gpanel.Text:SetText(DRFGT("DETY"))

	Y = Y - 18
	for i, v in pairs(DebuffTypeSymbol) do
		DRFCreateCheckBox(DRFSettings.gpanel, "G" .. i, true, X, Y, i, true) -- parent, key, vval, x, y, lstr)
		Y = Y - 18
	end
	DRFCreateCheckBox(DRFSettings.gpanel, "G" .. "None", true, X, Y, "None", true)

	Y = -10
	--DRFCreateComboBox(DRFSettings.gpanel, "GSORT", "Role", 0, Y, "SORTTYPE", SORTTAB)

	--Y = Y - 32
	DRFCreateComboBox(DRFSettings.gpanel, "GTETOTY", "Name", 0, Y, "TETOTY", {"Name", "Name + Realm", "Class", "Class + Name", "Name + Class", "None"})

	Y = Y - 32
	DRFCreateComboBox(DRFSettings.gpanel, "GTECETY", "Health in Percent", 0, Y, "TECETY", {"Health in Percent", "Lost Health in Percent", "None"})

	Y = Y - 32
	DRFCreateSlider(DRFSettings.gpanel, "GELEM", 5, 12, Y, 1, 40, 1.0, "ELEMENTS")

	Y = Y - 32
	DRFCreateCheckBox(DRFSettings.gpanel, "GSHPO", true, 12, Y, "SHPO") -- parent, key, vval, x, y, lstr)

	Y = Y - 20
	DRFCreateCheckBox(DRFSettings.gpanel, "GGRHO", true, 12, Y, "GRHO") -- parent, key, vval, x, y, lstr)

	Y = Y - 20
	DRFCreateCheckBox(DRFSettings.gpanel, "GBAUP", true, 12, Y, "BAUP") -- parent, key, vval, x, y, lstr)

	Y = Y - 20
	DRFCreateCheckBox(DRFSettings.gpanel, "GOVER", true, 12, Y, "OVER") -- parent, key, vval, x, y, lstr)

	if UnitHasRating then
		DRFCreateCheckBox(DRFSettings.gpanel, "GRATE", true, 200, Y + 60, "Rating") -- parent, key, vval, x, y, lstr)
	end

	if DRFBUILD == "RETAIL" then
		DRFCreateCheckBox(DRFSettings.gpanel, "GCOVE", true, 400, Y + 60, GARRISON_TYPE_9_0_LANDING_PAGE_TITLE) -- parent, key, vval, x, y, lstr)
	end

	DRFCreateCheckBox(DRFSettings.gpanel, "GFLAG", true, 200, Y + 40, LANGUAGE) -- parent, key, vval, x, y, lstr)

	DRFCreateCheckBox(DRFSettings.gpanel, "GCLAS", true, 200, Y + 20, CLASS) -- parent, key, vval, x, y, lstr)

	DRFCreateCheckBox(DRFSettings.gpanel, "GTHRE", true, 200, Y + 0, "Threat") -- parent, key, vval, x, y, lstr)

	Y = Y - 28
	DRFCreateSlider(DRFSettings.gpanel, "GOUBR", 6, sliderX, Y, 0, 20, 1.0, "OUBR")

	Y = Y - 32
	DRFCreateSlider(DRFSettings.gpanel, "GROSP", 6, sliderX, Y, 0, 50, 1.0, "ROSP")

	Y = Y - 32
	DRFCreateSlider(DRFSettings.gpanel, "GCOSP", 6, sliderX, Y, 0, 50, 1.0, "COSP")

	Y = Y - 10

	Y = Y - 32
	DRFCreateSlider(DRFSettings.gpanel, "GHEWI", 120, sliderX, Y, 20, 300, 1.0, "HEWI")

	Y = Y - 32
	DRFCreateSlider(DRFSettings.gpanel, "GHEHE", 60, sliderX, Y, 20, 300, 1.0, "HEHE")

	Y = Y - 32
	DRFCreateSlider(DRFSettings.gpanel, "GPOSI", 20, sliderX, Y, 8, 300, 1.0, "POSI")

	Y = Y - 10

	Y = Y - 32
	DRFCreateSlider(DRFSettings.gpanel, "GDESI", 16, sliderX, Y, 8, 64, 1.0, "DESI")

	Y = Y - 32
	DRFCreateSlider(DRFSettings.gpanel, "GBUSI", 16, sliderX, Y, 8, 64, 1.0, "BUSI")
	
	Y = Y - 32
	DRFCreateSlider(DRFSettings.gpanel, "GOORA", 0.4, sliderX, Y, 0.1, 0.9, 0.1, "OORA")

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
	local X = 500
	DRFSettings.rpanel.Text = DRFSettings.rpanel:CreateFontString(nil, "ARTWORK")
	DRFSettings.rpanel.Text:SetFont(STANDARD_TEXT_FONT, 11, "")
	DRFSettings.rpanel.Text:SetPoint("TOPLEFT", DRFSettings.rpanel, "TOPLEFT", X, Y)
	DRFSettings.rpanel.Text:SetText(DRFGT("DETY"))

	Y = Y - 18
	for i, v in pairs(DebuffTypeSymbol) do
		DRFCreateCheckBox(DRFSettings.rpanel, "R" .. i, true, X, Y, i, true) -- parent, key, vval, x, y, lstr)
		Y = Y - 18
	end
	DRFCreateCheckBox(DRFSettings.rpanel, "R" .. "None", true, X, Y, "None", true)



	Y = -10
	DRFCreateComboBox(DRFSettings.rpanel, "RSORT", "Role", 0, Y, "SORTTYPE", SORTTAB)

	Y = Y - 32
	DRFCreateComboBox(DRFSettings.rpanel, "RTETOTY", "Name", 0, Y, "TETOTY", {"Name", "Class", "Class + Name", "Name + Class", "None"})

	Y = Y - 32
	DRFCreateComboBox(DRFSettings.rpanel, "RTECETY", "Health in Percent", 0, Y, "TECETY", {"Health in Percent", "Lost Health in Percent", "None"})

	Y = Y - 32
	DRFCreateSlider(DRFSettings.rpanel, "RELEM", 5, 12, Y, 1, 40, 1.0, "ELEMENTS")

	Y = Y - 32
	DRFCreateCheckBox(DRFSettings.rpanel, "RSHPO", true, 12, Y, "SHPO") -- parent, key, vval, x, y, lstr)

	Y = Y - 20
	DRFCreateCheckBox(DRFSettings.rpanel, "RGRHO", true, 12, Y, "GRHO") -- parent, key, vval, x, y, lstr)

	Y = Y - 20
	DRFCreateCheckBox(DRFSettings.rpanel, "RBAUP", true, 12, Y, "BAUP") -- parent, key, vval, x, y, lstr)

	Y = Y - 20
	DRFCreateCheckBox(DRFSettings.rpanel, "ROVER", false, 12, Y, "OVER") -- parent, key, vval, x, y, lstr)

	if UnitHasRating then
		DRFCreateCheckBox(DRFSettings.rpanel, "RRATE", true, 200, Y + 60, "Rating") -- parent, key, vval, x, y, lstr)
	end

	if DRFBUILD == "RETAIL" then
		DRFCreateCheckBox(DRFSettings.rpanel, "RCOVE", true, 400, Y + 60, GARRISON_TYPE_9_0_LANDING_PAGE_TITLE) -- parent, key, vval, x, y, lstr)
	end

	DRFCreateCheckBox(DRFSettings.rpanel, "RFLAG", true, 200, Y + 40, LANGUAGE) -- parent, key, vval, x, y, lstr)

	DRFCreateCheckBox(DRFSettings.rpanel, "RCLAS", true, 200, Y + 20, CLASS) -- parent, key, vval, x, y, lstr)

	DRFCreateCheckBox(DRFSettings.rpanel, "RTHRE", false, 200, Y + 0, "Threat") -- parent, key, vval, x, y, lstr)

	Y = Y - 28
	DRFCreateSlider(DRFSettings.rpanel, "ROUBR", 6, sliderX, Y, 0, 20, 1.0, "OUBR")

	Y = Y - 32
	DRFCreateSlider(DRFSettings.rpanel, "RROSP", 4, sliderX, Y, 0, 50, 1.0, "ROSP")

	Y = Y - 32
	DRFCreateSlider(DRFSettings.rpanel, "RCOSP", 20, sliderX, Y, 0, 50, 1.0, "COSP")

	Y = Y - 10

	Y = Y - 32
	DRFCreateSlider(DRFSettings.rpanel, "RHEWI", 80, sliderX, Y, 20, 300, 1.0, "HEWI")

	Y = Y - 32
	DRFCreateSlider(DRFSettings.rpanel, "RHEHE", 60, sliderX, Y, 20, 300, 1.0, "HEHE")

	Y = Y - 32
	DRFCreateSlider(DRFSettings.rpanel, "RPOSI", 10, sliderX, Y, 8, 300, 1.0, "POSI")

	Y = Y - 10

	Y = Y - 32
	DRFCreateSlider(DRFSettings.rpanel, "RDESI", 16, sliderX, Y, 8, 64, 1.0, "DESI")

	Y = Y - 32
	DRFCreateSlider(DRFSettings.rpanel, "RBUSI", 16, sliderX, Y, 8, 64, 1.0, "BUSI")

	Y = Y - 32
	DRFCreateSlider(DRFSettings.rpanel, "ROORA", 0.4, sliderX, Y, 0.1, 0.9, 0.1, "OORA")


	InterfaceOptions_AddCategory(DRFSettings.rpanel)
end



local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("GROUP_ROSTER_UPDATE")
function f:OnEvent(event)
	if event == "GROUP_ROSTER_UPDATE" then
		DRFSizing = true
	end

	if ( event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" ) and not DRFLoaded then
		DRFLoaded = true

		DRFSizingForce = true
		DRFUpdateSize()

		DRFUpdating = true
		DRFUpdatingUnits = true
		DRFOnUpdate()
		
		C_Timer.After(0, function()
			DRFInitSettings()
		end)
	end
end
f:SetScript("OnEvent", f.OnEvent)
