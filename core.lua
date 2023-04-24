-- By D4KiR
local _, DRaidFrames = ...
-- CONFIG
local DRF_MAX_BUFFS = 8
local DRF_MAX_DEBUFFS = 8
-- CONFIG
-- "Globals"
local DRFReadyStatus = ""
local DRFUNITSGROUP = {}

for i = 1, 4 do
	tinsert(DRFUNITSGROUP, "PARTY" .. i)
end

local DRFUNITSRAID = {}

for i = 1, 40 do
	tinsert(DRFUNITSRAID, "RAID" .. i)
end

local texCoords = {
	["Raid-AggroFrame"] = {0.00781250, 0.55468750, 0.00781250, 0.27343750},
	["Raid-TargetFrame"] = {0.00781250, 0.55468750, 0.28906250, 0.55468750}
}

local DRFLayers = {}
DRFLayers["HealthBackground"] = 1
DRFLayers["HealthBar"] = 2
DRFLayers["Prediction"] = 3
DRFLayers["Absorb"] = 3
DRFLayers["AbsorbOverlay"] = 3
DRFLayers["HealthTextTop"] = 3
DRFLayers["HealthTextCen"] = 3
DRFLayers["HealthTextBot"] = 3
DRFLayers["PowerBackground"] = 1
DRFLayers["PowerBar"] = 2
DRFLayers["PowerTextCen"] = 3
DRFLayers["RaidIcon"] = 3
DRFLayers["Aggro"] = 3
DRFLayers["RoleIcon"] = 3
DRFLayers["ClassIcon"] = 3
DRFLayers["LangIcon"] = 3
DRFLayers["RankIcon"] = 3
DRFLayers["RankIcon2"] = 3
DRFLayers["ReadyCheck"] = 3
DRFLayers["Highlight"] = 4

if DRaidFrames:GetWoWBuild() ~= "RETAIL" then
	local DRFHealTab = {}
	local DRFIncomingHeals = {}
	local pfhp = PlayerFrameHealthBar:GetStatusBarTexture()
	local tfhp = TargetFrameHealthBar:GetStatusBarTexture()
	IncomingHealPlayer = PlayerFrameHealthBar:CreateTexture(nil, "OVERLAY")
	IncomingHealPlayer:SetSize(PlayerFrameHealthBar:GetWidth(), PlayerFrameHealthBar:GetHeight())
	IncomingHealPlayer:SetPoint("LEFT", pfhp, "RIGHT", 0, 0)
	IncomingHealPlayer:SetColorTexture(0, 0, 0, 0)
	IncomingHealTarget = TargetFrameHealthBar:CreateTexture(nil, "OVERLAY")
	IncomingHealTarget:SetSize(TargetFrameHealthBar:GetWidth(), TargetFrameHealthBar:GetHeight())
	IncomingHealTarget:SetPoint("LEFT", tfhp, "RIGHT", 0, 0)
	IncomingHealTarget:SetColorTexture(0, 0, 0, 0)

	function DRaidFrames:UpdateBLIZZUI()
		local pw = PlayerFrameHealthBar:GetWidth()

		if pw and UnitGetIncomingHeals("PLAYER") ~= 0 then
			local pre = pw * UnitGetIncomingHeals("PLAYER") / UnitHealthMax("PLAYER")
			IncomingHealPlayer:SetSize(pre, PlayerFrameHealthBar:GetHeight())
			local r, g, b = pfhp:GetVertexColor()
			IncomingHealPlayer:SetColorTexture(r, g, b, 0.5)
			IncomingHealPlayer:Show()
		else
			IncomingHealPlayer:Hide()
		end

		if UnitName("TARGET") == nil then
			IncomingHealTarget:Hide()

			return
		end

		local tw = TargetFrameHealthBar:GetWidth()

		if tw and UnitGetIncomingHeals("TARGET") ~= 0 then
			local pre = tw * UnitGetIncomingHeals("TARGET") / UnitHealthMax("TARGET")
			IncomingHealTarget:SetSize(pre, TargetFrameHealthBar:GetHeight())
			local r, g, b = tfhp:GetVertexColor()
			IncomingHealTarget:SetColorTexture(r, g, b, 0.5)
			IncomingHealTarget:Show()
		else
			IncomingHealTarget:Hide()
		end
	end

	local f = CreateFrame("FRAME")
	f:RegisterEvent("UNIT_SPELLCAST_SENT")
	f:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	f:RegisterEvent("UNIT_SPELLCAST_STOP")
	f:RegisterEvent("UNIT_SPELLCAST_FAILED")

	f:SetScript("OnEvent", function(self, event, ...)
		if event == "UNIT_SPELLCAST_SENT" then
			local unit, target, _, spellID = ...
			local heal = 1

			for i, v in pairs({string.split(" ", GetSpellDescription(spellID))}) do
				if type(tonumber(v)) == "number" then
					heal = v
					break
				end
			end

			if spellID and target then
				DRFHealTab[target] = unit
				DRFHealTab[unit] = target

				if DRFIncomingHeals[target] == nil then
					DRFIncomingHeals[target] = {}
				end

				DRFIncomingHeals[target][unit] = heal
			end
		elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
			local unit, _, spellID = ...
			local target = DRFHealTab[unit]

			if spellID and target then
				DRFHealTab[unit] = nil
				DRFHealTab[target] = nil
				DRFIncomingHeals[target][unit] = nil

				if getn(DRFIncomingHeals[target]) == 0 then
					DRFIncomingHeals[target] = nil
				end
			end
		elseif event == "UNIT_SPELLCAST_STOP" then
			local unit, _, spellID = ...
			local target = DRFHealTab[unit]

			if spellID and target then
				DRFHealTab[unit] = nil
				DRFHealTab[target] = nil
				DRFIncomingHeals[target][unit] = nil

				if getn(DRFIncomingHeals[target]) == 0 then
					DRFIncomingHeals[target] = nil
				end
			end
		elseif event == "UNIT_SPELLCAST_FAILED" then
			local unit, _, spellID = ...
			local target = DRFHealTab[unit]

			if spellID and target then
				DRFHealTab[unit] = nil
				DRFHealTab[target] = nil
				DRFIncomingHeals[target][unit] = nil

				if getn(DRFIncomingHeals[target]) == 0 then
					DRFIncomingHeals[target] = nil
				end
			end
		end

		DRaidFrames:UpdateBLIZZUI()
	end)

	function UnitGetIncomingHeals(unit)
		local target = UnitName(unit)
		local isPlayer = UnitIsPlayer(unit)

		if target then
			local heals = 0

			if DRFIncomingHeals[target] then
				for i, v in pairs(DRFIncomingHeals[target]) do
					if isPlayer then
						heals = heals + v
					else
						heals = heals - v
					end
				end
			end

			return heals
		end

		return 0
	end

	function UnitGetTotalAbsorbs(unit)
		return 0
	end

	DRaidFrames:UpdateBLIZZUI()
end

function DRaidFrames:UnitName(unit, showrealm)
	if UnitExists(unit) then
		local name, realm = UnitName(unit)

		if SM_CHARNAME then
			local pn = UnitName("player")
			if name == pn then return SM_CHARNAME end
		end

		if showrealm then
			if realm and realm ~= "" then
				name = name .. "-" .. realm
			else
				name = name .. "-" .. GetRealmName()
			end
		end

		return name
	else
		return ""
	end
end

function DRaidFrames:GetMaxLevel()
	local maxlevel = 60

	if DRaidFrames:GetWoWBuild() == "TBC" then
		maxlevel = 70
	end

	if DRaidFrames:GetWoWBuild() == "WRATH" then
		maxlevel = 80
	end

	if DRaidFrames:GetWoWBuild() == "RETAIL" then
		maxlevel = 70
	end

	if GetMaxLevelForPlayerExpansion ~= nil then
		maxlevel = GetMaxLevelForPlayerExpansion()
	end

	return maxlevel
end

function DRaidFrames:UnitXP(unit)
	if IATAB and IATAB.UnitXP then return IATAB:UnitXP(unit) end

	return 0
end

function DRaidFrames:UnitXPMax(unit)
	if IATAB and IATAB.UnitXPMax then return IATAB:UnitXPMax(unit) end

	return 1
end

-- Main Frame
local DRF = CreateFrame("Frame", "DRF", UIParent)
DRF:SetMovable(true)
DRF:SetUserPlaced(true)
DRF:EnableMouse(true)
DRF:RegisterForDrag("LeftButton")
DRF:SetClampedToScreen(true)

function DRaidFrames:SavePosition()
	local point, parent, relativePoint, ofsx, ofsy = DRF:GetPoint()

	if IsInRaid() then
		DRFTAB["DRFR" .. "point"] = point
		DRFTAB["DRFR" .. "parent"] = parent
		DRFTAB["DRFR" .. "relativePoint"] = relativePoint
		DRFTAB["DRFR" .. "ofsx"] = ofsx
		DRFTAB["DRFR" .. "ofsy"] = ofsy
	else
		DRFTAB["DRF" .. "point"] = point
		DRFTAB["DRF" .. "parent"] = parent
		DRFTAB["DRF" .. "relativePoint"] = relativePoint
		DRFTAB["DRF" .. "ofsx"] = ofsx
		DRFTAB["DRF" .. "ofsy"] = ofsy
	end
end

function DRaidFrames:UpdatePosition()
	if not InCombatLockdown() then
		if IsInRaid() and DRFTAB["DRFR" .. "point"] then
			local point = DRFTAB["DRFR" .. "point"]
			local parent = DRFTAB["DRFR" .. "parent"]
			local relativePoint = DRFTAB["DRFR" .. "relativePoint"]
			local ofsx = DRFTAB["DRFR" .. "ofsx"]
			local ofsy = DRFTAB["DRFR" .. "ofsy"]

			if point and relativePoint then
				DRF:ClearAllPoints()
				DRF:SetPoint(point, parent, relativePoint, ofsx, ofsy)
			end
		elseif DRFTAB["DRF" .. "point"] then
			local point = DRFTAB["DRF" .. "point"]
			local parent = DRFTAB["DRF" .. "parent"]
			local relativePoint = DRFTAB["DRF" .. "relativePoint"]
			local ofsx = DRFTAB["DRF" .. "ofsx"]
			local ofsy = DRFTAB["DRF" .. "ofsy"]

			if point and relativePoint then
				DRF:ClearAllPoints()
				DRF:SetPoint(point, parent, relativePoint, ofsx, ofsy)
			end
		end
	else
		C_Timer.After(0.01, DRaidFrames.UpdatePosition)
	end
end

DRF.isMoving = false

DRF:SetScript("OnDragStart", function(self)
	DRF:StartMoving()
	DRF.isMoving = true
end)

DRF:SetScript("OnDragStop", function(self)
	DRF:StopMovingOrSizing()
	DRF.isMoving = false
	DRaidFrames:SavePosition()
end)

DRF.isInRaid = false

DRF:HookScript("OnUpdate", function(self, ...)
	if DRF.isInRaid ~= IsInRaid() then
		DRF.isInRaid = IsInRaid()
		DRaidFrames:UpdatePosition()
	end
end)

DRF:SetPoint("CENTER", 0, 0)
DRF.texture = DRF:CreateTexture(nil, "BACKGROUND")
DRF.texture:SetAllPoints(DRF)
DRF.texture:SetColorTexture(0, 0, 0, 1)

function DRaidFrames:Think()
	if MouseIsOver(DRF) then
		DRF.texture:SetAlpha(0.5)
	else
		DRF.texture:SetAlpha(0.25)
	end

	C_Timer.After(0.1, DRaidFrames.Think)
end

DRaidFrames:Think()

function DRaidFrames:UpdateTooltip(self)
	if SHTO and self.unit and UnitExists(self.unit) then
		GameTooltip_SetDefaultAnchor(GameTooltip, self)

		if GameTooltip:SetUnit(self.unit, self.hideStatusOnTooltip) then
			self.UpdateTooltip = self.UpdateTooltip
		else
			self.UpdateTooltip = nil
		end

		local r, g, b = GameTooltip_UnitColor(self.unit)
		GameTooltipTextLeft1:SetTextColor(r, g, b)
	end
end

DRF.UFS = {}
-- Player Frames
local id = 1

for group = 1, 8 do
	for ply = 1, 5 do
		-- Player Box
		DRF.UFS[id] = CreateFrame("Frame", "DRF" .. id, DRF)
		DRF.UFS[id].id = id
		-- Health Bar
		DRF.UFS[id].HealthBackground = DRF.UFS[id]:CreateTexture(nil, "BORDER")
		DRF.UFS[id].HealthBackground:SetDrawLayer("BORDER", DRFLayers["HealthBackground"])
		DRF.UFS[id].HealthBackground:SetColorTexture(0, 0, 0, 0.75)
		DRF.UFS[id].HealthBar = DRF.UFS[id]:CreateTexture(nil, "ARTWORK")
		DRF.UFS[id].HealthBar:SetDrawLayer("ARTWORK", DRFLayers["HealthBar"])
		DRF.UFS[id].HealthBar:SetTexture("Interface/Addons/DRaidFrames/media/bar") --"Interface/RaidFrame/Raid-Bar-Hp-Fill")
		DRF.UFS[id].HealthBar:SetVertexColor(0.2, 1, 0.2)

		if UnitGetIncomingHeals and UnitGetTotalAbsorbs then
			DRF.UFS[id].Prediction = DRF.UFS[id]:CreateTexture(nil, "ARTWORK")
			DRF.UFS[id].Prediction:SetDrawLayer("ARTWORK", DRFLayers["Prediction"])
			DRF.UFS[id].Prediction:SetTexture("Interface/Addons/DRaidFrames/media/bar") --"Interface/RaidFrame/Raid-Bar-Hp-Fill")
			--DRF.UFS[id].Prediction:SetTexCoord(0, 1, 0, 0.53125);
			DRF.UFS[id].Prediction:SetVertexColor(0, 0, 0)
			DRF.UFS[id].Absorb = DRF.UFS[id]:CreateTexture(nil, "ARTWORK")
			DRF.UFS[id].Absorb:SetDrawLayer("ARTWORK", DRFLayers["Absorb"])
			DRF.UFS[id].Absorb.tileSize = 32
			DRF.UFS[id].Absorb:SetTexture("Interface/RaidFrame/Shield-Fill")
			DRF.UFS[id].Absorb:SetTexCoord(0, 1, 0, 0.53125)
			DRF.UFS[id].Absorb:SetVertexColor(0, 0, 0)
			DRF.UFS[id].AbsorbOverlay = DRF.UFS[id]:CreateTexture(nil, "OVERLAY")
			DRF.UFS[id].AbsorbOverlay:SetDrawLayer("OVERLAY", DRFLayers["AbsorbOverlay"])
			DRF.UFS[id].AbsorbOverlay:SetTexture("Interface/RaidFrame/Shield-Overlay", true, true) --Tile both vertically and horizontally
			DRF.UFS[id].AbsorbOverlay:SetAllPoints(DRF.UFS[id].Absorb)
			DRF.UFS[id].AbsorbOverlay.tileSize = 32
			DRF.UFS[id].AbsorbOverlay:SetHorizTile(true) -- fix
			DRF.UFS[id].AbsorbOverlay:SetVertTile(true) -- fix
		end

		DRF.UFS[id].HealthTextTop = DRF.UFS[id]:CreateFontString(nil, "OVERLAY")
		DRF.UFS[id].HealthTextTop:SetDrawLayer("OVERLAY", DRFLayers["HealthTextTop"])
		DRF.UFS[id].HealthTextTop:SetFont(STANDARD_TEXT_FONT, 9, "")
		DRF.UFS[id].HealthTextTop:SetText("")
		DRF.UFS[id].HealthTextTop:SetPoint("TOP", DRF.UFS[id].HealthBackground, "TOP", 0, -3)
		DRF.UFS[id].HealthTextCen = DRF.UFS[id]:CreateFontString(nil, "OVERLAY")
		DRF.UFS[id].HealthTextCen:SetDrawLayer("OVERLAY", DRFLayers["HealthTextCen"])
		DRF.UFS[id].HealthTextCen:SetFont(STANDARD_TEXT_FONT, 9, "")
		DRF.UFS[id].HealthTextCen:SetText("")
		DRF.UFS[id].HealthTextCen:SetPoint("CENTER", DRF.UFS[id].HealthBackground, "CENTER", 0, 0)
		DRF.UFS[id].HealthTextTop2 = DRF.UFS[id]:CreateFontString(nil, "OVERLAY")
		DRF.UFS[id].HealthTextTop2:SetDrawLayer("OVERLAY", DRFLayers["HealthTextBot"])
		DRF.UFS[id].HealthTextTop2:SetFont(STANDARD_TEXT_FONT, 9, "")
		DRF.UFS[id].HealthTextTop2:SetText("")
		DRF.UFS[id].HealthTextTop2:SetPoint("TOP", DRF.UFS[id].HealthBackground, "TOP", 0, -14)
		-- Power Bar
		DRF.UFS[id].PowerBackground = DRF.UFS[id]:CreateTexture(nil, "BORDER")
		DRF.UFS[id].PowerBackground:SetDrawLayer("BORDER", DRFLayers["PowerBackground"])
		DRF.UFS[id].PowerBackground:SetColorTexture(0, 0, 0, 0.4)
		DRF.UFS[id].PowerBar = DRF.UFS[id]:CreateTexture(nil, "ARTWORK")
		DRF.UFS[id].PowerBar:SetDrawLayer("ARTWORK", DRFLayers["PowerBar"])
		--DRF.UFS[id].PowerBar:SetAllPoints(DRF.UFS[id])
		DRF.UFS[id].PowerBar:SetTexture("Interface/Addons/DRaidFrames/media/bar")
		DRF.UFS[id].PowerBar:SetVertexColor(1, 1, 1)
		DRF.UFS[id].PowerTextCen = DRF.UFS[id]:CreateFontString(nil, "OVERLAY")
		DRF.UFS[id].PowerTextCen:SetDrawLayer("OVERLAY", DRFLayers["PowerTextCen"])
		DRF.UFS[id].PowerTextCen:SetFont(STANDARD_TEXT_FONT, 9, "")
		DRF.UFS[id].PowerTextCen:SetText("ID " .. id)
		DRF.UFS[id].PowerTextCen:SetPoint("CENTER", DRF.UFS[id].PowerBackground, "CENTER", 0, 0)
		-- Raid Icon
		DRF.UFS[id].RaidIcon = DRF.UFS[id]:CreateTexture(nil, "OVERLAY")
		DRF.UFS[id].RaidIcon:SetDrawLayer("OVERLAY", DRFLayers["RaidIcon"])
		DRF.UFS[id].RaidIcon:SetSize(14, 14)
		DRF.UFS[id].RaidIcon:SetPoint("BOTTOM", DRF.UFS[id].HealthBackground, "BOTTOM", 0, 14)
		DRF.UFS[id].RaidIcon:SetTexture(nil)
		-- Buff
		DRF.UFS[id].BuffBar = CreateFrame("Frame", "DRFBUFFBAR" .. id, DRF.UFS[id])
		DRF.UFS[id].BuffBar:SetSize(DRF_MAX_BUFFS * 18, 18)
		DRF.UFS[id].BuffBar:SetPoint("BOTTOMRIGHT", DRF.UFS[id].HealthBackground, "BOTTOMRIGHT", 0, 0)

		for i = 1, DRF_MAX_BUFFS do
			if DRaidFrames:GetWoWBuild() ~= "RETAIL" then
				DRF.UFS[id].BuffBar[i] = CreateFrame("Button", "DRFBUFF" .. id .. "_" .. i, DRF.UFS[id].BuffBar, "BuffButtonTemplate")
			else
				DRF.UFS[id].BuffBar[i] = CreateFrame("Button", "DRFBUFF" .. id .. "_" .. i, DRF.UFS[id].BuffBar, "AuraButtonTemplate")
				DRF.UFS[id].BuffBar[i]:UpdateAuraType("Buff")
			end

			DRF.UFS[id].BuffBar[i].buttonInfo = {}
			DRF.UFS[id].BuffBar[i].buttonInfo.expirationTime = -1
			DRF.UFS[id].BuffBar[i].parent = DRF.UFS[id].BuffBar

			if DRF.UFS[id].BuffBar[i].Icon == nil then
				DRF.UFS[id].BuffBar[i].Icon = _G["DRFBUFF" .. id .. "_" .. i .. "Icon"]
			end

			DRF.UFS[id].BuffBar[i]:EnableMouse(false)
			DRF.UFS[id].BuffBar[i]:SetSize(18, 18)

			if DRF.UFS[id].BuffBar[i].Icon then
				DRF.UFS[id].BuffBar[i].Icon:SetSize(18, 18)
			end

			DRF.UFS[id].BuffBar[i].cooldown = CreateFrame("Cooldown", "DRFBUFF" .. id .. "_" .. i .. "Cooldown", DRF.UFS[id].BuffBar[i], "CooldownFrameTemplate")
			DRF.UFS[id].BuffBar[i].cooldown:SetSize(18, 18)
			DRF.UFS[id].BuffBar[i].cooldown:SetAllPoints(DRF.UFS[id].BuffBar[i])
			DRF.UFS[id].BuffBar[i].cooldown:SetHideCountdownNumbers(true)
			DRF.UFS[id].BuffBar[i].cooldown:SetReverse(true)

			if _G["DRFBUFF" .. id .. "_" .. i .. "Duration"] ~= nil then
				local duration = _G["DRFBUFF" .. id .. "_" .. i .. "Duration"]

				hooksecurefunc(duration, "Show", function(self)
					self:Hide()
				end)

				duration:Hide()
			end

			if DRF.UFS[id].BuffBar[i].Duration ~= nil then
				local duration = DRF.UFS[id].BuffBar[i].Duration

				hooksecurefunc(duration, "Show", function(self)
					self:Hide()
				end)

				duration:Hide()
			end
		end

		-- Debuff
		DRF.UFS[id].DebuffBar = CreateFrame("Frame", "DRFDEBUFFBAR" .. id, DRF.UFS[id])
		DRF.UFS[id].DebuffBar:SetSize(DRF_MAX_DEBUFFS * 18, 18)
		DRF.UFS[id].DebuffBar:SetPoint("BOTTOMLEFT", DRF.UFS[id].HealthBackground, "BOTTOMLEFT", 0, 0)

		for i = 1, DRF_MAX_DEBUFFS do
			if DRaidFrames:GetWoWBuild() ~= "RETAIL" then
				DRF.UFS[id].DebuffBar[i] = CreateFrame("Button", "DRFDEBUFF" .. id .. "_" .. i, DRF.UFS[id].DebuffBar, "DebuffButtonTemplate")
			else
				DRF.UFS[id].DebuffBar[i] = CreateFrame("Button", "DRFDEBUFF" .. id .. "_" .. i, DRF.UFS[id].DebuffBar, "AuraButtonTemplate")
				DRF.UFS[id].DebuffBar[i]:UpdateAuraType("Debuff")
			end

			DRF.UFS[id].DebuffBar[i].buttonInfo = {}
			DRF.UFS[id].DebuffBar[i].buttonInfo.expirationTime = -1
			DRF.UFS[id].DebuffBar[i].parent = DRF.UFS[id].DebuffBar

			if DRF.UFS[id].DebuffBar[i].Icon == nil then
				DRF.UFS[id].DebuffBar[i].Icon = _G["DRFDEBUFF" .. id .. "_" .. i .. "Icon"]
			end

			if DRF.UFS[id].DebuffBar[i].Border == nil then
				DRF.UFS[id].DebuffBar[i].Border = _G["DRFDEBUFF" .. id .. "_" .. i .. "Border"]
			end

			if DRF.UFS[id].DebuffBar[i].Border then
				DRF.UFS[id].DebuffBar[i].Border:Hide()
				DRF.UFS[id].DebuffBar[i].Border:SetSize(18, 18)
			end

			DRF.UFS[id].DebuffBar[i]:EnableMouse(false)
			DRF.UFS[id].DebuffBar[i]:SetSize(18, 18)
			DRF.UFS[id].DebuffBar[i].cooldown = CreateFrame("Cooldown", "DRFDEBUFF" .. id .. "_" .. i .. "Cooldown", DRF.UFS[id].DebuffBar[i], "CooldownFrameTemplate")
			DRF.UFS[id].DebuffBar[i].cooldown:SetSize(18, 18)
			DRF.UFS[id].DebuffBar[i].cooldown:SetAllPoints(DRF.UFS[id].DebuffBar[i])
			DRF.UFS[id].DebuffBar[i].cooldown:SetHideCountdownNumbers(true)
			DRF.UFS[id].DebuffBar[i].cooldown:SetReverse(true)

			if _G["DRFDEBUFF" .. id .. "_" .. i .. "Duration"] ~= nil then
				local duration = _G["DRFDEBUFF" .. id .. "_" .. i .. "Duration"]

				hooksecurefunc(duration, "Show", function(self)
					self:Hide()
				end)

				duration:Hide()
			end

			if DRF.UFS[id].DebuffBar[i].Duration ~= nil then
				local duration = DRF.UFS[id].DebuffBar[i].Duration

				hooksecurefunc(duration, "Show", function(self)
					self:Hide()
				end)

				duration:Hide()
			end
		end

		-- Aggro
		DRF.UFS[id].Aggro = DRF.UFS[id]:CreateTexture(nil, "OVERLAY")
		DRF.UFS[id].Aggro:SetDrawLayer("OVERLAY", DRFLayers["Aggro"])
		DRF.UFS[id].Aggro:SetTexture("Interface\\RaidFrame\\Raid-FrameHighlights")
		DRF.UFS[id].Aggro:SetTexCoord(unpack(texCoords["Raid-AggroFrame"]))
		DRF.UFS[id].Aggro:SetVertexColor(1, 0.2, 0.2)

		-- Role Icon
		if UnitGroupRolesAssigned then
			DRF.UFS[id].HealthBackground.RoleIcon = DRF.UFS[id]:CreateTexture(nil, "OVERLAY")
			DRF.UFS[id].HealthBackground.RoleIcon:SetDrawLayer("OVERLAY", DRFLayers["RoleIcon"])
			DRF.UFS[id].HealthBackground.RoleIcon:SetSize(18, 18)
			DRF.UFS[id].HealthBackground.RoleIcon:SetPoint("TOPRIGHT", DRF.UFS[id].HealthBackground, "TOPRIGHT", 0, 0)
			DRF.UFS[id].HealthBackground.RoleIcon:SetTexture("Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES")
		end

		-- M+
		if DRaidFrames:GetWoWBuild() == "RETAIL" then
			DRF.UFS[id].HealthBackground.MythicIcon = DRF.UFS[id]:CreateTexture(nil, "OVERLAY")
			DRF.UFS[id].HealthBackground.MythicIcon:SetDrawLayer("OVERLAY", DRFLayers["RoleIcon"])
			DRF.UFS[id].HealthBackground.MythicIcon:SetSize(24, 24)
			DRF.UFS[id].HealthBackground.MythicIcon:SetPoint("TOPLEFT", DRF.UFS[id].HealthBackground, "TOPLEFT", 0, 0)
			DRF.UFS[id].HealthBackground.MythicIcon:SetTexture(nil)
		end

		-- Class Icon
		DRF.UFS[id].HealthBackground.ClassIcon = DRF.UFS[id]:CreateTexture(nil, "OVERLAY")
		DRF.UFS[id].HealthBackground.ClassIcon:SetDrawLayer("OVERLAY", DRFLayers["ClassIcon"])
		DRF.UFS[id].HealthBackground.ClassIcon:SetSize(18, 18)
		DRF.UFS[id].HealthBackground.ClassIcon:SetPoint("RIGHT", DRF.UFS[id].HealthBackground, "RIGHT", 0, 0)
		DRF.UFS[id].HealthBackground.ClassIcon:SetTexture("Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES")
		-- Covenant Icon
		DRF.UFS[id].HealthBackground.CovenantIcon = DRF.UFS[id]:CreateTexture(nil, "OVERLAY")
		DRF.UFS[id].HealthBackground.CovenantIcon:SetDrawLayer("OVERLAY", DRFLayers["CovenantIcon"])
		DRF.UFS[id].HealthBackground.CovenantIcon:SetSize(18, 18)
		DRF.UFS[id].HealthBackground.CovenantIcon:SetPoint("TOPLEFT", DRF.UFS[id].HealthBackground, "TOPLEFT", 0, 0)
		DRF.UFS[id].HealthBackground.CovenantIcon:SetTexture("")
		-- Lang Icon
		DRF.UFS[id].HealthBackground.LangIcon = DRF.UFS[id]:CreateTexture(nil, "OVERLAY")
		DRF.UFS[id].HealthBackground.LangIcon:SetDrawLayer("OVERLAY", DRFLayers["LangIcon"])
		DRF.UFS[id].HealthBackground.LangIcon:SetSize(18, 9)
		DRF.UFS[id].HealthBackground.LangIcon:SetPoint("LEFT", DRF.UFS[id].HealthBackground, "LEFT", 0, 0)
		DRF.UFS[id].HealthBackground.LangIcon:SetTexture("Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES")
		-- Threat
		DRF.UFS[id].HealthBackground.Threat = DRF.UFS[id]:CreateFontString(nil, "OVERLAY")
		DRF.UFS[id].HealthBackground.Threat:SetDrawLayer("OVERLAY", DRFLayers["LangIcon"])
		DRF.UFS[id].HealthBackground.Threat:SetFont(STANDARD_TEXT_FONT, 6, "")
		DRF.UFS[id].HealthBackground.Threat:SetText("")
		DRF.UFS[id].HealthBackground.Threat:SetPoint("LEFT", DRF.UFS[id].HealthBackground, "LEFT", 4, 0)
		-- Leader / Assist Icon
		DRF.UFS[id].HealthBackground.RankIcon = DRF.UFS[id]:CreateTexture(nil, "OVERLAY")
		DRF.UFS[id].HealthBackground.RankIcon:SetDrawLayer("OVERLAY", DRFLayers["RankIcon"])
		DRF.UFS[id].HealthBackground.RankIcon:SetSize(14, 14)
		DRF.UFS[id].HealthBackground.RankIcon:SetPoint("TOP", DRF.UFS[id].HealthBackground, "TOP", 0, 7)
		DRF.UFS[id].HealthBackground.RankIcon:SetTexture(nil)
		DRF.UFS[id].HealthBackground.RankIcon2 = DRF.UFS[id]:CreateTexture(nil, "OVERLAY")
		DRF.UFS[id].HealthBackground.RankIcon2:SetDrawLayer("OVERLAY", DRFLayers["RankIcon2"])
		DRF.UFS[id].HealthBackground.RankIcon2:SetSize(14, 14)
		DRF.UFS[id].HealthBackground.RankIcon2:SetPoint("TOP", DRF.UFS[id].HealthBackground, "TOP", 0, -10 - 7)
		DRF.UFS[id].HealthBackground.RankIcon2:SetTexture(nil)
		-- READY CHECK
		DRF.UFS[id].HealthBar.ReadyCheck = DRF.UFS[id]:CreateTexture(nil, "OVERLAY")
		DRF.UFS[id].HealthBar.ReadyCheck:SetDrawLayer("OVERLAY", DRFLayers["ReadyCheck"])
		DRF.UFS[id].HealthBar.ReadyCheck:SetSize(18, 18)
		DRF.UFS[id].HealthBar.ReadyCheck:SetPoint("CENTER", DRF.UFS[id].HealthBackground, "CENTER", 0, 0)
		DRF.UFS[id].HealthBar.ReadyCheck:SetTexture(nil)
		-- BTN
		DRF.UFS[id].btn = CreateFrame("Button", "DRFbtn" .. id, DRF, "SecureActionButtonTemplate")
		DRF.UFS[id].btn:SetMovable(true)
		DRF.UFS[id].btn:SetUserPlaced(true)
		DRF.UFS[id].btn.id = id
		DRF.UFS[id].btn:SetAttribute("*type1", "target")
		DRF.UFS[id].btn:SetAttribute("*type2", "togglemenu")
		DRF.UFS[id].btn:RegisterForClicks("LeftButtonDown", "RightButtonUp")
		DRF.UFS[id].btn.Highlight = DRF.UFS[id].btn:CreateTexture(nil, "OVERLAY")
		DRF.UFS[id].btn.Highlight:SetDrawLayer("OVERLAY", DRFLayers["Highlight"])
		DRF.UFS[id].btn.Highlight:SetAllPoints(DRF.UFS[id].btn)
		DRF.UFS[id].btn.Highlight:SetColorTexture(1, 1, 1)
		local BTN = DRF.UFS[id].btn

		BTN:SetScript("OnEnter", function(self)
			if SHTO then
				DRaidFrames:UpdateTooltip(self)
			end
		end)

		BTN:SetScript("OnLeave", function(self)
			self.UpdateTooltip = nil
			GameTooltip:FadeOut()
		end)

		function BTN.think()
			if MouseIsOver(BTN) or BTN.unit and UnitIsUnit("TARGET", BTN.unit) then
				BTN.Highlight:SetAlpha(0.2)
			else
				BTN.Highlight:SetAlpha(0)
			end

			C_Timer.After(0.1, BTN.think)
		end

		DRF.UFS[id].btn.think()
		id = id + 1
	end
end

local function DRaidFrames_SortByRole(a, b)
	local arole = "NONE" --UnitGroupRolesAssigned(a)
	local brole = "NONE" --UnitGroupRolesAssigned(b)

	if UnitGroupRolesAssigned ~= nil then
		arole = UnitGroupRolesAssigned(a)
		brole = UnitGroupRolesAssigned(b)
	end

	local av = 1 -- 1 = NONE
	local bv = 1 -- 1 = NONE

	if arole == "TANK" then
		av = 4
	elseif arole == "HEALER" then
		av = 3
	elseif arole == "DAMAGER" then
		av = 2
	elseif not UnitExists(a) then
		av = 0
	end

	if brole == "TANK" then
		bv = 4
	elseif brole == "HEALER" then
		bv = 3
	elseif brole == "DAMAGER" then
		bv = 2
	elseif not UnitExists(b) then
		bv = 0
	end

	if av == bv then
		a = string.gsub(a, "PLAYER", "0")
		b = string.gsub(b, "PLAYER", "0")
		a = string.gsub(a, "PARTY", "")
		b = string.gsub(b, "PARTY", "")
		a = string.gsub(a, "RAID", "")
		b = string.gsub(b, "RAID", "")
		a = tonumber(a)
		b = tonumber(b)

		return a < b
	else
		return av > bv
	end
end

local function DRaidFrames_SortByGroup(unitA, unitB)
	if unitA == nil then
		unitA = 0
	end

	if unitB == nil then
		unitB = 0
	end

	local unitAID = string.gsub(unitA, "RAID", "")
	local unitBID = string.gsub(unitB, "RAID", "")

	if unitAID and unitBID then
		unitAID = tonumber(unitAID)
		unitBID = tonumber(unitBID)
		local _, _, a = GetRaidRosterInfo(unitAID)
		local _, _, b = GetRaidRosterInfo(unitBID)

		if not UnitExists(unitA) then
			a = unitAID
		end

		if not UnitExists(unitB) then
			b = unitBID
		end

		return a < b
	else
		return DRaidFrames_SortByRole(unitA, unitB)
	end
end

local DRFSortedUnits = {}

function DRaidFrames:SortUnits()
	DRFSortedUnits = {}

	if IsInRaid() then
		for i, v in pairs(DRFUNITSRAID) do
			tinsert(DRFSortedUnits, v)
		end
	elseif IsInGroup() then
		tinsert(DRFSortedUnits, "PLAYER")

		for i, v in pairs(DRFUNITSGROUP) do
			tinsert(DRFSortedUnits, v)
		end
	else
		tinsert(DRFSortedUnits, "PLAYER")
	end

	if IsInRaid() then
		if DRaidFrames:GetConfig("RSORT", "Role") == "Group" then
			table.sort(DRFSortedUnits, DRaidFrames_SortByGroup)
		elseif DRaidFrames:GetConfig("RSORT", "Role") == "Role" then
			table.sort(DRFSortedUnits, DRaidFrames_SortByRole)
		end
	else
		table.sort(DRFSortedUnits, DRaidFrames_SortByRole)
	end
end

local OUBR = 0
local COSP = 0
local ROSP = 0
local HEWI = 0
local HEHE = 0
local POSI = 0
local PLWI = 0
local PLHE = 0
local SHPO = true
local GroupHorizontal = false
local BarUp = false
local OVER = true
local BUSI = 16
local DESI = 16
local TETOTY = "Name"
local TECETY = "Health in Percent"
local DRFSizing = true
local DRFSizingForce = false
local DRFUpdating = true

function DRaidFrames:SetSizing(val)
	DRFSizing = val
end

function DRaidFrames:IsSizing()
	return DRFSizing
end

function DRaidFrames:SetSizingForce(val)
	DRFSizingForce = val
end

function DRaidFrames:IsSizingForce()
	return DRFSizingForce
end

function DRaidFrames:SetUpdating(val)
	DRFUpdating = val
end

function DRaidFrames:IsUpdating()
	return DRFUpdating
end

function DRaidFrames:CanUpdate()
	return DRaidFrames:IsSizingForce() or (DRaidFrames:IsSizing() and not InCombatLockdown())
end

function DRaidFrames:UpdateSize()
	if DRaidFrames:CanUpdate() then
		DRaidFrames:SetSizing(false)
		DRaidFrames:SetSizingForce(false)
		DRaidFrames:SortUnits()
		SHTO = DRaidFrames:GetConfig("SHTO", true)
		OUBR = DRaidFrames:GetConfig("GOUBR", 6)
		COSP = DRaidFrames:GetConfig("GCOSP", 4)
		ROSP = DRaidFrames:GetConfig("GROSP", 4)
		HEWI = DRaidFrames:GetConfig("GHEWI", 120)
		HEHE = DRaidFrames:GetConfig("GHEHE", 60)
		POSI = DRaidFrames:GetConfig("GPOSI", 20)
		SHPO = DRaidFrames:GetConfig("GSHPO", true)
		GroupHorizontal = DRaidFrames:GetConfig("GGRHO", true)
		BarUp = DRaidFrames:GetConfig("GBAUP", true)
		BUSI = DRaidFrames:GetConfig("GBUSI", 16)
		DESI = DRaidFrames:GetConfig("GDESI", 16)
		TETOTY = DRaidFrames:GetConfig("GTETOTY", "Name")
		TECETY = DRaidFrames:GetConfig("GTECETY", "Health in Percent")
		OVER = DRaidFrames:GetConfig("GOVER", true)
		COVE = DRaidFrames:GetConfig("GCOVE", true)
		FLAG = DRaidFrames:GetConfig("GFLAG", true)
		CLAS = DRaidFrames:GetConfig("GCLAS", true)
		ELEM = DRaidFrames:GetConfig("GELEM", 5)
		THREAT = DRaidFrames:GetConfig("GTHRE", true)
		OORA = DRaidFrames:GetConfig("GOORA", 0.4)

		if IsInRaid() then
			OUBR = DRaidFrames:GetConfig("ROUBR", 6)
			COSP = DRaidFrames:GetConfig("RCOSP", 20)
			ROSP = DRaidFrames:GetConfig("RROSP", 4)
			HEWI = DRaidFrames:GetConfig("RHEWI", 80)
			HEHE = DRaidFrames:GetConfig("RHEHE", 60)
			POSI = DRaidFrames:GetConfig("RPOSI", 10)
			SHPO = DRaidFrames:GetConfig("RSHPO", true)
			GroupHorizontal = DRaidFrames:GetConfig("RGRHO", true)
			BarUp = DRaidFrames:GetConfig("RBAUP", true)
			BUSI = DRaidFrames:GetConfig("RBUSI", 16)
			DESI = DRaidFrames:GetConfig("RDESI", 16)
			TETOTY = DRaidFrames:GetConfig("RTETOTY", "Name")
			TECETY = DRaidFrames:GetConfig("RTECETY", "Health in Percent")
			OVER = DRaidFrames:GetConfig("ROVER", false)
			COVE = DRaidFrames:GetConfig("RCOVE", true)
			FLAG = DRaidFrames:GetConfig("RFLAG", true)
			CLAS = DRaidFrames:GetConfig("RCLAS", true)
			ELEM = DRaidFrames:GetConfig("RELEM", 5)
			THREAT = DRaidFrames:GetConfig("RTHRE", false)
			OORA = DRaidFrames:GetConfig("ROORA", 0.4)
		end

		if not SHPO then
			POSI = 0
		end

		PLWI = HEWI + POSI
		PLHE = HEHE + POSI
		local sw = 1
		local sh = GetNumGroupMembers()

		if sh == 0 then
			sh = 1
		end

		if GetNumGroupMembers() > ELEM then
			sw = ceil(GetNumGroupMembers() / ELEM)
			sh = ELEM
		end

		if GroupHorizontal then
			if BarUp then
				DRF:SetWidth(OUBR + sh * PLWI + (sh - 1) * COSP + OUBR)
				DRF:SetHeight(OUBR + sw * HEHE + (sw - 1) * ROSP + OUBR)
			else
				DRF:SetWidth(OUBR + sh * HEWI + (sh - 1) * COSP + OUBR)
				DRF:SetHeight(OUBR + sw * PLHE + (sw - 1) * ROSP + OUBR)
			end
		else
			if BarUp then
				DRF:SetWidth(OUBR + sw * PLWI + (sw - 1) * COSP + OUBR)
				DRF:SetHeight(OUBR + sh * HEHE + (sh - 1) * ROSP + OUBR)
			else
				DRF:SetWidth(OUBR + sw * HEWI + (sw - 1) * COSP + OUBR)
				DRF:SetHeight(OUBR + sh * PLHE + (sh - 1) * ROSP + OUBR)
			end
		end

		local pid = 1
		local posx = 0
		local posy = 0

		for group = 1, 8 do
			for ply = 1, 5 do
				--posx = posx + 1
				if posx >= ELEM then
					posx = 0
					posy = posy + 1
				end

				-- Player Box
				if GroupHorizontal then
					if BarUp then
						DRF.UFS[pid]:SetPoint("TOPLEFT", DRF, "TOPLEFT", OUBR + posx * (PLWI + COSP), -(OUBR + posy * (HEHE + ROSP)))
						DRF.UFS[pid]:SetSize(PLWI, HEHE)
					else
						DRF.UFS[pid]:SetPoint("TOPLEFT", DRF, "TOPLEFT", OUBR + posx * (HEWI + COSP), -(OUBR + posy * (PLHE + ROSP)))
						DRF.UFS[pid]:SetSize(HEWI, PLHE)
					end
				else
					if BarUp then
						DRF.UFS[pid]:SetPoint("TOPLEFT", DRF, "TOPLEFT", OUBR + posy * (PLWI + COSP), -(OUBR + posx * (HEHE + ROSP)))
						DRF.UFS[pid]:SetSize(PLWI, HEHE)
					else
						DRF.UFS[pid]:SetPoint("TOPLEFT", DRF, "TOPLEFT", OUBR + posy * (HEWI + COSP), -(OUBR + posx * (PLHE + ROSP)))
						DRF.UFS[pid]:SetSize(HEWI, PLHE)
					end
				end

				-- PLAYER BUTTON
				DRF.UFS[pid].btn:ClearAllPoints()

				if GroupHorizontal then
					if BarUp then
						DRF.UFS[pid].btn:SetSize(PLWI, HEHE)
						DRF.UFS[pid].btn:SetPoint("TOPLEFT", DRF, "TOPLEFT", OUBR + posx * (PLWI + COSP), -(OUBR + posy * (HEHE + ROSP)))
					else
						DRF.UFS[pid].btn:SetSize(HEWI, PLHE)
						DRF.UFS[pid].btn:SetPoint("TOPLEFT", DRF, "TOPLEFT", OUBR + posx * (HEWI + COSP), -(OUBR + posy * (PLHE + ROSP)))
					end
				else
					if BarUp then
						DRF.UFS[pid].btn:SetSize(PLWI, HEHE)
						DRF.UFS[pid].btn:SetPoint("TOPLEFT", DRF, "TOPLEFT", OUBR + posy * (PLWI + COSP), -(OUBR + posx * (HEHE + ROSP)))
					else
						DRF.UFS[pid].btn:SetSize(HEWI, PLHE)
						DRF.UFS[pid].btn:SetPoint("TOPLEFT", DRF, "TOPLEFT", OUBR + posy * (HEWI + COSP), -(OUBR + posx * (PLHE + ROSP)))
					end
				end

				posx = posx + 1
				-- Health Bar
				DRF.UFS[pid].HealthBackground:SetSize(HEWI, HEHE)
				DRF.UFS[pid].HealthBackground:SetPoint("TOPLEFT", DRF.UFS[pid], "TOPLEFT", 0, 0)
				DRF.UFS[pid].HealthBar:SetSize(HEWI, HEHE)
				DRF.UFS[pid].HealthBar:SetPoint("TOPLEFT", DRF.UFS[pid], "TOPLEFT", 0, 0)

				if UnitGetIncomingHeals and UnitGetTotalAbsorbs then
					DRF.UFS[pid].Prediction:ClearAllPoints()
					DRF.UFS[pid].Absorb:ClearAllPoints()

					if BarUp then
						DRF.UFS[pid].Prediction:SetSize(HEWI, HEHE)
						DRF.UFS[pid].Prediction:SetPoint("BOTTOMLEFT", DRF.UFS[pid].HealthBar, "TOPLEFT", 0, 0)
						DRF.UFS[pid].Absorb:SetSize(HEWI, HEHE)
						DRF.UFS[pid].Absorb:SetPoint("BOTTOMLEFT", DRF.UFS[pid].Prediction, "TOPLEFT", 0, 0)
					else
						DRF.UFS[pid].Prediction:SetSize(HEWI, HEHE)
						DRF.UFS[pid].Prediction:SetPoint("TOPLEFT", DRF.UFS[pid].HealthBar, "TOPRIGHT", 0, 0)
						DRF.UFS[pid].Absorb:SetSize(HEWI, HEHE)
						DRF.UFS[pid].Absorb:SetPoint("TOPLEFT", DRF.UFS[pid].Prediction, "TOPRIGHT", 0, 0)
					end

					DRF.UFS[pid].Prediction:Hide()
					DRF.UFS[pid].Absorb:Hide()
					DRF.UFS[pid].AbsorbOverlay:Hide()
				end

				DRF.UFS[pid].HealthTextTop:SetPoint("TOP", DRF.UFS[pid].HealthBackground, "TOP", 0, -3)
				DRF.UFS[pid].HealthTextCen:SetPoint("CENTER", DRF.UFS[pid].HealthBackground, "CENTER", 0, 0)
				DRF.UFS[pid].HealthTextTop2:SetPoint("TOP", DRF.UFS[pid].HealthBackground, "TOP", 0, -14)

				-- Power Bar
				if SHPO then
					if BarUp then
						DRF.UFS[pid].PowerBackground:SetSize(POSI, HEHE)
						DRF.UFS[pid].PowerBackground:SetPoint("TOPLEFT", DRF.UFS[pid], "TOPLEFT", HEWI, 0)
						DRF.UFS[pid].PowerBar:SetSize(POSI, HEHE)
						DRF.UFS[pid].PowerBar:SetPoint("TOPLEFT", DRF.UFS[pid], "TOPLEFT", HEWI, 0)
					else
						DRF.UFS[pid].PowerBackground:SetSize(HEWI, POSI)
						DRF.UFS[pid].PowerBackground:SetPoint("TOPLEFT", DRF.UFS[pid], "TOPLEFT", 0, -HEHE)
						DRF.UFS[pid].PowerBar:SetSize(HEWI, POSI)
						DRF.UFS[pid].PowerBar:SetPoint("TOPLEFT", DRF.UFS[pid], "TOPLEFT", 0, -HEHE)
					end

					DRF.UFS[pid].PowerTextCen:SetPoint("CENTER", DRF.UFS[pid].PowerBackground, "CENTER", 0, 0)
				else
					DRF.UFS[pid].PowerBackground:Hide()
					DRF.UFS[pid].PowerBar:Hide()
					DRF.UFS[pid].PowerTextCen:Hide()
				end

				DRF.UFS[pid].BuffBar:SetSize(DRF_MAX_BUFFS * BUSI, BUSI)
				DRF.UFS[pid].BuffBar:SetPoint("BOTTOMRIGHT", DRF.UFS[pid].HealthBackground, "BOTTOMRIGHT", 0, 0)
				DRF.UFS[pid].DebuffBar:SetSize(DRF_MAX_BUFFS * DESI, DESI)
				DRF.UFS[pid].DebuffBar:SetPoint("BOTTOMLEFT", DRF.UFS[pid].HealthBackground, "BOTTOMLEFT", 0, 0)

				for i = 1, DRF_MAX_BUFFS do
					if DRF.UFS[pid].BuffBar[i] then
						DRF.UFS[pid].BuffBar[i]:SetPoint("TOPRIGHT", DRF.UFS[pid].BuffBar, "TOPRIGHT", -(i - 1) * BUSI, 0)
						DRF.UFS[pid].BuffBar[i]:SetSize(BUSI, BUSI)

						if DRF.UFS[pid].BuffBar[i].Icon then
							DRF.UFS[pid].BuffBar[i].Icon:SetSize(BUSI, BUSI)
						end
					end

					if DRF.UFS[pid].DebuffBar[i] then
						DRF.UFS[pid].DebuffBar[i]:SetPoint("TOPLEFT", DRF.UFS[pid].DebuffBar, "TOPLEFT", (i - 1) * DESI, 0)
						DRF.UFS[pid].DebuffBar[i]:SetSize(DESI, DESI)

						if DRF.UFS[pid].DebuffBar[i].Icon then
							DRF.UFS[pid].DebuffBar[i].Icon:SetSize(DESI, DESI)
						end

						if DRF.UFS[pid].DebuffBar[i].Border ~= nil then
							DRF.UFS[pid].DebuffBar[i].Border:SetSize(DESI, DESI)
						end
					end
				end

				-- Aggro
				DRF.UFS[pid].Aggro:ClearAllPoints()
				DRF.UFS[pid].Aggro:SetAllPoints(DRF.UFS[pid])

				if UnitGroupRolesAssigned then
					DRF.UFS[pid].HealthBackground.RoleIcon:SetSize(18, 18)
					DRF.UFS[pid].HealthBackground.RoleIcon:SetPoint("TOPRIGHT", DRF.UFS[pid].HealthBackground, "TOPRIGHT", -1, -2)
				end

				DRF.UFS[pid].HealthBackground.RankIcon:SetSize(14, 14)
				DRF.UFS[pid].HealthBackground.RankIcon:SetPoint("TOP", DRF.UFS[pid].HealthBackground, "TOP", 0, 7)
				DRF.UFS[pid].HealthBackground.RankIcon2:SetSize(16, 16)
				DRF.UFS[pid].HealthBackground.RankIcon2:SetPoint("TOPLEFT", DRF.UFS[pid].HealthBackground, "TOPLEFT", 0, 0)
				DRF.UFS[pid].HealthBar.ReadyCheck:SetSize(18, 18)
				DRF.UFS[pid].HealthBar.ReadyCheck:SetPoint("CENTER", DRF.UFS[pid].HealthBackground, "CENTER", 0, 0)
				DRF.UFS[pid].RaidIcon:SetSize(16, 16)
				DRF.UFS[pid].RaidIcon:SetPoint("BOTTOM", DRF.UFS[pid].HealthBackground, "BOTTOM", 0, 24)
				pid = pid + 1
			end
		end
	end

	C_Timer.After(0.3, function()
		DRaidFrames:UpdateSize()
	end)
end

function DRaidFrames:UpdateUnitInfo(uf, unit)
	if UnitExists(unit) then
		uf:Hide()

		if not InCombatLockdown() then
			uf.btn:SetMovable(true)
			uf.btn:SetUserPlaced(true)
			uf.btn:SetAttribute("unit", unit)
			uf.btn:SetAttribute("togglemenu", unit)
			uf.btn.unit = unit
		end

		local ID = DRFSortedUnits[uf.id]
		ID = string.gsub(ID, "RAID", "")
		ID = tonumber(ID)
		local _, subgroup, _, role

		if IsInRaid() and ID and GetRaidRosterInfo then
			_, _, subgroup, _, _, _, _, _, _, role, _ = GetRaidRosterInfo(ID)
		end

		-- Health
		if BarUp then
			uf.HealthBar:SetWidth(HEWI)

			if UnitHealth(unit) > 1 and UnitHealthMax(unit) > 1 then
				local h = UnitHealth(unit) / UnitHealthMax(unit) * HEHE
				uf.HealthBar:SetPoint("TOPLEFT", uf, "TOPLEFT", 0, -(HEHE - h))
				uf.HealthBar:SetHeight(h)
				uf.HealthBar:Show()
			else
				uf.HealthBar:Hide()
			end
		else
			uf.HealthBar:SetWidth(HEWI)
			uf.HealthBar:SetPoint("TOPLEFT", uf, "TOPLEFT", 0, 0)

			if UnitHealth(unit) > 1 and UnitHealthMax(unit) > 1 then
				uf.HealthBar:SetWidth(UnitHealth(unit) / UnitHealthMax(unit) * HEWI)
				uf.HealthBar:Show()
			else
				uf.HealthBar:Hide()
			end
		end

		if UnitGetIncomingHeals and UnitGetTotalAbsorbs then
			local PREDICTION = UnitGetIncomingHeals(unit)

			if BarUp then
				if PREDICTION and PREDICTION > 0 then
					local rec = PREDICTION / UnitHealthMax(unit) * HEHE

					if not OVER then
						if rec + uf.HealthBar:GetHeight() > uf.HealthBackground:GetHeight() + 1 then
							rec = uf.HealthBackground:GetHeight() - uf.HealthBar:GetHeight()

							if rec <= 0 then
								rec = 1
							end
						end
					else
						if rec + uf.HealthBar:GetHeight() > uf.HealthBackground:GetHeight() * 2 then
							rec = uf.HealthBackground:GetHeight() * 2 - uf.HealthBar:GetHeight()

							if rec <= 0 then
								rec = 1
							end
						end
					end

					uf.Prediction:SetHeight(rec)
					uf.Prediction:Show()
				else
					uf.Prediction:SetHeight(0.1)
					uf.Prediction:Hide()
				end
			else
				if PREDICTION and PREDICTION > 0 then
					local rec = PREDICTION / UnitHealthMax(unit) * HEWI

					if not OVER then
						if rec + uf.HealthBar:GetWidth() > uf.HealthBackground:GetWidth() + 1 then
							rec = uf.HealthBackground:GetWidth() - uf.HealthBar:GetWidth()

							if rec <= 0 then
								rec = 1
							end
						end
					else
						if rec + uf.HealthBar:GetWidth() > uf.HealthBackground:GetWidth() * 2 then
							rec = uf.HealthBackground:GetWidth() * 2 - uf.HealthBar:GetWidth()

							if rec <= 0 then
								rec = 1
							end
						end
					end

					uf.Prediction:SetWidth(rec)
					uf.Prediction:Show()
				else
					uf.Prediction:SetWidth(0.1)
					uf.Prediction:Hide()
				end
			end

			local ABSORB = UnitGetTotalAbsorbs(unit)
			uf.Absorb:Hide()
			uf.AbsorbOverlay:Hide()

			if BarUp then
				if uf.Prediction:IsShown() then
					uf.Absorb:SetSize(HEWI, 0)
					uf.Absorb:SetPoint("BOTTOMLEFT", uf.Prediction, "TOPLEFT", 0, 0)
				else
					uf.Absorb:SetSize(HEWI, 0)
					uf.Absorb:SetPoint("BOTTOMLEFT", uf.HealthBar, "TOPLEFT", 0, 0)
				end
			else
				if uf.Prediction:IsShown() then
					uf.Absorb:SetSize(0, HEHE)
					uf.Absorb:SetPoint("TOPLEFT", uf.Prediction, "TOPRIGHT", 0, 0)
				else
					uf.Absorb:SetSize(0, HEHE)
					uf.Absorb:SetPoint("TOPLEFT", uf.HealthBar, "TOPRIGHT", 0, 0)
				end
			end

			uf.Absorb:Hide()
			uf.AbsorbOverlay:Hide()

			if BarUp then
				if ABSORB and ABSORB > 0 then
					local rec = ABSORB / UnitHealthMax(unit) * HEHE

					if not OVER and rec + uf.HealthBar:GetHeight() + uf.Prediction:GetHeight() > uf.HealthBackground:GetHeight() + 1 then
						rec = uf.HealthBackground:GetHeight() - uf.HealthBar:GetHeight() - uf.Prediction:GetHeight()

						if rec <= 0 then
							rec = 1
						end
					end

					uf.Absorb:SetHeight(rec)
					uf.Absorb:Show()
					uf.AbsorbOverlay:Show()
				else
					uf.Absorb:Hide()
					uf.AbsorbOverlay:Hide()
				end
			else
				if ABSORB and ABSORB > 0 then
					local rec = ABSORB / UnitHealthMax(unit) * HEWI

					if not OVER and rec + uf.HealthBar:GetWidth() + uf.Prediction:GetWidth() > uf.HealthBackground:GetWidth() + 1 then
						rec = uf.HealthBackground:GetWidth() - uf.HealthBar:GetWidth() - uf.Prediction:GetWidth()

						if rec <= 0 then
							rec = 1
						end
					end

					uf.Absorb:SetWidth(rec)
					uf.Absorb:Show()
					uf.AbsorbOverlay:Show()
				else
					uf.Absorb:Hide()
					uf.AbsorbOverlay:Hide()
				end
			end
		end

		local text = ""
		local uClass, uClassEng = UnitClass(unit)
		local uname = DRaidFrames:UnitName(unit, false)

		if uClass == nil then
			uClass = ""
		end

		if uname == nil then
			uname = ""
		end

		if TETOTY == "Name" then
			text = uname
		elseif TETOTY == "Name + Realm" then
			text = DRaidFrames:UnitName(unit, true)
		elseif TETOTY == "Class" then
			text = uClass
		elseif TETOTY == "Class + Name" then
			text = string.sub(uClass, 0, 3) .. ". " .. uname
		elseif TETOTY == "Name + Class" then
			text = string.sub(uname, 0, 3) .. ". " .. uClass
		end

		if HEWI - 16 * 2 > 0 then
			uf.HealthTextTop:SetWidth(HEWI - 16 * 2)
		else
			uf.HealthTextTop:SetWidth(1)
		end

		uf.HealthTextTop:SetHeight(16)
		uf.HealthTextTop:SetText(text)
		local HealthTextCen = ""

		if TECETY == "Health in Percent" then
			local rec = UnitHealth(unit) / UnitHealthMax(unit) * 100
			local val = string.format("%." .. math.abs(DRaidFrames:GetConfig("DECI", 0)) .. "f", rec)

			if rec > 0 then
				HealthTextCen = val .. "%"
			else
				HealthTextCen = ""
			end
		elseif TECETY == "Lost Health in Percent" then
			local rec = 1 - UnitHealth(unit) / UnitHealthMax(unit)

			if rec then
				local val = string.format("%." .. math.abs(DRaidFrames:GetConfig("DECI", 0)) .. "f", rec * 100)

				if rec > 0 then
					HealthTextCen = "-" .. val .. "%"
				else
					HealthTextCen = ""
				end
			else
				HealthTextCen = ""
			end
		else
			HealthTextCen = ""
		end

		if not UnitIsConnected(unit) then
			HealthTextCen = PLAYER_OFFLINE
		elseif UnitIsFeignDeath and UnitIsFeignDeath(unit) then
			HealthTextCen = DRaidFrames:GT("feigndeath")
		elseif UnitIsDead(unit) then
			HealthTextCen = DEAD
		elseif UnitHealth(unit) <= 1 then
			HealthTextCen = DRaidFrames:GT("ghost")
		elseif uf.resurrect then
			HealthTextCen = ""
		end

		uf.HealthTextCen:SetText(HealthTextCen)
		local tTop2 = ""

		if IsInRaid() and ID then
			tTop2 = "(" .. subgroup .. ")"
		else
			local xppercent = ""

			if DRaidFrames:UnitXPMax(unit) > 1 then
				xppercent = " (" .. string.format("%0.1f", DRaidFrames:UnitXP(unit) / DRaidFrames:UnitXPMax(unit) * 100) .. "%)"
			end

			if UnitEffectiveLevel ~= nil and UnitEffectiveLevel(unit) ~= UnitLevel(unit) then
				tTop2 = UnitEffectiveLevel(unit) .. " (" .. UnitLevel(unit) .. ")" .. xppercent
			elseif UnitLevel(unit) < DRaidFrames:GetMaxLevel() then
				tTop2 = UnitLevel(unit) .. xppercent
			else
				tTop2 = ""
			end
		end

		if UnitILvl and UnitILvl(unit) > 0 then
			if tTop2 ~= "" then
				tTop2 = tTop2 .. " "
			end

			tTop2 = tTop2 .. "i" .. string.format("%.1f", UnitILvl(unit))
		end

		if RAPLTAB and RAPLTAB.UnitHasRating and RAPLTAB:UnitHasRating(DRaidFrames:UnitName(unit, true), "com") then
			if tTop2 ~= "" then
				tTop2 = tTop2 .. " "
			end

			tTop2 = tTop2 .. RAPLTAB:UnitRating(DRaidFrames:UnitName(unit, true), "com", 12)
		end

		if C_PlayerInfo and C_PlayerInfo.GetPlayerMythicPlusRatingSummary and C_PlayerInfo.GetPlayerMythicPlusRatingSummary(unit) then
			local score = C_PlayerInfo.GetPlayerMythicPlusRatingSummary(unit).currentSeasonScore

			if UnitLevel(unit) == DRaidFrames:GetMaxLevel() then
				if tTop2 ~= "" then
					tTop2 = tTop2 .. " "
				end

				tTop2 = tTop2 .. "R: " .. score
			end
		end

		uf.HealthTextTop2:SetHeight(16)

		if InCombatLockdown() then
			uf.HealthTextTop2:SetText("")
		else
			uf.HealthTextTop2:SetText(tTop2)
		end

		if uClass ~= nil then
			local r, g, b, _ = GetClassColor(uClassEng)
			uf.HealthBar:SetVertexColor(r, g, b)

			if UnitGetIncomingHeals and UnitGetTotalAbsorbs then
				uf.Prediction:SetVertexColor(r + 0.2, g + 0.2, b + 0.2)
				uf.Absorb:SetVertexColor(1, 1, 1)
			end
		end

		local status = UnitThreatSituation(unit)

		if status and status > 0 then
			if GetThreatStatusColor ~= nil then
				uf.Aggro:SetVertexColor(GetThreatStatusColor(status))
			else
				uf.Aggro:SetVertexColor(1, 0, 0)
			end

			uf.Aggro:SetAlpha(0.9)
			uf.Aggro:Show()
		else
			uf.Aggro:Hide()
		end

		if UnitGroupRolesAssigned then
			if UnitGroupRolesAssigned(unit) ~= "NONE" then
				uf.HealthBackground.RoleIcon:SetTexCoord(GetTexCoordsForRoleSmallCircle(UnitGroupRolesAssigned(unit)))
				uf.HealthBackground.RoleIcon:Show()
			else
				uf.HealthBackground.RoleIcon:Hide()
			end
		end

		if uf.HealthBackground.MythicIcon then
			if UnitDebuff(unit, 396369) then
				uf.HealthBackground.MythicIcon:SetTexture(135769) -- "+"
			elseif UnitDebuff(unit, 396364) then
				uf.HealthBackground.MythicIcon:SetTexture(135768) -- "-"
			else
				uf.HealthBackground.MythicIcon:SetTexture(nil)
			end
		end

		local t = CLASS_ICON_TCOORDS[select(2, UnitClass(unit))]

		if CLAS and t and UnitIsPlayer(unit) then
			uf.HealthBackground.ClassIcon:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
			uf.HealthBackground.ClassIcon:SetTexCoord(unpack(t))
			uf.HealthBackground.ClassIcon:Show()
		else
			uf.HealthBackground.ClassIcon:Hide()
		end

		if COVE and UnitCovenantID and UnitCovenantID(unit) >= 1 and UnitCovenantID(unit) <= 4 then
			local pid = UnitCovenantID(unit)
			local covenants = {}
			covenants[1] = "ky"
			covenants[2] = "ve"
			covenants[3] = "ni"
			covenants[4] = "ne"
			uf.HealthBackground.CovenantIcon:SetTexture("Interface/Addons/DRaidFrames/media/" .. covenants[pid])
		else
			uf.HealthBackground.CovenantIcon:SetTexture("")
		end

		local guid = UnitGUID(unit)
		local lang = nil

		if guid then
			local server = tonumber(strmatch(guid, "^Player%-(%d+)"))
			local realm = DRaidFrames:GetRealms()[server]

			if realm == nil and DRaidFrames:GetRealmsLinked() then
				realm = DRaidFrames:GetRealms()[tonumber(DRaidFrames:GetRealmsLinked()[server])]
			end

			if realm then
				local s, _ = string.find(realm, ",")
				realm = string.sub(realm, s + 1)
				local _, e2 = string.find(realm, ",")

				if e2 then
					lang = string.sub(realm, 0, e2 - 1)
				else
					lang = realm
				end
			end
		end

		if lang ~= nil and UnitIsPlayer(unit) and uf.HealthBackground.LangIcon.lang ~= lang then
			if DRaidFrames:GetWoWBuild() ~= "RETAIL" then
				if UnitInBattleground("player") then
					uf.HealthBackground.LangIcon.lang = lang
					uf.HealthBackground.LangIcon:SetTexture("Interface\\Addons\\DRaidFrames\\media\\" .. lang)

					if FLAG then
						uf.HealthBackground.LangIcon:Show()
					end

					uf.HealthBackground.Threat:Hide()
				else
					local _, _, threatpct, _, _, _ = UnitDetailedThreatSituation(unit, "target")

					if threatpct == nil then
						threatpct = 0
					end

					if threatpct > 0 then
						threatpct = string.format("%.0f", threatpct)
						uf.HealthBackground.Threat:SetText(threatpct .. "%")
					else
						uf.HealthBackground.Threat:SetText("")
					end

					if THREAT then
						uf.HealthBackground.Threat:Show()
					end

					uf.HealthBackground.LangIcon:Hide()
				end
			else
				uf.HealthBackground.LangIcon.lang = lang
				uf.HealthBackground.LangIcon:SetTexture("Interface\\Addons\\DRaidFrames\\media\\" .. lang)

				if FLAG then
					uf.HealthBackground.LangIcon:Show()
				end
			end
		elseif lang == nil then
			uf.HealthBackground.LangIcon:Hide()
		end

		if UnitIsGroupLeader(unit) then
			uf.HealthBackground.RankIcon:SetTexture("Interface/GroupFrame/UI-Group-LeaderIcon")
		elseif UnitIsGroupAssistant(unit) then
			uf.HealthBackground.RankIcon:SetTexture("Interface/GroupFrame/UI-Group-AssistantIcon")
		else
			uf.HealthBackground.RankIcon:SetTexture(nil)
		end

		if IsInRaid() then
			if role == "MAINTANK" then
				uf.HealthBackground.RankIcon2:SetTexture("Interface/GroupFrame/UI-Group-MainTankIcon")
			elseif role == "MAINASSIST" then
				uf.HealthBackground.RankIcon2:SetTexture("Interface/GroupFrame/UI-Group-MainAssistIcon")
			else
				uf.HealthBackground.RankIcon2:SetTexture(nil)
			end
		end

		-- READY CHECK
		local readyCheckStatus = GetReadyCheckStatus(unit)
		local resurrect = nil

		if UnitHasIncomingResurrection then
			resurrect = UnitHasIncomingResurrection(unit)
		end

		local phase = nil

		if UnitPhaseReason then
			phase = UnitPhaseReason(unit)
		end

		local tp = nil

		if C_IncomingSummon then
			tp = C_IncomingSummon.HasIncomingSummon(unit)
		end

		if resurrect then
			uf.resurrect = true
		else
			uf.resurrect = false
		end

		if DRFReadyStatus ~= "" then
			if DRFReadyStatus == "ENDED" then
				if uf.HealthBar.ReadyCheck.readyCheckStatus == "waiting" then
					uf.HealthBar.ReadyCheck:SetTexture(READY_CHECK_NOT_READY_TEXTURE)
					uf.HealthBar.ReadyCheck:Show()
				end
			elseif DRFReadyStatus == "STARTED" then
				if readyCheckStatus ~= nil then
					uf.HealthBar.ReadyCheck.readyCheckStatus = readyCheckStatus
				end

				if readyCheckStatus == "ready" then
					uf.HealthBar.ReadyCheck:SetTexture(READY_CHECK_READY_TEXTURE)
					uf.HealthBar.ReadyCheck:Show()
				elseif readyCheckStatus == "notready" then
					uf.HealthBar.ReadyCheck:SetTexture(READY_CHECK_NOT_READY_TEXTURE)
					uf.HealthBar.ReadyCheck:Show()
				elseif readyCheckStatus == "waiting" then
					uf.HealthBar.ReadyCheck:SetTexture(READY_CHECK_WAITING_TEXTURE)
					uf.HealthBar.ReadyCheck:Show()
				end
			end
		elseif resurrect then
			uf.HealthBar.ReadyCheck:SetTexture("Interface\\RaidFrame\\Raid-Icon-Rez")
			uf.HealthBar.ReadyCheck:Show()
		elseif tp then
			local tpReason = C_IncomingSummon.IncomingSummonStatus(unit)

			if tpReason == Enum.SummonStatus.Pending then
				uf.HealthBar.ReadyCheck:SetAtlas("Raid-Icon-SummonPending")
				uf.HealthBar.ReadyCheck:Show()
			elseif tpReason == Enum.SummonStatus.Accepted then
				uf.HealthBar.ReadyCheck:SetAtlas("Raid-Icon-SummonAccepted")
				uf.HealthBar.ReadyCheck:Show()
			elseif tpReason == Enum.SummonStatus.Declined then
				uf.HealthBar.ReadyCheck:SetAtlas("Raid-Icon-SummonDeclined")
				uf.HealthBar.ReadyCheck:Show()
			end
		elseif phase then
			uf.HealthBar.ReadyCheck:SetTexture("Interface\\TargetingFrame\\UI-PhasingIcon")
			uf.HealthBar.ReadyCheck:Show()
		else
			uf.HealthBar.ReadyCheck:Hide()
		end

		-- RaidIcon
		if GetRaidTargetIndex(unit) then
			uf.RaidIcon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_" .. GetRaidTargetIndex(unit))
		else
			uf.RaidIcon:SetTexture(nil)
		end

		-- POWER
		if SHPO then
			local power = UnitPower(unit, Enum.PowerType.Mana)
			local powermax = UnitPowerMax(unit, Enum.PowerType.Mana)

			if uClass == "MONK" then
				power = UnitPower(unit)
				powermax = UnitPowerMax(unit)
			elseif powermax == 0 then
				power = UnitPower(unit)
				powermax = UnitPowerMax(unit)
			end

			if BarUp then
				uf.PowerBar:SetWidth(POSI)
				uf.PowerTextCen:SetText("")

				if power and powermax and power > 0 and powermax > 0 and power <= powermax then
					local h = power / powermax * HEHE
					uf.PowerBar:SetPoint("TOPLEFT", uf.HealthBackground, "TOPLEFT", HEWI, -(HEHE - h))
					uf.PowerBar:SetHeight(h)
					uf.PowerBar:Show()
				else
					uf.PowerBar:Hide()
				end
			else
				uf.PowerBar:SetHeight(POSI)

				if power and powermax and power > 0 and powermax > 0 and power <= powermax then
					uf.PowerBar:SetWidth(power / powermax * HEWI)
					uf.PowerTextCen:SetText(string.format("%." .. math.abs(DRaidFrames:GetConfig("DECI", 0)) .. "f", power / powermax * 100) .. "%")
					uf.PowerBar:Show()
				else
					uf.PowerTextCen:SetText("0.0%")
					uf.PowerBar:Hide()
				end
			end

			uf.PowerBackground:Show()
			uf.PowerTextCen:Show()
		else
			uf.PowerBackground:Hide()
			uf.PowerBar:Hide()
			uf.PowerTextCen:Hide()
		end

		local powerToken
		local powermax = UnitPowerMax(unit, Enum.PowerType.Mana)

		if powermax and powermax > 0 and uClass ~= "MONK" then
			local info = PowerBarColor["MANA"]
			powerType = 0
			powerToken = "MANA"

			if info then
				uf.PowerBar:SetVertexColor(info.r, info.g, info.b, 1)
			end
		else
			powerType, powerToken = UnitPowerType(unit)
			local info = PowerBarColor[powerToken]

			if info then
				uf.PowerBar:SetVertexColor(info.r, info.g, info.b)
			end
		end

		-- Buff
		local idbu = 1

		for i = 1, 20 do
			local name, icon, count, _, duration, expirationTime, unitCaster, _, _, _ = UnitBuff(unit, i, "PLAYER|HELPFUL") --"RAID")
			if idbu > DRF_MAX_BUFFS then break end

			if name then
				-- "player" or unitCaster == "pet" or unitCaster == "mouseover") then
				if name and (unitCaster ~= nil) and (DRaidFrames:GetWoWBuild() ~= "RETAIL" or DRaidFrames:GetWoWBuild() == "RETAIL" and duration > 0) then
					if uf.BuffBar[idbu].Icon ~= nil then
						uf.BuffBar[idbu].Icon:SetTexture(icon)
					end

					if uf.BuffBar[idbu].count and count and count > 1 then
						local countText = count

						if count >= 100 then
							countText = BUFF_STACKS_OVERFLOW
						end

						if uf.BuffBar[idbu].count then
							uf.BuffBar[idbu].count:Show()
							uf.BuffBar[idbu].count:SetText(countText)
						end
					else
						if uf.BuffBar[idbu].count then
							uf.BuffBar[idbu].count:Hide()
						end
					end

					local enabled = expirationTime and expirationTime ~= 0

					if enabled and duration > 0 then
						local startTime = expirationTime - duration
						CooldownFrame_Set(uf.BuffBar[idbu].cooldown, startTime, duration, true)
					else
						CooldownFrame_Clear(uf.BuffBar[idbu].cooldown)
					end

					uf.BuffBar[idbu]:Show()
					idbu = idbu + 1
				end
			else
				uf.BuffBar[idbu]:Hide()
				idbu = idbu + 1
			end
		end

		for i = idbu, DRF_MAX_BUFFS do
			CooldownFrame_Clear(uf.BuffBar[i].cooldown)

			if uf.BuffBar[i].Icon ~= nil then
				uf.BuffBar[i].Icon:SetTexture(nil)
			end

			if uf.BuffBar[i].count ~= nil then
				uf.BuffBar[i].count:Hide()
			end

			if uf.BuffBar[idbu].count then
				uf.BuffBar[i].count:Hide()
			end
		end

		-- Debuff
		local idde = 1

		for i = 1, 20 do
			local name, icon, count, debuffType, duration, expirationTime, unitCaster = UnitDebuff(unit, i, "RAID")
			if idde > DRF_MAX_DEBUFFS then break end

			if name then
				local allowed = false

				if debuffType ~= nil then
					if IsInRaid() then
						allowed = DRaidFrames:GetConfig("R" .. debuffType, true, true)
					else
						allowed = DRaidFrames:GetConfig("G" .. debuffType, true, true)
					end
				else
					if IsInRaid() then
						allowed = DRaidFrames:GetConfig("R" .. "None", true, true)
					else
						allowed = DRaidFrames:GetConfig("G" .. "None", true, true)
					end
				end

				if name ~= nil and (unitCaster == "player" or debuffType ~= nil) and allowed then
					if uf.DebuffBar[idde].Icon ~= nil then
						uf.DebuffBar[idde].Icon:SetTexture(icon)
					end

					if uf.DebuffBar[idde].count and count and count > 1 then
						local countText = count

						if count >= 100 then
							countText = BUFF_STACKS_OVERFLOW
						end

						uf.DebuffBar[idde].count:Show()
						uf.DebuffBar[idde].count:SetText(countText)
					elseif uf.DebuffBar[idde].count then
						uf.DebuffBar[idde].count:Hide()
					end

					if uf.DebuffBar[idde].Border then
						local color = DebuffTypeColor["none"]

						if DebuffTypeColor[debuffType] ~= nil then
							color = DebuffTypeColor[debuffType]
						end

						uf.DebuffBar[idde].Border:SetVertexColor(color.r, color.g, color.b)
						uf.DebuffBar[idde].Border:Show()

						if uf.DebuffBar[idde].symbol then
							local fontFamily, _, fontFlags = uf.DebuffBar[idde].symbol:GetFont()
							uf.DebuffBar[idde].symbol:SetFont(fontFamily, 9, fontFlags)
							uf.DebuffBar[idde].symbol:SetWidth(DESI)
							uf.DebuffBar[idde].symbol:SetHeight(DESI / 2)

							if DebuffTypeSymbol[debuffType] ~= nil then
								uf.DebuffBar[idde].symbol:SetText(DebuffTypeSymbol[debuffType])
							end

							uf.DebuffBar[idde].symbol:SetVertexColor(color.r, color.g, color.b)
						end
					end

					uf.DebuffBar[idde]:SetID(i)
					uf.DebuffBar[idde].unit = unit
					uf.DebuffBar[idde].filter = nil
					uf.DebuffBar[idde]:SetAlpha(1.0)
					uf.DebuffBar[idde].exitTime = nil
					uf.DebuffBar[idde]:Show()
					local enabled = expirationTime and expirationTime ~= 0

					if enabled then
						local startTime = expirationTime - duration
						CooldownFrame_Set(uf.DebuffBar[idde].cooldown, startTime, duration, true)
					else
						CooldownFrame_Clear(uf.DebuffBar[idde].cooldown)
					end

					uf.DebuffBar[idde]:Show()
					idde = idde + 1
				end
			else
				uf.DebuffBar[idde]:Hide()
				idde = idde + 1
			end
		end

		for i = idde, DRF_MAX_DEBUFFS do
			if uf.DebuffBar[i] then
				if uf.DebuffBar[i].Icon ~= nil then
					uf.DebuffBar[i].Icon:SetTexture(nil)
				end

				if uf.DebuffBar[i].symbol then
					uf.DebuffBar[i].symbol:SetText("")
				end

				if uf.DebuffBar[i].Border ~= nil then
					uf.DebuffBar[i].Border:Hide()
				end

				if uf.DebuffBar[i].count ~= nil then
					uf.DebuffBar[i].count:Hide()
				end

				CooldownFrame_Clear(uf.DebuffBar[i].cooldown)
			end
		end

		-- or unit == player, because unitinrange("player") == nil
		if UnitInRange(unit) or unit == "PLAYER" then
			uf:SetAlpha(1)
		else
			uf:SetAlpha(OORA) -- 0.2
		end

		uf:Show()

		if not InCombatLockdown() then
			uf.btn:SetMovable(true)
			uf.btn:SetUserPlaced(true)
			uf.btn:Show()

			if ClickCastFrames then
				ClickCastFrames[uf.btn] = true -- "Clicked" Support
			end
		end
	else
		uf:Hide()

		if not InCombatLockdown() then
			uf.btn:SetMovable(true)
			uf.btn:SetUserPlaced(true)
			uf.btn:Hide()

			if ClickCastFrames then
				ClickCastFrames[uf.btn] = false -- "Clicked" Support
			end
		end
	end
end

function DRaidFrames:OnUpdate()
	if DRaidFrames:IsUpdating() then
		DRaidFrames:SetUpdating(false)

		if DRF.size ~= GetNumGroupMembers() then
			DRF.size = GetNumGroupMembers()
			DRaidFrames:SetSizing(true)
		end

		if IsInRaid() then
			if DRF.typ ~= "raid" then
				DRF.typ = "raid"
				DRaidFrames:SetSizing(true)
			end
		elseif IsInGroup() then
			if DRF.typ ~= "group" then
				DRF.typ = "group"
				DRaidFrames:SetSizing(true)
			end
		else
			if DRF.typ ~= "none" then
				DRF.typ = "none"
				DRaidFrames:SetSizing(true)
			end
		end

		if (DRaidFrames:IsUpdating() or not InCombatLockdown()) and not DRF:IsShown() then
			DRF:SetMovable(true)
			DRF:SetUserPlaced(true)
		end

		if DRF.typ == "none" then
			if not InCombatLockdown() then
				DRF:Hide()
			end
		else
			for i, uf in pairs(DRF.UFS) do
				local unit = DRFSortedUnits[uf.id]

				if unit and UnitExists(unit) then
					DRaidFrames:UpdateUnitInfo(uf, unit)
				else
					uf:Hide()

					if not InCombatLockdown() then
						uf.btn:Hide()
					end
				end
			end

			if not InCombatLockdown() then
				DRF:Show()
			end
		end
	end
end

function DRaidFrames:UpdateLoop()
	C_Timer.After(0.3, function()
		DRaidFrames:SetUpdating(true)
		DRaidFrames:OnUpdate()
		DRaidFrames:UpdateLoop()
	end)
end

DRaidFrames:UpdateLoop()
DRF:RegisterEvent("READY_CHECK")
DRF:RegisterEvent("READY_CHECK_CONFIRM")
DRF:RegisterEvent("READY_CHECK_FINISHED")

function DRF:OnEvent(event, ...)
	if event == "READY_CHECK" then
		--DRF.rcts = GetTime() + 13
		DRFReadyStatus = "STARTED"
	elseif event == "READY_CHECK_FINISHED" then
		C_Timer.After(1, function()
			DRFReadyStatus = "ENDED"
		end)

		C_Timer.After(11, function()
			DRFReadyStatus = ""
		end)
	end

	DRaidFrames:SetUpdating(true)
	DRaidFrames:OnUpdate()
end

DRF:SetScript("OnEvent", DRF.OnEvent)
local DRFHIDDEN = CreateFrame("FRAME")
DRFHIDDEN:Hide()

if _G["CompactRaidFrameContainer"] then
	_G["CompactRaidFrameContainer"]:SetParent(DRFHIDDEN)
end

if PartyFrame then
	PartyFrame:SetParent(DRFHIDDEN)
end

for i = 1, 4 do
	local partyframe = _G["PartyMemberFrame" .. i]

	if partyframe then
		partyframe:SetParent(DRFHIDDEN)
	end
end

function DRaidFrames:Setup(force)
	if not InCombatLockdown() or force then
		DRaidFrames:UpdatePosition()
	else
		C_Timer.After(0.1, DRaidFrames.Setup)
	end
end

local DRFLoaded = false
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("PLAYER_ENTERING_WORLD")

function f:OnEvent(event)
	if (event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD") and not DRFLoaded then
		DRFLoaded = true
		DRaidFrames:Setup()
	end
end

f:SetScript("OnEvent", f.OnEvent)