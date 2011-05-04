local E, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

local BORDER = 2

-- BUTTON SIZES
E.buttonsize = E.Scale(C["actionbar"].buttonsize)
E.buttonspacing = E.Scale(C["actionbar"].buttonspacing)
E.petbuttonsize = E.Scale(C["actionbar"].petbuttonsize)
E.buttonspacing = E.Scale(C["actionbar"].buttonspacing)
E.minimapsize = E.Scale(168)

--BOTTOM DUMMY FRAME DOES NOTHING BUT HOLDS FRAME POSITIONS
local bottompanel = CreateFrame("Frame", "ElvuiBottomPanel", UIParent)
bottompanel:SetHeight(23)
bottompanel:SetWidth(UIParent:GetWidth() + (E.mult * 2))
bottompanel:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", -E.mult, -E.mult)
bottompanel:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", E.mult, -E.mult)

local mini = CreateFrame("Frame", "ElvuiMinimap", Minimap)
mini:CreatePanel("Default", E.minimapsize, E.minimapsize, "CENTER", Minimap, "CENTER", 0, 0)
mini:ClearAllPoints()
mini:SetPoint("TOPLEFT", E.Scale(-2), E.Scale(2))
mini:SetPoint("BOTTOMRIGHT", E.Scale(2), E.Scale(-2))
ElvuiMinimap:CreateShadow("Default")
TukuiMinimap = ElvuiMinimap -- conversion

-- MINIMAP STAT FRAMES
if ElvuiMinimap then
	local minimapstatsleft = CreateFrame("Frame", "ElvuiMinimapStatsLeft", ElvuiMinimap)
	minimapstatsleft:CreatePanel("Default", (E.minimapsize / 2)-1, 20, "TOPLEFT", ElvuiMinimap, "BOTTOMLEFT", 0, E.Scale(-3))
	ElvuiMinimapStatsLeft:SetFrameLevel(ElvuiMinimap:GetFrameLevel())
	ElvuiMinimapStatsLeft:SetTemplate("Transparent", true)
	ElvuiMinimapStatsLeft:CreateShadow("Default")

	local minimapstatsright = CreateFrame("Frame", "ElvuiMinimapStatsRight", ElvuiMinimap)
	minimapstatsright:CreatePanel("Default", (E.minimapsize / 2)-1, 20, "TOPRIGHT", ElvuiMinimap, "BOTTOMRIGHT", 0, E.Scale(-3))
	ElvuiMinimapStatsRight:SetFrameLevel(ElvuiMinimap:GetFrameLevel())
	ElvuiMinimapStatsRight:SetTemplate("Transparent", true)
	ElvuiMinimapStatsRight:CreateShadow("Default")
	
	TukuiMinimapStatsLeft = ElvuiMinimapStatsLeft -- conversion
	TukuiMinimapStatsRight = ElvuiMinimapStatsRight -- conversion
end

-- MAIN ACTION BAR
local barbg = CreateFrame("Frame", "ElvuiActionBarBackground", UIParent)
if C["actionbar"].bottompetbar ~= true then
	barbg:CreatePanel("Default", 1, 1, "BOTTOM", UIParent, "BOTTOM", 0, E.Scale(4))
else
	barbg:CreatePanel("Default", 1, 1, "BOTTOM", UIParent, "BOTTOM", 0, (E.buttonsize + (E.buttonspacing * 2)) + E.Scale(8))
end
barbg:SetWidth(((E.buttonsize * 12) + (E.buttonspacing * 13)))
barbg:SetFrameStrata("BACKGROUND")
barbg:SetFrameLevel(8)
barbg:SetHeight(E.buttonsize + (E.buttonspacing * 2))
barbg:SetTemplate("Transparent", true)
barbg:CreateShadow("Default")
barbg:SetAlpha(1)

if C["actionbar"].enable ~= true then
	barbg:SetAlpha(0)
end

--SPLIT BAR PANELS
local splitleft = CreateFrame("Frame", "ElvuiSplitActionBarLeftBackground", ElvuiActionBarBackground)
splitleft:CreatePanel("Default", (E.buttonsize * 4) + (E.buttonspacing * 5), ElvuiActionBarBackground:GetHeight(), "RIGHT", ElvuiActionBarBackground, "LEFT", E.Scale(-4), 0)
splitleft:SetFrameLevel(ElvuiActionBarBackground:GetFrameLevel())
splitleft:SetFrameStrata(ElvuiActionBarBackground:GetFrameStrata())
splitleft:CreateShadow("Default")
splitleft:SetTemplate("Transparent", true)

splitright = CreateFrame("Frame", "ElvuiSplitActionBarRightBackground", ElvuiActionBarBackground)
splitright:CreatePanel("Default", (E.buttonsize * 4) + (E.buttonspacing * 5), ElvuiActionBarBackground:GetHeight(), "LEFT", ElvuiActionBarBackground, "RIGHT", E.Scale(4), 0)
splitright:SetFrameLevel(ElvuiActionBarBackground:GetFrameLevel())
splitright:SetFrameStrata(ElvuiActionBarBackground:GetFrameStrata())
splitright:CreateShadow("Default")
splitright:SetTemplate("Transparent", true)

local splitleft2 = CreateFrame("Frame", "ElvuiSplitActionBarLeftBackground2", ElvuiActionBarBackground)
splitleft2:CreatePanel("Default", (E.buttonsize * 2) + (E.buttonspacing * 3), ElvuiActionBarBackground:GetHeight(), "RIGHT", ElvuiSplitActionBarLeftBackground, "LEFT", E.Scale(-4), 0)
splitleft2:SetFrameLevel(ElvuiActionBarBackground:GetFrameLevel())
splitleft2:SetFrameStrata(ElvuiActionBarBackground:GetFrameStrata())
splitleft2:CreateShadow("Default")
splitleft2:SetTemplate("Transparent", true)

local splitright2 = CreateFrame("Frame", "ElvuiSplitActionBarRightBackground2", ElvuiActionBarBackground)
splitright2:CreatePanel("Default", (E.buttonsize * 2) + (E.buttonspacing * 3), ElvuiActionBarBackground:GetHeight(), "LEFT", ElvuiSplitActionBarRightBackground, "RIGHT", E.Scale(4), 0)
splitright2:SetFrameLevel(ElvuiActionBarBackground:GetFrameLevel())
splitright2:SetFrameStrata(ElvuiActionBarBackground:GetFrameStrata())
splitright2:CreateShadow("Default")
splitright2:SetTemplate("Transparent", true)


-- RIGHT BAR
if C["actionbar"].enable == true then
	local barbgr = CreateFrame("Frame", "ElvuiActionBarBackgroundRight", ElvuiActionBarBackground)
	barbgr:CreatePanel("Default", 1, (E.buttonsize * 12) + (E.buttonspacing * 13), "RIGHT", UIParent, "RIGHT", E.Scale(-4), E.Scale(-8))
	barbgr:SetTemplate("Transparent", true)
	barbgr:CreateShadow("Default")
	barbgr:Hide()

	local petbg = CreateFrame("Frame", "ElvuiPetActionBarBackground", UIParent)
	petbg:SetTemplate("Transparent")
	petbg:CreateShadow("Default")
	
	if C["actionbar"].bottompetbar ~= true then
		petbg:CreatePanel("Transparent", E.petbuttonsize + (E.buttonspacing * 2), (E.petbuttonsize * 10) + (E.buttonspacing * 11), "RIGHT", UIParent, "RIGHT", E.Scale(-6), E.Scale(-13.5))
	else
		petbg:CreatePanel("Transparent", (E.petbuttonsize * 10) + (E.buttonspacing * 11), E.petbuttonsize + (E.buttonspacing * 2), "BOTTOM", UIParent, "BOTTOM", 0, E.Scale(8))
	end
	
	local ltpetbg = CreateFrame("Frame", "ElvuiLineToPetActionBarBackground", petbg)
	if C["actionbar"].bottompetbar ~= true then
		ltpetbg:CreatePanel("Transparent", 30, 265, "LEFT", petbg, "RIGHT", 0, 0)
	else
		ltpetbg:CreatePanel("Transparent", 265, 30, "BOTTOM", petbg, "TOP", 0, 220)
	end
	
	ltpetbg:SetScript("OnShow", function(self)
		self:SetFrameStrata("BACKGROUND")
		self:SetFrameLevel(0)
	end)
	
end

-- VEHICLE BAR
if C["actionbar"].enable == true then
	local vbarbg = CreateFrame("Frame", "ElvuiVehicleBarBackground", UIParent)
	vbarbg:CreatePanel("Default", 1, 1, "BOTTOM", UIParent, "BOTTOM", 0, E.Scale(4))
	vbarbg:SetWidth((E.buttonsize * 12) + (E.buttonspacing * 13))
	vbarbg:SetHeight(E.buttonsize + (E.buttonspacing * 2))
	vbarbg:CreateShadow("Default")
end

-- CHAT BACKGROUND LEFT (MOVES)
local chatlbgdummy = CreateFrame("Frame", "ChatLBackground", UIParent)
chatlbgdummy:SetWidth(C["chat"].chatwidth-2)
chatlbgdummy:SetHeight(C["chat"].chatheight+6)
chatlbgdummy:SetPoint("BOTTOMLEFT", ElvuiBottomPanel, "TOPLEFT", E.Scale(4),  E.Scale(4))

-- CHAT BACKGROUND LEFT (DOESN'T MOVE THIS IS WHAT WE ATTACH FRAMES TO)
local chatlbgdummy2 = CreateFrame("Frame", "ChatLBackground2", UIParent)
chatlbgdummy2:SetWidth(C["chat"].chatwidth)
chatlbgdummy2:SetHeight(C["chat"].chatheight+6)
chatlbgdummy2:SetPoint("BOTTOMLEFT", ElvuiBottomPanel, "TOPLEFT", E.Scale(2),  E.Scale(3))

-- CHAT BACKGROUND RIGHT (MOVES)
local chatrbgdummy = CreateFrame("Frame", "ChatRBackground", UIParent)
chatrbgdummy:SetWidth(C["chat"].chatwidth-2)
chatrbgdummy:SetHeight(C["chat"].chatheight+6)
chatrbgdummy:SetPoint("BOTTOMRIGHT", ElvuiBottomPanel, "TOPRIGHT", E.Scale(-4),  E.Scale(4))

-- CHAT BACKGROUND RIGHT (DOESN'T MOVE THIS IS WHAT WE ATTACH FRAMES TO)
local chatrbgdummy2 = CreateFrame("Frame", "ChatRBackground2", UIParent)
chatrbgdummy2:SetWidth(C["chat"].chatwidth)
chatrbgdummy2:SetHeight(C["chat"].chatheight+6)
chatrbgdummy2:SetPoint("BOTTOMRIGHT", ElvuiBottomPanel, "TOPRIGHT", E.Scale(-2),  E.Scale(3))

E.AnimGroup(ChatLBackground, E.Scale(-375), 0, 0.4)
E.AnimGroup(ChatRBackground, E.Scale(375), 0, 0.4)

E.ChatRightShown = true
if C["chat"].showbackdrop == true then
	local chatlbg = CreateFrame("Frame", "ChatLBG", ChatLBackground)
	chatlbg:SetTemplate("Transparent")
	chatlbg:SetAllPoints(chatlbgdummy)
	chatlbg:SetFrameStrata("BACKGROUND")
	
	local chatltbg = CreateFrame("Frame", nil, chatlbg)
	chatltbg:SetTemplate("Default", true)
	chatltbg:SetPoint("BOTTOMLEFT", chatlbg, "TOPLEFT", 0, E.Scale(3))
	chatltbg:SetPoint("BOTTOMRIGHT", chatlbg, "TOPRIGHT", E.Scale(-24), E.Scale(3))
	chatltbg:SetHeight(E.Scale(22))
	chatltbg:SetFrameStrata("BACKGROUND")
	
	chatlbg:CreateShadow("Default")
	chatltbg:CreateShadow("Default")
end

if C["chat"].showbackdrop == true then
	local chatrbg = CreateFrame("Frame", "ChatRBG", ChatRBackground)
	chatrbg:SetAllPoints(chatrbgdummy)
	chatrbg:SetTemplate("Transparent")
	chatrbg:SetFrameStrata("BACKGROUND")
	chatrbg:SetAlpha(0)

	local chatrtbg = CreateFrame("Frame", nil, chatrbg)
	chatrtbg:SetTemplate("Default", true)
	chatrtbg:SetPoint("BOTTOMLEFT", chatrbg, "TOPLEFT", 0, E.Scale(3))
	chatrtbg:SetPoint("BOTTOMRIGHT", chatrbg, "TOPRIGHT", E.Scale(-24), E.Scale(3))
	chatrtbg:SetHeight(E.Scale(22))
	chatrtbg:SetFrameStrata("BACKGROUND")
	chatrbg:CreateShadow("Default")
	chatrtbg:CreateShadow("Default")
end

--INFO LEFT
local infoleft = CreateFrame("Frame", "ElvuiInfoLeft", UIParent)
infoleft:SetFrameLevel(2)
infoleft:SetTemplate("Transparent", true)
infoleft:CreateShadow("Default")
infoleft:SetPoint("TOPLEFT", chatlbgdummy2, "BOTTOMLEFT", E.Scale(17), E.Scale(-4))
infoleft:SetPoint("BOTTOMRIGHT", chatlbgdummy2, "BOTTOMRIGHT", E.Scale(-17), E.Scale(-26))

	--INFOLEFT L BUTTON
	local infoleftLbutton = CreateFrame("Button", "ElvuiInfoLeftLButton", ElvuiInfoLeft)
	infoleftLbutton:SetTemplate("Transparent", true)
	infoleftLbutton:SetFrameStrata("BACKGROUND")
	infoleftLbutton:CreateShadow("Default")
	infoleftLbutton:SetPoint("TOPRIGHT", infoleft, "TOPLEFT", E.Scale(-2), 0)
	infoleftLbutton:SetPoint("BOTTOMLEFT", chatlbgdummy2, "BOTTOMLEFT", 0, E.Scale(-26))

	--INFOLEFT R BUTTON
	local infoleftRbutton = CreateFrame("Button", "ElvuiInfoLeftRButton", ElvuiInfoLeft)
	infoleftRbutton:SetTemplate("Transparent", true)
	infoleftRbutton:SetFrameStrata("BACKGROUND")
	infoleftRbutton:CreateShadow("Default")
	infoleftRbutton:SetPoint("TOPLEFT", infoleft, "TOPRIGHT", E.Scale(2), -1)
	infoleftRbutton:SetPoint("BOTTOMRIGHT", chatlbgdummy2, "BOTTOMRIGHT", -2, E.Scale(-26))
	
	--INFOLEFT R2 BUTTON
	local infoleftR2button = CreateFrame("Button", "ElvuiInfoLeftR2Button", ElvuiInfoLeft)
	infoleftR2button:SetTemplate("Transparent", true)
	infoleftR2button:SetFrameStrata("BACKGROUND")
	infoleftR2button:CreateShadow("Default")
	infoleftR2button:SetPoint("TOPLEFT", infoleft, "TOPRIGHT", E.Scale(4) + infoleftRbutton:GetWidth(), -1)
	infoleftR2button:SetPoint("BOTTOMRIGHT", chatlbgdummy2, "BOTTOMRIGHT", infoleftRbutton:GetWidth(), E.Scale(-26))

	--infoleft.shadow:ClearAllPoints()
	--infoleft.shadow:SetPoint("TOPLEFT", infoleftLbutton, "TOPLEFT", E.Scale(-4), E.Scale(4))
	--infoleft.shadow:SetPoint("BOTTOMRIGHT", infoleftRbutton, "BOTTOMRIGHT", E.Scale(4), E.Scale(-4))

	infoleftLbutton:FontString(nil, C["media"].font, C["general"].fontscale, "THINOUTLINE")
	--infoleftLbutton.text:SetText("<")
	--infoleftLbutton.text:SetPoint("CENTER")

	infoleftRbutton:FontString(nil, C["media"].font, C["general"].fontscale, "THINOUTLINE, MONOCHROME")
	--infoleftRbutton.text:SetText("|")
	--infoleftRbutton.text:SetPoint("CENTER", infoleftRbutton, "CENTER", 2, 0)

--INFO RIGHT
local inforight = CreateFrame("Frame", "ElvuiInfoRight", UIParent)
inforight:SetTemplate("Transparent", true)
inforight:SetFrameLevel(2)
inforight:CreateShadow("Default")
inforight:SetPoint("TOPLEFT", chatrbgdummy2, "BOTTOMLEFT", E.Scale(17), E.Scale(-4))
inforight:SetPoint("BOTTOMRIGHT", chatrbgdummy2, "BOTTOMRIGHT", E.Scale(-17), E.Scale(-26))

	--INFORIGHT L BUTTON
	local inforightLbutton = CreateFrame("Button", "ElvuiInfoRightLButton", ElvuiInfoRight)
	inforightLbutton:SetTemplate("Transparent", true)
	inforightLbutton:SetFrameStrata("BACKGROUND")
	inforightLbutton:CreateShadow("Default")
	inforightLbutton:SetPoint("TOPRIGHT", inforight, "TOPLEFT", E.Scale(-2), -1)
	inforightLbutton:SetPoint("BOTTOMLEFT", chatrbgdummy2, "BOTTOMLEFT", 2, E.Scale(-26))
	
	--INFORIGHT L2 BUTTON
	local inforightL2button = CreateFrame("Button", "ElvuiInfoRightL2Button", ElvuiInfoRight)
	inforightL2button:SetTemplate("Transparent", true)
	inforightL2button:SetFrameStrata("BACKGROUND")
	inforightL2button:CreateShadow("Default")
	inforightL2button:SetPoint("TOPRIGHT", inforight, "TOPLEFT", E.Scale(-4) - inforightLbutton:GetWidth(), -1)
	inforightL2button:SetPoint("BOTTOMLEFT", chatrbgdummy2, "BOTTOMLEFT", - inforightLbutton:GetWidth(), E.Scale(-26))

	--INFORIGHT R BUTTON
	local inforightRbutton = CreateFrame("Button", "ElvuiInfoRightRButton", ElvuiInfoRight)
	inforightRbutton:SetTemplate("Transparent", true)
	inforightRbutton:CreateShadow("Default")
	inforightRbutton:SetPoint("TOPLEFT", inforight, "TOPRIGHT", E.Scale(2), 0)
	inforightRbutton:SetPoint("BOTTOMRIGHT", chatrbgdummy2, "BOTTOMRIGHT", 0, E.Scale(-26))
	
	--inforight.shadow:ClearAllPoints()
	--inforight.shadow:SetPoint("TOPLEFT", inforightLbutton, "TOPLEFT", E.Scale(-4), E.Scale(4))
	--inforight.shadow:SetPoint("BOTTOMRIGHT", inforightRbutton, "BOTTOMRIGHT", E.Scale(4), E.Scale(-4))

	inforightLbutton:FontString(nil, C["media"].font, C["general"].fontscale, "THINOUTLINE")
	--inforightLbutton.text:SetText("R")
	--inforightLbutton.text:SetPoint("CENTER")

	inforightRbutton:FontString(nil, C["media"].font, C["general"].fontscale, "THINOUTLINE")
	--inforightRbutton.text:SetText(">")
	--inforightRbutton.text:SetPoint("CENTER")


-- Beautiful bottom bar, bitches. 
local BBB = CreateFrame("Frame", "bottombarbitches", UIParent)
BBB:SetTemplate("Transparent", true)
BBB:CreateShadow("Default")
BBB:SetFrameStrata("BACKGROUND")
BBB:SetFrameLevel(10)
BBB:Point("TOPLEFT", infoleft, "TOPRIGHT", E.Scale(infoleftRbutton:GetWidth()*2+BORDER*3), 0)
BBB:Point("BOTTOMRIGHT", inforight, "BOTTOMLEFT", -E.Scale(inforightLbutton:GetWidth()*2+BORDER*3), 0)

---[[style1
local LocBar = CreateFrame("Frame", "LocationBar", UIParent)
LocBar:SetTemplate("Transparent", true)
LocBar:CreateShadow("Default")
LocBar:SetFrameStrata("BACKGROUND")
LocBar:SetFrameLevel(10)
LocBar:Point("TOP", UIParent, "TOP", 0, -3)
LocBar:SetSize(210, 20)
LocBar:SetAlpha(1)

	local CRD1 = CreateFrame("Frame", "Coord1", UIParent)
	CRD1:SetTemplate("Transparent", true)
	CRD1:CreateShadow("Default")
	CRD1:SetParent(LocBar)
	CRD1:SetFrameStrata("BACKGROUND")
	CRD1:SetFrameLevel(10)
	CRD1:Point("RIGHT", LocationBar, "LEFT", -BORDER, 0)
	CRD1:SetSize(30, 20)

	local CRD2 = CreateFrame("Frame", "Coord2", UIParent)
	CRD2:SetTemplate("Transparent", true)
	CRD2:CreateShadow("Default")
	CRD2:SetParent(LocBar)
	CRD2:SetFrameStrata("BACKGROUND")
	CRD2:SetFrameLevel(10)
	CRD2:Point("LEFT", LocationBar, "RIGHT", BORDER, 0)
	CRD2:SetSize(30, 20)
--]]

--[[style2
local LocBar = CreateFrame("Frame", "LocationBar", ElvuiActionBarBackground)
LocBar:SetTemplate("Transparent", true)
LocBar:CreateShadow("Default")
LocBar:SetFrameStrata("BACKGROUND")
LocBar:SetFrameLevel(10)
LocBar:Point("BOTTOMRIGHT", ElvuiActionBarBackground, "TOPRIGHT", -34, 4)
LocBar:Point("BOTTOMLEFT", ElvuiActionBarBackground, "TOPLEFT", 34, 4)
LocBar:SetSize(210, 16)
LocBar:SetAlpha(1)

	local CRD1 = CreateFrame("Frame", "Coord1", UIParent)
	CRD1:SetTemplate("Transparent", true)
	--CRD1:CreateShadow("Default")
	CRD1:SetParent(LocBar)
	CRD1:SetFrameStrata("BACKGROUND")
	CRD1:SetFrameLevel(10)
	CRD1:Point("RIGHT", LocationBar, "LEFT", -BORDER*2, 0)
	CRD1:SetSize(30, 16)

	local CRD2 = CreateFrame("Frame", "Coord2", UIParent)
	CRD2:SetTemplate("Transparent", true)
	--CRD2:CreateShadow("Default")
	CRD2:SetParent(LocBar)
	CRD2:SetFrameStrata("BACKGROUND")
	CRD2:SetFrameLevel(10)
	--CRD2:SetAlpha(0)
	CRD2:Point("LEFT", LocationBar, "RIGHT", BORDER*2, 0)
	CRD2:SetSize(30, 16)
--]]
--[[	
	LocBar:RegisterEvent("PLAYER_REGEN_ENABLED")
	LocBar:RegisterEvent("PLAYER_REGEN_DISABLED")
	LocBar:SetScript("OnEvent", function(self, event)
		if event == "PLAYER_REGEN_DISABLED" then
			LocBar:SetAlpha(0)
		elseif event == "PLAYER_REGEN_ENABLED" then
			LocBar:SetAlpha(1)
		end
	end)


local CCC = CreateFrame("Frame", "coolbean", UIParent)
CCC:CreatePanel("Default", 200, 50, "CENTER", UIParent, "CENTER", 0, 50)
local CCC2 = CreateFrame("Frame", "coolbean2", UIParent)
CCC2:CreatePanel("Default", 80, 12, "CENTER", coolbean, "BOTTOM", 0, 0)
CCC2:SetFrameLevel(CCC:GetFrameLevel()+1)
--]]
TukuiInfoLeft = ElvuiInfoLeft -- conversion
TukuiInfoRight = ElvuiInfoRight -- conversion	