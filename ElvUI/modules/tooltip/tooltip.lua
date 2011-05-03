-- credits : Aezay (TipTac) and Caellian for some parts of code.

local E, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if not C["tooltip"].enable then return end

local ElvuiTooltip = CreateFrame("Frame", nil, UIParent)


local _G = getfenv(0)

local GameTooltip, GameTooltipStatusBar = _G["GameTooltip"], _G["GameTooltipStatusBar"]

local TooltipHolder = CreateFrame("Frame", "TooltipHolder", UIParent)
TooltipHolder:SetWidth(130)
TooltipHolder:SetHeight(22)
TooltipHolder:SetPoint("BOTTOMRIGHT", ElvuiInfoRight, "BOTTOMRIGHT")

E.CreateMover(TooltipHolder, "TooltipMover", "Tooltip")

local gsub, find, format = string.gsub, string.find, string.format

local Tooltips = {GameTooltip,ItemRefTooltip,ShoppingTooltip1,ShoppingTooltip2,ShoppingTooltip3,WorldMapTooltip}

local linkTypes = {item = true, enchant = true, spell = true, quest = true, unit = true, talent = true, achievement = true, glyph = true}

local classification = {
	worldboss = "|cffAF5050Boss|r",
	rareelite = "|cffAF5050+ Rare|r",
	elite = "|cffAF5050+|r",
	rare = "|cffAF5050Rare|r",
}
 	
local NeedBackdropBorderRefresh = false

hooksecurefunc("GameTooltip_SetDefaultAnchor", function(self, parent)
	if C["tooltip"].cursor == true then
		if IsAddOnLoaded("Elvui_RaidHeal") and parent ~= UIParent then 
			self:SetOwner(parent, "ANCHOR_NONE")	
		else
			self:SetOwner(parent, "ANCHOR_CURSOR")
		end
	else
		self:SetOwner(parent, "ANCHOR_NONE")
	end
	self.default = 1
end)

local function SetRightTooltipPos(self)
	local inInstance, instanceType = IsInInstance()
	self:ClearAllPoints()
	if InCombatLockdown() and C["tooltip"].hidecombat == true and (C["tooltip"].hidecombatraid == true and inInstance and (instanceType == "raid")) then
		self:Hide()
	elseif InCombatLockdown() and C["tooltip"].hidecombat == true and C["tooltip"].hidecombatraid == false then
		self:Hide()
	else
		if C["others"].enablebag == true and StuffingFrameBags and StuffingFrameBags:IsShown() then
			self:SetPoint("BOTTOMRIGHT", StuffingFrameBags, "TOPRIGHT", -1, E.Scale(18))	
		elseif TooltipMover and E.Movers["TooltipMover"]["moved"] == true then
			local point, _, _, _, _ = TooltipMover:GetPoint()
			if point == "TOPLEFT" then
				self:SetPoint("TOPLEFT", TooltipMover, "BOTTOMLEFT", 1, E.Scale(-4))
			elseif point == "TOPRIGHT" then
				self:SetPoint("TOPRIGHT", TooltipMover, "BOTTOMRIGHT", -1, E.Scale(-4))
			elseif point == "BOTTOMLEFT" or point == "LEFT" then
				self:SetPoint("BOTTOMLEFT", TooltipMover, "TOPLEFT", 1, E.Scale(18))
			else
				self:SetPoint("BOTTOMRIGHT", TooltipMover, "TOPRIGHT", -1, E.Scale(18))
			end
		else
			if E.CheckAddOnShown() == true then
				if C["chat"].showbackdrop == true and E.ChatRightShown == true then
					if E.RightChat == true then
						self:SetPoint("BOTTOMRIGHT", ChatRBackground2, "TOPRIGHT", -1, E.Scale(42))	
					else
						self:SetPoint("BOTTOMRIGHT", ChatRBackground2, "TOPRIGHT", -1, E.Scale(18))	
					end
				else
					self:SetPoint("BOTTOMRIGHT", ChatRBackground2, "TOPRIGHT", -1, E.Scale(18))		
				end	
			else
				self:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", E.Scale(-3), E.Scale(42))	
			end
		end
	end
end

GameTooltip:HookScript("OnUpdate",function(self, ...)
	if self:GetAnchorType() == "ANCHOR_CURSOR" then
		local x, y = GetCursorPosition();
		local effScale = self:GetEffectiveScale();
		self:ClearAllPoints();
		self:SetPoint("BOTTOMLEFT","UIParent","BOTTOMLEFT",(x / effScale + (15)),(y / effScale + (7)))		
	end
	
	if self:GetAnchorType() == "ANCHOR_CURSOR" and NeedBackdropBorderRefresh == true and C["tooltip"].cursor ~= true then
		-- h4x for world object tooltip border showing last border color 
		-- or showing background sometime ~blue :x
		NeedBackdropBorderRefresh = false
		self:SetBackdropColor(unpack(C.media.backdropfadecolor))
		self:SetBackdropBorderColor(unpack(C.media.bordercolor))
	elseif self:GetAnchorType() == "ANCHOR_NONE" then
		SetRightTooltipPos(self)
	end
end)

local function Hex(color)
	return string.format('|cff%02x%02x%02x', color.r * 255, color.g * 255, color.b * 255)
end

local function GetColor(unit)
	if(UnitIsPlayer(unit) and not UnitHasVehicleUI(unit)) then
		local _, class = UnitClass(unit)
		local color = RAID_CLASS_COLORS[class]
		if not color then return end -- sometime unit too far away return nil for color :(
		local r,g,b = color.r, color.g, color.b
		return Hex(color), r, g, b	
	else
		local color = FACTION_BAR_COLORS[UnitReaction(unit, "player")]
		if not color then return end -- sometime unit too far away return nil for color :(
		local r,g,b = color.r, color.g, color.b		
		return Hex(color), r, g, b		
	end
end

-- update HP value on status bar
GameTooltipStatusBar:SetScript("OnValueChanged", function(self, value)
	if not value then
		return
	end
	local min, max = self:GetMinMaxValues()
	
	if (value < min) or (value > max) then
		return
	end
	local _, unit = GameTooltip:GetUnit()
	
	-- fix target of target returning nil
	if (not unit) then
		local GMF = GetMouseFocus()
		unit = GMF and GMF:GetAttribute("unit")
	end

	if not self.text then
		self.text = self:CreateFontString(nil, "OVERLAY")
		self.text:Point("CENTER", GameTooltipStatusBar, 0, -4)
		self.text:SetFont(C["media"].pixel, 9, "THINOUTLINE, MONOCHROME")
		self.text:Show()
		if unit then
			min, max = UnitHealth(unit), UnitHealthMax(unit)
			local hp = E.ShortValue(min).." / "..E.ShortValue(max)
			if UnitIsGhost(unit) then
				self.text:SetText(L.unitframes_ouf_ghost)
			elseif min == 0 or UnitIsDead(unit) or UnitIsGhost(unit) then
				self.text:SetText(L.unitframes_ouf_dead)
			else
				self.text:SetText(hp)
			end
		end
	else
		if unit then
			min, max = UnitHealth(unit), UnitHealthMax(unit)
			self.text:Show()
			local hp = E.ShortValue(min).." / "..E.ShortValue(max)
			if min == 0 or min == 1 then
				self.text:SetText(L.unitframes_ouf_dead)
			else
				self.text:SetText(hp)
			end
		else
			self.text:Hide()
		end
	end
end)

local healthBar = GameTooltipStatusBar
healthBar:ClearAllPoints()
healthBar:SetHeight(E.Scale(5))
healthBar:Point("TOPLEFT", healthBar:GetParent(), "BOTTOMLEFT", 2, -5)
healthBar:Point("TOPRIGHT", healthBar:GetParent(), "BOTTOMRIGHT", -2, -5)
healthBar:SetStatusBarTexture(C.media.normTex)


local healthBarBG = CreateFrame("Frame", "StatusBarBG", healthBar)
healthBarBG:SetFrameLevel(healthBar:GetFrameLevel() - 1)
healthBarBG:SetPoint("TOPLEFT", -E.Scale(2), E.Scale(2))
healthBarBG:SetPoint("BOTTOMRIGHT", E.Scale(2), -E.Scale(2))
healthBarBG:SetTemplate("Default")
healthBarBG:SetBackdropColor(unpack(C.media.backdropfadecolor))

-- Add "Targeted By" line
local targetedList = {}
local ClassColors = {};
local token
for class, color in next, RAID_CLASS_COLORS do
	ClassColors[class] = ("|cff%.2x%.2x%.2x"):format(color.r*255,color.g*255,color.b*255);
end

local function AddTargetedBy()
	local numParty, numRaid = GetNumPartyMembers(), GetNumRaidMembers();
	if (numParty > 0 or numRaid > 0) then
		for i = 1, (numRaid > 0 and numRaid or numParty) do
			local unit = (numRaid > 0 and "raid"..i or "party"..i);
			if (UnitIsUnit(unit.."target",token)) and (not UnitIsUnit(unit,"player")) then
				local _, class = UnitClass(unit);
				targetedList[#targetedList + 1] = ClassColors[class];
				targetedList[#targetedList + 1] = UnitName(unit);
				targetedList[#targetedList + 1] = "|r, ";
			end
		end
		if (#targetedList > 0) then
			targetedList[#targetedList] = nil;
			GameTooltip:AddLine(" ",nil,nil,nil,1);
			local line = _G["GameTooltipTextLeft"..GameTooltip:NumLines()];
			if not line then return end
			line:SetFormattedText(L.tooltip_whotarget.." (|cffffffff%d|r): %s",(#targetedList + 1) / 3,table.concat(targetedList));
			wipe(targetedList);
		end
	end
end

GameTooltip:HookScript("OnTooltipSetUnit", function(self)
	local lines = self:NumLines()
	local GMF = GetMouseFocus()
	local unit = (select(2, self:GetUnit())) or (GMF and GMF:GetAttribute("unit"))
	
	-- A mage's mirror images sometimes doesn't return a unit, this would fix it
	if (not unit) and (UnitExists("mouseover")) then
		unit = "mouseover"
	end
	
	-- Sometimes when you move your mouse quicky over units in the worldframe, we can get here without a unit
	if not unit then self:Hide() return end
	
	-- for hiding tooltip on unitframes
	if (self:GetOwner() ~= UIParent and C["tooltip"].hideuf) then self:Hide() return end

	if self:GetOwner() ~= UIParent and unit then
		SetRightTooltipPos(self)
	end	
	
	-- A "mouseover" unit is better to have as we can then safely say the tip should no longer show when it becomes invalid.
	if (UnitIsUnit(unit,"mouseover")) then
		unit = "mouseover"
	end

	local race = UnitRace(unit)
	local class = UnitClass(unit)
	local level = UnitLevel(unit)
	local guildName, guildRankName, guildRankIndex = GetGuildInfo(unit)
	local name, realm = UnitName(unit)
	local crtype = UnitCreatureType(unit)
	local classif = UnitClassification(unit)
	local title = UnitPVPName(unit)

	local r, g, b = GetQuestDifficultyColor(level).r, GetQuestDifficultyColor(level).g, GetQuestDifficultyColor(level).b

	local color = GetColor(unit)	
	if not color then color = "|CFFFFFFFF" end -- just safe mode for when GetColor(unit) return nil for unit too far away

	_G["GameTooltipTextLeft1"]:SetFormattedText("%s%s%s", color, title or name, realm and realm ~= "" and " - "..realm.."|r" or "|r")
	

	if(UnitIsPlayer(unit)) then
		if UnitIsAFK(unit) then
			self:AppendText((" %s"):format(CHAT_FLAG_AFK))
		elseif UnitIsDND(unit) then 
			self:AppendText((" %s"):format(CHAT_FLAG_DND))
		end

		local offset = 2
		if guildName then
			if UnitIsInMyGuild(unit) then
				_G["GameTooltipTextLeft2"]:SetText("<"..E.ValColor..guildName.."|r> ["..E.ValColor..guildRankName.."|r]")
			else
				_G["GameTooltipTextLeft2"]:SetText("<|cff00ff10"..guildName.."|r> [|cff00ff10"..guildRankName.."|r]")
			end
			offset = offset + 1
		end

		for i= offset, lines do
			
			if _G["GameTooltipTextLeft"..i] and _G["GameTooltipTextLeft"..i]:GetText() and (_G["GameTooltipTextLeft"..i]:GetText():find("^"..LEVEL)) then
				_G["GameTooltipTextLeft"..i]:SetFormattedText("|cff%02x%02x%02x%s|r %s %s%s", r*255, g*255, b*255, level > 0 and level or "??", race, color, class.."|r")
				break
			end
		end
	else
		for i = 2, lines do			
			if _G["GameTooltipTextLeft"..i] and _G["GameTooltipTextLeft"..i]:GetText() and ((_G["GameTooltipTextLeft"..i]:GetText():find("^"..LEVEL)) or (crtype and _G["GameTooltipTextLeft"..i]:GetText():find("^"..crtype))) then
				_G["GameTooltipTextLeft"..i]:SetFormattedText("|cff%02x%02x%02x%s|r%s %s", r*255, g*255, b*255, classif ~= "worldboss" and level > 0 and level or "?? ", classification[classif] or "", crtype or "")
				break
			end
		end
	end

	local pvpLine
	for i = 1, lines do
		if _G["GameTooltipTextLeft"..i] and _G["GameTooltipTextLeft"..i]:GetText() and _G["GameTooltipTextLeft"..i]:GetText() == PVP_ENABLED then
			pvpLine = _G["GameTooltipTextLeft"..i]
			pvpLine:SetText()
			break
		end
	end

	-- ToT line
	if UnitExists(unit.."target") and unit~="player" then
		local hex, r, g, b = GetColor(unit.."target")
		if not r and not g and not b then r, g, b = 1, 1, 1 end
		GameTooltip:AddLine(UnitName(unit.."target"), r, g, b)
	end
	
	if C["tooltip"].whotargetting == true then token = unit AddTargetedBy() end
		
	
	-- Sometimes this wasn't getting reset, the fact a cleanup isn't performed at this point, now that it was moved to "OnTooltipCleared" is very bad, so this is a fix
	self.fadeOut = nil
end)

local Colorize = function(self)
	local GMF = GetMouseFocus()
	local unit = (select(2, self:GetUnit())) or (GMF and GMF:GetAttribute("unit"))
		
	local reaction = unit and UnitReaction(unit, "player")
	local player = unit and UnitIsPlayer(unit)
	local tapped = unit and UnitIsTapped(unit)
	local tappedbyme = unit and UnitIsTappedByPlayer(unit)
	local connected = unit and UnitIsConnected(unit)
	local dead = unit and UnitIsDead(unit)
	

	if (reaction) and (tapped and not tappedbyme or not connected or dead) then
		r, g, b = 0.55, 0.57, 0.61
		self:SetBackdropBorderColor(r, g, b)
		healthBarBG:SetBackdropBorderColor(r, g, b)
		healthBar:SetStatusBarColor(r, g, b)
	elseif player and not C["tooltip"].colorreaction == true then
		local class = select(2, UnitClass(unit))
		local c = E.colors.class[class]
		if c then
			r, g, b = c[1], c[2], c[3]
		end
		self:SetBackdropBorderColor(r, g, b)
		healthBarBG:SetBackdropBorderColor(r, g, b)
		healthBar:SetStatusBarColor(r, g, b)
	elseif reaction then
		local c = E.colors.reaction[reaction]
		r, g, b = c[1], c[2], c[3]
		self:SetBackdropBorderColor(r, g, b)
		healthBarBG:SetBackdropBorderColor(r, g, b)
		healthBar:SetStatusBarColor(r, g, b)
	else
		local _, link = self:GetItem()
		local quality = link and select(3, GetItemInfo(link))
		if quality and quality >= 2 then
			local r, g, b = GetItemQualityColor(quality)
			self:SetBackdropBorderColor(r, g, b)
		else
			self:SetBackdropBorderColor(unpack(C["media"].bordercolor))
			healthBarBG:SetBackdropBorderColor(unpack(C["media"].bordercolor))
			healthBar:SetStatusBarColor(unpack(C["media"].bordercolor))
		end
	end	
	-- need this
	NeedBackdropBorderRefresh = true
end

local SetStyle = function(self)
	self:SetTemplate("Transparent", true)
	Colorize(self)
end

ElvuiTooltip:RegisterEvent("PLAYER_ENTERING_WORLD")
ElvuiTooltip:SetScript("OnEvent", function(self, event, addon)
	for _, tt in pairs(Tooltips) do
		tt:HookScript("OnShow", SetStyle)
	end
	
	FriendsTooltip:SetTemplate("Transparent", true)
	BNToastFrame:SetTemplate("Transparent", true)
	DropDownList1MenuBackdrop:SetTemplate("Transparent", true)
	DropDownList2MenuBackdrop:SetTemplate("Transparent", true)
	DropDownList1Backdrop:SetTemplate("Transparent", true)
	DropDownList2Backdrop:SetTemplate("Transparent", true)
	
	BNToastFrame:HookScript("OnShow", function(self)
		self:ClearAllPoints()
		self:SetPoint("TOPLEFT", UIParent, "TOPLEFT", E.Scale(5), E.Scale(-5))
	end)
		
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	self:SetScript("OnEvent", nil)
	
	-- Hide tooltips in combat for actions, pet actions and shapeshift
	if C["tooltip"].hidebuttons == true then
		local CombatHideActionButtonsTooltip = function(self)
			if not IsShiftKeyDown() then
				self:Hide()
			end
		end
	 
		hooksecurefunc(GameTooltip, "SetAction", CombatHideActionButtonsTooltip)
		hooksecurefunc(GameTooltip, "SetPetAction", CombatHideActionButtonsTooltip)
		hooksecurefunc(GameTooltip, "SetShapeshift", CombatHideActionButtonsTooltip)
	end
	
	LoadAddOn("Blizzard_DebugTools")
	FrameStackTooltip:HookScript("OnShow", function(self)
		local noscalemult = E.mult * C["general"].uiscale
		self:SetBackdrop({
		  bgFile = C["media"].blank, 
		  edgeFile = C["media"].blank, 
		  tile = false, tileSize = 0, edgeSize = noscalemult, 
		  insets = { left = -noscalemult, right = -noscalemult, top = -noscalemult, bottom = -noscalemult}
		})
		self:SetBackdropColor(unpack(C.media.backdropfadecolor))
		self:SetBackdropBorderColor(unpack(C.media.bordercolor))
	end)
	
	EventTraceTooltip:HookScript("OnShow", function(self)
		self:SetTemplate("Transparent")
	end)
end)
