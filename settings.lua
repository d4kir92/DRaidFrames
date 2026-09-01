-- By D4KiR
local _, DRaidFrames = ...
local ICON = 254652
local DEFAULT_WIDTH = 520
local DEFAULT_HEIGHT = 560
local DRFLoaded = false
local drfset = nil
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

	if tonumber(value) ~= nil then value = tonumber(value) end
	return value
end

function DRaidFrames:SetConfig(key, value, pc)
	if pc then
		DRFTABPC = DRFTABPC or {}
		DRFTABPC[key] = value
		return
	end

	DRFTAB = DRFTAB or {}
	DRFTAB[key] = value
end

DRaidFrames:SetAddonOutput("DRaidFrames", ICON)
local TOPTEXTCHOICES = {
	{
		["value"] = "Name",
		["label"] = "LID_TETY_NAME"
	},
	{
		["value"] = "Name + Realm",
		["label"] = "LID_TETY_NAMEREALM"
	},
	{
		["value"] = "Class",
		["label"] = "LID_TETY_CLASS"
	},
	{
		["value"] = "Class + Name",
		["label"] = "LID_TETY_CLASSNAME"
	},
	{
		["value"] = "Name + Class",
		["label"] = "LID_TETY_NAMECLASS"
	},
	{
		["value"] = "None",
		["label"] = "LID_TETY_NONE"
	}
}

local CENTERTEXTCHOICES = {
	{
		["value"] = "Health in Percent",
		["label"] = "LID_CETY_HEALTHPCT"
	},
	{
		["value"] = "Lost Health in Percent",
		["label"] = "LID_CETY_LOSTHEALTHPCT"
	},
	{
		["value"] = "None",
		["label"] = "LID_TETY_NONE"
	}
}

local SORTCHOICES = {
	{
		["value"] = "Group",
		["label"] = "LID_SORT_GROUP"
	},
	{
		["value"] = "Role",
		["label"] = "LID_SORT_ROLE"
	}
}

function DRaidFrames:ToggleSettings()
	if drfset == nil then return end
	drfset:Toggle()
end

local function GetCollapsed(key)
	if key == nil then return nil end
	if type(DRFTAB) ~= "table" then return nil end
	if type(DRFTAB["COLLAPSED"]) ~= "table" then return nil end
	return DRFTAB["COLLAPSED"][key]
end

local function SetCollapsed(key, collapsed)
	if key == nil then return end
	if type(DRFTAB) ~= "table" then return end
	if type(DRFTAB["COLLAPSED"]) ~= "table" then DRFTAB["COLLAPSED"] = {} end
	if collapsed then
		DRFTAB["COLLAPSED"][key] = true
	else
		DRFTAB["COLLAPSED"][key] = nil
	end
end

local function LID(key)
	return "LID_" .. key
end

local function AddCategory(key, label, level)
	drfset:AddCategory({
		["label"] = label,
		["key"] = key,
		["search"] = key,
		["level"] = level
	})
end

local function AddCheckbox(key, default, pc, func)
	drfset:AddCheckbox({
		["label"] = LID(key),
		["search"] = key,
		["value"] = DRaidFrames:GetConfig(key, default, pc),
		["func"] = function(value)
			DRaidFrames:SetConfig(key, value, pc)
			DRaidFrames:SetSizing(true)
			if func then func(value) end
		end
	})
end

local function AddSlider(key, default, vmin, vmax, step, decimals)
	drfset:AddSlider({
		["label"] = LID(key),
		["search"] = key,
		["value"] = DRaidFrames:GetConfig(key, default),
		["min"] = vmin,
		["max"] = vmax,
		["step"] = step,
		["decimals"] = decimals or 0,
		["func"] = function(value)
			DRaidFrames:SetConfig(key, value)
			DRaidFrames:SetSizing(true)
		end
	})
end

local function AddDropdown(key, default, choices)
	drfset:AddDropdown({
		["label"] = LID(key),
		["search"] = key,
		["value"] = DRaidFrames:GetConfig(key, default),
		["choices"] = choices,
		["func"] = function(value)
			DRaidFrames:SetConfig(key, value)
			DRaidFrames:SetSizing(true)
		end
	})
end

local function AddDebuffTypes(prefix)
	local colors = GetDebuffColors()
	if colors == nil then
		DRaidFrames:MSG("MISSING GetDebuffColors()")
		return
	end

	local types = {}
	for typ in pairs(colors) do
		if typ ~= "None" then tinsert(types, typ) end
	end

	table.sort(types)
	for _, typ in ipairs(types) do
		AddCheckbox(prefix .. typ, true, true)
	end

	AddCheckbox(prefix .. "None", true, true)
end

local function AddFrameOptions(category, prefix)
	AddCategory(category .. "_LAYOUT", "LID_LAYOUT", 2)
	AddCheckbox(prefix .. "GRHO", true)
	AddCheckbox(prefix .. "BAUP", true)
	AddCheckbox(prefix .. "OVER", true)
	AddSlider(prefix .. "ELEM", 5, 1, 40, 1)
	AddSlider(prefix .. "ROSP", 6, 0, 50, 1)
	AddSlider(prefix .. "COSP", 6, 0, 50, 1)
	AddSlider(prefix .. "OUBR", 6, 0, 20, 1)
	AddCategory(category .. "_SIZE", "LID_SIZE", 2)
	AddSlider(prefix .. "HEWI", 120, 20, 300, 1)
	AddSlider(prefix .. "HEHE", 60, 20, 300, 1)
	AddSlider(prefix .. "POSI", 20, 8, 300, 1)
	AddCategory(category .. "_DISPLAY", "LID_DISPLAY", 2)
	AddCheckbox(prefix .. "SHPO", true)
	AddCheckbox(prefix .. "FLAG", true)
	AddCheckbox(prefix .. "CLAS", true)
	AddCheckbox(prefix .. "THRE", true)
	AddSlider(prefix .. "OORA", 0.4, 0.1, 0.9, 0.1, 1)
	AddCategory(category .. "_TEXT", "LID_TEXT", 2)
	AddDropdown(prefix .. "TETOTY", "Name", TOPTEXTCHOICES)
	AddDropdown(prefix .. "TECETY", "Health in Percent", CENTERTEXTCHOICES)
	AddCategory(category .. "_AURAS", "LID_AURAS", 2)
	AddSlider(prefix .. "BUSI", 16, 8, 65, 1)
	AddSlider(prefix .. "DESI", 16, 8, 65, 1)
	AddCategory(category .. "_DEBUFFTYPES", LID(prefix .. "DETY"), 3)
	AddDebuffTypes(prefix)
end

local drfsetting = false
function DRaidFrames:InitSettings()
	if drfsetting then return end
	drfsetting = true
	DRFTAB = DRFTAB or {}
	DRaidFrames:SetVersion(ICON, "1.2.0")
	drfset = DRaidFrames:CreateUIWindow({
		["name"] = "DRaidFramesSettings",
		["pTab"] = {"CENTER"},
		["width"] = DRaidFrames:GetConfig("WINDOWWIDTH", DEFAULT_WIDTH),
		["height"] = DRaidFrames:GetConfig("WINDOWHEIGHT", DEFAULT_HEIGHT),
		["minWidth"] = 360,
		["minHeight"] = 240,
		["onResize"] = function(width, height)
			DRaidFrames:SetConfig("WINDOWWIDTH", width)
			DRaidFrames:SetConfig("WINDOWHEIGHT", height)
		end,
		["getCollapsed"] = function(key) return GetCollapsed(key) end,
		["setCollapsed"] = function(key, collapsed) SetCollapsed(key, collapsed) end,
		["title"] = format("|T%d:16:16:0:0|t DRaidFrames by |cff55d2ffD4KiR|r v%s", ICON, DRaidFrames:GetVersion())
	})

	drfset:SuspendLayout()
	drfset:AddSearch()
	AddCategory("GENERAL", "LID_GENERAL", 1)
	AddCheckbox("MMBTN", DRaidFrames:GetWoWBuild() ~= "RETAIL", false, function(value)
		if value then
			DRaidFrames:ShowMMBtn("DRaidFrames")
		else
			DRaidFrames:HideMMBtn("DRaidFrames")
		end
	end)

	AddCheckbox("SHTO", true)
	AddDropdown("SORTTYPE", "Role", SORTCHOICES)
	AddSlider("DECI", 0, 0, 3, 1)
	AddCategory("PARTY", "LID_PARTY", 1)
	AddFrameOptions("PARTY", "G")
	AddCategory("RAID", "LID_RAID", 1)
	AddFrameOptions("RAID", "R")
	drfset:ResumeLayout()
	DRaidFrames:CreateMinimapButton({
		["name"] = "DRaidFrames",
		["icon"] = ICON,
		["dbtab"] = DRFTAB,
		["dbkey"] = "MMBTN",
		["vTT"] = {{format("|T%d:16:16:0:0|t DRaidFrames", ICON), "v" .. DRaidFrames:GetVersion()}, {DRaidFrames:Trans("LID_LEFTCLICK"), DRaidFrames:Trans("LID_OPENSETTINGS")}, {DRaidFrames:Trans("LID_RIGHTCLICK"), DRaidFrames:Trans("LID_HIDEMINIMAPBUTTON")}},
		["funcL"] = function() DRaidFrames:ToggleSettings() end,
		["funcR"] = function()
			DRaidFrames:SetConfig("MMBTN", false)
			DRaidFrames:MSG("Minimap Button is now hidden.")
			DRaidFrames:HideMMBtn("DRaidFrames")
		end
	})

	DRaidFrames:AddSlash("drf", function() DRaidFrames:ToggleSettings() end)
	DRaidFrames:AddSlash("draidframes", function() DRaidFrames:ToggleSettings() end)
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("GROUP_ROSTER_UPDATE")
function f:OnEvent(event)
	if event == "GROUP_ROSTER_UPDATE" then DRaidFrames:SetSizing(true) end
	if (event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD") and not DRFLoaded then
		DRFLoaded = true
		DRaidFrames:SetAddonOutput("DRaidFrames", ICON)
		DRaidFrames:SetSizingForce(true)
		DRaidFrames:UpdateSize()
		DRaidFrames:SetUpdating(true)
		DRaidFrames:OnUpdate()
		C_Timer.After(0, function() DRaidFrames:InitSettings() end)
	end
end

f:SetScript("OnEvent", f.OnEvent)
