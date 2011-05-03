------------------------------------------------------------------------
--	UnitFrame Functions
------------------------------------------------------------------------
local E, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales
local _, ns = ...

E.LoadUFFunctions = function(layout)
	local oUF = ElvUF or oUF
	assert(oUF, "ElvUI was unable to locate oUF.")

	
	--------------------------------------
	-- HEALTH							--
	--------------------------------------
	function E.ContructHealthBar(self, bg, text)
		local health = CreateFrame('StatusBar', nil, self)
		health:SetStatusBarTexture(C["media"].normTex)
		
		health:SetFrameStrata("LOW")
		health:SetFrameLevel(10)
		--health.SetFrameLevel = E.dummy
		--health.SetFrameStrata = E.dummy
		health.frequentUpdates = 0.2
		health.PostUpdate = E.PostUpdateHealth
		
		if C["unitframes"].showsmooth == true then
			health.Smooth = true
		end	
		
		if bg then
			health.bg = health:CreateTexture(nil, 'BORDER')
			health.bg:SetAllPoints()
			health.bg:SetTexture(C["media"].blank)
			
			if C["unitframes"].healthbackdrop ~= true then
				health.bg.multiplier = 0.25
			else
				health.bg:SetTexture(unpack(C["unitframes"].healthbackdropcolor))
			end
		end
		
		if text then
			health:FontString("value", C["media"].uffont, C["unitframes"].fontsize, "THINOUTLINE")
			health.value:SetParent(self)
		end
		
		if C["unitframes"].classcolor ~= true then
			health.colorTapping = true
			
			if C["unitframes"].healthcolorbyvalue == true then
				health.colorSmooth = true
			else
				health.colorHealth = true
			end
		else
			health.colorTapping = true	
			health.colorClass = true
			health.colorReaction = true
		end
		health.colorDisconnected = true
		
		health.backdrop = CreateFrame('Frame', nil, health)
		health.backdrop:SetTemplate("Tanthalus")
		health.backdrop:CreateShadow("Transparent")
		health.backdrop:Point("TOPRIGHT", health, "TOPRIGHT", 2, 2)
		health.backdrop:Point("BOTTOMLEFT", health, "BOTTOMLEFT", -2, -2)
		health.backdrop:SetFrameLevel(health:GetFrameLevel() - 1)
	
		hback = health.backdrop
--[[		
		health.backdrop:RegisterEvent("PLAYER_REGEN_ENABLED")
		health.backdrop:RegisterEvent("PLAYER_REGEN_DISABLED")
		health.backdrop:SetScript("OnEvent", function(self, event)
			if event == "PLAYER_REGEN_DISABLED" then
				health.backdrop:SetTemplate("Tukui", true)
				health.backdrop:CreateShadow("Tukui")
			elseif event == "PLAYER_REGEN_ENABLED" then
				health.backdrop:SetTemplate("Default", true)
				health.backdrop:CreateShadow("Default")
			end
		end)
--]]		
		return health
	end
	
	--------------------------------------
	-- POWER							--
	--------------------------------------
	function E.ConstructPowerBar(self, bg, text)
		local power = CreateFrame('StatusBar', nil, self)
		power:SetStatusBarTexture(C["media"].normTex)
		power.frequentUpdates = 0.2
		
		power:SetFrameStrata(hback:GetFrameStrata())
		power:SetFrameLevel(hback:GetFrameLevel() - 1)
		--power.SetFrameLevel = E.dummy
		--power.SetFrameStrata = E.dummy
		power.PostUpdate = E.PostUpdatePower
	
		if C["unitframes"].showsmooth == true then
			power.Smooth = true
		end	
		
		if bg then
			power.bg = power:CreateTexture(nil, 'BORDER')
			power.bg:SetAllPoints()
			power.bg:SetTexture(C["media"].blank)
			power.bg.multiplier = 0.2
		end
		
		if text then
			power:FontString("value", C["media"].uffont, C["unitframes"].fontsize, "THINOUTLINE")
			power.value:SetParent(self)
		end
		
		power.colorClass = true
		power.colorClassNPC = true
		power.colorClassPet = true	
		power.colorDisconnected = true
		power.colorTapping = true

		power.backdrop = CreateFrame('Frame', nil, power)
		power.backdrop:CreateShadow("Transparent")
		power.backdrop:SetTemplate("Default")
		power.backdrop:Point("TOPRIGHT", power, "TOPRIGHT", 2, 2)
		power.backdrop:Point("BOTTOMLEFT", power, "BOTTOMLEFT", -2, -2)
		
		power.backdrop:SetFrameStrata(power:GetFrameStrata())
		power.backdrop:SetFrameLevel(power:GetFrameLevel() - 1)
		--power.backdrop.SetFrameLevel = E.dummy
		--power.backdrop.SetFrameStrata = E.dummy

--[[		
		power.backdrop:RegisterEvent("PLAYER_REGEN_ENABLED")
		power.backdrop:RegisterEvent("PLAYER_REGEN_DISABLED")
		power.backdrop:SetScript("OnEvent", function(self, event)
			if event == "PLAYER_REGEN_DISABLED" then
				power.backdrop:SetTemplate("Hydra", true)
				power.backdrop:CreateShadow("Hydra")
			elseif event == "PLAYER_REGEN_ENABLED" then
				power.backdrop:SetTemplate("Default", true)
				power.backdrop:CreateShadow("Default")
			end
		end)
--]]	
		return power
	end	
	
	--------------------------------------
	-- CAST								--
	--------------------------------------
	function E.ConstructCastBar(self, width, height, direction)
		local castbar = CreateFrame("StatusBar", nil, self)
		castbar:SetStatusBarTexture(C["media"].normTex)
		castbar:Height(height)
		castbar:Width(width - 4)
		castbar.CustomDelayText = E.CustomCastDelayText
		castbar.PostCastStart = E.PostCastStart
		castbar.PostChannelStart = E.PostCastStart
				
		castbar.bg = CreateFrame("Frame", nil, castbar)
		castbar.bg:SetTemplate("Default")
		castbar.bg:CreateShadow("Transparent")
		castbar.bg:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
		castbar.bg:Point("TOPLEFT", -2, 2)
		castbar.bg:Point("BOTTOMRIGHT", 2, -2)
		castbar.bg:SetFrameLevel(castbar:GetFrameLevel() - 1)
		
		castbar:FontString("Time", C["media"].pixel, 9, "THINOUTLINE, MONOCHROME")
		castbar.Time:Point("RIGHT", castbar, "RIGHT", -4, 0)
		castbar.Time:SetShadowColor( 0, 0, 0 )
		castbar.Time:SetShadowOffset( 0, 0 )
		castbar.Time:SetTextColor(0.84, 0.75, 0.65)
		castbar.Time:SetJustifyH("RIGHT")
		castbar.CustomTimeText = E.CustomCastTimeText

		castbar:FontString("Text", C["media"].pixel, 9, "THINOUTLINE, MONOCHROME")
		castbar.Text:Point("LEFT", castbar, "LEFT", 6, 0)
		castbar.Text:SetShadowColor( 0, 0, 0 )
		castbar.Text:SetShadowOffset( 0, 0 )
		castbar.Text:SetTextColor(0.84, 0.75, 0.65)
		
		castbar.Spark = castbar:CreateTexture(nil, 'OVERLAY')
		castbar.Spark:SetHeight(height*2.2)
		castbar.Spark:SetWidth(15)
		castbar.Spark:SetBlendMode('ADD')

		-- cast bar latency on player
		if C["castbar"].cblatency == true and self.unit == "player" then
			castbar.SafeZone = castbar:CreateTexture(nil, "OVERLAY")
			castbar.SafeZone:SetTexture(C["media"].normTex)
			castbar.SafeZone:SetVertexColor(0.69, 0.31, 0.31, 0.75)
		end			

		if C["castbar"].cbicons == true then
			local button = CreateFrame("Frame", nil, castbar)
			button:Height(height + 4)
			button:Width(height + 4)
			button:SetTemplate("Default")
			button:CreateShadow("Transparent")
			button:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
			if direction == "LEFT" then
				button:Point("RIGHT", castbar, "LEFT", -5, 0)
			else
				button:Point("LEFT", castbar, "RIGHT", 5, 0)
			end
			
			castbar.Icon = button:CreateTexture(nil, "ARTWORK")
			castbar.Icon:Point("TOPLEFT", button, 2, -2)
			castbar.Icon:Point("BOTTOMRIGHT", button, -2, 2)
			castbar.Icon:SetTexCoord(0.08, 0.92, 0.08, .92)
			
			castbar:Width(width - button:GetWidth() - 6)
		end
	
		return castbar
	end

	--------------------------------------
	-- FADERS							--
	--------------------------------------
	function CombatFX2(f)
	if not f then return end
		f:RegisterEvent("PLAYER_REGEN_ENABLED")
		f:RegisterEvent("PLAYER_REGEN_DISABLED")
		f:SetScript("OnEvent", function(self, event)
			if event == "PLAYER_REGEN_DISABLED" then
				UIFrameFadeOut(f, .6, 1, 0)
			elseif event == "PLAYER_REGEN_ENABLED" then
				UIFrameFadeIn(f, .6, 0, 1)
			end
		end)
	end
	CombatFX2(m_zone)
	
	function CombatFX3(f)
	if not f then return end
		f:RegisterEvent("PLAYER_REGEN_ENABLED")
		f:RegisterEvent("PLAYER_REGEN_DISABLED")
		f:SetScript("OnEvent", function(self, event)
			if event == "PLAYER_REGEN_DISABLED" then
				UIFrameFadeIn(f, 1, 0, 1)
			elseif event == "PLAYER_REGEN_ENABLED" then
				UIFrameFadeOut(f, 1, 1, 0)
			end
		end)
	end
	
	function E.SpawnMenu(self)
		local unit = self.unit:gsub("(.)", string.upper, 1)
		if self.unit == "targettarget" then return end
		if _G[unit.."FrameDropDown"] then
			ToggleDropDownMenu(1, nil, _G[unit.."FrameDropDown"], "cursor")
		elseif (self.unit:match("party")) then
			ToggleDropDownMenu(1, nil, _G["PartyMemberFrame"..self.id.."DropDown"], "cursor")
		else
			FriendsDropDown.unit = self.unit
			FriendsDropDown.id = self.id
			FriendsDropDown.initialize = RaidFrameDropDown_Initialize
			ToggleDropDownMenu(1, nil, FriendsDropDown, "cursor")
		end
	end

	local frameshown = true
	local unitlist = {}
	local function FadeFramesInOut(fade)
		for frames, unitlist in pairs(unitlist) do
			if not UnitExists(_G[unitlist].unit) then return end
			if fade == true then
				UIFrameFadeIn(_G[unitlist], 0.15)
			else
				UIFrameFadeOut(_G[unitlist], 0.15)
			end
		end
	end

	E.Fader = function(self, arg1, arg2)	
		if arg1 == "UNIT_HEALTH" and self.unit ~= arg2 then return end
		
		local unit = self.unit
		if arg2 == true then self = self:GetParent() end
		if not unitlist[tostring(self:GetName())] then tinsert(unitlist, tostring(self:GetName())) end
		
		local cur = UnitHealth("player")
		local max = UnitHealthMax("player")
		
		if (UnitCastingInfo("player") or UnitChannelInfo("player")) and frameshown ~= true then
			FadeFramesInOut(true)
			frameshown = true	
		elseif cur ~= max and frameshown ~= true then
			FadeFramesInOut(true)
			frameshown = true	
		elseif (UnitExists("target") or UnitExists("focus")) and frameshown ~= true then
			FadeFramesInOut(true)
			frameshown = true	
		elseif arg1 == true and frameshown ~= true then
			FadeFramesInOut(true)
			frameshown = true
		else
			if InCombatLockdown() and frameshown ~= true then
				FadeFramesInOut(true)
				frameshown = true	
			elseif not UnitExists("target") and not InCombatLockdown() and not UnitExists("focus") and (cur == max) and not (UnitCastingInfo("player") or UnitChannelInfo("player")) then
				FadeFramesInOut(false)
				frameshown = false
			end
		end
	end

	E.AuraFilter = function(icons, unit, icon, name, rank, texture, count, dtype, duration, timeLeft, caster, isStealable, shouldConsolidate, spellID)	
		local header = icon:GetParent():GetParent():GetParent():GetName()
		local inInstance, instanceType = IsInInstance()
		icon.owner = caster
		icon.isStealable = isStealable
		
		if (unit and unit:find("arena%d")) then --Arena frames
			if dtype then
				if E.DebuffWhiteList[name] then
					return true
				else
					return false
				end			
			else
				if E.ArenaBuffWhiteList[name] then
					return true
				else
					return false
				end		
			end
		elseif unit == "target" or (unit and unit:find("boss%d")) then --Target/Boss Only
			if C["auras"].playerdebuffsonly == true then
				-- Show all debuffs on friendly targets
				if UnitIsFriend("player", "target") then return true end
				
				local isPlayer
				
				if(caster == 'player' or caster == 'vehicle') then
					isPlayer = true
				else
					isPlayer = false
				end

				if isPlayer then
					return true
				elseif E.DebuffWhiteList[name] or (inInstance and ((instanceType == "pvp" or instanceType == "arena") and E.TargetPVPOnly[name])) then
					return true
				else
					return false
				end
			else
				return true
			end
		else --Everything else
			if unit ~= "player" and unit ~= "targettarget" and unit ~= "focus" and C["auras"].arenadebuffs == true and inInstance and (instanceType == "pvp" or instanceType == "arena") then
				if E.DebuffWhiteList[name] or E.TargetPVPOnly[name] then
					return true
				else
					return false
				end
			else
				if E.DebuffBlacklist[name] then
					return false
				else
					return true
				end
			end
		end
	end

	E.PostUpdateHealth = function(health, unit, min, max)
		local r, g, b = health:GetStatusBarColor()
		
		if C["general"].classcolortheme == true then
			health.backdrop:SetBackdropBorderColor(r, g, b)
		end
		
		if C["unitframes"].classcolor == true and C["unitframes"].healthcolorbyvalue == true and not (UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit)) then
			local newr, newg, newb = ElvUF.ColorGradient(min / max, 1, 0, 0, 1, 1, 0, r, g, b)
	
			health:SetStatusBarColor(newr, newg, newb)
			if health.bg and health.bg.multiplier then
				local mu = health.bg.multiplier
				health.bg:SetVertexColor(newr * mu, newg * mu, newb * mu)
			end
		end
		
		if not health.value then return end
		
		local header = health:GetParent():GetParent():GetName()
		if header == "ElvuiHealParty" or header == "ElvuiDPSParty" or header == "ElvuiHealR6R25" or header == "ElvuiDPSR6R25" or header == "ElvuiHealR26R40" or header == "ElvuiDPSR26R40" then --Raid/Party Layouts
			if not UnitIsConnected(unit) or UnitIsDead(unit) or UnitIsGhost(unit) then
				if not UnitIsConnected(unit) then
					health.value:SetText("|cffD7BEA5"..L.unitframes_ouf_offline.."|r")
				elseif UnitIsDead(unit) then
					health.value:SetText("|cffD7BEA5"..L.unitframes_ouf_dead.."|r")
				elseif UnitIsGhost(unit) then
					health.value:SetText("|cffD7BEA5"..L.unitframes_ouf_ghost.."|r")
				end
			else
				if min ~= max and C["raidframes"].healthdeficit == true then
					health.value:SetText("|cff559655-"..E.ShortValueNegative(max-min).."|r")
				else
					health.value:SetText("")
				end
			end
		else
			if not UnitIsConnected(unit) or UnitIsDead(unit) or UnitIsGhost(unit) then
				if not UnitIsConnected(unit) then
					health.value:SetText("|cffD7BEA5"..L.unitframes_ouf_offline.."|r")
				elseif UnitIsDead(unit) then
					health.value:SetText("|cffD7BEA5"..L.unitframes_ouf_dead.."|r")
				elseif UnitIsGhost(unit) then
					health.value:SetText("|cffD7BEA5"..L.unitframes_ouf_ghost.."|r")
				end
			else
				if min ~= max then
					local r, g, b
					r, g, b = oUF.ColorGradient(min/max, 0.69, 0.31, 0.31, 0.65, 0.63, 0.35, 0.33, 0.59, 0.33)
					if unit == "player" and health:GetAttribute("normalUnit") ~= "pet" then
						if C["unitframes"].showtotalhpmp == true then
							health.value:SetFormattedText("|cff559655%s|r |cffD7BEA5|||r |cff559655%s|r", E.ShortValue(min), E.ShortValue(max))
						else
							health.value:SetFormattedText("|cffAF5050%s|r |cffD7BEA5-|r |cff%02x%02x%02x%d%%|r", E.ShortValue(min), r * 255, g * 255, b * 255, floor(min / max * 100))
						end
					elseif unit == "target" or unit == "focus" or (unit and unit:find("boss%d")) then
						if C["unitframes"].showtotalhpmp == true then
							health.value:SetFormattedText("|cff559655%s|r |cffD7BEA5|||r |cff559655%s|r", E.ShortValue(min), E.ShortValue(max))
						else
							health.value:SetFormattedText("|cffAF5050%s|r |cffD7BEA5-|r |cff%02x%02x%02x%d%%|r", E.ShortValue(min), r * 255, g * 255, b * 255, floor(min / max * 100))
						end
					elseif (unit and unit:find("arena%d")) then
						health.value:SetText("|cff559655"..E.ShortValue(min).."|r")
					else
						health.value:SetFormattedText("|cffAF5050%s|r |cffD7BEA5-|r |cff%02x%02x%02x%d%%|r", E.ShortValue(min), r * 255, g * 255, b * 255, floor(min / max * 100))
					end
				else
					if unit == "player" and health:GetAttribute("normalUnit") ~= "pet" then
						health.value:SetText("|cff559655"..E.ShortValue(max).."|r")
					elseif unit == "target" or unit == "focus" or (unit and unit:find("arena%d")) then
						health.value:SetText("|cff559655"..E.ShortValue(max).."|r")
					else
						health.value:SetText("|cff559655"..E.ShortValue(max).."|r")
					end
				end
			end
		end
	end

	E.PostNamePosition = function(self)
		self.Name:ClearAllPoints()
		if (self.Power.value:GetText() and UnitIsPlayer("target") and C["unitframes"].targetpowerplayeronly == true) or (self.Power.value:GetText() and C["unitframes"].targetpowerplayeronly == false) then
			self.Power.value:SetAlpha(1)
			self.Name:SetPoint("CENTER", self.Health, "CENTER")
		else
			self.Power.value:SetAlpha(0)
			self.Name:SetPoint("LEFT", self.Health, "LEFT", 4, 0)
		end
	end

	E.PostUpdatePower = function(power, unit, min, max)
		local self = power:GetParent()
		local pType, pToken, altR, altG, altB = UnitPowerType(unit)
		local color = E.oUF_colors.power[pToken]
		
		if C["general"].classcolortheme == true then
			power.backdrop:SetBackdropBorderColor(power:GetParent().Health:GetStatusBarColor())
		end
		
		if not power.value then return end		
	
		if color then
			power.value:SetTextColor(color[1], color[2], color[3])
		else
			power.value:SetTextColor(altR, altG, altB, 1)
		end	
			
		if min == 0 then 
			power.value:SetText("") 
		else
			if (not UnitIsPlayer(unit) and not UnitPlayerControlled(unit) or not UnitIsConnected(unit)) and not (unit and unit:find("boss%d")) then
				power.value:SetText()
			elseif UnitIsDead(unit) or UnitIsGhost(unit) then
				power.value:SetText()
			else
				if min ~= max then
					if pType == 0 then
						if unit == "target" then
							if C["unitframes"].showtotalhpmp == true then
								power.value:SetFormattedText("%s |cffD7BEA5|||r %s", E.ShortValue(max - (max - min)), E.ShortValue(max))
							else
								power.value:SetFormattedText("%d%% |cffD7BEA5-|r %s", floor(min / max * 100), E.ShortValue(max - (max - min)))
							end
						elseif unit == "player" and self:GetAttribute("normalUnit") == "pet" or unit == "pet" then
							if C["unitframes"].showtotalhpmp == true then
								power.value:SetFormattedText("%s |cffD7BEA5|||r %s", E.ShortValue(max - (max - min)), E.ShortValue(max))
							else
								power.value:SetFormattedText("%d%%", floor(min / max * 100))
							end
						elseif (unit and unit:find("arena%d")) then
							power.value:SetText(E.ShortValue(min))
						elseif (unit and unit:find("boss%d")) then
							if C["unitframes"].showtotalhpmp == true then
								power.value:SetFormattedText("%s |cffD7BEA5|||r %s", E.ShortValue(max), E.ShortValue(max - (max - min)))
							else
								power.value:SetFormattedText("%s |cffD7BEA5-|r %d%%", E.ShortValue(max - (max - min)), floor(min / max * 100))
							end						
						else
							if C["unitframes"].showtotalhpmp == true then
								power.value:SetFormattedText("%s |cffD7BEA5|||r %s", E.ShortValue(max - (max - min)), E.ShortValue(max))
							else
								power.value:SetFormattedText("%d%% |cffD7BEA5-|r %s", floor(min / max * 100), E.ShortValue(max - (max - min)))
							end
						end
					else
						power.value:SetText(max - (max - min))
					end
				else
					if unit == "pet" or unit == "target" or (unit and unit:find("arena%d")) then
						power.value:SetText(E.ShortValue(min))
					else
						power.value:SetText(E.ShortValue(min))
					end
				end
			end
		end
		
		if self.Name and unit == "target"  then
			E.PostNamePosition(self)
		end
	end
	
	local delay = 0
	E.UpdateManaLevel = function(self, elapsed)
		delay = delay + elapsed
		if self.unit ~= "player" or delay < 0.2 or UnitIsDeadOrGhost("player") or UnitPowerType("player") ~= 0 then return end
		delay = 0

		local percMana = UnitMana("player") / UnitManaMax("player") * 100

		if percMana <= 20 then
			self.ManaLevel:SetText("|cffaf5050"..L.unitframes_ouf_lowmana.."|r")
			E.Flash(self.ManaLevel, 0.3)
		else
			self.ManaLevel:SetText()
			E.StopFlash(self.ManaLevel)
		end
	end
	
	E.MLAnchorUpdate = function(self)
		if self.Leader:IsShown() then
			self.MasterLooter:Point("TOPRIGHT", -18, 9)
		else
			self.MasterLooter:Point("TOPRIGHT", -4, 9)
		end
	end
	
	E.UpdateShards = function(self, event, unit, powerType)
		if(self.unit ~= unit or (powerType and powerType ~= 'SOUL_SHARDS')) then return end
		local num = UnitPower(unit, SPELL_POWER_SOUL_SHARDS)
		for i = 1, SHARD_BAR_NUM_SHARDS do
			if(i <= num) then
				self.SoulShards[i]:SetAlpha(1)
			else
				self.SoulShards[i]:SetAlpha(.2)
			end
		end
	end

	E.UpdateHoly = function(self, event, unit, powerType)
		if(self.unit ~= unit or (powerType and powerType ~= 'HOLY_POWER')) then return end
		local num = UnitPower(unit, SPELL_POWER_HOLY_POWER)
		for i = 1, MAX_HOLY_POWER do
			if(i <= num) then
				self.HolyPower[i]:SetAlpha(1)
			else
				self.HolyPower[i]:SetAlpha(.2)
			end
		end
	end	
	
	E.EclipseDirection = function(self)
		if ( GetEclipseDirection() == "sun" ) then
			self.Text:SetText(">")
			self.Text:SetTextColor(.2,.2,1,1)
		elseif ( GetEclipseDirection() == "moon" ) then
			self.Text:SetText("<")
			self.Text:SetTextColor(1,1,.3, 1)
		else
			self.Text:SetText("")
		end
	end	

	E.CustomCastTimeText = function(self, duration)
		self.Time:SetText(("%.1f / %.1f"):format(self.channeling and duration or self.max - duration, self.max))
	end

	E.CustomCastDelayText = function(self, duration)
		self.Time:SetText(("%.1f |cffaf5050%s %.1f|r"):format(self.channeling and duration or self.max - duration, self.channeling and "- " or "+", self.delay))
	end

	local FormatTime = function(s, reverse)
		local day, hour, minute, second = 86400, 3600, 60, 1
		if s >= day then
			return format("%dd", ceil(s / hour))
		elseif s >= hour then
			return format("%dh", ceil(s / hour))
		elseif s >= minute then
			return format("%dm", ceil(s / minute))
		elseif s >= minute / 12 then
			return floor(s)
		end
		
		if reverse and reverse == true and s >= second then
			return floor(s)
		else	
			return format("%.1f", s)
		end
	end
	
	local abs = math.abs --faster
	local CreateAuraTimer = function(self, elapsed)	
		if self.timeLeft then
			self.elapsed = (self.elapsed or 0) + elapsed
			if self.elapsed >= 0.1 then
				if not self.first then
					self.timeLeft = self.timeLeft - self.elapsed
				else
					self.timeLeft = self.timeLeft - GetTime()
					self.first = false
				end
				if self.timeLeft > 0 then
					local time = FormatTime(self.timeLeft)
					if self.reverse then time = FormatTime(abs(self.timeLeft - self.duration), true) end
					self.text:SetText(time)
					if self.timeLeft <= 5 then
						self.text:SetTextColor(0.99, 0.31, 0.31)
					else
						self.text:SetTextColor(1, 1, 1)
					end
				else
					self.text:Hide()
					self:SetScript("OnUpdate", nil)
				end
				if (not self.debuff) and C["general"].classcolortheme == true then
					local r, g, b = self:GetParent():GetParent().Health.backdrop:GetBackdropBorderColor()
					self:SetBackdropBorderColor(r, g, b)
				end
				self.elapsed = 0
			end
		end
	end

	function E.PvPUpdate(self, elapsed)
		if(self.elapsed and self.elapsed > 0.2) then
			local unit = self.unit
			local time = GetPVPTimer()

			local min = format("%01.f", floor((time/1000)/60))
			local sec = format("%02.f", floor((time/1000) - min *60)) 
			if(self.PvP) then
				if(UnitIsPVPFreeForAll(unit)) then
					if time ~= 301000 and time ~= -1 then
						self.PvP:SetText(PVP.." ".."("..min..":"..sec..")")
					else
						self.PvP:SetText(PVP)
					end
				elseif UnitIsPVP(unit) then
					if time ~= 301000 and time ~= -1 then
						self.PvP:SetText(PVP.." ".."("..min..":"..sec..")")
					else
						self.PvP:SetText(PVP)
					end
				else
					self.PvP:SetText("")
				end
			end
			self.elapsed = 0
		else
			self.elapsed = (self.elapsed or 0) + elapsed
		end
	end

	--------------------------------------
	-- AURA FUNCTION					--
	--------------------------------------
	function E.PostCreateAura(element, button)
		local unit = button:GetParent():GetParent().unit
		local header = button:GetParent():GetParent():GetParent():GetName()
		
		button:FontString(nil, C["media"].pixel, 9, "THINOUTLINE, MONOCHROME")	
		button:SetTemplate("Default")
		button.text:SetShadowOffset(0, 0)
		button.text:Point("BOTTOM", 1, -4)
		
		button.cd.noOCC = true		 	-- hide OmniCC CDs
		button.cd.noCooldownCount = true	-- hide CDC CDs		
		button.cd:SetReverse()
		
		button.icon:Point("TOPLEFT", 2, -2)
		button.icon:Point("BOTTOMRIGHT", -2, 2)
		button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		button.icon:SetDrawLayer('ARTWORK')
		
		--button.count:FontString(nil, C["media"].pixel, 9, "THINOUTLINE, MONOCHROME")
		--button.count:SetShadowOffset(0, 0)
		button.count:Point("BOTTOMRIGHT", 1, -1)
		button.count:SetJustifyH("RIGHT")
		button.count:SetFont(C["media"].font, C["auras"].auratextscale*0.8, "THINOUTLINE")

		button.overlayFrame = CreateFrame("frame", nil, button, nil)
		button.cd:SetFrameLevel(button:GetFrameLevel())
		button.cd:ClearAllPoints()
		button.cd:SetPoint("TOPLEFT", button, "TOPLEFT", E.Scale(-1), E.Scale(1))
		button.cd:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", E.Scale(1), E.Scale(-1))
		button.overlayFrame:SetFrameLevel(button.cd:GetFrameLevel() + 5)	   
		button.overlay:SetParent(button.overlayFrame)
		button.count:SetParent(button.overlayFrame)
		button.text:SetParent(button.overlayFrame)
		
		local highlight = button:CreateTexture(nil, "HIGHLIGHT")
		highlight:SetTexture(1,1,1,0.45)
		highlight:SetAllPoints(button.icon)	
	end

	function E.PostUpdateAura(icons, unit, icon, index, offset, filter, isDebuff, duration, timeLeft)
		local name, _, _, _, dtype, duration, expirationTime, unitCaster, _, _, spellID = UnitAura(unit, index, icon.filter)
		
		if(icon.debuff) then
			if(not UnitIsFriend("player", unit) and icon.owner ~= "player" and icon.owner ~= "vehicle") and (not E.DebuffWhiteList[name]) then
				icon:SetBackdropBorderColor(unpack(C["media"].bordercolor))
				icon.icon:SetDesaturated(true)
			else
				local color = DebuffTypeColor[dtype] or DebuffTypeColor.none
				if (name == "Unstable Affliction" or name == "Vampiric Touch") and E.myclass ~= "WARLOCK" then
					icon:SetBackdropBorderColor(0.05, 0.85, 0.94)
				else
					icon:SetBackdropBorderColor(color.r * 0.6, color.g * 0.6, color.b * 0.6)
				end
				icon.icon:SetDesaturated(false)
			end
		else
			if (icon.isStealable or ((E.myclass == "PRIEST" or E.myclass == "SHAMAN") and dtype == "Magic")) and not UnitIsFriend("player", unit) then
				icon:SetBackdropBorderColor(237/255, 234/255, 142/255)
			else
				if C["general"].classcolortheme == true then
					local r, g, b = icon:GetParent():GetParent().backdrop:GetBackdropBorderColor()
					icon:SetBackdropBorderColor(r, g, b)
				else
					icon:SetBackdropBorderColor(unpack(C["media"].bordercolor))
				end			
			end
		end
		
		if duration and duration > 0 then
			if C["auras"].auratimer == true then
				icon.text:Show()
			else
				icon.text:Hide()
			end
		else
			icon.text:Hide()
		end
		
		icon.duration = duration
		icon.timeLeft = expirationTime
		icon.first = true
		
		
		if E.ReverseTimerSpells and E.ReverseTimerSpells[spellID] then icon.reverse = true end
		icon:SetScript("OnUpdate", CreateAuraTimer)
	end

	E.PostCastStart = function(self, unit, name, rank, castid)
		if unit == "vehicle" then unit = "player" end
		--Fix blank castbar with opening text
		if name == "Opening" then
			self.Text:SetText(OPENING)
		else
			self.Text:SetText(string.sub(name, 0, 25))
		end
		
		if self.interrupt and unit ~= "player" then
			if UnitCanAttack("player", unit) then
				self:SetStatusBarColor(unpack(C["castbar"].nointerruptcolor))
			else
				self:SetStatusBarColor(unpack(C["castbar"].castbarcolor))	
			end
		else
			if C["castbar"].classcolor ~= true or unit ~= "player" then
				self:SetStatusBarColor(unpack(C["castbar"].castbarcolor))
			else
				self:SetStatusBarColor(unpack(oUF.colors.class[select(2, UnitClass(unit))]))
			end	
		end
	end

	E.ComboDisplay = function(self, event, unit)
		if(unit == 'pet') then return end
		
		local cpoints = self.CPoints
		local cp
		if (UnitHasVehicleUI("player") or UnitHasVehicleUI("vehicle")) then
			cp = GetComboPoints('vehicle', 'target')
		else
			cp = GetComboPoints('player', 'target')
		end

		for i=1, MAX_COMBO_POINTS do
			if(i <= cp) then
				cpoints[i]:SetAlpha(1)
			else
				cpoints[i]:SetAlpha(0.15)
			end
		end
		
		if cpoints[1]:GetAlpha() == 1 then
			cpoints:Show()
		else
			cpoints:Hide()
		end
	end

	E.RestingIconUpdate = function (self)
		if IsResting() then
			self.Resting:Show()
		else
			self.Resting:Hide()
		end
	end

	E.UpdateDruidMana = function(self)
		if self.unit ~= "player" then return end

		local num, str = UnitPowerType("player")
		if num ~= 0 then
			local min = UnitPower("player", 0)
			local max = UnitPowerMax("player", 0)

			local percMana = min / max * 100
			if percMana <= C["unitframes"].lowThreshold then
				self.ManaLevel:SetText("|cffaf5050"..L.unitframes_ouf_lowmana.."|r")
				E.Flash(self.ManaLevel, 0.3)
			else
				self.ManaLevel:SetText()
				E.StopFlash(self.ManaLevel)
			end

			if min ~= max then
				if self.Power.value:GetText() then
					self.DruidMana:SetPoint("LEFT", self.Power.value, "RIGHT", -3, 0)
					self.DruidMana:SetFormattedText("|cffD7BEA5-|r %d%%|r", floor(min / max * 100))
				else
					self.DruidMana:SetPoint("LEFT", self.Health, "LEFT", 4, 1)
					self.DruidMana:SetFormattedText("%d%%", floor(min / max * 100))
				end
			else
				self.DruidMana:SetText()
			end

			self.DruidMana:SetAlpha(1)
		else
			self.DruidMana:SetAlpha(0)
		end
	end

	function E.UpdateThreat(self, event, unit)
		if (self.unit ~= unit) or not unit then return end
		
		local threat = UnitThreatSituation(unit)
		if threat and threat > 1 then
			local r, g, b = GetThreatStatusColor(threat)			
			if self.shadow then
				self.shadow:SetBackdropBorderColor(r, g, b)
			elseif self.Health.backdrop then
				self.Health.backdrop:SetBackdropBorderColor(r, g, b)
				
				if self.Power and self.Power.backdrop then
					self.Power.backdrop:SetBackdropBorderColor(r, g, b)
				end
			end
		else		
			if self.shadow then
				self.shadow:SetBackdropBorderColor(0, 0, 0, 0)
			elseif self.Health.backdrop then
				self.Health.backdrop:SetTemplate("Default")
				
				if self.Power and self.Power.backdrop then
					self.Power.backdrop:SetTemplate("Default")
				end
			end
		end 
	end

	function E.AltPowerBarOnToggle(self)
		local unit = self:GetParent().unit or self:GetParent():GetParent().unit
		
		if unit == nil or unit ~= "player" then return end
		
		if self:IsShown() then
			for _, text in pairs(E.LeftDatatexts) do text:Hide() end
			local type = select(10, UnitAlternatePowerInfo(unit))
			if self.text and type then self.text:SetText(type..": "..E.ValColor.."0%") end
		else
			for _, text in pairs(E.LeftDatatexts) do text:Show() end		
		end
	end
	
	function E.AltPowerBarPostUpdate(self, min, cur, max)
		local perc = math.floor((cur/max)*100)
		
		if perc < 35 then
			self:SetStatusBarColor(0, 1, 0)
		elseif perc < 70 then
			self:SetStatusBarColor(1, 1, 0)
		else
			self:SetStatusBarColor(1, 0, 0)
		end
		
		local unit = self:GetParent().unit or self:GetParent():GetParent().unit
		
		if unit == nil or unit ~= "player" then return end --Only want to see this on the players bar
		
		local type = select(10, UnitAlternatePowerInfo(unit))
				
		if self.text and perc > 0 then
			self.text:SetText(type..": "..E.ValColor..format("%d%%", perc))
		elseif self.text then
			self.text:SetText(type..": "..E.ValColor.."0%")
		end
	end


	----------------------------------------------------------------------------------------------
	-- THE AURAWATCH FUNCTION ITSELF. HERE BE DRAGONS!											--
	----------------------------------------------------------------------------------------------

	E.countOffsets = {
		TOPLEFT = {6, 1},
		TOPRIGHT = {-6, 1},
		BOTTOMLEFT = {6, 1},
		BOTTOMRIGHT = {-6, 1},
		LEFT = {6, 1},
		RIGHT = {-6, 1},
		TOP = {0, 0},
		BOTTOM = {0, 0},
	}

	function E.CreateAuraWatchIcon(self, icon)
		if (icon.cd) then
			icon.cd:SetReverse()
		end 	
	end

	function E.createAuraWatch(self, unit)
		local auras = CreateFrame("Frame", nil, self)
		auras:SetPoint("TOPLEFT", self.Health, 2, -2)
		auras:SetPoint("BOTTOMRIGHT", self.Health, -2, 2)
		auras.presentAlpha = 1
		auras.missingAlpha = 0
		auras.icons = {}
		auras.PostCreateIcon = E.CreateAuraWatchIcon

		if (not C["auras"].auratimer) then
			auras.hideCooldown = true
		end

		local buffs = {}
		if IsAddOnLoaded("Elvui_RaidDPS") then
			if (E.DPSBuffIDs["ALL"]) then
				for key, value in pairs(E.DPSBuffIDs["ALL"]) do
					tinsert(buffs, value)
				end
			end

			if (E.DPSBuffIDs[E.myclass]) then
				for key, value in pairs(E.DPSBuffIDs[E.myclass]) do
					tinsert(buffs, value)
				end
			end	
		else
			if (E.HealerBuffIDs["ALL"]) then
				for key, value in pairs(E.HealerBuffIDs["ALL"]) do
					tinsert(buffs, value)
				end
			end

			if (E.HealerBuffIDs[E.myclass]) then
				for key, value in pairs(E.HealerBuffIDs[E.myclass]) do
					tinsert(buffs, value)
				end
			end
		end
		
		if E.PetBuffs[E.myclass] then
			for key, value in pairs(E.PetBuffs[E.myclass]) do
				tinsert(buffs, value)
			end
		end

		-- "Cornerbuffs"
		if (buffs) then
			for key, spell in pairs(buffs) do
				local icon = CreateFrame("Frame", nil, auras)
				icon.spellID = spell[1]
				icon.anyUnit = spell[4]
				icon:SetWidth(E.Scale(C["auras"].buffindicatorsize))
				icon:SetHeight(E.Scale(C["auras"].buffindicatorsize))
				icon:SetPoint(spell[2], 0, 0)

				local tex = icon:CreateTexture(nil, "OVERLAY")
				tex:SetAllPoints(icon)
				tex:SetTexture(C["media"].blank)
				if (spell[3]) then
					tex:SetVertexColor(unpack(spell[3]))
				else
					tex:SetVertexColor(0.8, 0.8, 0.8)
				end

				local count = icon:CreateFontString(nil, "OVERLAY")
				count:SetFont(C["media"].uffont, 8, "THINOUTLINE")
				count:SetPoint("CENTER", unpack(E.countOffsets[spell[2]]))
				icon.count = count

				auras.icons[spell[1]] = icon
			end
		end

		self.AuraWatch = auras
	end

	local ORD = ns.oUF_RaidDebuffs or oUF_RaidDebuffs

	if not ORD then return end
	ORD.ShowDispelableDebuff = true
	ORD.FilterDispellableDebuff = true
	ORD.MatchBySpellName = true

	ORD:RegisterDebuffs(E.RaidDebuffs)	
	
	E.LoadUFFunctions = nil
end