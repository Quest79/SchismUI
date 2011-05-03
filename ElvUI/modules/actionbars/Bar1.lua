local E, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if not C["actionbar"].enable == true then return end

---------------------------------------------------------------------------
-- Setup Main Action Bar.
-- Now used for stances, Bonus at the same time.
---------------------------------------------------------------------------

local bar = CreateFrame("Frame", "ElvuiMainMenuBar", ElvuiActionBarBackground, "SecureHandlerStateTemplate")
bar:ClearAllPoints()
bar:SetAllPoints(ElvuiActionBarBackground)

--[[
	Bonus bar classes id

	DRUID: Caster: 0, Cat: 1, Tree of Life: 0, Bear: 3, Moonkin: 4
	WARRIOR: Battle Stance: 1, Defensive Stance: 2, Berserker Stance: 3 
	ROGUE: Normal: 0, Stealthed: 1
	PRIEST: Normal: 0, Shadowform: 1
	
	When Possessing a Target: 5
]]--

local Page = {
	["DRUID"] = "[bonusbar:1,nostealth] 7; [bonusbar:1,stealth] 8; [bonusbar:2] 8; [bonusbar:3] 9; [bonusbar:4] 10;",
	["WARRIOR"] = "[bonusbar:1] 7; [bonusbar:2] 8; [bonusbar:3] 9;",
	["PRIEST"] = "[bonusbar:1] 7;",
	["ROGUE"] = "[bonusbar:1] 7; [form:3] 7;",
	["DEFAULT"] = "[bonusbar:5] 11; [bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6;",
}

local function GetBar()
	local condition = Page["DEFAULT"]
	local class = E.myclass
	local page = Page[class]
	if page then
		condition = condition.." "..page
	end
	condition = condition.." 1"
	return condition
end

function E.PositionMainBar()
	MainMenuBar_UpdateKeyRing()
	local button
	for i = 1, 12 do
		button = _G["ActionButton"..i]
		button:SetSize(E.buttonsize, E.buttonsize)
		button:SetParent(ElvuiMainMenuBar)
		button:ClearAllPoints()
		button:SetFrameLevel(bottombarbitches:GetFrameLevel() + 2)
		button:SetFrameStrata(bottombarbitches:GetFrameStrata())
		
		if i == 1 then
			if C["actionbar"].swaptopbottombar == true then
				button:SetPoint("TOPLEFT", ElvuiMainMenuBar, E.buttonspacing, -E.buttonspacing)
			else
				button:SetPoint("BOTTOMLEFT", ElvuiMainMenuBar, E.buttonspacing, E.buttonspacing)
			end
		else
			local previous = _G["ActionButton"..i-1]
			button:SetPoint("LEFT", previous, "RIGHT", E.buttonspacing, 0)
		end
	end
end

bar:RegisterEvent("PLAYER_ENTERING_WORLD")
bar:RegisterEvent("ADDON_LOADED")
bar:RegisterEvent("PLAYER_REGEN_ENABLED")
bar:RegisterEvent("PLAYER_REGEN_DISABLED")
bar:RegisterEvent("PLAYER_LOGIN")
bar:RegisterEvent("KNOWN_CURRENCY_TYPES_UPDATE")
bar:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
bar:RegisterEvent("BAG_UPDATE")
bar:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
bar:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_LOGIN" then
		local button
		for i = 1, NUM_ACTIONBAR_BUTTONS do
			button = _G["ActionButton"..i]
			self:SetFrameRef("ActionButton"..i, button)
		end

		local Bar1TextUpdate = CreateFrame("Frame")
		Bar1TextUpdate:RegisterEvent("PLAYER_ENTERING_WORLD")
		Bar1TextUpdate:RegisterEvent("ADDON_LOADED")
		Bar1TextUpdate:RegisterEvent("PLAYER_REGEN_ENABLED")
		Bar1TextUpdate:RegisterEvent("PLAYER_REGEN_DISABLED")
		Bar1TextUpdate:SetScript("OnEvent", UpdateBar1keys)

		self:Execute([[
			buttons = table.new()
			for i = 1, 12 do
				table.insert(buttons, self:GetFrameRef("ActionButton"..i))
			end
			firedonce = false
		]])

		self:SetAttribute("_onstate-page", [[ 
			for i, button in ipairs(buttons) do
				button:SetAttribute("actionpage", tonumber(newstate))
			end
		]])

		self:SetAttribute("_onstate-vehicleupdate", [[		
			if newstate == "s2" then
				self:GetParent():Hide()
			else
				self:GetParent():Show()
			end	
		]])
		
		RegisterStateDriver(self, "page", GetBar())
		RegisterStateDriver(self, "vehicleupdate", "[vehicleui] s2;s1")
	elseif event == "ACTIVE_TALENT_GROUP_CHANGED" then
		-- attempt to fix blocked glyph change after switching spec.
		LoadAddOn("Blizzard_GlyphUI")
--	elseif event == "ADDON_LOADED" then
	
	
	else
	
			--print("HALP!")
		for i=1, 12 do
			_G["ElvuiMainMenuBarHotkey"..i] = _G["ActionButton"..i]:CreateFontString("ElvuiMainMenuBarHotkey"..i, "OVERLAY", nil)
			_G["ElvuiMainMenuBarHotkey"..i]:ClearAllPoints()
			--_G["ElvuiMainMenuBarHotkey"..i]:Point("TOPRIGHT", 0, -2)
			_G["ElvuiMainMenuBarHotkey"..i]:SetFont(C["media"].pixel, 9, "OUTLINE, MONOCHROME")
			_G["ElvuiMainMenuBarHotkey"..i].ClearAllPoints = E.dummy
			_G["ElvuiMainMenuBarHotkey"..i].Point = E.dummy
			_G["ElvuiMainMenuBarHotkey"..i]:SetText(_G["ActionButton"..i.."HotKey"]:GetText())
			_G["ElvuiMainMenuBarHotkey"..i]:SetTextColor(_G["ActionButton"..i.."HotKey"]:SetTextColor(1,1,1,1))

			if not C["actionbar"].hotkey == true then
				_G["ElvuiMainMenuBarHotkey"..i]:SetText("")
				_G["ElvuiMainMenuBarHotkey"..i]:Hide()
				_G["ElvuiMainMenuBarHotkey"..i].Show = E.dummy
			else
				_G["ElvuiMainMenuBarHotkey"..i]:SetText(_G["ActionButton"..i.."HotKey"]:GetText())
			end
		end

		local UpdateBar1keys = function()
			for i=1, 12 do
				_G["ElvuiMainMenuBarHotkey"..i]:SetText(_G["ActionButton"..i.."HotKey"]:GetText())
				_G["ElvuiMainMenuBarHotkey"..i]:SetTextColor(_G["ActionButton"..i.."HotKey"]:SetTextColor(1,1,1,1))
			end
		end	
		MainMenuBar_OnEvent(self, event, ...)
	end
end)