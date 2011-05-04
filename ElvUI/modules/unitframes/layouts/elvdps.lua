local E, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if not C["unitframes"].enable == true then return end
if not C["unitframes"].charportrait == true then C["unitframes"].charportraithealth = false end

------------------------------------------------------------------------
--	Variables														  --
------------------------------------------------------------------------

local font1 = C["media"].uffont
local font2 = C["media"].font
local normTex = C["media"].normTex
local glowTex = C["media"].glowTex

local resscale = 1
if E.lowversion == true then resscale = 0.9 end

--Constants
local PLAYER_WIDTH = C["framesizes"].playtarwidth*resscale
local PLAYER_HEIGHT = C["framesizes"].playtarheight*resscale
local TARGET_WIDTH = C["framesizes"].playtarwidth*resscale
local TARGET_HEIGHT = C["framesizes"].playtarheight*resscale
local SMALL_WIDTH = C["framesizes"].smallwidth*resscale
local SMALL_HEIGHT = C["framesizes"].smallheight*resscale
local TANK_WIDTH = C["framesizes"].assisttankwidth*resscale
local TANK_HEIGHT = C["framesizes"].assisttankheight*resscale
local BOSS_WIDTH = C["framesizes"].arenabosswidth*resscale
local BOSS_HEIGHT = C["framesizes"].arenabossheight*resscale
local BORDER = 2
local OFFSET = 10

------------------------------------------------------------------------
--	Layout															  --
------------------------------------------------------------------------
local function Shared(self, unit)
	-- Set Colors
	self.colors = E.oUF_colors
	
	-- Register Frames for Click
	self:RegisterForClicks("AnyUp")
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)
	
	-- Setup Menu
	self.menu = E.SpawnMenu
	
	-- Frame Level
	self:SetFrameLevel(5)
	
	--Create Backdrop Frame
	local backdrop = CreateFrame("Frame", nil, self)
	backdrop:SetPoint("TOPRIGHT")
	backdrop:SetPoint("BOTTOMLEFT")
	--backdrop:SetTemplate("Transparent")
	backdrop:SetFrameStrata("BACKGROUND")
	self.backdrop = backdrop
	
	------------------------------------------------------------------------
	--	Player															  --
	------------------------------------------------------------------------
	if unit == "player" then
		local POWERBAR_WIDTH = PLAYER_WIDTH
		local POWERBAR_HEIGHT = PLAYER_HEIGHT
		local CASTBAR_HEIGHT = SMALL_HEIGHT
		local CASTBAR_WIDTH = PLAYER_WIDTH+BORDER+1+OFFSET
		local portrait_width = PLAYER_WIDTH/4.5
		
		--Threat Glow
		--self:CreateShadow("Default")
		--self.shadow:SetFrameStrata("BACKGROUND")
		--self.shadow:SetBackdropBorderColor(0, 0, 0, 1)
	
		if C["unitframes"].charportraithealth == true or C["unitframes"].charportrait ~= true then
			portrait_width = BORDER
		elseif C["unitframes"].charportrait == true then
			POWERBAR_WIDTH = POWERBAR_WIDTH - portrait_width
		end
	
		--Health Bar											--
		local health = E.ContructHealthBar(self, true, true)
		health:Point("TOPLEFT", self, "TOPLEFT", portrait_width, -BORDER)
		health:Point("BOTTOMRIGHT", self, "BOTTOMRIGHT", -BORDER-OFFSET, BORDER+OFFSET)		
		health.value:Point("RIGHT", health, "RIGHT", -5, 0)
		self.Health = health

		--Power Bar												--
		local power = E.ConstructPowerBar(self, true, true)
		power:Point("TOPLEFT", health, "TOPLEFT", OFFSET, -OFFSET)
		power:Point("BOTTOMRIGHT", health, "BOTTOMRIGHT", OFFSET, -OFFSET)
		power.value:Point("LEFT", health, "LEFT", 7, 0)
		power.colorClass = true		
		self.Power = power		
		
		local connector = CreateFrame("Frame", nil, power)
		connector:SetTemplate("NoBorder", false)
		connector:SetFrameStrata(power:GetFrameStrata())
		connector:SetFrameLevel(power:GetFrameLevel() + 2)
		connector:Point("CENTER", power, "BOTTOMLEFT", -1, 1+OFFSET-BORDER*2)
		connector:Width(1)
		connector:Height(1)
		local connector = CreateFrame("Frame", nil, power)
		connector:SetTemplate("NoBorder", false)
		connector:SetFrameStrata(power:GetFrameStrata())
		connector:SetFrameLevel(power:GetFrameLevel() + 2)
		connector:Point("CENTER", power, "TOPRIGHT", -OFFSET+BORDER+1, 1)
		connector:Width(1)
		connector:Height(1)
		
		
		
		--Portrait												--
		if C["unitframes"].charportrait == true then
			if C["unitframes"].charportraithealth == true then
				local portrait = CreateFrame("PlayerModel", nil, health)
				portrait:SetFrameLevel(health:GetFrameLevel() + 1)
				portrait:SetAllPoints(health)
				portrait.PostUpdate = function(self) self:SetAlpha(0) self:SetAlpha(0.35) end		
				self.Portrait = portrait
				
				local overlay = CreateFrame("Frame", nil, self)
				overlay:SetFrameLevel(self:GetFrameLevel() - 2)
				
				health.bg:ClearAllPoints()
				health.bg:Point('BOTTOMLEFT', health:GetStatusBarTexture(), 'BOTTOMRIGHT')
				health.bg:Point('TOPRIGHT', health)
				health.bg:SetDrawLayer("OVERLAY", 7)
				health.bg:SetParent(overlay)
			else				
				local portrait = CreateFrame("PlayerModel", "PlayerPort", self)
				portrait:SetFrameStrata("LOW")
				portrait.backdrop = CreateFrame("Frame", nil, portrait)
				portrait.backdrop:SetTemplate("Default")
				portrait.backdrop:CreateShadow("Transparent")
				portrait.backdrop:SetFrameLevel(portrait:GetFrameLevel() - 1)

				portrait.backdrop:Point("TOPLEFT", health, "TOPLEFT", -PLAYER_WIDTH/4.5, BORDER)
				portrait.backdrop:Point("BOTTOMRIGHT", health, "BOTTOMLEFT", -BORDER*3, -BORDER-OFFSET)
				
				portrait:Point('BOTTOMLEFT', portrait.backdrop, 'BOTTOMLEFT', BORDER, BORDER)		
				portrait:Point('TOPRIGHT', portrait.backdrop, 'TOPRIGHT', -BORDER, -BORDER)
				
				self.Portrait = portrait				
			end
		end

		--Auras
		if C["auras"].playerauras then
			if C["unitframes"].charportraithealth == true or not C["unitframes"].charportrait == true then
				local debuffs = CreateFrame("Frame", nil, self)
				debuffs.num = C["auras"].playtarbuffperrow+1
				debuffs:SetWidth(PLAYER_WIDTH+PLAYER_WIDTH/4.5+BORDER)
				debuffs.spacing = E.Scale(1)
				debuffs.size = ((PLAYER_WIDTH+PLAYER_WIDTH/4.5+BORDER - (debuffs.spacing*(debuffs.num - 1))) / debuffs.num)
				debuffs:SetHeight(debuffs.size)
				debuffs:Point("BOTTOMLEFT", self.Health, "TOPLEFT", -BORDER, BORDER+1)	
				debuffs.initialAnchor = 'BOTTOMRIGHT'
				debuffs["growth-y"] = "UP"
				debuffs["growth-x"] = "LEFT"
				debuffs.PostCreateIcon = E.PostCreateAura
				debuffs.PostUpdateIcon = E.PostUpdateAura
				debuffs.CustomFilter = E.AuraFilter
				self.Debuffs = debuffs
				
				if C["auras"].playershowonlydebuffs == false then
					local buffs = CreateFrame("Frame", nil, self)
					buffs.num = C["auras"].playtarbuffperrow
					buffs:SetWidth(PLAYER_WIDTH + BORDER * 2)
					buffs.spacing = E.Scale(1)
					buffs.size = (((PLAYER_WIDTH+BORDER*2 - (buffs.spacing*(buffs.num - 1))) / buffs.num))
					buffs:Point("BOTTOMLEFT", debuffs, "TOPLEFT", -1, 0)
					buffs:SetHeight(debuffs:GetHeight())
					buffs.initialAnchor = 'BOTTOMLEFT'
					buffs["growth-y"] = "UP"	
					buffs["growth-x"] = "RIGHT"
					buffs.PostCreateIcon = E.PostCreateAura
					buffs.PostUpdateIcon = E.PostUpdateAura
					self.Buffs = buffs	
				end
			else
				local debuffs = CreateFrame("Frame", nil, self)
					debuffs.num = C["auras"].playtarbuffperrow - 1
					debuffs:SetWidth(PLAYER_WIDTH + BORDER * 2)
					debuffs.spacing = E.Scale(1)
					debuffs.size = ((PLAYER_WIDTH + BORDER * 2 - (debuffs.spacing*(debuffs.num - 1))) / debuffs.num)
					debuffs:SetHeight(debuffs.size)
					debuffs:Point("BOTTOMLEFT", self.Health, "TOPLEFT", -BORDER, BORDER+1)	
					debuffs.initialAnchor = 'BOTTOMRIGHT'
					debuffs["growth-y"] = "UP"
					debuffs["growth-x"] = "LEFT"
					debuffs.PostCreateIcon = E.PostCreateAura
					debuffs.PostUpdateIcon = E.PostUpdateAura
					debuffs.CustomFilter = E.AuraFilter
					self.Debuffs = debuffs
					
				if C["auras"].playershowonlydebuffs == false then
					local buffs = CreateFrame("Frame", nil, self)
					buffs.num = C["auras"].playtarbuffperrow
					buffs:SetWidth(PLAYER_WIDTH + BORDER * 2)
					buffs.spacing = E.Scale(1)
					buffs.size = (((PLAYER_WIDTH+BORDER*2 - (buffs.spacing*(buffs.num - 1))) / buffs.num))
					buffs:Point("BOTTOMLEFT", debuffs, "TOPLEFT", 0, 0)
					buffs:SetHeight(debuffs:GetHeight())
					buffs.initialAnchor = 'BOTTOMLEFT'
					buffs["growth-y"] = "UP"	
					buffs["growth-x"] = "RIGHT"
					buffs.PostCreateIcon = E.PostCreateAura
					buffs.PostUpdateIcon = E.PostUpdateAura
					self.Buffs = buffs	
				end
			end
		end	

		--Cast Bar
		if C["castbar"].unitcastbar == true then
			local castbar = E.ConstructCastBar(self, PLAYER_WIDTH+PLAYER_WIDTH/4.5+OFFSET+1, CASTBAR_HEIGHT, "LEFT")
			castbar:Point("TOPRIGHT", power, "BOTTOMRIGHT", 0, -BORDER*4)
			self.Castbar = castbar
		end

		-- Debuff Highlight
		if C["unitframes"].debuffhighlight == true then
			local dbh = self:CreateTexture(nil, "OVERLAY")
			dbh:SetAllPoints()
			dbh:SetTexture(C["media"].blank)
			dbh:SetBlendMode("ADD")
			dbh:SetVertexColor(0,0,0,0)
			self.DebuffHighlight = dbh
			self.DebuffHighlightFilter = true
			self.DebuffHighlightAlpha = 0.35
		end

		--Combat Feedback
		if C["unitframes"].combatfeedback == true then
			self:FontString("CombatFeedbackText", font1, C["unitframes"].fontsize+1, "OUTLINE")
			self.CombatFeedbackText:SetPoint("CENTER", self.Portrait, "CENTER", 0, -5)
			
			self.CombatFeedbackText.colors = {
				DAMAGE = {0.69, 0.31, 0.31},
				CRUSHING = {0.69, 0.31, 0.31},
				CRITICAL = {0.69, 0.31, 0.31},
				GLANCING = {0.69, 0.31, 0.31},
				STANDARD = {0.84, 0.75, 0.65},
				IMMUNE = {0.84, 0.75, 0.65},
				ABSORB = {0.84, 0.75, 0.65},
				BLOCK = {0.84, 0.75, 0.65},
				RESIST = {0.84, 0.75, 0.65},
				MISS = {0.84, 0.75, 0.65},
				HEAL = {0.33, 0.59, 0.33},
				CRITHEAL = {0.33, 0.59, 0.33},
				ENERGIZE = {0.31, 0.45, 0.63},
				CRITENERGIZE = {0.31, 0.45, 0.63},
			}
		end
		
		--Low Mana
		self:FontString("ManaLevel", font1, C["unitframes"].fontsize, "THINOUTLINE")
		self.ManaLevel:Point("CENTER", health, "CENTER", 0, -5)
		self:HookScript("OnUpdate", E.UpdateManaLevel)
		
		--PvP Text
		self:FontString("PvP", font1, C["unitframes"].fontsize, "THINOUTLINE")
		self.PvP:Point("CENTER", health, "CENTER", 0, -5)
		self.PvP:SetTextColor(0.69, 0.31, 0.31)
		self.PvP:Hide()
		self.PvP.Override = E.dummy		
		
		self:HookScript("OnUpdate", E.PvPUpdate)
		self:HookScript("OnEnter", function(self) self.ManaLevel:Hide() self.PvP:Show() end)
		self:HookScript("OnLeave", function(self) self.ManaLevel:Show() self.PvP:Hide() end)
		
		--Combat Icon
		local combat = self:CreateTexture(nil, "OVERLAY")
		combat:Size(16, 16)
		combat:Point("CENTER", health, "CENTER", 0,7)
		combat:SetVertexColor(0.69, 0.31, 0.31)
		self.Combat = combat		
		
		--Leader Icon
		local leader = self:CreateTexture(nil, "OVERLAY")
		leader:Size(16)
		leader:Point("BOTTOMRIGHT", health, "TOPRIGHT", 0, -4)
		self.Leader = leader
		
		--Master Looter Icon
		local ml = self:CreateTexture(nil, "OVERLAY")
		ml:Size(16)
		self.MasterLooter = ml
		self:RegisterEvent("PARTY_LEADER_CHANGED", E.MLAnchorUpdate)
		self:RegisterEvent("PARTY_MEMBERS_CHANGED", E.MLAnchorUpdate)	
			
		--Aggro Glow
		table.insert(self.__elements, E.UpdateThreat)
		self:RegisterEvent('PLAYER_TARGET_CHANGED', E.UpdateThreat)
		self:RegisterEvent('UNIT_THREAT_LIST_UPDATE', E.UpdateThreat)
		self:RegisterEvent('UNIT_THREAT_SITUATION_UPDATE', E.UpdateThreat)
		
		--Auto Hide
		if C["unitframes"].combat == true then
			self:RegisterEvent("PLAYER_ENTERING_WORLD", E.Fader)
			self:RegisterEvent("PLAYER_REGEN_ENABLED", E.Fader)
			self:RegisterEvent("PLAYER_REGEN_DISABLED", E.Fader)
			self:RegisterEvent("PLAYER_TARGET_CHANGED", E.Fader)
			self:RegisterEvent("PLAYER_FOCUS_CHANGED", E.Fader)
			self:RegisterEvent("UNIT_HEALTH", E.Fader)
			self:RegisterEvent("UNIT_SPELLCAST_START", E.Fader)
			self:RegisterEvent("UNIT_SPELLCAST_STOP", E.Fader)
			self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START", E.Fader)
			self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP", E.Fader)
			self:RegisterEvent("UNIT_PORTRAIT_UPDATE", E.Fader)
			self:RegisterEvent("UNIT_MODEL_CHANGED", E.Fader)			
			self:HookScript("OnEnter", function(self) E.Fader(self, true) end)
			self:HookScript("OnLeave", function(self) E.Fader(self, false) end)
		end		
		
---[[	--Experience Bar
		if E.level ~= MAX_PLAYER_LEVEL then
			local experience = CreateFrame("StatusBar", nil, self)
			experience:SetStatusBarTexture(C["media"].normTex2)
			experience:SetStatusBarColor(.45, .68, .72, .6)
			--experience:SetAllPoints(LocationBar)
			experience:Point("TOPLEFT", LocationBar, "TOPLEFT", 2, -2)
			experience:Point("BOTTOMRIGHT", LocationBar, "BOTTOMRIGHT", -2, 2)
			experience:SetFrameStrata("LOW")
			experience:SetFrameLevel(health:GetFrameLevel() - 1)
			experience:SetParent(LocationBar)
			--experience:SetAlpha(.25)
			CombatFX(experience)

			--experience:HookScript("OnEnter", function(self) self:SetAlpha(1) end)
			--experience:HookScript("OnLeave", function(self) self:SetAlpha(0) end)

			experience.Rested = CreateFrame('StatusBar', nil, experience)
			experience.Rested:SetStatusBarTexture(C["media"].normTex2)
			experience.Rested:SetStatusBarColor(.1, .2, 1, .6)
			experience.Rested:SetFrameLevel(experience:GetFrameLevel() - 1)
			experience.Rested.SetFrameLevel = E.dummy --oUF_Experience thinks its a good idea to set frame level to 1
			experience.Rested:SetAllPoints(experience)
			
			local resting = self:CreateTexture(nil, "OVERLAY")
			resting:Size(22)
			resting:Point("CENTER", health, "TOPRIGHT", 0, 6)
			resting:SetTexture([=[Interface\CharacterFrame\UI-StateIcon]=])
			resting:SetTexCoord(0, 0.5, 0, 0.421875)
			resting:Hide()
			self.Resting = resting
--[[			
			experience.backdrop = CreateFrame("Frame", nil, experience)
			experience.backdrop:SetTemplate("Transparent")
			experience.backdrop:CreateShadow("Transparent")
			
			experience.backdrop:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
			experience.backdrop:Point("TOPRIGHT", experience, "TOPRIGHT", 2, 2)
			experience.backdrop:Point("BOTTOMLEFT", experience, "BOTTOMLEFT", -2, -2)
			experience.backdrop:SetFrameLevel(experience:GetFrameLevel() - 2)
--]]		
			self:RegisterEvent("PLAYER_UPDATE_RESTING", E.RestingIconUpdate)
			self.Experience = experience

		end
	
--]]		

		if E.level == MAX_PLAYER_LEVEL then
			local Reputation = CreateFrame("StatusBar", self:GetName().."_Reputation", self)
			Reputation:SetStatusBarTexture(C["media"].altTex)
			Reputation:SetBackdrop(backdrop)
			Reputation:SetStatusBarColor(.5, .5, .5, .6)
			Reputation:SetBackdropColor(1,0,0)
			Reputation:Point("TOPLEFT", LocationBar, "TOPLEFT", 2, -2)
			Reputation:Point("BOTTOMRIGHT", LocationBar, "BOTTOMRIGHT", -2, 2)
			Reputation:SetParent(LocationBar)

			Reputation.Tooltip = false
--[[
			Reputation:SetScript("OnEnter", function(self)
				if not InCombatLockdown() then
					Reputation:SetHeight(E.Scale(20))
					Reputation.Text:Show()
				end
			end)
			
			Reputation:SetScript("OnLeave", function(self)
				if not InCombatLockdown() then
					Reputation:SetHeight(E.Scale(5))
					Reputation.Text:Hide()
				end
			end)
--]]			
			if C["unitframes"].combat == true then
				Reputation:HookScript("OnEnter", function(self) E.Fader(self, true, true) end)
				Reputation:HookScript("OnLeave", function(self) E.Fader(self, false, true) end)
			end			

			Reputation.Text = Reputation:CreateFontString(nil, 'OVERLAY')
			Reputation.Text:SetFont(font1, C["unitframes"].fontsize, "THINOUTLINE")
			Reputation.Text:SetPoint('CENTER', Reputation)
			Reputation.Text:Hide()
			
			Reputation.PostUpdate = E.UpdateReputation
			self.Reputation = Reputation
			
			self.Reputation.Text = Reputation.Text
			self.Reputation.F = CreateFrame("Frame", nil, self.Reputation)
			--self.Reputation.F:SetTemplate("Transparent")
			--self.Reputation.F:CreateShadow("Default")
			self.Reputation.F:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
			self.Reputation.F:SetPoint("TOPLEFT", E.Scale(-2), E.Scale(2))
			self.Reputation.F:SetPoint("BOTTOMRIGHT", E.Scale(2), E.Scale(-2))
			self.Reputation.F:SetFrameLevel(self.Reputation:GetFrameLevel() - 1)
		end

		--Class Resource Bars
		if C["unitframes"].classbar == true and (E.myclass == "PALADIN" or E.myclass == "SHAMAN" or E.myclass == "DRUID" or E.myclass == "DEATHKNIGHT" or E.myclass == "WARLOCK") then
--[[			--Reposition Health Bar for ClassBars
			health:Point("TOPRIGHT", self, "TOPRIGHT", -BORDER, -(BORDER+POWERBAR_HEIGHT+1))
			health:Point("TOPLEFT", self, "TOPLEFT", portrait_width+BORDER, -(BORDER+POWERBAR_HEIGHT+1))
--]]			
			--Soul Shard / Holy Power Bar
			if E.myclass == "PALADIN" or E.myclass == "WARLOCK" then
				local bars = CreateFrame("Frame", nil, self)
				bars:SetFrameStrata("HIGH")
				bars:SetFrameLevel(1)
					--[[
				bars:Point("CENTER", UIParent, "CENTER", 0, -270)
				bars:Width(PLAYER_WIDTH/1.2)
				bars:Height(PLAYER_HEIGHT/5)
			--]]
				bars:Point("LEFT", health, "TOPLEFT", OFFSET, -1)
				bars:Width(PLAYER_WIDTH/2)
				bars:Height(PLAYER_HEIGHT/8)
				--bars:SetTemplate("Hydra", true)
				
				local connector = CreateFrame("Frame", nil, bars)
				connector:SetTemplate("NoBorder", false)
				connector:SetFrameStrata(bars:GetFrameStrata())
				connector:SetFrameLevel(bars:GetFrameLevel() + 2)
				connector:Point("CENTER", bars, "RIGHT", 3, 2)
				connector:Width(1)
				connector:Height(1)
				
				local connector = CreateFrame("Frame", nil, bars)
				connector:SetTemplate("NoBorder", false)
				connector:SetFrameStrata(bars:GetFrameStrata())
				connector:SetFrameLevel(bars:GetFrameLevel() + 2)
				connector:Point("CENTER", bars, "LEFT", -2, 2)
				connector:Width(1)
				connector:Height(1)
				
				
				for i = 1, 3 do					
					bars[i]=CreateFrame("StatusBar", nil, bars)
					bars[i]:SetHeight(bars:GetHeight())			
					bars[i]:SetStatusBarTexture(normTex)
					bars[i]:GetStatusBarTexture():SetHorizTile(false)

					bars[i].bg = bars[i]:CreateTexture(nil, 'BORDER')
					
					if E.myclass == "WARLOCK" then
						bars[i]:SetStatusBarColor(148/255, 130/255, 201/255)
						bars[i].bg:SetTexture(148/255, 130/255, 201/255)
					elseif E.myclass == "PALADIN" then
						bars[i]:SetStatusBarColor(228/255,225/255,16/255)
						bars[i].bg:SetTexture(228/255,225/255,16/255)
					end
					
					if i == 1 then
						bars[i]:SetPoint("LEFT", bars)
					else
						bars[i]:Point("LEFT", bars[i-1], "RIGHT", 1, 0)
					end
					
					bars[i].bg:SetAllPoints(bars[i])
					bars[i]:SetWidth(E.Scale(bars:GetWidth() - 2)/3)
					--bars[i]:CreateShadow("Default")
					bars[i].bg:SetTexture(normTex)					
					bars[i].bg:SetAlpha(.1)
				end
---[[				
				bars.backdrop = CreateFrame("Frame", nil, bars)
				bars.backdrop:SetTemplate("Default")
				--bars.backdrop:CreateShadow("Default")
				bars.backdrop:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
				bars.backdrop:Point("TOPLEFT", -BORDER, BORDER)
				bars.backdrop:Point("BOTTOMRIGHT", BORDER, -BORDER)
				bars.backdrop:SetFrameLevel(bars:GetFrameLevel() - 1)
--]]
--[[				
				bars:SetScript("OnShow", function()
					health:Point("TOPRIGHT", self, "TOPRIGHT", -BORDER, -(BORDER+POWERBAR_HEIGHT+1))
					health:Point("TOPLEFT", self, "TOPLEFT", portrait_width+BORDER, -(BORDER+POWERBAR_HEIGHT+1))
				end)
				bars:HookScript("OnHide", function()	
					--health:Point("TOPRIGHT", self, "TOPRIGHT", -BORDER, -BORDER)
					--health:Point("TOPLEFT", self, "TOPLEFT", portrait_width+BORDER, -BORDER)		
				end)			
--]]				
				if E.myclass == "PALADIN" then
					bars.Override = E.UpdateHoly
					self.HolyPower = bars
				else
					bars.Override = E.UpdateShards
					self.SoulShards = bars
				end	
			end
			
			--Rune Bar
			if E.myclass == "DEATHKNIGHT" then
				local runes = CreateFrame("Frame", nil, self)
				runes:Point("LEFT", health, "TOPLEFT", OFFSET, 1)
				runes:SetFrameStrata("MEDIUM")
				runes:SetFrameLevel(10)
				runes:Width(PLAYER_WIDTH/1.8)
				runes:Height(POWERBAR_HEIGHT/8)
				
				local connector = CreateFrame("Frame", nil, runes)
				connector:SetTemplate("NoBorder", false)
				connector:SetFrameStrata(runes:GetFrameStrata())
				connector:SetFrameLevel(runes:GetFrameLevel() + 2)
				connector:Point("CENTER", runes, "RIGHT", 3, 0)
				connector:Width(1)
				connector:Height(1)
				
				local connector = CreateFrame("Frame", nil, runes)
				connector:SetTemplate("NoBorder", false)
				connector:SetFrameStrata(runes:GetFrameStrata())
				connector:SetFrameLevel(runes:GetFrameLevel() + 2)
				connector:Point("CENTER", runes, "LEFT", -2, 0)
				connector:Width(1)
				connector:Height(1)

				for i = 1, 6 do
					runes[i] = CreateFrame("StatusBar", nil, runes)
					runes[i]:Height(runes:GetHeight())
					runes[i]:SetWidth(E.Scale(runes:GetWidth() - 5) / 6)

					if (i == 1) then
						runes[i]:SetPoint("LEFT", runes)
					else
						runes[i]:Point("LEFT", runes[i-1], "RIGHT", 1, 0)
					end
					runes[i]:SetStatusBarTexture(normTex)
					runes[i]:GetStatusBarTexture():SetHorizTile(false)
				end
				
				runes.backdrop = CreateFrame("Frame", nil, runes)
				runes.backdrop:SetTemplate("Default")
				--runes.backdrop:CreateShadow("Transparent")
				runes.backdrop:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
				runes.backdrop:Point("TOPLEFT", -BORDER, BORDER)
				runes.backdrop:Point("BOTTOMRIGHT", BORDER, -BORDER)
				runes.backdrop:SetFrameLevel(runes:GetFrameLevel() - 1)
--[[
				runes:HookScript("OnShow", function()
					health:Point("TOPRIGHT", self, "TOPRIGHT", -BORDER, -(BORDER+POWERBAR_HEIGHT+1))
					health:Point("TOPLEFT", self, "TOPLEFT", portrait_width+BORDER, -(BORDER+POWERBAR_HEIGHT+1))
				end)
				runes:HookScript("OnHide", function()
					health:Point("TOPRIGHT", self, "TOPRIGHT", -BORDER, -BORDER)
					health:Point("TOPLEFT", self, "TOPLEFT", portrait_width+BORDER, -BORDER)		
				end)	
--]]				
				self.Runes = runes
			end
			
			--Totem Bar
			if E.myclass == "SHAMAN" then
				local totems = CreateFrame("Frame", nil, self)
				totems:Point("LEFT", health, "TOPLEFT", OFFSET, 1)
				totems:SetFrameStrata("MEDIUM")
				totems:SetFrameLevel(10)
				totems:Width(PLAYER_WIDTH/1.8)
				totems:Height(POWERBAR_HEIGHT/8)
				totems.Destroy = true
				
				local connector = CreateFrame("Frame", nil, totems)
				connector:SetTemplate("NoBorder", false)
				connector:SetFrameStrata(totems:GetFrameStrata())
				connector:SetFrameLevel(totems:GetFrameLevel() + 2)
				connector:Point("CENTER", totems, "RIGHT", 3, 0)
				connector:Width(1)
				connector:Height(1)
				
				local connector = CreateFrame("Frame", nil, totems)
				connector:SetTemplate("NoBorder", false)
				connector:SetFrameStrata(totems:GetFrameStrata())
				connector:SetFrameLevel(totems:GetFrameLevel() + 2)
				connector:Point("CENTER", totems, "LEFT", -2, 0)
				connector:Width(1)
				connector:Height(1)

				for i = 1, 4 do
					totems[i] = CreateFrame("StatusBar", nil, totems)
					totems[i]:SetHeight(totems:GetHeight())
					totems[i]:SetFrameStrata(self:GetFrameStrata())
					totems[i]:SetFrameLevel(self:GetFrameLevel())
					totems[i]:SetWidth(E.Scale(totems:GetWidth() - 3) / 4)

					if (i == 1) then
						totems[i]:SetPoint("LEFT", totems)
					else
						totems[i]:Point("LEFT", totems[i-1], "RIGHT", 1, 0)
					end
					totems[i]:SetStatusBarTexture(normTex)
					totems[i]:GetStatusBarTexture():SetHorizTile(false)
					totems[i]:SetMinMaxValues(0, 1)

					
					totems[i].bg = totems[i]:CreateTexture(nil, "BORDER")
					totems[i].bg:SetAllPoints()
					totems[i].bg:SetTexture(normTex)
					totems[i].bg.multiplier = 0.3
				end
				totems.backdrop = CreateFrame("Frame", nil, totems)
				totems.backdrop:SetTemplate("Default")
				totems.backdrop:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
				totems.backdrop:SetPoint("TOPLEFT", -BORDER, BORDER)
				totems.backdrop:SetPoint("BOTTOMRIGHT", BORDER, -BORDER)
				totems.backdrop:SetFrameLevel(totems:GetFrameLevel() - 1)
--[[				
				totems:HookScript("OnShow", function()
					health:Point("TOPRIGHT", self, "TOPRIGHT", -BORDER, -(BORDER+POWERBAR_HEIGHT+1))
					health:Point("TOPLEFT", self, "TOPLEFT", portrait_width+BORDER, -(BORDER+POWERBAR_HEIGHT+1))
				end)
				totems:HookScript("OnHide", function()
					health:Point("TOPRIGHT", self, "TOPRIGHT", -BORDER, -BORDER)
					health:Point("TOPLEFT", self, "TOPLEFT", portrait_width+BORDER, -BORDER)		
				end)
--]]
				self.TotemBar = totems			
			end
			
			--Eclipse Bar
			if E.myclass == "DRUID" then
				local eclipseBar = CreateFrame('Frame', nil, self)
				eclipseBar:Point("LEFT", health, "TOPLEFT", OFFSET, 1)
				eclipseBar:SetFrameStrata("LOW")
				eclipseBar:Width(PLAYER_WIDTH/1.8)
				eclipseBar:Height(POWERBAR_HEIGHT/8)
				
				local connector = CreateFrame("Frame", nil, eclipseBar)
				connector:SetTemplate("NoBorder", false)
				connector:SetFrameStrata(eclipseBar:GetFrameStrata())
				connector:SetFrameLevel(eclipseBar:GetFrameLevel() + 2)
				connector:Point("CENTER", eclipseBar, "RIGHT", 3, 0)
				connector:Width(1)
				connector:Height(1)
				
				local connector = CreateFrame("Frame", nil, eclipseBar)
				connector:SetTemplate("NoBorder", false)
				connector:SetFrameStrata(eclipseBar:GetFrameStrata())
				connector:SetFrameLevel(eclipseBar:GetFrameLevel() + 2)
				connector:Point("CENTER", eclipseBar, "LEFT", -2, 0)
				connector:Width(1)
				connector:Height(1)

				local lunarBar = CreateFrame('StatusBar', nil, eclipseBar)
				lunarBar:SetPoint('LEFT', eclipseBar)
				lunarBar:SetSize(eclipseBar:GetWidth(), eclipseBar:GetHeight())
				lunarBar:SetStatusBarTexture(normTex)
				lunarBar:SetStatusBarColor(.30, .52, .90)
				eclipseBar.LunarBar = lunarBar

				local solarBar = CreateFrame('StatusBar', nil, eclipseBar)
				solarBar:SetPoint('LEFT', lunarBar:GetStatusBarTexture(), 'RIGHT')
				solarBar:SetSize(eclipseBar:GetWidth(), eclipseBar:GetHeight())
				solarBar:SetStatusBarTexture(normTex)
				solarBar:SetStatusBarColor(.80, .82,  .60)
				eclipseBar.SolarBar = solarBar

				eclipseBar:FontString("Text", font1, 10, "THINOUTLINE")
				eclipseBar.Text:SetPoint("CENTER", lunarBar:GetStatusBarTexture(), "RIGHT")
				eclipseBar.Text:SetParent(lunarBar)
				
				eclipseBar.backdrop = CreateFrame("Frame", nil, eclipseBar)
				eclipseBar.backdrop:SetTemplate("Default")
				eclipseBar.backdrop:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
				eclipseBar.backdrop:Point("TOPLEFT", eclipseBar, "TOPLEFT", -BORDER, BORDER)
				eclipseBar.backdrop:Point("BOTTOMRIGHT", lunarBar, "BOTTOMRIGHT", BORDER, -BORDER)
				eclipseBar.backdrop:SetFrameLevel(eclipseBar:GetFrameLevel() - 1)
--[[
				eclipseBar:HookScript("OnShow", function()
					health:Point("TOPRIGHT", self, "TOPRIGHT", -BORDER, -(BORDER+POWERBAR_HEIGHT+1))
					health:Point("TOPLEFT", self, "TOPLEFT", portrait_width+BORDER, -(BORDER+POWERBAR_HEIGHT+1))
				end)
				eclipseBar:HookScript("OnHide", function()
					health:Point("TOPRIGHT", self, "TOPRIGHT", -BORDER, -BORDER)
					health:Point("TOPLEFT", self, "TOPLEFT", portrait_width+BORDER, -BORDER)
				end)
--]]				
				self.EclipseBar = eclipseBar
				self.EclipseBar.PostUpdatePower = E.EclipseDirection
			end
		end
		
		--Druid Mana
		if E.myclass == "DRUID" then
			self:FontString("DruidMana", font1, C["unitframes"].fontsize, "THINOUTLINE")
			self.DruidMana:SetTextColor(1, 0.49, 0.04)	
			self:HookScript("OnUpdate", E.UpdateDruidMana)
		end
		
		--Alternative Power Bar
		local altpower = CreateFrame("StatusBar", nil, health)
		altpower:SetStatusBarTexture(normTex)
		altpower:GetStatusBarTexture():SetHorizTile(false)
		altpower:EnableMouse(true)
		altpower:SetFrameStrata("HIGH")
		altpower.PostUpdate = E.AltPowerBarPostUpdate
		altpower:Point("TOPLEFT", ElvuiInfoLeft, "TOPLEFT", BORDER, -BORDER)
		altpower:Point("BOTTOMRIGHT", ElvuiInfoLeft, "BOTTOMRIGHT", -BORDER, BORDER)
		altpower:HookScript("OnShow", E.AltPowerBarOnToggle)
		altpower:HookScript("OnHide", E.AltPowerBarOnToggle)
		
		altpower:FontString("text", font1, C["unitframes"].fontsize, "THINOUTLINE")
		altpower.text:SetPoint("CENTER")
		altpower.text:SetJustifyH("CENTER")		
		self.AltPowerBar = altpower
	end
	
	------------------------------------------------------------------------
	-- Target															  --
	------------------------------------------------------------------------
	if unit == "target" then
		local POWERBAR_WIDTH = TARGET_WIDTH
		local POWERBAR_HEIGHT = TARGET_HEIGHT
		local CASTBAR_HEIGHT = SMALL_HEIGHT
		local CASTBAR_WIDTH = TARGET_WIDTH+BORDER+1+OFFSET
		local portrait_width = TARGET_WIDTH/4.5
		
		if C["unitframes"].charportraithealth == true or C["unitframes"].charportrait ~= true then
			portrait_width = BORDER
		elseif C["unitframes"].charportrait == true then
			POWERBAR_WIDTH = POWERBAR_WIDTH - portrait_width
		end

		--Health Bar											--
		local health = E.ContructHealthBar(self, true, true)		
		health:Point("TOPRIGHT", self, "TOPRIGHT", -portrait_width, -BORDER)
		health:Point("BOTTOMLEFT", self, "BOTTOMLEFT", BORDER+OFFSET, BORDER+OFFSET)
		health.value:Point("RIGHT", health, "RIGHT", -5, 0)		
		self.Health = health

		--Power Bar												--
		local power = E.ConstructPowerBar(self, true, true)
		power:Point("TOPLEFT", health, "TOPLEFT", -OFFSET, -OFFSET)
		power:Point("BOTTOMRIGHT", health, "BOTTOMRIGHT", -OFFSET, -OFFSET)
		power.value:Point("LEFT", health, "LEFT", 7, 0)		
		self.Power = power
		
		local connector = CreateFrame("Frame", nil, power)
		connector:SetTemplate("NoBorder", false)
		connector:SetFrameStrata(power:GetFrameStrata())
		connector:SetFrameLevel(power:GetFrameLevel() + 2)
		connector:Point("CENTER", power, "BOTTOMRIGHT", BORDER, 1+OFFSET-BORDER*2)
		connector:Width(1)
		connector:Height(1)
		local connector = CreateFrame("Frame", nil, power)
		connector:SetTemplate("NoBorder", false)
		connector:SetFrameStrata(power:GetFrameStrata())
		connector:SetFrameLevel(power:GetFrameLevel() + 2)
		connector:Point("CENTER", power, "TOPLEFT", OFFSET-BORDER, 1)
		connector:Width(1)
		connector:Height(1)

		
		--Portrait												--
		if C["unitframes"].charportrait == true then
			if C["unitframes"].charportraithealth == true then
				local portrait = CreateFrame("PlayerModel", nil, health)
				portrait:SetFrameLevel(health:GetFrameLevel() + 1)
				portrait:SetAllPoints(health)
				portrait.PostUpdate = function(self) self:SetAlpha(0) self:SetAlpha(0.3) end		
				self.Portrait = portrait
				
				local overlay = CreateFrame("Frame", nil, self)
				overlay:SetFrameLevel(self:GetFrameLevel() - 2)
				
				health.bg:ClearAllPoints()
				health.bg:Point('BOTTOMLEFT', health:GetStatusBarTexture(), 'BOTTOMRIGHT')
				health.bg:Point('TOPRIGHT', health)
				health.bg:SetDrawLayer("OVERLAY", 7)
				health.bg:SetParent(overlay)
			else
				local portrait = CreateFrame("PlayerModel", "PlayerPort", self)
				portrait:SetFrameStrata("LOW")
				portrait.backdrop = CreateFrame("Frame", nil, portrait)
				portrait.backdrop:SetTemplate("Default")
				portrait.backdrop:CreateShadow("Transparent")
				portrait.backdrop:SetFrameLevel(portrait:GetFrameLevel() - 1)
				
				portrait.backdrop:Point("TOPRIGHT", health, "TOPRIGHT", PLAYER_WIDTH/4.5, BORDER)
				portrait.backdrop:Point("BOTTOMLEFT", health, "BOTTOMRIGHT", BORDER*3, -BORDER-OFFSET)
				
				portrait:Point('BOTTOMLEFT', portrait.backdrop, 'BOTTOMLEFT', BORDER, BORDER)		
				portrait:Point('TOPRIGHT', portrait.backdrop, 'TOPRIGHT', -BORDER, -BORDER)
				
				self.Portrait = portrait
			end
		end
		
		--Name
		self:FontString("Name", font1, C["unitframes"].fontsize, "THINOUTLINE")
		self.Name:SetJustifyH("LEFT")
		self.Name.frequentUpdates = 0.2
		self:Tag(self.Name, '[Elvui:getnamecolor][Elvui:namelong] [Elvui:diffcolor][level] [shortclassification]')
				
		--Auras
		if C["auras"].targetauras then
			if C["unitframes"].charportraithealth == true or not C["unitframes"].charportrait == true then
				local buffs = CreateFrame("Frame", nil, self)
				buffs.num = C["auras"].playtarbuffperrow+1
				buffs:SetWidth(TARGET_WIDTH + TARGET_WIDTH/4.5 + BORDER)
				buffs.spacing = E.Scale(1)
				buffs.size = (((TARGET_WIDTH+BORDER+TARGET_WIDTH/4.5 - (buffs.spacing*(buffs.num - 1))) / buffs.num))
				buffs:Point("BOTTOMLEFT", self.Health, "TOPLEFT", -BORDER, BORDER+1)
				buffs:SetHeight(buffs.size)
				--buffs:CreateShadow("Tanthalus")
				buffs.initialAnchor = 'BOTTOMLEFT'
				buffs["growth-y"] = "UP"	
				buffs["growth-x"] = "RIGHT"
				buffs.PostCreateIcon = E.PostCreateAura
				buffs.PostUpdateIcon = E.PostUpdateAura
				self.Buffs = buffs	
				
				local debuffs = CreateFrame("Frame", nil, self)
				debuffs.num = C["auras"].playtarbuffperrow
				debuffs:SetWidth(TARGET_WIDTH+TARGET_WIDTH/4.5+BORDER*2)
				debuffs.spacing = E.Scale(1)
				debuffs.size = ((TARGET_WIDTH+BORDER+TARGET_WIDTH/4.5 - (debuffs.spacing*(debuffs.num - 1))) / debuffs.num)
				debuffs:SetHeight(debuffs.size)
				debuffs:Point("BOTTOM", buffs, "TOP", -1, 1)	
				debuffs.initialAnchor = 'BOTTOMRIGHT'
				debuffs["growth-y"] = "UP"
				debuffs["growth-x"] = "LEFT"
				debuffs.PostCreateIcon = E.PostCreateAura
				debuffs.PostUpdateIcon = E.PostUpdateAura
				debuffs.CustomFilter = E.AuraFilter
				self.Debuffs = debuffs
			else
				local buffs = CreateFrame("Frame", nil, self)
				buffs.num = C["auras"].playtarbuffperrow
				buffs:SetWidth(TARGET_WIDTH + BORDER)
				buffs.spacing = E.Scale(1)
				buffs.size = (((TARGET_WIDTH+BORDER*2 - (buffs.spacing*(buffs.num - 1))) / buffs.num))
				buffs:Point("BOTTOMLEFT", self.Health, "TOPLEFT", -BORDER, BORDER+1)
				buffs:SetHeight(buffs.size)
				--buffs:CreateShadow("Tanthalus")
				buffs.initialAnchor = 'BOTTOMLEFT'
				buffs["growth-y"] = "UP"	
				buffs["growth-x"] = "RIGHT"
				buffs.PostCreateIcon = E.PostCreateAura
				buffs.PostUpdateIcon = E.PostUpdateAura
				self.Buffs = buffs	
			
				local debuffs = CreateFrame("Frame", nil, self)
				debuffs.num = C["auras"].playtarbuffperrow - 1
				debuffs:SetWidth(TARGET_WIDTH+BORDER*2)
				debuffs.spacing = E.Scale(1)
				debuffs.size = ((TARGET_WIDTH+BORDER*2 - (debuffs.spacing*(debuffs.num - 1))) / debuffs.num)
				debuffs:SetHeight(debuffs.size)
				debuffs:Point("BOTTOM", buffs, "TOP", 1, 1)	
				debuffs.initialAnchor = 'BOTTOMRIGHT'
				debuffs["growth-y"] = "UP"
				debuffs["growth-x"] = "LEFT"
				debuffs.PostCreateIcon = E.PostCreateAura
				debuffs.PostUpdateIcon = E.PostUpdateAura
				debuffs.CustomFilter = E.AuraFilter
				self.Debuffs = debuffs
			end
		end

		--Cast Bar
		if C["castbar"].unitcastbar == true then
			local castbar = E.ConstructCastBar(self, PLAYER_WIDTH+PLAYER_WIDTH/4.5+OFFSET+1, CASTBAR_HEIGHT, "RIGHT")
			castbar:Point("TOPLEFT", power, "BOTTOMLEFT", 0, -BORDER*4)
			self.Castbar = castbar
		end

		-- Debuff Highlight
		if C["unitframes"].debuffhighlight == true then
			local dbh = self:CreateTexture(nil, "OVERLAY")
			dbh:SetAllPoints()
			dbh:SetTexture(C["media"].blank)
			dbh:SetBlendMode("ADD")
			dbh:SetVertexColor(0,0,0,0)
			self.DebuffHighlight = dbh
			self.DebuffHighlightFilter = true
			self.DebuffHighlightAlpha = 0.35	
		end

		--Combat Feedback
		if C["unitframes"].combatfeedback == true then
			self:FontString("CombatFeedbackText", font1, C["unitframes"].fontsize, "OUTLINE")
			self.CombatFeedbackText:SetPoint("CENTER", health, "CENTER", 0, -5)
			
			self.CombatFeedbackText.colors = {
				DAMAGE = {0.69, 0.31, 0.31},
				CRUSHING = {0.69, 0.31, 0.31},
				CRITICAL = {0.69, 0.31, 0.31},
				GLANCING = {0.69, 0.31, 0.31},
				STANDARD = {0.84, 0.75, 0.65},
				IMMUNE = {0.84, 0.75, 0.65},
				ABSORB = {0.84, 0.75, 0.65},
				BLOCK = {0.84, 0.75, 0.65},
				RESIST = {0.84, 0.75, 0.65},
				MISS = {0.84, 0.75, 0.65},
				HEAL = {0.33, 0.59, 0.33},
				CRITHEAL = {0.33, 0.59, 0.33},
				ENERGIZE = {0.31, 0.45, 0.63},
				CRITENERGIZE = {0.31, 0.45, 0.63},
			}
		end
		
		
		--Combo Bar
		local combo = CreateFrame("Frame", nil, self)
		combo:Point("RIGHT", health.backdrop, "TOPRIGHT", -OFFSET, -1)
		combo:SetFrameStrata("MEDIUM")
		combo:SetFrameLevel(10)
		combo:Width(PLAYER_WIDTH/1.8)
		combo:Height(POWERBAR_HEIGHT/8)
		
		local connector = CreateFrame("Frame", nil, combo)
		connector:SetTemplate("NoBorder", false)
		connector:SetFrameStrata(combo:GetFrameStrata())
		connector:SetFrameLevel(combo:GetFrameLevel() + 2)
		connector:Point("CENTER", combo, "RIGHT", 3, 0)
		connector:Width(1)
		connector:Height(1)
		
		local connector = CreateFrame("Frame", nil, combo)
		connector:SetTemplate("NoBorder", false)
		connector:SetFrameStrata(combo:GetFrameStrata())
		connector:SetFrameLevel(combo:GetFrameLevel() + 2)
		connector:Point("CENTER", combo, "LEFT", -2, 0)
		connector:Width(1)
		connector:Height(1)

		for i = 1, 5 do					
			combo[i] = CreateFrame("StatusBar", nil, combo)
			combo[i]:SetHeight(combo:GetHeight())					
			combo[i]:SetStatusBarTexture(normTex)
			combo[i]:GetStatusBarTexture():SetHorizTile(false)
							
			if i == 1 then
				combo[i]:SetPoint("LEFT", combo)
			else
				combo[i]:Point("LEFT", combo[i-1], "RIGHT", 1, 0)
			end
			combo[i]:SetAlpha(0.15)
			combo[i]:SetWidth(E.Scale(PLAYER_WIDTH/1.8-4)/5)
		end
		
		combo[1]:SetStatusBarColor(0.69, 0.31, 0.31)		
		combo[2]:SetStatusBarColor(0.69, 0.31, 0.31)
		combo[3]:SetStatusBarColor(0.65, 0.63, 0.35)
		combo[4]:SetStatusBarColor(0.65, 0.63, 0.35)
		combo[5]:SetStatusBarColor(0.33, 0.59, 0.33)
		
		combo.backdrop = CreateFrame("Frame", nil, combo)
		combo.backdrop:SetTemplate("Default")
		combo.backdrop:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
		combo.backdrop:Point("TOPLEFT", -2, 2)
		combo.backdrop:Point("BOTTOMRIGHT", 2, -2)
		combo.backdrop:SetFrameLevel(combo:GetFrameLevel() - 1)
		
		--[[This is a little differant than everything else because we have to take into account 
		the combobar is movable with the /moveele command, this should make it work correctly only 
		after a reloadui.]]
		combo:HookScript("OnShow", function()
			if DPSComboBar then DPSComboBar:SetFrameLevel(DPSComboBar:GetFrameLevel() + 1) end
			
			--if ElementsPos["DPSComboBar"]["moved"] == true and E.CreatedMoveEleFrames["DPSComboBar"] then return end
			--combo:ClearAllPoints()
			--combo:Point("BOTTOMLEFT", health.backdrop, "TOPLEFT", BORDER, BORDER+1)
			
			--health:Point("TOPRIGHT", self, "TOPRIGHT", -(BORDER+portrait_width), -(BORDER+POWERBAR_HEIGHT+1))
		end)
		--combo:HookScript("OnHide", function()
			--health:Point("TOPRIGHT", self, "TOPRIGHT", -(BORDER+portrait_width), -BORDER)
		--end)			
		combo:Hide()
		
		combo.Override = E.ComboDisplay
		self.CPoints = combo
	end
	
	------------------------------------------------------------------------
	--	TargetofTarget, Pet, PetTarget, Focus, FocusTarget				  --
	------------------------------------------------------------------------
	if (unit == "targettarget" or unit == "pet" or unit == "pettarget" or unit == "focustarget" or unit == "focus") then
		local POWERBAR_WIDTH = SMALL_WIDTH - (BORDER*2)
		local POWERBAR_HEIGHT = 19
		local CASTBAR_WIDTH = C["castbar"].focuswidth*resscale
		
		--Health Bar
		local health = E.ContructHealthBar(self, true, nil)
		health:Point("CENTER", self, "CENTER", 0, 0)
		health:SetSize(SMALL_WIDTH, SMALL_HEIGHT)
		--health:Point("BOTTOMLEFT", self, "BOTTOMLEFT", BORDER, BORDER + SMALL_HEIGHT)
		
		self.Health = health
		
		---[[STYLE 1
		--Power Bar
		if unit ~= "pettarget" and unit ~= "pet" then
			local power = E.ConstructPowerBar(self, true, nil)
			--power:Point("TOPLEFT", health.backdrop, "BOTTOMLEFT", -5, 18)
			--power:Point("BOTTOMRIGHT", health.backdrop, "BOTTOMRIGHT", 5, -6)			
			power:Point("CENTER", health.backdrop, "CENTER", 0, -(SMALL_HEIGHT*1.3-SMALL_HEIGHT))
			power:SetSize(SMALL_WIDTH*1.15, SMALL_HEIGHT*1.15)
			
			local connector = CreateFrame("Frame", nil, power)
			connector:SetTemplate("NoBorder", false)
			connector:SetFrameStrata(power:GetFrameStrata())
			connector:SetFrameLevel(power:GetFrameLevel() + 2)
			connector:Point("CENTER", power, "TOPRIGHT", BORDER-((SMALL_WIDTH*1.15)-SMALL_WIDTH)/2, BORDER)
			connector:Width(1)
			connector:Height(1)
			local connector = CreateFrame("Frame", nil, power)
			connector:SetTemplate("NoBorder", false)
			connector:SetFrameStrata(power:GetFrameStrata())
			connector:SetFrameLevel(power:GetFrameLevel() + 2)
			connector:Point("CENTER", power, "TOPLEFT", ((SMALL_WIDTH*1.15)-SMALL_WIDTH)/2-BORDER, BORDER)
			connector:Width(1)
			connector:Height(1)
			
			power.colorTapping = false
			power.colorClass = true
			power.colorDisconnected = false

			self.Power = power
		end
		
		if unit == "pet" then
			local power = E.ConstructPowerBar(self, true, nil)
			power:Point("TOPLEFT", health.backdrop, "BOTTOMLEFT", -5, 18)
			power:Point("BOTTOMRIGHT", health.backdrop, "BOTTOMRIGHT", 5, -6)
			
			local connector = CreateFrame("Frame", nil, power)
			connector:SetTemplate("NoBorder", false)
			connector:SetFrameStrata(power:GetFrameStrata())
			connector:SetFrameLevel(power:GetFrameLevel() + 2)
			connector:Point("CENTER", power, "TOPRIGHT", 1+BORDER-((SMALL_WIDTH*1.15)-SMALL_WIDTH)/2, BORDER)
			connector:Width(1)
			connector:Height(1)
			local connector = CreateFrame("Frame", nil, power)
			connector:SetTemplate("NoBorder", false)
			connector:SetFrameStrata(power:GetFrameStrata())
			connector:SetFrameLevel(power:GetFrameLevel() + 2)
			connector:Point("CENTER", power, "TOPLEFT", ((SMALL_WIDTH*1.15)-SMALL_WIDTH)/2-BORDER, BORDER)
			connector:Width(1)
			connector:Height(1)
			
			power.colorPower = true
			power.colorClassPet = false
			power.colorClass = false
			
			self.Power = power
		end
		--]]

		--[[STYLE 2
		--Power Bar
		if unit ~= "pettarget" and unit ~= "pet" then
			local power = E.ConstructPowerBar(self, true, nil)
			power:Point("TOPLEFT", self.Health, "BOTTOMLEFT", SMALL_WIDTH/10, 2)
			power:Point("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", -(SMALL_WIDTH/10), -2)
			
			power.colorTapping = false
			power.colorClass = true
			power.colorDisconnected = false
			
			power:SetFrameStrata(health:GetFrameStrata())
			power:SetFrameLevel(health:GetFrameLevel()+2)

			self.Power = power
		end
		
		if unit == "pet" then
			local power = E.ConstructPowerBar(self, true, nil)
			power:Point("TOPLEFT", self.Health, "BOTTOMLEFT", SMALL_WIDTH/10, 2)
			power:Point("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", -(SMALL_WIDTH/10), -2)
			
			power.colorClassPet = false
			power.colorClass = false			
			power.colorPower = true

			power:SetFrameStrata(health:GetFrameStrata())
			power:SetFrameLevel(health:GetFrameLevel()+2)
			
			self.Power = power
		end
		--]]

		--Portrait												--
		if C["unitframes"].charportraithealth == true then
			local portrait = CreateFrame("PlayerModel", nil, health)
			portrait:SetFrameLevel(health:GetFrameLevel() + 1)
			portrait:SetAllPoints(health)
			portrait.PostUpdate = function(self) self:SetAlpha(0) self:SetAlpha(0.25) end		
			self.Portrait = portrait
	
			local overlay = CreateFrame("Frame", nil, self)
			overlay:SetFrameLevel(self:GetFrameLevel() - 2)
	
			health.bg:ClearAllPoints()
			health.bg:Point('BOTTOMLEFT', health:GetStatusBarTexture(), 'BOTTOMRIGHT')
			health.bg:Point('TOPRIGHT', health)
			health.bg:SetDrawLayer("OVERLAY", 7)
			health.bg:SetParent(overlay)
		end

		--Name
		self:FontString("Name", C["media"].pixel, 9, "OUTLINE, MONOCHROME")
		self.Name:SetShadowOffset(0, 0)
		self.Name:Point("CENTER", health, "CENTER", 0, 0)
		self.Name.frequentUpdates = 0.5
		self:Tag(self.Name, '[Elvui:getnamecolor][Elvui:namemedium]')		
		
		--Auras
		if (unit == "targettarget" and C["auras"].totdebuffs == true) or (unit == "focus" and C["auras"].focusdebuffs == true) then	
			local debuffs = CreateFrame("Frame", nil, self)
			debuffs.num = C["auras"].smallbuffperrow
			debuffs:SetWidth(SMALL_WIDTH*1.15)
			debuffs.spacing = E.Scale(1)
			debuffs.size = ((SMALL_WIDTH*1.15+BORDER*2 - (debuffs.spacing*(debuffs.num - 1))) / debuffs.num)
			debuffs:SetHeight(debuffs.size)
			debuffs:Point("TOP", self, "BOTTOM", -BORDER, -4)	
			debuffs.initialAnchor = 'BOTTOMLEFT'
			debuffs["growth-y"] = "UP"
			debuffs["growth-x"] = "RIGHT"
			debuffs.PostCreateIcon = E.PostCreateAura
			debuffs.PostUpdateIcon = E.PostUpdateAura
			debuffs.CustomFilter = E.AuraFilter
			self.Debuffs = debuffs
		end

		-- Debuff Highlight
		if C["unitframes"].debuffhighlight == true then
			local dbh = self:CreateTexture(nil, "OVERLAY")
			dbh:SetAllPoints()
			dbh:SetTexture(C["media"].blank)
			dbh:SetBlendMode("ADD")
			dbh:SetVertexColor(0,0,0,0)
			self.DebuffHighlight = dbh
			self.DebuffHighlightFilter = true
			self.DebuffHighlightAlpha = 0.35
		end
		
		if unit == "pet" then
			--Dummy Cast Bar, so we don't see an extra castbar while in vehicle
			if (C["castbar"].unitcastbar == true) then
				local castbar = CreateFrame("StatusBar", nil, self)
				self.Castbar = castbar
			end
			
			--Incoming Pet Heals
			if C["auras"].raidunitbuffwatch == true then
				E.createAuraWatch(self,unit)
			end
			
			--Autohide in combat
			if C["unitframes"].combat == true then
				self:HookScript("OnEnter", function(self) E.Fader(self, true) end)
				self:HookScript("OnLeave", function(self) E.Fader(self, false) end)
			end
		elseif unit == "focus" and C["castbar"].unitcastbar == true	then
			--Cast Bar
			local castbar = E.ConstructCastBar(self, CASTBAR_WIDTH, 20, "LEFT")
			castbar:Point("TOP", UIParent, "TOP", 0, -150)
			
			self.Castbar = castbar
		end
	end
	
	------------------------------------------------------------------------
	--	Arena and Boss													  --
	------------------------------------------------------------------------
	if (unit and unit:find("arena%d") and C["arena"].unitframes == true) or (unit and unit:find("boss%d") and C["raidframes"].showboss == true) then
		local TRINKET_WIDTH = BOSS_HEIGHT
		local POWERBAR_WIDTH = BOSS_HEIGHT - (BORDER*2)
		local POWERBAR_HEIGHT = 8
		local CASTBAR_HEIGHT = BOSS_HEIGHT
		local CASTBAR_WIDTH = BOSS_WIDTH
		
		
		--Health Bar											--
		local health = E.ContructHealthBar(self, true, true)
		health:Point("TOPRIGHT", self, "TOPRIGHT", -BORDER, -BORDER)
		health:Point("BOTTOMLEFT", self, "BOTTOMLEFT", BORDER, BORDER + POWERBAR_HEIGHT)
		health.value:Point("RIGHT", health, "RIGHT", -4, 0)
		self.Health = health
		
		--Power Bar												--
		local power = E.ConstructPowerBar(self, true, true)
		power:Point("TOPLEFT", self.Health, "TOPLEFT", OFFSET, -OFFSET)
		power:Point("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", OFFSET, -OFFSET)
		power.value:Point("LEFT", health, "LEFT", 4, 0)		
		self.Power = power
		
		--Portrait												--
		if C["unitframes"].charportrait == true then
			local portrait = CreateFrame("PlayerModel", nil, health)
			portrait:SetFrameLevel(health:GetFrameLevel() + 1)
			portrait:SetAllPoints(health)
			portrait.PostUpdate = function(self) self:SetAlpha(0) self:SetAlpha(0.3) end		
			self.Portrait = portrait
			
			local overlay = CreateFrame("Frame", nil, self)
			overlay:SetFrameLevel(self:GetFrameLevel() - 2)
			
			health.bg:ClearAllPoints()
			health.bg:Point('BOTTOMLEFT', health:GetStatusBarTexture(), 'BOTTOMRIGHT')
			health.bg:Point('TOPRIGHT', health)
			health.bg:SetDrawLayer("OVERLAY", 7)
			health.bg:SetParent(overlay)
		end

		--Name & Trinkets										--
		if (unit and unit:find('arena%d')) then
			health:Point("TOPRIGHT", self, "TOPRIGHT", -(TRINKET_WIDTH + 2), -2)
			
			self:FontString("Name", font1, C["unitframes"].fontsize, "THINOUTLINE")
			self.Name:Point("LEFT", health, "LEFT", 4, 0)
			self.Name.frequentUpdates = 0.5
			self:Tag(self.Name, '[Elvui:getnamecolor][Elvui:namemedium]')
			
			health.value:ClearAllPoints()
			health.value:Point("TOPRIGHT", health, "TOPRIGHT", 0, -1)

			power.value:ClearAllPoints()
			power.value:Point("BOTTOMRIGHT", health, "BOTTOMRIGHT")
			
			local trinket = CreateFrame("Frame", nil, self)
			trinket.trinketUseAnnounce = true
			
			trinket.bg = CreateFrame("Frame", nil, trinket)
			trinket.bg:Point("TOPLEFT", health.backdrop, "TOPRIGHT", 2, 0)
			trinket.bg:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT")		
			trinket.bg:SetTemplate("Default")
			trinket.bg:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
			trinket.bg:SetFrameLevel(trinket:GetFrameLevel() - 1)
			trinket.bg:CreateShadow("Default")
			
			trinket:Point("TOPLEFT", trinket.bg, 2, -2)
			trinket:Point("BOTTOMRIGHT", trinket.bg, -2, 2)
			
			self.Trinket = trinket			
			
			power:Point("BOTTOMRIGHT", trinket.bg, "BOTTOMLEFT", -BORDER*2, BORDER)
		end
		
		--Name & AltPowerBar									--
		if (unit and unit:find('boss%d')) then
			self:FontString("Name", font1, C["unitframes"].fontsize, "THINOUTLINE")
			self.Name:Point("CENTER", health, "CENTER")
			self.Name.frequentUpdates = 0.5
			self:Tag(self.Name, '[Elvui:getnamecolor][Elvui:nameshort]')		
		
			local altpower = CreateFrame("StatusBar", nil, self)
			altpower:SetStatusBarTexture(C.media.normTex)
			altpower:GetStatusBarTexture():SetHorizTile(false)
			altpower.PostUpdate = E.AltPowerBarPostUpdate
			
			altpower.bg = CreateFrame("Frame", nil, altpower)
			altpower.bg:Point("BOTTOMLEFT", health.backdrop, "TOPLEFT", 0, 1)
			altpower.bg:Point("TOPRIGHT", self, "TOPRIGHT")
			altpower.bg:SetTemplate("Default")
			altpower.bg:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
			altpower.bg:SetFrameLevel(altpower:GetFrameLevel() - 1)

			altpower:Point("TOPLEFT", altpower.bg, "TOPLEFT", 2, -2)
			altpower:Point("BOTTOMRIGHT", altpower.bg, "BOTTOMRIGHT", -2, 2)
			altpower:HookScript("OnShow", function(self) 			
				health:Point("TOPRIGHT", self:GetParent(), "TOPRIGHT", -2, -(POWERBAR_HEIGHT + 2))	
			end)
			
			altpower:HookScript("OnHide", function(self) 
				health:Point("TOPRIGHT", self:GetParent(), "TOPRIGHT", -2, -2)			
			end)			
			self.AltPowerBar = altpower
			
			-- Boss Auras										--
			local debuffs = CreateFrame("Frame", nil, self)
			debuffs.num = C["auras"].playtarbuffperrow
			debuffs:SetWidth(BOSS_WIDTH + BORDER)
			debuffs.spacing = E.Scale(1)
			debuffs.size = (((BOSS_WIDTH - (debuffs.spacing*(debuffs.num - 1))) / debuffs.num))
			debuffs:SetHeight(debuffs.size)
			debuffs:Point("BOTTOMLEFT", self.Health, "TOPLEFT", -BORDER, BORDER+1)
			debuffs.initialAnchor = 'LEFT'
			debuffs["growth-y"] = "UP"
			debuffs["growth-x"] = "RIGHT"
			debuffs.PostCreateIcon = E.PostCreateAura
			debuffs.PostUpdateIcon = E.PostUpdateAura
			debuffs.CustomFilter = E.AuraFilter
			self.Debuffs = debuffs
		else
			-- Arena Auras										--
			local buffs = CreateFrame("Frame", nil, self)
			buffs.num = 3
			buffs:SetWidth(BOSS_WIDTH)
			buffs.spacing = E.Scale(1)
			buffs.size = BOSS_HEIGHT
			buffs:Point("RIGHT", self, "LEFT", -4, 0)
			buffs:SetHeight(buffs.size)
			buffs.initialAnchor = 'RIGHT'
			buffs["growth-y"] = "UP"	
			buffs["growth-x"] = "LEFT"
			buffs.PostCreateIcon = E.PostCreateAura
			buffs.PostUpdateIcon = E.PostUpdateAura
			self.Buffs = buffs	
			
			local debuffs = CreateFrame("Frame", nil, self)
			debuffs.num = 3
			debuffs:SetWidth(BOSS_WIDTH)
			debuffs.spacing = E.Scale(1)
			debuffs.size = BOSS_HEIGHT
			debuffs:SetHeight(debuffs.size)
			debuffs:Point("BOTTOMLEFT", power, "BOTTOMRIGHT", 6, -2)
			debuffs.initialAnchor = 'LEFT'
			debuffs["growth-y"] = "UP"
			debuffs["growth-x"] = "RIGHT"
			debuffs.PostCreateIcon = E.PostCreateAura
			debuffs.PostUpdateIcon = E.PostUpdateAura
			debuffs.CustomFilter = E.AuraFilter
			self.Debuffs = debuffs
		end
		
		--Cast Bar												--
		if C["castbar"].unitcastbar == true then
			local castbar = E.ConstructCastBar(self, BOSS_WIDTH+CASTBAR_HEIGHT-BORDER*2, CASTBAR_HEIGHT-OFFSET-BORDER, "LEFT")
			castbar:SetAllPoints(self.Health)
			--castbar:Point("RIGHT", health, "LEFT", 5, 0)
			castbar:SetFrameLevel(health:GetFrameLevel() + 1)
			self.Castbar = castbar
		end
	end

	------------------------------------------------------------------------
	--	Main tanks and Main Assists										  --
	------------------------------------------------------------------------
	if(self:GetParent():GetName():match"ElvDPSMainTank" or self:GetParent():GetName():match"ElvDPSMainAssist") then
		--Health Bar
		local health = E.ContructHealthBar(self, true, nil)
		health:Point("TOPRIGHT", self, "TOPRIGHT", -2, -2)
		health:Point("BOTTOMLEFT", self, "BOTTOMLEFT", 2, 2)
		self.Health = health
	
		--Name
		self:FontString("Name", font1, C["unitframes"].fontsize, "THINOUTLINE")
		self.Name:SetPoint("CENTER", health, "CENTER")
		self.Name.frequentUpdates = 0.5
		self:Tag(self.Name, '[Elvui:getnamecolor][Elvui:namemedium]')			
	end
	
	------------------------------------------------------------------------
	--	All Units														  --
	------------------------------------------------------------------------
	if unit ~= "party" then
		local RaidIcon = self:CreateTexture(nil, "OVERLAY")
		RaidIcon:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\raidicons.blp") 
		RaidIcon:Size(18, 18)
		RaidIcon:Point("CENTER", self.Health, "TOP", 0, BORDER)
		self.RaidIcon = RaidIcon
	end
		
	return self
end

------------------------------------------------------------------------
--	Default Positions												  --
------------------------------------------------------------------------
local function LoadDPSLayout()
	local oUF = ElvUF or oUF
	assert(oUF, "ElvUI was unable to locate oUF.")

	if E.LoadUFFunctions then E.LoadUFFunctions("ElvDPS") end	
	oUF:RegisterStyle('Elv', Shared)

	--print(HasPetUI())
	--print(PetHasActionBar())
	
	print(select(1, HasPetUI()))
	
	-- Player 										--
	local player = oUF:Spawn('player', "ElvDPS_player")
	if C["actionbar"].bottompetbar == true and E.myclass == "WARLOCK" or E.myclass == "HUNTER" then
		if not C["unitframes"].portraitonhealthbar == true then
		print("1")
			player:Point("BOTTOMLEFT", ElvuiSplitActionBarLeftBackground, "TOPLEFT", 0, OFFSET+SMALL_HEIGHT+ElvuiPetActionBarBackground:GetHeight()+BORDER*4+10)
			player:Point("TOPRIGHT", ElvuiSplitActionBarLeftBackground, "TOPLEFT", PLAYER_WIDTH+PLAYER_WIDTH/4.5+OFFSET+BORDER, PLAYER_HEIGHT+OFFSET*2+SMALL_HEIGHT+ElvuiPetActionBarBackground:GetHeight()+BORDER*6+10)
		elseif C["unitframes"].charportrait == true and C["unitframes"].portraitonhealthbar == true then
		print("2")
			player:Point("BOTTOMLEFT", ElvuiSplitActionBarLeftBackground, "TOPLEFT", 0, OFFSET+SMALL_HEIGHT+ElvuiPetActionBarBackground:GetHeight()+BORDER*4+10)
			player:Point("TOPRIGHT", ElvuiSplitActionBarLeftBackground, "TOPLEFT", PLAYER_WIDTH+OFFSET+BORDER, PLAYER_HEIGHT+OFFSET*2+SMALL_HEIGHT+ElvuiPetActionBarBackground:GetHeight()+BORDER*6+10)	
		end
	else
		if not C["unitframes"].portraitonhealthbar == true then
		print("3")
			player:Point("BOTTOMLEFT", ElvuiSplitActionBarLeftBackground, "TOPLEFT", 0, OFFSET+20+BORDER*4)
			player:Point("TOPRIGHT", ElvuiSplitActionBarLeftBackground, "TOPLEFT", PLAYER_WIDTH+PLAYER_WIDTH/4.5+OFFSET+BORDER, PLAYER_HEIGHT+OFFSET*2+20+BORDER*6)
		elseif C["unitframes"].charportrait == true and C["unitframes"].portraitonhealthbar == true then
		print("4")
			player:Point("BOTTOMLEFT", ElvuiSplitActionBarLeftBackground, "TOPLEFT", 0, OFFSET+20+BORDER*4)
			player:Point("TOPRIGHT", ElvuiSplitActionBarLeftBackground, "TOPLEFT", PLAYER_WIDTH+OFFSET+BORDER, PLAYER_HEIGHT+OFFSET*2+20+BORDER*6)	
		end
	end
	player:SetSize(PLAYER_WIDTH, PLAYER_HEIGHT)
	
	-- Target										--
	local target = oUF:Spawn('target', "ElvDPS_target")	
	if C["actionbar"].bottompetbar == true and E.myclass == "WARLOCK" or E.myclass == "HUNTER" then
		if not C["unitframes"].portraitonhealthbar == true then
			if E["actionbar"].splitbar == false and E["actionbar"].bottomrows == 2 then
				target:Point("BOTTOMRIGHT", ElvuiSplitActionBarRightBackground, "TOPRIGHT", 0, OFFSET+SMALL_HEIGHT+ElvuiPetActionBarBackground:GetHeight()+BORDER*4+27)
				target:Point("TOPLEFT", ElvuiSplitActionBarRightBackground, "TOPRIGHT", -TARGET_WIDTH-TARGET_WIDTH/4.5-OFFSET-BORDER, PLAYER_HEIGHT+OFFSET*2+SMALL_HEIGHT+ElvuiPetActionBarBackground:GetHeight()+BORDER*6+27)
				--print("wtf")
			else
				target:Point("BOTTOMRIGHT", ElvuiSplitActionBarRightBackground, "TOPRIGHT", 0, OFFSET+SMALL_HEIGHT+ElvuiPetActionBarBackground:GetHeight()+BORDER*4+10)
				target:Point("TOPLEFT", ElvuiSplitActionBarRightBackground, "TOPRIGHT", -TARGET_WIDTH-TARGET_WIDTH/4.5-OFFSET-BORDER, PLAYER_HEIGHT+OFFSET*2+SMALL_HEIGHT+ElvuiPetActionBarBackground:GetHeight()+BORDER*6+10)
			end
		elseif C["unitframes"].charportrait == true and C["unitframes"].portraitonhealthbar == true then
			target:Point("BOTTOMRIGHT", ElvuiSplitActionBarRightBackground, "TOPRIGHT", 0, OFFSET+SMALL_HEIGHT+ElvuiPetActionBarBackground:GetHeight()+BORDER*4+10)
			target:Point("TOPLEFT", ElvuiSplitActionBarRightBackground, "TOPRIGHT", -TARGET_WIDTH-OFFSET-BORDER, PLAYER_HEIGHT+OFFSET*2+SMALL_HEIGHT+ElvuiPetActionBarBackground:GetHeight()+BORDER*6+10)
		end
	else
		if not C["unitframes"].portraitonhealthbar == true then
			target:Point("BOTTOMRIGHT", ElvuiSplitActionBarRightBackground, "TOPRIGHT", 0, OFFSET+20+BORDER*4)
			target:Point("TOPLEFT", ElvuiSplitActionBarRightBackground, "TOPRIGHT", -TARGET_WIDTH-TARGET_WIDTH/4.5-OFFSET-BORDER, PLAYER_HEIGHT+OFFSET*2+20+BORDER*6)
		elseif C["unitframes"].charportrait == true and C["unitframes"].portraitonhealthbar == true then
			target:Point("BOTTOMRIGHT", ElvuiSplitActionBarRightBackground, "TOPRIGHT", 0, OFFSET+20+BORDER*4)
			target:Point("TOPLEFT", ElvuiSplitActionBarRightBackground, "TOPRIGHT", -TARGET_WIDTH-OFFSET-BORDER, PLAYER_HEIGHT+OFFSET*2+20+BORDER*6)
		end
	end
	target:SetSize(TARGET_WIDTH, TARGET_HEIGHT)
	
	-- Focus										--
	local focus = oUF:Spawn('focus', "ElvDPS_focus")
	focus:Point("BOTTOMLEFT", ElvDPS_target, "TOPRIGHT", -35, 120)
	focus:Size(SMALL_WIDTH+20, SMALL_HEIGHT+13)

	-- Target's Target								--
	local tot = oUF:Spawn('targettarget', "ElvDPS_targettarget")
	if C["actionbar"].bottompetbar == true and E.myclass == "WARLOCK" or E.myclass == "HUNTER" then
		tot:Point("BOTTOM", ElvuiPetActionBarBackground, "TOP", 0, 35)
	else
	tot:Point("BOTTOM", ElvuiActionBarBackground, "TOP", 0, 35)
	end
	tot:SetSize(SMALL_WIDTH+20, SMALL_HEIGHT+13)

	-- Player's Pet									--
	local pet = oUF:Spawn('pet', "ElvDPS_pet")
	pet:SetPoint("BOTTOM", ElvDPS_targettarget, "TOP", 0, E.Scale(15))
	pet:SetSize(SMALL_WIDTH+20, SMALL_HEIGHT+13)
	pet:SetParent(player)

	-- Player's Pet's Target						--
	if C["unitframes"].pettarget == true then
		local pettarget = oUF:Spawn('pettarget', "ElvDPS_pettarget")
		pettarget:Point("BOTTOM", ElvDPS_pet, "TOP", 0, BORDER*3)
		pettarget:SetSize(SMALL_WIDTH+20, SMALL_HEIGHT+10)
		pettarget:SetParent(pet)
	end

	-- Focus's target								--
	if C["unitframes"].showfocustarget == true then
		local focustarget = oUF:Spawn('focustarget', "ElvDPS_focustarget")
		focustarget:Point("BOTTOM", ElvDPS_focus, "TOP", 0, 15)
		focustarget:Size(SMALL_WIDTH, SMALL_HEIGHT+10)
	end

	if C.arena.unitframes then
		local arena = {}
		for i = 1, 5 do
			arena[i] = oUF:Spawn("arena"..i, "ElvDPSArena"..i)
			if i == 1 then
				arena[i]:Point("BOTTOMLEFT", ChatRBackground2, "TOPLEFT", -80, 160)
			else
				arena[i]:Point("BOTTOM", arena[i-1], "TOP", 0, 45)
			end
			arena[i]:Size(BOSS_WIDTH, BOSS_HEIGHT)
		end
	end

	if C.raidframes.showboss then
		local boss = {}
		for i = 1, MAX_BOSS_FRAMES do
			boss[i] = oUF:Spawn("boss"..i, "ElvDPSBoss"..i)
			if i == 1 then
				boss[i]:Point("BOTTOMLEFT", ChatRBackground2, "TOPLEFT", -80, 160)
			else
				boss[i]:Point('BOTTOM', boss[i-1], 'TOP', 0, 45)             
			end
			boss[i]:Size(BOSS_WIDTH, BOSS_HEIGHT)
		end
	end
	
	if C["raidframes"].maintank == true then
		local tank = oUF:SpawnHeader('ElvDPSMainTank', nil, 'raid', 
			'oUF-initialConfigFunction', ([[
				self:SetWidth(%d)
				self:SetHeight(%d)
			]]):format(TANK_WIDTH, TANK_HEIGHT),
			'showRaid', true, 
			'groupFilter', 'MAINTANK', 
			'yOFFSET', 7, 
			'point' , 'BOTTOM',
			'template', 'Elv_Mtt'
		)
		tank:Point("LEFT", UIParent, "LEFT", 6, 250)
	end

	if C["raidframes"].mainassist == true then
		local assist = oUF:SpawnHeader("ElvDPSMainAssist", nil, 'raid', 
			'oUF-initialConfigFunction', ([[
				self:SetWidth(%d)
				self:SetHeight(%d)
			]]):format(TANK_WIDTH, TANK_HEIGHT),
			'showRaid', true, 
			'groupFilter', 'MAINASSIST', 
			'yOFFSET', 7, 
			'point' , 'BOTTOM',
			'template', 'Elv_Mtt'
		)
		if C["raidframes"].maintank == true then 
			assist:Point("TOPLEFT", ElvDPSMainTank, "BOTTOMLEFT", 0, -50)
		else
			assist:Point("LEFT", UIParent, "LEFT", 6, 250)
		end
	end

	local party
	if C["raidframes"].disableblizz == true then --seriosly lazy addon authors can suck my dick
		for i = 1,MAX_BOSS_FRAMES do
			local t_boss = _G["Boss"..i.."TargetFrame"]
			t_boss:UnregisterAllEvents()
			t_boss.Show = E.dummy
			t_boss:Hide()
			_G["Boss"..i.."TargetFrame".."HealthBar"]:UnregisterAllEvents()
			_G["Boss"..i.."TargetFrame".."ManaBar"]:UnregisterAllEvents()
		end
		
		party = oUF:SpawnHeader("oUF_noParty", nil, "party", "showParty", true)
		local blizzloader = CreateFrame("Frame")
		blizzloader:RegisterEvent("ADDON_LOADED")
		blizzloader:SetScript("OnEvent", function(self, event, addon)
			if addon == "Elvui_RaidDPS" then 
				CompactRaidFrameContainer:Kill()
				CompactPartyFrame:Kill()
			end
		end)
	end
	
	------------------------------------------------------------------------
	--	Right-Click on unit frames menu.								  --
	------------------------------------------------------------------------
	do
		UnitPopupMenus["SELF"] = { "PVP_FLAG", "LOOT_METHOD", "LOOT_THRESHOLD", "OPT_OUT_LOOT_TITLE", "LOOT_PROMOTE", "DUNGEON_DIFFICULTY", "RAID_DIFFICULTY", "RESET_INSTANCES", "RAID_TARGET_ICON", "SELECT_ROLE", "CONVERT_TO_PARTY", "CONVERT_TO_RAID", "LEAVE", "CANCEL" };
		UnitPopupMenus["PET"] = { "PET_PAPERDOLL", "PET_RENAME", "PET_ABANDON", "PET_DISMISS", "CANCEL" };
		UnitPopupMenus["PARTY"] = { "MUTE", "UNMUTE", "PARTY_SILENCE", "PARTY_UNSILENCE", "RAID_SILENCE", "RAID_UNSILENCE", "BATTLEGROUND_SILENCE", "BATTLEGROUND_UNSILENCE", "WHISPER", "PROMOTE", "PROMOTE_GUIDE", "LOOT_PROMOTE", "VOTE_TO_KICK", "UNINVITE", "INSPECT", "ACHIEVEMENTS", "TRADE", "FOLLOW", "DUEL", "RAID_TARGET_ICON", "SELECT_ROLE", "PVP_REPORT_AFK", "RAF_SUMMON", "RAF_GRANT_LEVEL", "CANCEL" }
		UnitPopupMenus["PLAYER"] = { "WHISPER", "INSPECT", "INVITE", "ACHIEVEMENTS", "TRADE", "FOLLOW", "DUEL", "RAID_TARGET_ICON", "RAF_SUMMON", "RAF_GRANT_LEVEL", "CANCEL" }
		UnitPopupMenus["RAID_PLAYER"] = { "MUTE", "UNMUTE", "RAID_SILENCE", "RAID_UNSILENCE", "BATTLEGROUND_SILENCE", "BATTLEGROUND_UNSILENCE", "WHISPER", "INSPECT", "ACHIEVEMENTS", "TRADE", "FOLLOW", "DUEL", "RAID_TARGET_ICON", "SELECT_ROLE", "RAID_LEADER", "RAID_PROMOTE", "RAID_DEMOTE", "LOOT_PROMOTE", "RAID_REMOVE", "PVP_REPORT_AFK", "RAF_SUMMON", "RAF_GRANT_LEVEL", "CANCEL" };
		UnitPopupMenus["RAID"] = { "MUTE", "UNMUTE", "RAID_SILENCE", "RAID_UNSILENCE", "BATTLEGROUND_SILENCE", "BATTLEGROUND_UNSILENCE", "RAID_LEADER", "RAID_PROMOTE", "RAID_MAINTANK", "RAID_MAINASSIST", "RAID_TARGET_ICON", "SELECT_ROLE", "LOOT_PROMOTE", "RAID_DEMOTE", "RAID_REMOVE", "PVP_REPORT_AFK", "CANCEL" };
		UnitPopupMenus["VEHICLE"] = { "RAID_TARGET_ICON", "VEHICLE_LEAVE", "CANCEL" }
		UnitPopupMenus["TARGET"] = { "RAID_TARGET_ICON", "CANCEL" }
		UnitPopupMenus["ARENAENEMY"] = { "CANCEL" }
		UnitPopupMenus["FOCUS"] = { "RAID_TARGET_ICON", "CANCEL" }
		UnitPopupMenus["BOSS"] = { "RAID_TARGET_ICON", "CANCEL" }
	end
	
	E.LoadDPSMoveElements("ElvDPS")
	if C["classtimer"].enable == true then
		E.LoadClassTimers(ElvDPS_player, ElvDPS_target)
	end
end
--[[
local dowerk = CreateFrame("Frame", nil, self)
dowerk:RegisterEvent("PET_BAR_UPDATE")
dowerk:RegisterEvent("PET_BAR_HIDE")
dowerk:SetScript("OnEvent",LoadDPSLayout) 
--]]
E.Layouts["DPS"] = LoadDPSLayout