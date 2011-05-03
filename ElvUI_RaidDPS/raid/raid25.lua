local E, C, L = unpack(ElvUI) -- Import Functions/Constants, Config, Locales

local oUF = ElvUF or oUF
assert(oUF, "ElvUI was unable to locate oUF.")

if not C["raidframes"].enable == true then return end

local RAID_WIDTH
local RAID_HEIGHT

if C["raidframes"].griddps ~= true then
	RAID_WIDTH = E.Scale(110)*C["raidframes"].scale
	RAID_HEIGHT = E.Scale(36)*C["raidframes"].scale
else
	RAID_WIDTH = ((ChatLBackground2:GetWidth() / 5) - 2.5)*C["raidframes"].scale
	RAID_HEIGHT = E.Scale(36)*C["raidframes"].scale
end

local BORDER = 2

local function Shared(self, unit)
	local POWERBAR_WIDTH = RAID_WIDTH - (BORDER*2)
	local POWERBAR_HEIGHT = 8
	
	if C["raidframes"].griddps ~= true then
		POWERBAR_HEIGHT = 7
	end
	
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
	
	--Health Bar										--
	local health = E.ContructHealthBar(self, true, true)
	health:Point("TOPRIGHT", self, "TOPRIGHT", -BORDER, -BORDER)
	health:Point("BOTTOMLEFT", self, "BOTTOMLEFT", BORDER, BORDER+2)
	if C["raidframes"].griddps ~= true then
		health.value:Point("RIGHT", health, "RIGHT", -2, 0)
	else
		health.value:Point("BOTTOM", health, "BOTTOM", 0, 1)
	end
	health.value:SetFont(C["media"].pixel, C["media"].psize, "OUTLINE, MONOCHROME")
	health.backdrop:CreateShadow("Quest")
	health:SetFrameStrata("LOW")
	health:SetFrameLevel(5)
	
	self.Health = health

	--Power Bar											--
	local power = E.ConstructPowerBar(self, true, nil)
	power:Point("TOPLEFT", health.backdrop, "BOTTOMLEFT", RAID_WIDTH/8, 3)
	power:Point("BOTTOMRIGHT", health.backdrop, "BOTTOMRIGHT", -RAID_WIDTH/8, 0)
	power:SetFrameLevel(self.Health:GetFrameLevel() + 3)
	power.backdrop:CreateShadow("Quest")
	power.colorClass = true

	self.Power = power
	
	--[[ Portrait										--
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
--]]	
	--Name												--
	self:FontString("Name", C["media"].pixel, C["media"].psize, "OUTLINE, MONOCHROME")
	if C["raidframes"].griddps ~= true then
		self.Name:Point("LEFT", health, "LEFT", 2, 0)
	else
		self.Name:Point("CENTER", health, "CENTER", 0, 2)
	end
	self.Name.frequentUpdates = 0.3
	self.Name:SetShadowOffset(0, 0)
	self.Name:SetShadowColor(0, 0, 0, .6)
	self:Tag(self.Name, "[Elvui:getnamecolor][Elvui:nameshort]")

	if C["raidframes"].role == true then
		local LFDRole = self:CreateTexture(nil, "OVERLAY")
		LFDRole:Size(6, 6)
		if C["raidframes"].griddps ~= true then
			LFDRole:Point("BOTTOMRIGHT", health, "BOTTOMRIGHT", -2, -2)
		else
			LFDRole:Point("TOP", self.Name, "BOTTOM", 0, -1)
		end
		LFDRole:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\lfdicons.blp")
		self.LFDRole = LFDRole
	end
	
	table.insert(self.__elements, E.UpdateThreat)
	self:RegisterEvent('PLAYER_TARGET_CHANGED', E.UpdateThreat)
	self:RegisterEvent('UNIT_THREAT_LIST_UPDATE', E.UpdateThreat)
	self:RegisterEvent('UNIT_THREAT_SITUATION_UPDATE', E.UpdateThreat)


	local RaidIcon = self:CreateTexture(nil, 'OVERLAY')
	RaidIcon:Size(15*C["raidframes"].scale, 15*C["raidframes"].scale)
	if C["raidframes"].griddps ~= true then
		RaidIcon:SetPoint('LEFT', self.Name, 'RIGHT')
	else
		RaidIcon:SetPoint('CENTER', self, 'TOP')
	end
	RaidIcon:SetTexture('Interface\\AddOns\\ElvUI\\media\\textures\\raidicons.blp')
	self.RaidIcon = RaidIcon
	
	local ReadyCheck = self.Health:CreateTexture(nil, "OVERLAY")
	ReadyCheck:SetHeight(C["raidframes"].fontsize)
	ReadyCheck:SetWidth(C["raidframes"].fontsize)
	if C["raidframes"].griddps ~= true then
		ReadyCheck:Point('LEFT', self.Name, 'RIGHT', 4, 0)
	else	
		ReadyCheck:Point('TOP', self.Name, 'BOTTOM', 0, -2)
	end
	self.ReadyCheck = ReadyCheck
	

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
	
	if C["raidframes"].griddps ~= true then
		local debuffs = CreateFrame('Frame', nil, self)
		debuffs:SetPoint('LEFT', self, 'RIGHT', E.Scale(6), 0)
		debuffs:SetHeight(RAID_HEIGHT)
		debuffs:SetWidth(RAID_HEIGHT*5)
		debuffs.size = (RAID_HEIGHT)
		debuffs.num = 5
		debuffs.spacing = 2
		
		debuffs.initialAnchor = 'LEFT'
		debuffs.PostCreateIcon = E.PostCreateAura
		debuffs.PostUpdateIcon = E.PostUpdateAura
		self.Debuffs = debuffs
		
		-- Debuff Aura Filter
		self.Debuffs.CustomFilter = E.AuraFilter		
	else
		-- Raid Debuffs (big middle icon)
		local RaidDebuffs = CreateFrame('Frame', nil, self)
		RaidDebuffs:Height(RAID_HEIGHT*0.6)
		RaidDebuffs:Width(RAID_HEIGHT*0.6)
		RaidDebuffs:Point('BOTTOM', self, 'BOTTOM', 0, 1)
		RaidDebuffs:SetFrameLevel(self:GetFrameLevel() + 2)
		
		RaidDebuffs:SetTemplate("Default")
		
		RaidDebuffs.icon = RaidDebuffs:CreateTexture(nil, 'OVERLAY')
		RaidDebuffs.icon:SetTexCoord(.1,.9,.1,.9)
		RaidDebuffs.icon:Point("TOPLEFT", 2, -2)
		RaidDebuffs.icon:Point("BOTTOMRIGHT", -2, 2)
		
		RaidDebuffs.count = RaidDebuffs:CreateFontString(nil, 'OVERLAY')
		RaidDebuffs.count:SetFont(C["media"].pixel, C["media"].psize, "OUTLINE, MONOCHROME")
		RaidDebuffs.count:SetShadowOffset(0, 0)
		RaidDebuffs.count:SetPoint('BOTTOMRIGHT', RaidDebuffs, 'BOTTOMRIGHT', 0, 2)
		RaidDebuffs.count:SetTextColor(1, .9, 0)
		
		RaidDebuffs:FontString('time', C["media"].pixel, C["media"].psize, "OUTLINE, MONOCHROME")
		RaidDebuffs.time:SetPoint('CENTER')
		RaidDebuffs.time:SetShadowOffset(0, 0)
		RaidDebuffs.time:SetTextColor(1, .9, 0)
		
		self.RaidDebuffs = RaidDebuffs
	end
				
	if C["raidframes"].showrange == true then
		local range = {insideAlpha = 1, outsideAlpha = C["raidframes"].raidalphaoor}
		self.Range = range
	end
	
	if C["auras"].raidunitbuffwatch == true then
		E.createAuraWatch(self,unit)
    end
	power.colorClass = true
	return self
end

oUF:RegisterStyle('ElvuiDPSR6R25', Shared)
oUF:Factory(function(self)
	oUF:SetActiveStyle("ElvuiDPSR6R25")	
	local raid
	if C["raidframes"].griddps ~= true then
		raid = self:SpawnHeader("ElvuiDPSR6R25", nil, "custom [@raid6,noexists][@raid26,exists] hide;show",
			'oUF-initialConfigFunction', [[
				local header = self:GetParent()
				self:SetWidth(header:GetAttribute('initial-width'))
				self:SetHeight(header:GetAttribute('initial-height'))
			]],
			'initial-width', RAID_WIDTH,
			'initial-height', RAID_HEIGHT,			
			"showRaid", true, 
			"showParty", true,
			"showSolo", false,
			"point", "BOTTOM",
			"showPlayer", C["raidframes"].showplayerinparty,
			"groupFilter", "1,2,3,4,5",
			"groupingOrder", "1,2,3,4,5",
			"groupBy", "GROUP",	
			"yOffset", E.Scale(6)
		)	
		raid:Point("BOTTOMLEFT", ChatLBackground2, "TOPLEFT", 1, 40)
	else
		raid = self:SpawnHeader("ElvuiDPSR6R25", nil, "custom [@raid6,noexists][@raid26,exists] hide;show",
			'oUF-initialConfigFunction', [[
				local header = self:GetParent()
				self:SetWidth(header:GetAttribute('initial-width'))
				self:SetHeight(header:GetAttribute('initial-height'))
			]],
			'initial-width', RAID_WIDTH,
			'initial-height', RAID_HEIGHT,	
			"showRaid", true, 
			"showParty", false,
			"showPlayer", C["raidframes"].showplayerinparty,
			"xoffset", 3,
			"yOffset", -3,
			"point", "LEFT",
			"groupFilter", "1,2,3,4,5",
			"groupingOrder", "1,2,3,4,5",
			"groupBy", "GROUP",
			"maxColumns", 5,
			"showSolo", false,
			"unitsPerColumn", 5,
			"columnSpacing", 3,
			"columnAnchorPoint", "TOP"		
		)	
		raid:Point("BOTTOMLEFT", ChatLBackground2, "TOPLEFT", 1, 35)	
	end
	
	local function ChangeVisibility(visibility)
		if(visibility) then
			local type, list = string.split(' ', visibility, 2)
			if(list and type == 'custom') then
				RegisterAttributeDriver(ElvuiDPSR6R25, 'state-visibility', list)
			end
		end	
	end
	
	local raidToggle = CreateFrame("Frame")
	raidToggle:RegisterEvent("PLAYER_ENTERING_WORLD")
	raidToggle:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	raidToggle:SetScript("OnEvent", function(self, event)
		local inInstance, instanceType = IsInInstance()
		local _, _, _, _, maxPlayers, _, _ = GetInstanceInfo()
		if event == "PLAYER_REGEN_ENABLED" then self:UnregisterEvent("PLAYER_REGEN_ENABLED") end
		if not InCombatLockdown() then
			if inInstance and instanceType == "raid" and maxPlayers ~= 40 then
				ChangeVisibility("custom [group:party,nogroup:raid][group:raid] show;hide")
			else
				if C["raidframes"].gridonly == true then
					ChangeVisibility("custom [@raid26,exists] show;show")
				else
					ChangeVisibility("custom [@raid6,noexists][@raid26,exists] hide;show")
				end
			end
		else
			self:RegisterEvent("PLAYER_REGEN_ENABLED")
		end
	end)
end)