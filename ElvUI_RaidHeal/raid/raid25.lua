local E, C, L = unpack(ElvUI) -- Import Functions/Constants, Config, Locales

local oUF = ElvUF or oUF
assert(oUF, "ElvUI was unable to locate oUF.")

if not C["raidframes"].enable == true then return end
if IsAddOnLoaded("ElvUI_Dps_Layout") then return end

local RAID_WIDTH = ((ElvuiActionBarBackground:GetWidth() / 5) - 2.5)*C["raidframes"].scale
local RAID_HEIGHT = E.Scale(38)*C["raidframes"].scale

local BORDER = 2

local function Shared(self, unit)
	local POWERBAR_WIDTH = RAID_WIDTH - (BORDER*2)
	local POWERBAR_HEIGHT = 8
		
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
	
	--Health Bar
	local health = E.ContructHealthBar(self, true, true)
	health:Point("TOPRIGHT", self, "TOPRIGHT", -BORDER, -BORDER)
	health:Point("BOTTOMLEFT", self, "BOTTOMLEFT", BORDER, BORDER + POWERBAR_HEIGHT)
	if C["raidframes"].gridhealthvertical == true then
		health:SetOrientation("VERTICAL")
	end		
	health.value:Point("BOTTOM", health, "BOTTOM", 0, 3)
	health.value:SetFont(C["media"].pixel, 9, "THINOUTLINE, MONOCHROME")
	
	self.Health = health
			
	--Power Bar
	local power = E.ConstructPowerBar(self, true, nil)
	power:Point("TOPLEFT", health.backdrop, "BOTTOMLEFT", BORDER, -(BORDER + 1))
	power:Point("BOTTOMRIGHT", self, "BOTTOMRIGHT", -BORDER, BORDER)

	self.Power = power

	--Name
	self:FontString("Name", C["media"].pixel, 9, "THINOUTLINE, MONOCHROME")
	self.Name:Point("CENTER", health, "CENTER", 2, 2)
	self.Name.frequentUpdates = 0.3
	self:Tag(self.Name, "[Elvui:getnamecolor][Elvui:nameshort]")

	if C["raidframes"].role == true then
		local LFDRole = self:CreateTexture(nil, "OVERLAY")
		LFDRole:Size(6, 6)
		LFDRole:Point("TOP", self.Name, "BOTTOM", 0, -1)
		LFDRole:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\lfdicons.blp")
		self.LFDRole = LFDRole
	end
	
	table.insert(self.__elements, E.UpdateThreat)
	self:RegisterEvent('PLAYER_TARGET_CHANGED', E.UpdateThreat)
	self:RegisterEvent('UNIT_THREAT_LIST_UPDATE', E.UpdateThreat)
	self:RegisterEvent('UNIT_THREAT_SITUATION_UPDATE', E.UpdateThreat)


	local RaidIcon = self:CreateTexture(nil, 'OVERLAY')
	RaidIcon:Size(15*C["raidframes"].scale, 15*C["raidframes"].scale)
	RaidIcon:SetPoint('CENTER', self, 'TOP')
	RaidIcon:SetTexture('Interface\\AddOns\\ElvUI\\media\\textures\\raidicons.blp')
	self.RaidIcon = RaidIcon
	
	local ReadyCheck = self.Health:CreateTexture(nil, "OVERLAY")
	ReadyCheck:SetHeight(C["raidframes"].fontsize)
	ReadyCheck:SetWidth(C["raidframes"].fontsize)
	ReadyCheck:Point('TOP', self.Name, 'BOTTOM', 0, -2)
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

	--Heal Comm
	if C["raidframes"].healcomm == true then
		local mhpb = CreateFrame('StatusBar', nil, health)
		if C["raidframes"].gridhealthvertical == true then
			mhpb:SetOrientation("VERTICAL")
			mhpb:SetPoint('BOTTOM', health:GetStatusBarTexture(), 'TOP', 0, 0)
			mhpb:SetHeight(RAID_HEIGHT)
		else
			mhpb:SetPoint('BOTTOMLEFT', health:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
			mhpb:SetPoint('TOPLEFT', health:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)		
		end
		mhpb:SetWidth(RAID_WIDTH - (BORDER*2))
		mhpb:SetStatusBarTexture(C["media"].blank)
		mhpb:SetStatusBarColor(0, 1, 0.5, 0.25)

		local ohpb = CreateFrame('StatusBar', nil, health)
		if C["raidframes"].gridhealthvertical == true then		
			ohpb:SetOrientation("VERTICAL")
			ohpb:SetPoint('BOTTOM', mhpb:GetStatusBarTexture(), 'TOP', 0, 0)
			ohpb:SetHeight(RAID_HEIGHT)
		else
			ohpb:SetPoint('BOTTOMLEFT', mhpb:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
			ohpb:SetPoint('TOPLEFT', mhpb:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)		
		end
		ohpb:SetWidth(RAID_WIDTH)
		ohpb:SetStatusBarTexture(C["media"].blank)
		ohpb:SetStatusBarColor(0, 1, 0, 0.25)

		self.HealPrediction = {
			myBar = mhpb,
			otherBar = ohpb,
			maxOverflow = 1,
		}
	end
	
	-- Raid Debuffs
	local RaidDebuffs = CreateFrame('Frame', nil, self)
	RaidDebuffs:Height(RAID_HEIGHT*0.6)
	RaidDebuffs:Width(RAID_HEIGHT*0.6)
	RaidDebuffs:Point('BOTTOM', self, 'BOTTOM', 0, 1)
	
	RaidDebuffs:SetTemplate("Default")
	
	RaidDebuffs.icon = RaidDebuffs:CreateTexture(nil, 'OVERLAY')
	RaidDebuffs.icon:SetTexCoord(.1,.9,.1,.9)
	RaidDebuffs.icon:Point("TOPLEFT", 2, -2)
	RaidDebuffs.icon:Point("BOTTOMRIGHT", -2, 2)
	
	RaidDebuffs.count = RaidDebuffs:FontString('count', C["media"].pixel, 9, "THINOUTLINE, MONOCHROME")
	RaidDebuffs.count:Point('BOTTOMRIGHT', RaidDebuffs, 'BOTTOMRIGHT', 0, 2)
	RaidDebuffs.count:SetTextColor(1, .9, 0)
	
	RaidDebuffs:FontString('time', C["media"].pixel, 9, "THINOUTLINE, MONOCHROME")
	RaidDebuffs.time:SetPoint('CENTER')
	RaidDebuffs.time:SetTextColor(1, .9, 0)
	
	self.RaidDebuffs = RaidDebuffs	
				
	if C["raidframes"].showrange == true then
		local range = {insideAlpha = 1, outsideAlpha = C["raidframes"].raidalphaoor}
		self.Range = range
	end
	
	if C["auras"].raidunitbuffwatch == true then
		E.createAuraWatch(self,unit)
    end
	
	return self
end


oUF:RegisterStyle('ElvuiHealR6R25', Shared)
oUF:Factory(function(self)
	oUF:SetActiveStyle("ElvuiHealR6R25")	
	local raid = self:SpawnHeader("ElvuiHealR6R25", nil, "custom [@raid6,noexists][@raid26,exists] hide;show",
		'oUF-initialConfigFunction', [[
			local header = self:GetParent()
			self:SetWidth(header:GetAttribute('initial-width'))
			self:SetHeight(header:GetAttribute('initial-height'))
		]],
		'initial-width', RAID_WIDTH,
		'initial-height', RAID_HEIGHT,	
		"showRaid", true, 
		"showParty", true,
		"showPlayer", C["raidframes"].showplayerinparty,
		"xoffset", 3,
		"yOffset", -3,
		"point", "LEFT",
		"groupFilter", "1,2,3,4,5",
		"groupingOrder", "1,2,3,4,5",
		"groupBy", "GROUP",
		"maxColumns", 5,
		"unitsPerColumn", 5,
		"columnSpacing", 3,
		"columnAnchorPoint", "TOP"		
	)
	raid:Point("BOTTOM", ElvuiActionBarBackground, "TOP", 0, 6)	
	
	local function ChangeVisibility(visibility)
		if(visibility) then
			local type, list = string.split(' ', visibility, 2)
			if(list and type == 'custom') then
				RegisterAttributeDriver(ElvuiHealR6R25, 'state-visibility', list)
			end
		end	
	end
	
	local raidToggle = CreateFrame("Frame")
	raidToggle:RegisterEvent("PLAYER_ENTERING_WORLD")
	raidToggle:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	raidToggle:SetScript("OnEvent", function(self)
		local inInstance, instanceType = IsInInstance()
		local _, _, _, _, maxPlayers, _, _ = GetInstanceInfo()
		if event == "PLAYER_REGEN_ENABLED" then self:UnregisterEvent("PLAYER_REGEN_ENABLED") end
		if not InCombatLockdown() then
			if inInstance and instanceType == "raid" and maxPlayers ~= 40 then
				ChangeVisibility("custom [group:party,nogroup:raid][group:raid] show;hide")
			else
				if C["raidframes"].gridonly == true then
					ChangeVisibility("custom [@raid26,exists] hide;show")
				else
					ChangeVisibility("custom [@raid6,noexists][@raid26,exists] hide;show")
				end
			end
		else
			self:RegisterEvent("PLAYER_REGEN_ENABLED")
		end
	end)
end)